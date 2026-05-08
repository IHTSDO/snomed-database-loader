# SNOMED CT transitive closure (Python)

`snomed-transitive-closure.py` builds an in-memory SNOMED CT **IS-A** hierarchy from **RF2 Snapshot** ZIP packages and writes a tab-separated file with **immediate parents** and **all ancestors** (transitive closure) for every active concept.

## Requirements

- Python 3 (standard library only: no `pip install` needed)

Edition and extension packages are distributed under SNOMED International’s licensing terms; see [Get SNOMED CT](https://www.snomed.org/get-snomed).

## What it reads

Inside each ZIP, the script looks for RF2 tab-delimited snapshot files whose names contain:

- `sct2_Concept_Snapshot` — active concepts (`active = 1`)
- `sct2_Relationship_Snapshot` — active **inferred** IS-A edges only

Relationships are kept only when:

- `typeId` is `116680003` (*Is a (attribute)*)
- `characteristicTypeId` is `900000000000011006` (*Inferred relationship*)

## Usage

Load a single **Edition** snapshot:

```bash
python3 snomed-transitive-closure.py \
  --edition /path/to/SnomedCT_InternationalRF2_....zip \
  --output hierarchy.tsv
```

Load the Edition first, then one or more **Extension** snapshots (each `--extension` can be repeated). Later ZIPs merge into the same loader: concepts and parent links accumulate in load order.

```bash
python3 snomed-transitive-closure.py \
  --edition /path/to/InternationalRF2.zip \
  --extension /path/to/NationalExtension.zip \
  --extension /path/to/LocalExtension.zip \
  --output hierarchy.tsv
```

Progress and file names are printed to **stderr**; the TSV is written to `--output`.

## Output format

The output is UTF-8 TSV with a header row:

| Column | Description |
|--------|-------------|
| `conceptId` | SNOMED concept identifier |
| `immediateParents` | Pipe-separated (`\|`) parent concept IDs |
| `ancestorsIncludingParents` | Pipe-separated transitive ancestors (includes all parents reachable via inferred IS-A) |

Rows are sorted by `conceptId`. Empty parent columns mean no inferred IS-A parents were loaded for that concept.

## Notes

- **Snapshot only**: the script expects full snapshot RF2 ZIPs (not Delta-only layouts unless they still ship the Snapshot files).
- **Cycles**: ancestor computation assumes an acyclic IS-A graph; malformed data with cycles could cause deep recursion errors.
- The module docstring in the script refers to `snomed_hierarchy.py`; the runnable entrypoint in this folder is **`snomed-transitive-closure.py`**.
