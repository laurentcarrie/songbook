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
}

fn parse_args() -> Args {
    let mut template = None;
    let mut pdf_dir = None;
    let mut out = None;
    let mut file_hash = -1i64;
    let mut prefix = String::new();
    let mut setlists = Vec::new();
    let mut songs_dir = None;

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
                     [--songs-dir DIR  (one collection per tag found in DIR/<artist>/<song>/song.yml)]"
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

/// tag -> PDF filenames, from DIR/<artist>/<song>/song.yml.
/// The PDF is named `<author>--@--<title>.pdf` (info.author / info.title, normalized).
fn collect_tags(dir: &str) -> std::collections::BTreeMap<String, Vec<String>> {
    let mut map: std::collections::BTreeMap<String, Vec<String>> = Default::default();
    let rd = |p: &Path| fs::read_dir(p).map(|r| r.filter_map(|e| e.ok()).collect::<Vec<_>>()).unwrap_or_default();
    for artist in rd(Path::new(dir)) {
        for song in rd(&artist.path()) {
            let Ok(text) = fs::read_to_string(song.path().join("song.yml")) else { continue };
            let (Some(author), Some(title)) = (info_field(&text, "author"), info_field(&text, "title")) else {
                eprintln!("warning: {}: no info.author/title", song.path().display());
                continue;
            };
            let pdf = format!("{}--@--{}.pdf", normalize_name(&author), normalize_name(&title));
            for tag in parse_tags(&text) {
                map.entry(tag).or_default().push(pdf.clone());
            }
        }
    }
    map
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
    for (i, fname) in pdfs.iter().enumerate() {
        let n = i as i64 + 1;
        let path = Path::new(&args.pdf_dir).join(fname);
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
            params![n, title_from_name(fname), ts, ts],
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
        records.push((n, path_s));
    }

    let song_id: HashMap<&str, i64> = pdfs
        .iter()
        .enumerate()
        .map(|(i, f)| (f.as_str(), i as i64 + 1))
        .collect();
    for (i, (name, files)) in args.setlists.iter().enumerate() {
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
    if let Some(dir) = &args.songs_dir {
        let mut row = 0i64;
        for (i, (tag, files)) in collect_tags(dir).iter().enumerate() {
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
    }
    out.write_all(&[0xff; 8])?;
    out.flush()?;
    drop(out);
    println!(
        "wrote {}: {} songs, {:.1} MB",
        args.out,
        records.len(),
        fs::metadata(&args.out)?.len() as f64 / 1e6
    );
    Ok(())
}
