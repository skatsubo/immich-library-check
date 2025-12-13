# Immich library consistency check

[Description](#description) | [How to use](#how-to-use) | [Caveats](#caveats) | [Todo](#todo)

## Description

This script finds inconsistencies between the Immich database and the actual photo library files on disk.

It compares asset info from the database and actual state on disk to uncover missing and untracked asset files:
- Untracked files - assets present only in file system on disk (fs)
- Missing files - assets present only in the database (db)
- Normal assets - files present both in the database and on disk (fs, db)

It writes two TSV (tab-separated values) files:
- `library.mismatch.tsv` - assets that are only on disk (untracked) or only in the database (missing files)
- `library.tsv` - all assets (both mismatches and normal assets)

Each row has **FS fields** (columns 1–5) and **DB fields** (columns 6–14). A normal asset has non-empty values in both.

Motivation for this script:
- "How I can look up untracked files?" on Discord https://discord.com/channels/979116623879368755/1441618274906407054

## How to use

1. Get the script [check.sh](https://raw.githubusercontent.com/skatsubo/immich-library-check/refs/heads/main/check.sh).

2. (Optional) Adjust the variables (`datadir`, etc.) according to your setup.

3. Run the script:

```sh
bash check.sh
```

4. Review the results.  
Two TSV files `library.tsv` and `library.mismatch.tsv` will be created.  
Open `library.mismatch.tsv` in your spreadsheet app and check for problems found:
    - Rows with only `fs` source - untracked files, present only on disk
    - Rows with only `db` source - missing files, present only in the database

## Caveats

> [!WARNING]
> This is a proof of concept and not extensively tested. It may produce incomplete or incorrect results in edge cases, such as stacked assets. Please report if you encounter bugs.

Current limitations:
- Filenames containing the pipe character `|`, tabs or newlines are not supported.
     
## Todo

Track other resources:
- sidecars
- thumbnails
- transcoded videos
- ...
