#!/usr/bin/env python3

"""
Build a SNOMED CT concept hierarchy from RF2 Snapshot archives.

Inputs:
    - One SNOMED CT Edition RF2 Snapshot ZIP (required)
    - One or more SNOMED CT Extension Snapshot ZIPs (optional)

The script:
    - Loads active concepts
    - Loads active inferred IS-A relationships
    - Builds an in-memory hierarchy
    - Outputs a tab-separated file containing:
        conceptId
        directParents (pipe separated)
        ancestors (pipe separated)

Usage:
    python snomed_hierarchy.py \
        --edition SnomedCT_InternationalRF2.zip \
        --extension UKExtension.zip \
        --extension LocalExtension.zip \
        --output hierarchy.tsv

Notes:
    - Only active inferred relationships are used.
    - Relationship type must be 116680003 |Is a (attribute)|
    - Characteristic type must be:
        900000000000011006 |Inferred relationship|
    - Snapshot files are expected inside RF2 release ZIPs.
"""

import argparse
import csv
import io
import sys
import zipfile
from collections import defaultdict
from functools import lru_cache

ISA_TYPE_ID = "116680003"
INFERRED_RELATIONSHIP_ID = "900000000000011006"

CONCEPT_FILE_TOKEN = "sct2_Concept_Snapshot"
RELATIONSHIP_FILE_TOKEN = "sct2_Relationship_Snapshot"


class RF2Loader:
    def __init__(self):
        self.active_concepts = set()

        # child -> set(parent)
        self.parents = defaultdict(set)

    def load_zip(self, zip_path):
        print(f"Loading: {zip_path}", file=sys.stderr)

        with zipfile.ZipFile(zip_path, "r") as zf:
            concept_files = [
                n for n in zf.namelist()
                if CONCEPT_FILE_TOKEN in n and n.endswith(".txt")
            ]

            relationship_files = [
                n for n in zf.namelist()
                if RELATIONSHIP_FILE_TOKEN in n and n.endswith(".txt")
            ]

            if not concept_files:
                raise RuntimeError(
                    f"No Concept Snapshot file found in {zip_path}"
                )

            if not relationship_files:
                raise RuntimeError(
                    f"No Relationship Snapshot file found in {zip_path}"
                )

            for filename in concept_files:
                self._load_concepts(zf, filename)

            for filename in relationship_files:
                self._load_relationships(zf, filename)

    def _load_concepts(self, zf, filename):
        print(f"  Concepts: {filename}", file=sys.stderr)

        with zf.open(filename) as f:
            reader = csv.DictReader(
                io.TextIOWrapper(f, encoding="utf-8"),
                delimiter="\t"
            )

            for row in reader:
                if row["active"] != "1":
                    continue

                concept_id = row["id"]
                self.active_concepts.add(concept_id)

    def _load_relationships(self, zf, filename):
        print(f"  Relationships: {filename}", file=sys.stderr)

        with zf.open(filename) as f:
            reader = csv.DictReader(
                io.TextIOWrapper(f, encoding="utf-8"),
                delimiter="\t"
            )

            for row in reader:
                if row["active"] != "1":
                    continue

                # Must be inferred relationship
                if row["characteristicTypeId"] != INFERRED_RELATIONSHIP_ID:
                    continue

                # Must be IS-A relationship
                if row["typeId"] != ISA_TYPE_ID:
                    continue

                child = row["sourceId"]
                parent = row["destinationId"]

                self.parents[child].add(parent)

    def compute_ancestors(self):
        """
        Returns:
            dict(conceptId -> sorted list of ancestors)
        """

        @lru_cache(maxsize=None)
        def get_ancestors(concept_id):
            ancestors = set()

            for parent in self.parents.get(concept_id, set()):
                ancestors.add(parent)
                ancestors.update(get_ancestors(parent))

            return frozenset(ancestors)

        result = {}

        for concept_id in self.active_concepts:
            result[concept_id] = sorted(get_ancestors(concept_id))

        return result


def write_output(output_path, active_concepts, parents, ancestors):
    with open(output_path, "w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f, delimiter="\t")

        writer.writerow([
            "conceptId",
            "directParents",
            "ancestors"
        ])

        for concept_id in sorted(active_concepts):
            immediate_parents = sorted(parents.get(concept_id, set()))
            all_ancestors = ancestors.get(concept_id, [])

            writer.writerow([
                concept_id,
                "|".join(immediate_parents),
                "|".join(all_ancestors)
            ])


def parse_args():
    parser = argparse.ArgumentParser(
        description="Build SNOMED CT concept hierarchy from RF2 Snapshots"
    )

    parser.add_argument(
        "--edition",
        required=True,
        help="SNOMED CT Edition RF2 Snapshot ZIP"
    )

    parser.add_argument(
        "--extension",
        action="append",
        default=[],
        help="SNOMED CT Extension RF2 Snapshot ZIP (repeatable)"
    )

    parser.add_argument(
        "--output",
        required=True,
        help="Output TSV file"
    )

    return parser.parse_args()


def main():
    args = parse_args()

    loader = RF2Loader()

    # Load edition first
    loader.load_zip(args.edition)

    # Load extensions afterwards
    for ext_zip in args.extension:
        loader.load_zip(ext_zip)

    print(
        f"Loaded {len(loader.active_concepts):,} active concepts",
        file=sys.stderr
    )

    print("Computing ancestors...", file=sys.stderr)

    ancestors = loader.compute_ancestors()

    print("Writing output...", file=sys.stderr)

    write_output(
        args.output,
        loader.active_concepts,
        loader.parents,
        ancestors
    )

    print("Done.", file=sys.stderr)


if __name__ == "__main__":
    main()
