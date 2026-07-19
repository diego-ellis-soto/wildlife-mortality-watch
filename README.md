---
title: Wildlife Mortality Watch
emoji: 🐾
colorFrom: green
colorTo: blue
sdk: docker
app_port: 7860
pinned: false
license: bsd-2-clause
short_description: A Shiny dashboard for monitoring wildlife mortality records from iNaturalist.
---

## Overview

This archive contains the version-of-record application code, analysis code, deposited input data, and documentation associated with:

> Ellis-Soto, D., Taylor, L. U., Edson, E., Hill, A., Schell, C. J., Boettiger, C., and Johnson, R. F. *Global monitoring of wildlife mortality through participatory science in near-real time.*

**Wildlife Mortality Watch** is an open-source R Shiny application for querying, mapping, visualizing, and downloading iNaturalist observations annotated as dead.

The application supports:

- near-real-time retrieval through the iNaturalist API;
- retrospective exploration through a precompiled Parquet archive;
- taxonomic and conservation-status filtering;
- spatial queries based on bounding boxes, uploaded study areas, or iNaturalist Places;
- daily, weekly, or monthly temporal aggregation;
- mortality-record counts;
- numbers of unique contributing observers;
- mortality observations per observer;
- percentages of matching iNaturalist observations annotated as dead;
- interactive and static spatial summaries; and
- downloads of filtered records and query metadata.

The application is intended for exploratory surveillance, decision support, and hypothesis generation. It does **not** estimate population-level mortality rates, detection probabilities, or complete numbers of wildlife deaths.

## Links

- **Interactive application:** https://huggingface.co/spaces/diegoellissoto/wildlife-mortality-watch
- **Active development repository:** https://github.com/diego-ellis-soto/wildlife-mortality-watch
- **Preprint:** https://doi.org/10.1101/2025.08.08.669145
- **Version-specific Zenodo DOI:** `10.5281/zenodo.XXXXXXX`
- **Release version:** `[VERSION]`

Replace the DOI, release version, and publication year placeholders before publishing the final Zenodo record.

## Archive structure

The application and analysis scripts use paths relative to the project root. Preserve the following structure unless the paths in `Code/src/ms_analysis.R` are updated.

```text
.
├── README.md
├── LICENSE
├── CITATION.cff
├── Code/
│   └── src/
│       ├── app.R
│       ├── ms_analysis.R
│       ├── Dockerfile
│       ├── install.r
│       ├── README.md
│       └── www/
│           └── all_logos.png
├── indir/
│   ├── hmod_americas_masked.tif
│   ├── inat_mortality_observations-2026-04-21.parquet
│   └── resubmission_case_studies/
│       ├── California/
│       │   └── California_mammals_inat_dead_filtered_2026-05-12.csv
│       └── Puma/
│           └── puma_case_study_2inat_dead_filtered_2026-05-12.csv
└── outdir/
    └── [generated figures]
```

The IUCN *Puma concolor* range layer and the record-level CSV used for the Africa threatened-species case study are not included in this public archive. Their availability and reproduction requirements are described below under **Externally sourced or non-redistributed data**.

## File-level metadata

The following inventory should match the final Zenodo deposit exactly. Files that are not included in the public archive are listed separately under **Externally sourced or non-redistributed data**.

### Documentation and code

| Exact path | Description |
|---|---|
| `README.md` | Primary documentation for the archived application, manuscript analyses, data provenance, reproduction instructions, limitations, licensing, and citation. |
| `LICENSE` | BSD 2-Clause License covering the original software and analysis code in this release. Third-party datasets and media retain their original licenses. |
| `CITATION.cff` | Machine-readable citation metadata for the versioned software and data release. |
| `Code/src/app.R` | Version-of-record R Shiny application. The file implements live and archived iNaturalist queries, spatial and taxonomic filtering, conservation-status filtering, temporal summaries, maps, tables, downloads, and query diagnostics. |
| `Code/src/ms_analysis.R` | R script used to generate manuscript analyses and figures for the California mammal, Africa threatened-species, puma, and global mortality-archive workflows. |
| `Code/src/Dockerfile` | Docker recipe used to install system dependencies and run the Shiny application on port 7860. |
| `Code/src/install.r` | R package installation script used by the application container. |
| `Code/src/README.md` | Hugging Face Space metadata and user-facing application documentation. |
| `Code/src/www/all_logos.png` | Static logo image displayed in the Shiny interface. Individual image components retain their applicable attribution and reuse requirements. |

### Deposited input data

| Exact path | Description |
|---|---|
| `indir/resubmission_case_studies/California/California_mammals_inat_dead_filtered_2026-05-12.csv` | Mortality-annotated mammal observations exported from Wildlife Mortality Watch and used for the California spatial, road-distance, Human Landscape Modification, and taxonomic analyses. |
| `indir/hmod_americas_masked.tif` | Human Landscape Modification raster used to characterize landscape conditions associated with California mammal mortality observations. The original source, version, spatial resolution, coordinate reference system, processing steps, and license should be reported in the Zenodo metadata. |
| `indir/resubmission_case_studies/Puma/puma_case_study_2inat_dead_filtered_2026-05-12.csv` | Mortality-annotated *Puma concolor* observations used for mapping, country or territory summaries, and candidate-duplicate screening. |
| `indir/inat_mortality_observations-2026-04-21.parquet` | Fixed archive of mortality-annotated iNaturalist observations used for annual-growth and taxonomic-composition summaries. This deposited file preserves the snapshot used in the manuscript analyses. |

## Externally sourced or non-redistributed data

The following files were used in the manuscript analyses but are not redistributed in this public archive.

| File used in the analysis | Availability and purpose |
|---|---|
| IUCN range map for *Puma concolor* | The species-range layer used in the puma analysis was downloaded from the IUCN Red List of Threatened Species. Because the original spatial data remain subject to IUCN access and redistribution terms, the range layer and its associated shapefile components are not redistributed in this Zenodo archive. Users wishing to reproduce the range-based analysis must obtain the corresponding *Puma concolor* range layer directly from the IUCN Red List. The analysis code documents the expected local file path and processing workflow. |
| `Africa_inat_dead_filtered_2026-05-12.csv` | The record-level dataset used for the Africa threatened-species case study is not included in the public Zenodo archive. It may be provided by the corresponding author upon reasonable request. The archived analysis code documents the expected filename, structure, filters, and processing workflow.

## Software requirements

The application and analyses were developed in R. The California spatial workflow was developed using R 4.4.1.

## Running the Shiny application

### From R

From the project root, run:

```r
shiny::runApp("Code/src")
```

The application requires internet access for:

- live iNaturalist observation queries;
- taxon and iNaturalist Place searches; and
- retrieval of remote datasets that are not included locally.

## Reproducing the manuscript analyses

1. Download and extract the  Zenodo archive.
2. Set the extracted archive directory as the R working directory.
3. Open `Code/src/ms_analysis.R`.
4. Obtain the non-redistributed IUCN range layer when reproducing the puma range analysis.
5. Run the analysis .

The script contains workflows for:

- California mammal mortality, road proximity, Human Landscape Modification, and frequently reported taxa;
- threatened-species mortality observations across Africa;
- puma mortality mapping, country or territory summaries, and candidate-duplicate screening;
- annual growth and taxonomic composition of the global mortality archive; and
- annual percentages of Animalia and major taxonomic-group observations annotated as dead.

## Data provenance

The mortality-record CSV files were generated from public iNaturalist observations using Wildlife Mortality Watch.

The archived Parquet file is a fixed snapshot of mortality-annotated iNaturalist observations through 21 April 2026.

External spatial data used in the analyses include:

- road geometries retrieved through the `tigris` R package;
- country boundaries obtained from Natural Earth through `rnaturalearth`;
- a Human Landscape Modification raster; and
- a *Puma concolor* range layer obtained from the IUCN Red List of Threatened Species.

The IUCN range layer is not redistributed in this archive because it remains subject to the source provider’s access and redistribution terms. Users must obtain the corresponding range layer directly from the IUCN Red List before running the range-based puma analysis.

The record-level CSV used in the Africa threatened-species case study is not included in the public Zenodo deposit. It may be made available by the corresponding author upon reasonable request, subject to applicable record-level licensing and data-use conditions.

The application reports **mortality-annotated observations**.

Signals identified through the application should be evaluated using individual-record inspection, local ecological knowledge, independent surveillance, and other relevant environmental or public-health information.

For uploaded polygons, mortality observations may be clipped to the exact uploaded geometry, while reference totals and all-observation denominators may be calculated using the polygon bounding box. Percentages calculated for irregular or small polygons should therefore be interpreted cautiously.

## Licensing

iNaturalist observations and other media retain the licenses selected by their original contributors. This archive preserves observation identifiers and source links rather than redistributing photographs or audio unless their individual licenses permit redistribution.

Third-party spatial datasets retain their original licenses, access conditions, and citation requirements.

The IUCN *Puma concolor* range layer is not redistributed through this archive. Users are responsible for obtaining the data directly from IUCN and complying with the applicable IUCN terms of use.

Wildlife Mortality Watch is an independent research tool and is not affiliated with or endorsed by iNaturalist.

## Citation

Please cite both the archived release and the associated paper.

### Archived release

> Ellis-Soto, D., Taylor, L. U., Edson, E., Hill, A., Schell, C. J., Boettiger, C., and Johnson, R. F. ([YEAR]). *Code and data for: Global monitoring of wildlife mortality through participatory science in near-real time* (Version [VERSION]). Zenodo. XXX

### Associated paper

> Ellis-Soto, D., Taylor, L. U., Edson, E., Hill, A., Schell, C. J., Boettiger, C., and Johnson, R. F. (2025). *Global monitoring of wildlife mortality through participatory science in near-real time*. bioRxiv. https://doi.org/10.1101/2025.08.08.669145

## Contact

Diego Ellis-Soto  
Department of Environmental Science, Policy, and Management  
University of California, Berkeley  
diego.ellissoto@berkeley.edu