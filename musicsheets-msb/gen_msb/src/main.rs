//! Generate a MobileSheets backup (.msb) from a folder of PDFs.
//!
//! Usage:
//!   gen_msb --template MobileSheets_2026-11-03.msb --pdf-dir songbook/pdf \
//!           --out MobileSheets_generated.msb [--file-hash -1] [--prefix P] \
//!           [--setlist NAME=a.pdf,b.pdf ...]
//!
//! The template is a real .msb exported by the app. Its preference blocks and
//! database schema are reused; all song data is replaced by the PDFs found.
//!
//! .msb layout (big-endian):
//!   [0x499602D7][u32 n] n x ([u16 len][name][u64 size][xml])   preference blocks
//!   ... misc blocks (u64 length + data) ...
//!   [u64 db_len][SQLite file]
//!   per file: [0x11DEDA2C5161659C][u64 Files.Id][u64 size][bytes]
//!   [0xFF * 8]                                                   terminator

use rusqlite::{params, Connection};
use std::collections::HashMap;
use std::fs;
use std::io::Write;
use std::path::Path;
use std::process::{self, Command};
use std::time::{SystemTime, UNIX_EPOCH};

const MAGIC_FILE: u64 = 0x11DE_DA2C_5161_659C;
const SQLITE_HDR: &[u8] = b"SQLite format 3\0";
const KEEP_TABLES: &[&str] = &[
    "android_metadata",
    "Defaults",
    "SourceType",
    "Genres",
    "Key",
    "MidiAction",
    "BatchMidiAction",
    "MidiActionSysex",
];

fn die(msg: impl AsRef<str>) -> ! {
    eprintln!("{}", msg.as_ref());
    process::exit(1);
}

fn find(hay: &[u8], needle: &[u8]) -> Option<usize> {
    hay.windows(needle.len()).position(|w| w == needle)
}

/// Return (prefix_before_db_len, db_bytes).
fn split_template(data: &[u8]) -> (&[u8], &[u8]) {
    let i = match find(data, SQLITE_HDR) {
        Some(i) if i >= 8 => i,
        _ => die("template: no SQLite database found"),
    };
    let mut page_size = u16::from_be_bytes(data[i + 16..i + 18].try_into().unwrap()) as u64;
    if page_size == 1 {
        page_size = 65536;
    }
    let pages = u32::from_be_bytes(data[i + 28..i + 32].try_into().unwrap()) as u64;
    let db_len = u64::from_be_bytes(data[i - 8..i].try_into().unwrap());
    if db_len != page_size * pages {
        die(format!(
            "template: DB length field ({}) != pages*page_size ({})",
            db_len,
            page_size * pages
        ));
    }
    (&data[..i - 8], &data[i..i + db_len as usize])
}

fn run(cmd: &str, args: &[&str]) -> Option<String> {
    Command::new(cmd)
        .args(args)
        .output()
        .ok()
        .map(|o| String::from_utf8_lossy(&o.stdout).into_owned())
}

fn first_number(text: &str, prefix: &str) -> Option<u32> {
    text.lines().find_map(|l| {
        let l = l.trim();
        let rest = if prefix.is_empty() { l } else { l.strip_prefix(prefix)? };
        let rest = rest.trim();
        if !rest.is_empty() && rest.bytes().all(|b| b.is_ascii_digit()) {
            rest.parse().ok()
        } else {
            None
        }
    })
}

fn pdf_pages(path: &str) -> u32 {
    if let Some(n) = run("pdfinfo", &[path]).and_then(|o| first_number(&o, "Pages:")) {
        return n;
    }
    // Fallback for malformed PDFs (mupdf repairs them better than poppler).
    if let Some(n) =
        run("mutool", &["show", path, "trailer/Root/Pages/Count"]).and_then(|o| first_number(&o, ""))
    {
        eprintln!("warning: pdfinfo failed on {}, mutool says {} pages", path, n);
        return n;
    }
    die(format!(
        "cannot determine page count of {} (need pdfinfo or mutool)",
        path
    ));
}

/// Duration of an audio file in milliseconds (truncated), via ffprobe.
fn mp3_duration_ms(path: &str) -> i64 {
    let out = run(
        "ffprobe",
        &["-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", path],
    );
    match out.and_then(|o| o.trim().parse::<f64>().ok()) {
        Some(sec) => (sec * 1000.0) as i64,
        None => {
            eprintln!("warning: cannot get duration of {} (need ffprobe), using 0", path);
            0
        }
    }
}

fn title_from_name(fname: &str) -> String {
    // alannah_myles--@--black_velvet.pdf -> "alannah myles--@--black velvet"
    let stem = Path::new(fname)
        .file_stem()
        .map(|s| s.to_string_lossy().into_owned())
        .unwrap_or_default();
    stem.replace('_', " ")
}

fn clear_db(con: &Connection) -> rusqlite::Result<()> {
    let tables: Vec<String> = con
        .prepare("select name from sqlite_master where type='table' and name not like 'sqlite_%'")?
        .query_map([], |r| r.get(0))?
        .collect::<Result<_, _>>()?;
    for t in &tables {
        if KEEP_TABLES.contains(&t.as_str()) {
            continue;
        }
        con.execute(&format!("delete from \"{}\"", t), [])?;
    }
    // sqlite_sequence is excluded by the name filter above in Python too
    // (its `in tables` test is always false); mirror that behaviour.
    Ok(())
}

struct Args {
    template: String,
    pdf_dir: String,
    out: String,
    file_hash: i64,
    prefix: String,
    setlists: Vec<(String, Vec<String>)>,
    songs_dir: Option<String>,
    raw_dir: Option<String>,
    books_dir: Option<String>,
    snippets_dir: Option<String>,
    install_dir: Option<String>,
    audio_path: String,
}

fn parse_args() -> Args {
    let mut template = None;
    let mut pdf_dir = None;
    let mut out = None;
    let mut file_hash = -1i64;
    let mut prefix = String::new();
    let mut setlists = Vec::new();
    let mut songs_dir = None;
    let mut raw_dir = None;
    let mut books_dir = None;
    let mut snippets_dir = None;
    let mut install_dir = None;
    let mut audio_path = String::from("/storage/emulated/0/Download/songbook/mp3");

    let mut it = std::env::args().skip(1);
    while let Some(a) = it.next() {
        let mut val = |name: &str| it.next().unwrap_or_else(|| die(format!("{} needs a value", name)));
        match a.as_str() {
            "--template" => template = Some(val("--template")),
            "--pdf-dir" => pdf_dir = Some(val("--pdf-dir")),
            "--out" => out = Some(val("--out")),
            "--file-hash" => {
                file_hash = val("--file-hash")
                    .parse()
                    .unwrap_or_else(|_| die("--file-hash must be an integer"))
            }
            "--prefix" => prefix = val("--prefix"),
            "--songs-dir" => songs_dir = Some(val("--songs-dir")),
            "--raw-dir" => raw_dir = Some(val("--raw-dir")),
            "--books-dir" => books_dir = Some(val("--books-dir")),
            "--install-dir" => install_dir = Some(val("--install-dir")),
            "--snippets-dir" => snippets_dir = Some(val("--snippets-dir")),
            "--audio-path" => audio_path = val("--audio-path"),
            "--setlist" => {
                let spec = val("--setlist");
                let (name, files) = spec.split_once('=').unwrap_or(("", ""));
                if name.is_empty() || files.is_empty() {
                    die(format!("bad --setlist {:?}, expected NAME=a.pdf,b.pdf", spec));
                }
                setlists.push((
                    name.to_string(),
                    files.split(',').map(|x| x.trim().to_string()).collect(),
                ));
            }
            "-h" | "--help" => {
                println!(
                    "usage: gen_msb --template T.msb --pdf-dir DIR --out OUT.msb \
                     [--file-hash N] [--prefix P] [--setlist NAME=a.pdf,b.pdf]... \
                     [--songs-dir DIR  (one collection per tag found in DIR/<artist>/<song>/song.yml)] \\
                     [--raw-dir DIR  (where the build delivers the `raw` pdf of the songs without a structure; needs --songs-dir)] \\
                     [--books-dir DIR  (one setlist per DIR/*.yml book, in the book's song order)] \\
                     [--snippets-dir DIR  (where the build renders <stem>-<snippet>.mp3; needs --songs-dir)] \\
                     [--install-dir DIR  (symlink the audio files as DIR/mp3/*, DIR/mp3-renders/* for upload)] \\
                     [--audio-path P  (device folder recorded in AudioFiles.File)]"
                );
                process::exit(0);
            }
            other => die(format!("unknown argument {}", other)),
        }
    }
    let req = |v: Option<String>, n: &str| v.unwrap_or_else(|| die(format!("{} is required", n)));
    Args {
        template: req(template, "--template"),
        pdf_dir: req(pdf_dir, "--pdf-dir"),
        out: req(out, "--out"),
        file_hash,
        prefix,
        setlists,
        songs_dir,
        raw_dir,
        books_dir,
        snippets_dir,
        install_dir,
        audio_path,
    }
}

/// Extract `info.tags` from a song.yml (inline `[a, 'b']` or block `- a` list).
fn parse_tags(text: &str) -> Vec<String> {
    let clean = |t: &str| t.trim().trim_matches(|c| c == '\'' || c == '"').trim().to_string();
    let mut lines = text.lines();
    while let Some(l) = lines.next() {
        let Some(rest) = l.trim_start().strip_prefix("tags:") else { continue };
        let rest = rest.trim();
        if let Some(inner) = rest.strip_prefix('[').and_then(|r| r.strip_suffix(']')) {
            return inner.split(',').map(clean).filter(|t| !t.is_empty()).collect();
        }
        if rest.is_empty() {
            return lines
                .map(|l| l.trim())
                .take_while(|l| l.starts_with('-'))
                .map(|l| clean(&l[1..]))
                .filter(|t| !t.is_empty())
                .collect();
        }
        return Vec::new();
    }
    Vec::new()
}

/// Same normalization as band-songbook's `normalize_name`.
fn normalize_name(s: &str) -> String {
    let mut out = String::new();
    for c in s.to_lowercase().chars() {
        match c {
            'a'..='z' | '0'..='9' => out.push(c),
            'à' | 'á' | 'â' | 'ã' | 'ä' | 'å' => out.push('a'),
            'ç' => out.push('c'),
            'è' | 'é' | 'ê' | 'ë' => out.push('e'),
            'ì' | 'í' | 'î' | 'ï' => out.push('i'),
            'ñ' => out.push('n'),
            'ò' | 'ó' | 'ô' | 'õ' | 'ö' | 'ø' => out.push('o'),
            'ù' | 'ú' | 'û' | 'ü' => out.push('u'),
            'ý' | 'ÿ' => out.push('y'),
            'ð' => out.push('d'),
            'æ' => out.push_str("ae"),
            'œ' => out.push_str("oe"),
            'ß' => out.push_str("ss"),
            'þ' => out.push_str("th"),
            _ => out.push('_'),
        }
    }
    out
}

/// Value of a key at exactly 2-space indent (the `info:` block).
fn info_field(text: &str, key: &str) -> Option<String> {
    let prefix = format!("  {}:", key);
    text.lines().find_map(|l| {
        let v = l.strip_prefix(prefix.as_str())?.trim();
        Some(v.trim_matches(|c| c == '\'' || c == '"').to_string())
    })
}

struct SongMeta {
    dir: std::path::PathBuf,
    tags: Vec<String>,
    has_mp3: bool,
    snippets: Vec<String>,
    /// `raw` of a song.yml: ready-made pdf file name, delivered in the raw dir.
    raw: Option<String>,
    tempo: Option<i64>,
    author: String,
    title: String,
}

/// `files.mp3` of a song.yml: snippet names such as `solo.mp3`.
fn parse_snippets(text: &str) -> Vec<String> {
    let clean = |t: &str| t.trim().trim_matches(|c| c == '\'' || c == '"').trim().to_string();
    let mut lines = text.lines();
    while let Some(l) = lines.next() {
        let Some(rest) = l.strip_prefix("  mp3:") else { continue };
        let rest = rest.trim();
        if let Some(inner) = rest.strip_prefix('[').and_then(|r| r.strip_suffix(']')) {
            return inner.split(',').map(clean).filter(|t| !t.is_empty()).collect();
        }
        return lines
            .map(|l| l.trim())
            .take_while(|l| l.starts_with('-'))
            .map(|l| clean(&l[1..]))
            .filter(|t| !t.is_empty())
            .collect();
    }
    Vec::new()
}

/// `raw` of a song.yml: the file name of a ready-made pdf, if any.
fn parse_raw(text: &str) -> Option<String> {
    let v = text.lines().find_map(|l| l.strip_prefix("raw:"))?;
    let v = v.trim().trim_matches(|c| c == '\'' || c == '"').trim();
    (!v.is_empty()).then(|| v.to_string())
}

/// PDF filename -> metadata, from DIR/<artist>/<song>/song.yml.
/// The PDF is named `<author>--@--<title>.pdf` (info.author / info.title, normalized).
fn load_songs(dir: &str) -> HashMap<String, SongMeta> {
    let mut map = HashMap::new();
    let rd = |p: &Path| fs::read_dir(p).map(|r| r.filter_map(|e| e.ok()).collect::<Vec<_>>()).unwrap_or_default();
    for artist in rd(Path::new(dir)) {
        for song in rd(&artist.path()) {
            let Ok(text) = fs::read_to_string(song.path().join("song.yml")) else { continue };
            let (Some(author), Some(title)) = (info_field(&text, "author"), info_field(&text, "title")) else {
                eprintln!("warning: {}: no info.author/title", song.path().display());
                continue;
            };
            let pdf = format!("{}--@--{}.pdf", normalize_name(&author), normalize_name(&title));
            map.insert(
                pdf,
                SongMeta {
                    dir: song.path(),
                    tags: parse_tags(&text),
                    has_mp3: text.lines().any(|l| l.trim() == "has_mp3: true"),
                    snippets: parse_snippets(&text),
                    raw: parse_raw(&text),
                    author: author.clone(),
                    title: title.clone(),
                    tempo: info_field(&text, "tempo").and_then(|t| t.parse().ok()).filter(|&t| t > 0),
                },
            );
        }
    }
    map
}

/// Collection holding every song that has a `raw` pdf.
const RAW_COLLECTION: &str = "brut";

/// tag -> PDF filenames. The raw songs also go in the `brut` collection.
fn collect_tags(songs: &HashMap<String, SongMeta>) -> std::collections::BTreeMap<String, Vec<String>> {
    let mut map: std::collections::BTreeMap<String, Vec<String>> = Default::default();
    for (pdf, meta) in songs {
        for tag in &meta.tags {
            map.entry(tag.clone()).or_default().push(pdf.clone());
        }
        if meta.raw.is_some() {
            map.entry(RAW_COLLECTION.to_string()).or_default().push(pdf.clone());
        }
    }
    map
}

/// A book yml: (name, [pdf filename, ...]) in book order.
fn load_books(dir: &str) -> Vec<(String, Vec<String>)> {
    let clean = |t: &str| t.trim().trim_matches(|c| c == '\'' || c == '"').trim().to_string();
    let mut files: Vec<_> = fs::read_dir(dir)
        .unwrap_or_else(|e| die(format!("cannot read {}: {}", dir, e)))
        .filter_map(|e| e.ok())
        .map(|e| e.path())
        .filter(|p| p.extension().map_or(false, |x| x == "yml"))
        .collect();
    files.sort();
    let mut books = Vec::new();
    for f in files {
        let text = fs::read_to_string(&f).unwrap_or_default();
        let mut name = f.file_stem().unwrap().to_string_lossy().into_owned();
        let mut songs = Vec::new();
        let mut in_songs = false;
        for l in text.lines() {
            if let Some(v) = l.strip_prefix("name:") {
                name = clean(v);
            }
            if !l.starts_with(' ') && !l.starts_with('-') {
                in_songs = l.trim_end() == "songs:";
            } else if in_songs {
                if let Some(v) = l.trim().strip_prefix('-') {
                    songs.push(format!("{}.pdf", clean(v)));
                }
            }
        }
        books.push((name, songs));
    }
    books
}

fn millis(t: SystemTime) -> i64 {
    t.duration_since(UNIX_EPOCH).map(|d| d.as_millis() as i64).unwrap_or(0)
}

fn main() {
    let args = parse_args();
    let prefix_lc = args.prefix.to_lowercase();

    let mut pdfs: Vec<String> = fs::read_dir(&args.pdf_dir)
        .unwrap_or_else(|e| die(format!("cannot read {}: {}", args.pdf_dir, e)))
        .filter_map(|e| e.ok())
        .map(|e| e.file_name().to_string_lossy().into_owned())
        .filter(|f| {
            let l = f.to_lowercase();
            l.ends_with(".pdf") && l.starts_with(&prefix_lc)
        })
        .collect();
    // Songs without a structure have no pdf in the pdf dir: their `raw` pdf is
    // in the raw dir, and goes in under the usual <author>--@--<title>.pdf name.
    if let (Some(songs_dir), Some(raw_dir)) = (&args.songs_dir, &args.raw_dir) {
        for (name, meta) in load_songs(songs_dir) {
            let Some(raw) = &meta.raw else { continue };
            if !Path::new(raw_dir).join(raw).is_file() {
                eprintln!("warning: {}: raw pdf {} not found in {}", meta.dir.display(), raw, raw_dir);
                continue;
            }
            if name.to_lowercase().starts_with(&prefix_lc) && !pdfs.contains(&name) {
                pdfs.push(name);
            }
        }
    }
    pdfs.sort();
    if pdfs.is_empty() {
        die(format!("no PDF found in {}", args.pdf_dir));
    }

    let tpl = fs::read(&args.template).unwrap_or_else(|e| die(format!("{}: {}", args.template, e)));
    let (prefix, db) = split_template(&tpl);

    let tmp = std::env::temp_dir().join(format!("gen_msb_{}", process::id()));
    fs::create_dir_all(&tmp).unwrap();
    let dbpath = tmp.join("ms.db");
    let result = build(&args, &pdfs, prefix, db, &dbpath);
    let _ = fs::remove_dir_all(&tmp);
    if let Err(e) = result {
        die(format!("error: {}", e));
    }
}

fn build(
    args: &Args,
    pdfs: &[String],
    prefix: &[u8],
    db: &[u8],
    dbpath: &Path,
) -> Result<(), Box<dyn std::error::Error>> {
    fs::write(dbpath, db)?;
    let con = Connection::open(dbpath)?;
    clear_db(&con)?;

    let now = millis(SystemTime::now());
    let mut records: Vec<(i64, String)> = Vec::new();
    // song id -> mp3 path, embedded right after the song's PDF record
    let mut audio: HashMap<i64, Vec<String>> = HashMap::new();
    let mut audio_id = 0i64;
    let songs = args.songs_dir.as_deref().map(load_songs).unwrap_or_default();
    for (i, fname) in pdfs.iter().enumerate() {
        let n = i as i64 + 1;
        let path = match (songs.get(fname).and_then(|m| m.raw.as_ref()), &args.raw_dir) {
            (Some(raw), Some(raw_dir)) => Path::new(raw_dir).join(raw),
            _ => Path::new(&args.pdf_dir).join(fname),
        };
        let path_s = path.to_string_lossy().into_owned();
        let meta = fs::metadata(&path)?;
        let size = meta.len() as i64;
        let mtime = millis(meta.modified()?);
        let pages = pdf_pages(&path_s);
        let ts = now + n; // distinct creation timestamps
        con.execute(
            "insert into Songs(Id,Title,Difficulty,Custom,Custom2,LastPage,OrientationLock,\
             Duration,Stars,VerticalZoom,SortTitle,Sharpen,SharpenLevel,CreationDate,\
             LastModified,Keywords,AutoStartAudio,SongId) \
             values(?,?,0,'','',0,0,0,0,1.0,'',0,7,?,?,'',0,0)",
            params![
                n,
                songs.get(fname).map(|m| m.title.clone()).unwrap_or_else(|| title_from_name(fname)),
                ts,
                ts
            ],
        )?;
        con.execute(
            "insert into Files(Id,SongId,Path,PageOrder,FileSize,LastModified,Source,Type,\
             Password,SourceFilePageCount,FileHash,Width,Height) \
             values(?,?,?,?,?,?,1,1,'',?,?,-1,-1)",
            params![n, n, fname, format!("1-{}", pages), size, mtime, pages, args.file_hash],
        )?;
        con.execute(
            "insert into AutoScroll(Id,SongId,Behavior,PauseDuration,Speed,\
             FixedDuration,ScrollPercent,ScrollOnLoad,TimeBeforeScroll) \
             values(?,?,0,8000,3,1000,20,0,2000)",
            params![n, n],
        )?;
        con.execute(
            "insert into MetronomeSettings(Id,SongId,Sig1,Sig2,Subdivision,SoundFX,\
             AccentFirst,AutoStart,CountIn,NumberCount,AutoTurn) \
             values(?,?,2,0,0,0,0,0,0,1,0)",
            params![n, n],
        )?;
        con.execute("insert into Recent(Id,Song,RecentType) values(?,?,0)", params![n, n])?;
        for page in 0..pages {
            con.execute(
                "insert into ZoomPerPage(SongId,Page,Zoom,PortPanX,PortPanY,LandZoom,\
                 LandPanX,LandPanY,FirstHalfY,SecondHalfY) \
                 values(?,?,100.0,0.0,0.0,100.0,0.0,0.0,0,0)",
                params![n, page],
            )?;
            con.execute(
                "insert into Crop(SongId,Page,Left,Top,Right,Bottom,Rotation) \
                 values(?,?,0,0,0,0,0)",
                params![n, page],
            )?;
            con.execute(
                "insert into MetronomeBeatsPerPage(SongId,Page,BeatsPerPage) values(?,?,0)",
                params![n, page],
            )?;
            con.execute(
                "insert into Layers(SongId,Page,LayerIndex,Name,Visible) \
                 values(?,?,0,'Calque 1',1)",
                params![n, page],
            )?;
        }
        if let Some(tempo) = songs.get(fname).and_then(|m| m.tempo) {
            con.execute(
                "insert into Tempos(Id,SongId,Tempo,TempoIndex) values(?,?,?,0)",
                params![n, n, tempo],
            )?;
        }
        let stem = fname.strip_suffix(".pdf").or_else(|| fname.strip_suffix(".PDF")).unwrap_or(fname);
        // (source file, device file name, is snippet): the full song first, then the snippets
        let mut mp3s: Vec<(std::path::PathBuf, String, bool)> = Vec::new();
        if let Some(meta) = songs.get(fname) {
            if meta.has_mp3 {
                let f = meta.dir.join("song.mp3");
                if f.is_file() {
                    mp3s.push((f, format!("{}.mp3", stem), false));
                } else {
                    eprintln!("warning: {}: has_mp3 is true but song.mp3 is missing", meta.dir.display());
                }
            }
            if let Some(dir) = &args.snippets_dir {
                for sn in &meta.snippets {
                    let name = format!("{}-{}", stem, sn);
                    let f = Path::new(dir).join(&name);
                    if f.is_file() {
                        mp3s.push((f, name, true));
                    } else {
                        eprintln!("warning: {}: snippet {} not rendered in {}", fname, sn, dir);
                    }
                }
            }
        }
        for (mp3, name, snippet) in mp3s {
            let m = fs::metadata(&mp3)?;
            let mp3_s = mp3.to_string_lossy().into_owned();
            let dur = mp3_duration_ms(&mp3_s);
            audio_id += 1;
            con.execute(
                "insert into AudioFiles(Id,SongId,Title,File,FileSource,StartPos,EndPos,FileSize,\
                 LastModified,APosition,BPosition,ABEnabled,FullDuration,Volume,Artist,PitchShift,\
                 TempoSpeed,AudioFileHash) values(?,?,?,?,1,0,?,?,?,-1,-1,0,?,0.75,'',0,1.0,0)",
                params![
                    audio_id,
                    n,
                    name,
                    // snippets live in a sibling "mp3-renders" folder on the device
                    if snippet {
                        let base = args.audio_path.trim_end_matches('/');
                        let parent = base.rsplit_once('/').map(|x| x.0).unwrap_or("");
                        format!("{}/mp3-renders/{}", parent, name)
                    } else {
                        format!("{}/{}", args.audio_path.trim_end_matches('/'), name)
                    },
                    dur,
                    m.len() as i64,
                    millis(m.modified()?),
                    dur
                ],
            )?;
            if let Some(inst) = &args.install_dir {
                let sub = Path::new(inst).join(if snippet { "mp3-renders" } else { "mp3" });
                fs::create_dir_all(&sub)?;
                let link = sub.join(&name);
                let _ = fs::remove_file(&link);
                std::os::unix::fs::symlink(fs::canonicalize(&mp3)?, &link)?;
            }
            audio.entry(n).or_default().push(mp3_s);
        }
        records.push((n, path_s));
    }

    let song_id: HashMap<&str, i64> = pdfs
        .iter()
        .enumerate()
        .map(|(i, f)| (f.as_str(), i as i64 + 1))
        .collect();
    let mut setlists = args.setlists.clone();
    if let Some(dir) = &args.books_dir {
        for (name, files) in load_books(dir) {
            let (found, missing): (Vec<_>, Vec<_>) =
                files.into_iter().partition(|f| song_id.contains_key(f.as_str()));
            for m in &missing {
                eprintln!("warning: book {:?}: {} not in PDF set, skipped", name, m);
            }
            println!("setlist {:?}: {} songs", name, found.len());
            setlists.push((name, found));
        }
    }
    for (i, (name, files)) in setlists.iter().enumerate() {
        let sid = i as i64 + 1;
        let missing: Vec<&str> = files
            .iter()
            .filter(|x| !song_id.contains_key(x.as_str()))
            .map(|x| x.as_str())
            .collect();
        if !missing.is_empty() {
            die(format!("setlist {:?}: PDF not included: {}", name, missing.join(", ")));
        }
        // SortBy=0: manual order, SetlistSong row order = play order
        con.execute(
            "insert into Setlists(Id,Name,LastPage,LastIndex,SortBy,Ascending,\
             DateCreated,LastModified) values(?,?,0,0,0,1,?,?)",
            params![sid, name, now, now],
        )?;
        for x in files {
            con.execute(
                "insert into SetlistSong(SetlistId,SongId) values(?,?)",
                params![sid, song_id[x.as_str()]],
            )?;
        }
    }
    {
        let mut row = 0i64;
        for (i, (tag, files)) in collect_tags(&songs).iter().enumerate() {
            let cid = i as i64 + 1;
            let mut ids: Vec<i64> = files.iter().filter_map(|f| song_id.get(f.as_str()).copied()).collect();
            for f in files.iter().filter(|f| !song_id.contains_key(f.as_str())) {
                eprintln!("warning: tag {:?}: {} not in PDF set, skipped", tag, f);
            }
            if ids.is_empty() {
                continue;
            }
            ids.sort();
            ids.dedup();
            con.execute(
                "insert into Collections(Id,Name,SortBy,Ascending,DateCreated,LastModified) \
                 values(?,?,1,1,?,?)",
                params![cid, tag, now, now],
            )?;
            for sid in &ids {
                row += 1;
                con.execute(
                    "insert into CollectionSong(Id,CollectionId,SongId) values(?,?,?)",
                    params![row, cid, sid],
                )?;
            }
            println!("collection {:?}: {} songs", tag, ids.len());
        }
    }
    // one artist per distinct info.author, linked to its songs
    {
        let mut by_author: std::collections::BTreeMap<&str, Vec<i64>> = Default::default();
        for (pdf, meta) in &songs {
            if let Some(&sid) = song_id.get(pdf.as_str()) {
                if !meta.author.is_empty() {
                    by_author.entry(meta.author.as_str()).or_default().push(sid);
                }
            }
        }
        let mut row = 0i64;
        for (i, (name, ids)) in by_author.iter_mut().enumerate() {
            let aid = i as i64 + 1;
            ids.sort();
            con.execute(
                "insert into Artists(Id,Name,SortBy,Ascending,DateCreated,LastModified) values(?,?,1,1,?,?)",
                params![aid, name, now, now],
            )?;
            for sid in ids.iter() {
                row += 1;
                con.execute(
                    "insert into ArtistsSongs(Id,ArtistId,SongId) values(?,?,?)",
                    params![row, aid, sid],
                )?;
            }
        }
        println!("{} artists", by_author.len());
    }
    con.execute_batch("vacuum")?;
    con.close().map_err(|(_, e)| e)?;
    let newdb = fs::read(dbpath)?;

    let mut out = std::io::BufWriter::new(fs::File::create(&args.out)?);
    out.write_all(prefix)?;
    out.write_all(&(newdb.len() as u64).to_be_bytes())?;
    out.write_all(&newdb)?;
    for (fid, path) in &records {
        let blob = fs::read(path)?;
        out.write_all(&MAGIC_FILE.to_be_bytes())?;
        out.write_all(&(*fid as u64).to_be_bytes())?;
        out.write_all(&(blob.len() as u64).to_be_bytes())?;
        out.write_all(&blob)?;
        for mp3 in audio.get(fid).into_iter().flatten() {
            let blob = fs::read(mp3)?;
            out.write_all(&(blob.len() as u64).to_be_bytes())?;
            out.write_all(&blob)?;
        }
    }
    out.write_all(&[0xff; 8])?;
    out.flush()?;
    drop(out);
    println!(
        "wrote {}: {} songs, {} audio files ({} songs), {:.1} MB",
        args.out,
        records.len(),
        audio_id,
        audio.len(),
        fs::metadata(&args.out)?.len() as f64 / 1e6
    );
    Ok(())
}
