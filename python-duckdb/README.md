# SNOMED-CT DuckDB Loader

This script imports SNOMED-CT RF2 files from an Edition package into [DuckDB](https://duckdb.org). It has been tested with the SNOMED-CT May 2025 International Edition release.

The script also launches a [DuckDB UI](https://duckdb.org/docs/stable/extensions/ui) for interactive queries. Query results can be converted to a [Numpy array](https://duckdb.org/docs/stable/guides/python/export_numpy) or [Pandas DataFrame](https://duckdb.org/docs/stable/guides/python/export_pandas), and exported to various formats, including CSV, Parquet, Arrow, and Excel (with additional [extensions](https://duckdb.org/docs/stable/extensions/overview) enabled).


![Screenshot of DuckDB UI](./resources/docs/example.gif)


## Requirements

- Python 3.8+
- [DuckDB Python library](https://duckdb.org/docs/stable/clients/python/overview.html)


## Installation

* Clone the repository:
    ```bash
    $ git clone https://github.com/IHTSDO/snomed-database-loader.git
    $ cd snomed-database-loader/python-duckdb
    ```
* Install dependencies:
    ```bash
    $ pip install -r requirements.txt
    ```

## Usage
1. Download SNOMED-CT
    * Obtain an _Edition_ package of SNOMED-CT (see https://www.snomed.org/get-snomed)
    * If you have an Extension package, please make sure to convert it into an _Edition_ package before proceeding

2. Place the zip file in the [releases](./releases/) directory

3. Run the script
    * Execute the script with the path to your Edition package as an argument:
        ```bash
        $ python snomed-duckdb.py --package ./releases/SnomedCT_InternationalRF2_PRODUCTION_20250501T120000Z.zip
        ```

4. Interact with the DuckDB UI
    * The DuckDB UI will start in your default web browser at http://localhost:4213

## Notes
### Database Persistence
By default, the database runs in in-memory mode. To persist the database to a file, specify it with the --db parameter
```bash
$ python snomed-duckdb.py --package .... --db ./snomed_data.duckdb
```
