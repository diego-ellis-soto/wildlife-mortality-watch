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

# Wildlife Mortality Watch

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

Add any query-metadata JSON files, data dictionaries, checksums, derived tables, or additional deposited files to this inventory using their exact filenames.

## Externally sourced or non-redistributed data

The following files were used in the manuscript analyses but are not redistributed in this public archive.

| File used in the analysis | Availability and purpose |
|---|---|
| IUCN range map for *Puma concolor* | The species-range layer used in the puma analysis was downloaded from the IUCN Red List of Threatened Species. Because the original spatial data remain subject to IUCN access and redistribution terms, the range layer and its associated shapefile components are not redistributed in this Zenodo archive. Users wishing to reproduce the range-based analysis must obtain the corresponding *Puma concolor* range layer directly from the IUCN Red List. The analysis code documents the expected local file path and processing workflow. |
| `Africa_inat_dead_filtered_2026-05-12.csv` | The record-level dataset used for the Africa threatened-species case study is not included in the public Zenodo archive. It may be provided by the corresponding author upon reasonable request, subject to applicable iNaturalist record-level licenses and data-use requirements. The archived analysis code documents the expected filename, structure, filters, and processing workflow. |

To support reproducibility of the Africa case study, the final archive should also include, where possible:

- the iNaturalist observation identifiers used in the analysis;
- the query date;
- the spatial and temporal query definition;
- selected conservation-status categories;
- query metadata and diagnostics;
- derived summary values reported in the manuscript; and
- code for reconstructing the analysis from public source records.

## Software requirements

The application and analyses were developed in R. The California spatial workflow was developed using R 4.4.1.

Principal application packages include:

```text
shiny
bslib
shinyjs
shinycssloaders
tidyverse
httr
jsonlite
glue
lubridate
viridis
hexbin
DT
leaflet
leaflet.extras
maps
mapdata
arrow
sf
cowplot
stringr
scales
```

Principal analysis packages include:

```text
tidyverse
ggplot2
sf
raster
units
tidycensus
tigris
mapview
viridis
cowplot
patchwork
gridExtra
ggimage
rnaturalearth
rnaturalearthdata
arrow
treemapify
tidygraph
ggraph
ineq
jsonlite
httr2
glue
lubridate
purrr
forcats
```

For a fully versioned R environment, include an `renv.lock` file and restore the package environment with:

```r
install.packages("renv")
renv::restore()
```

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

### With Docker

From the project root, run:

```bash
docker build -t wildlife-mortality-watch Code/src
docker run --rm -p 7860:7860 wildlife-mortality-watch
```

Then open:

```text
http://localhost:7860
```

in a web browser.

## Reproducing the manuscript analyses

1. Download and extract the complete Zenodo archive.
2. Set the extracted archive directory as the R working directory.
3. Confirm that the deposited files follow the directory structure documented above.
4. Create the output directory when it does not already exist:

```r
dir.create("outdir", showWarnings = FALSE, recursive = TRUE)
```

5. Install or restore the required R packages.
6. Open `Code/src/ms_analysis.R`.
7. Obtain the non-redistributed IUCN range layer when reproducing the puma range analysis.
8. Contact the corresponding author regarding access to the Africa case-study CSV when record-level reproduction is required.
9. Run the documented analysis sections in order.

The script contains workflows for:

- California mammal mortality, road proximity, Human Landscape Modification, and frequently reported taxa;
- threatened-species mortality observations across Africa;
- puma mortality mapping, country or territory summaries, and candidate-duplicate screening;
- annual growth and taxonomic composition of the global mortality archive; and
- annual percentages of Animalia and major taxonomic-group observations annotated as dead.

Some sections retrieve roads, country boundaries, flags, or iNaturalist totals from external services. Results obtained from live services can change after publication. Exact reproduction therefore depends on the fixed datasets, query metadata, and derived values archived with this release.

## Application metrics

The application provides several complementary temporal metrics.

### Mortality-annotated observations

The number of iNaturalist observations annotated as dead within each selected day, week, or month.

### Unique observers

The number of unique iNaturalist users contributing mortality-annotated observations within each time bin.

### Mortality observations per observer

The number of mortality-annotated observations divided by the number of unique observers contributing those records within the time bin.

### Percentage of observations annotated as dead

For each time bin, the application calculates:

```text
100 × mortality-annotated observations in the time bin
      ------------------------------------------------
      all observations matching the same taxonomic,
      spatial, temporal, and quality criteria
```

The denominator is recalculated independently for each selected day, week, or month.

This percentage is a descriptive observation index. It is not a biological mortality rate because iNaturalist observations are not generated through a standardized sampling design and the probability of detecting or reporting mortality is unknown.

## Data provenance

The mortality-record CSV files were generated from public iNaturalist observations using Wildlife Mortality Watch.

For each exported dataset, users should retain:

- observation identifiers;
- retrieval date;
- taxonomic filters;
- conservation-status filters;
- spatial bounds or study-area definition;
- date range;
- time aggregation;
- mortality numerator;
- all-observation denominator; and
- downloaded query metadata.

The archived Parquet file is a fixed snapshot of mortality-annotated iNaturalist observations through 21 April 2026.

External spatial data used in the analyses include:

- road geometries retrieved through the `tigris` R package;
- country boundaries obtained from Natural Earth through `rnaturalearth`;
- a Human Landscape Modification raster; and
- a *Puma concolor* range layer obtained from the IUCN Red List of Threatened Species.

The IUCN range layer is not redistributed in this archive because it remains subject to the source provider’s access and redistribution terms. Users must obtain the corresponding range layer directly from the IUCN Red List before running the range-based puma analysis.

The record-level CSV used in the Africa threatened-species case study is not included in the public Zenodo deposit. It may be made available by the corresponding author upon reasonable request, subject to applicable record-level licensing and data-use conditions.

## Interpretation and limitations

iNaturalist observations are opportunistic participatory-science records. Patterns presented by the application and manuscript analyses may reflect both ecological processes and variation in:

- observer participation;
- geographic accessibility;
- taxonomic detectability;
- seasonal platform activity;
- optional use of the alive/dead annotation;
- repeated reporting of the same mortality event or carcass;
- spatial uncertainty;
- obscured coordinates;
- taxonomic identifications;
- conservation-status metadata; and
- changes to source observations after retrieval.

The application reports **mortality-annotated observations**, not independently verified causes of death or complete counts of mortality events.

Signals identified through the application should be evaluated using individual-record inspection, local ecological knowledge, independent surveillance, and other relevant environmental or public-health information.

For uploaded polygons, mortality observations may be clipped to the exact uploaded geometry, while reference totals and all-observation denominators may be calculated using the polygon bounding box. Percentages calculated for irregular or small polygons should therefore be interpreted cautiously.

## Licensing

Original software and analysis code in this release are distributed under the BSD 2-Clause License.

iNaturalist observations, photographs, audio, and other media retain the licenses selected by their original contributors. This archive preserves observation identifiers and source links rather than redistributing photographs or audio unless their individual licenses permit redistribution.

Third-party spatial datasets retain their original licenses, access conditions, and citation requirements.

The IUCN *Puma concolor* range layer is not redistributed through this archive. Users are responsible for obtaining the data directly from IUCN and complying with the applicable IUCN terms of use.

Wildlife Mortality Watch is an independent research tool and is not affiliated with or endorsed by iNaturalist.

## Citation

Please cite both the archived release and the associated paper.

### Archived release

> Ellis-Soto, D., Taylor, L. U., Edson, E., Hill, A., Schell, C. J., Boettiger, C., and Johnson, R. F. ([YEAR]). *Code and data for: Global monitoring of wildlife mortality through participatory science in near-real time* (Version [VERSION]). Zenodo. https://doi.org/10.5281/zenodo.XXXXXXX

### Associated paper

> Ellis-Soto, D., Taylor, L. U., Edson, E., Hill, A., Schell, C. J., Boettiger, C., and Johnson, R. F. (2025). *Global monitoring of wildlife mortality through participatory science in near-real time*. bioRxiv. https://doi.org/10.1101/2025.08.08.669145

When reporting an application query, also record:

- the archived software version or Git commit;
- date accessed;
- live or archived data mode;
- spatial query definition;
- date range;
- daily, weekly, or monthly aggregation;
- taxonomic or conservation-status filters;
- number of mortality-annotated observations;
- number of matching total observations;
- percentage calculation and denominator threshold; and
- downloaded query-metadata JSON file.

## Open Research statement

After the Zenodo record is publicly available, the manuscript may use the following statement:

> **Open Research.** The data, derived data products, query metadata, and version-of-record R code supporting this study are archived in Zenodo: Ellis-Soto, D., Taylor, L. U., Edson, E., Hill, A., Schell, C. J., Boettiger, C., and Johnson, R. F. ([YEAR]). *Code and data for: Global monitoring of wildlife mortality through participatory science in near-real time* (Version [VERSION]). Zenodo. https://doi.org/10.5281/zenodo.XXXXXXX. The actively maintained development repository is available at https://github.com/diego-ellis-soto/wildlife-mortality-watch, and the interactive application is available at https://huggingface.co/spaces/diegoellissoto/wildlife-mortality-watch. Source observations were obtained from iNaturalist and retain contributor-selected licenses. The *Puma concolor* range layer was obtained from the IUCN Red List and is not redistributed because it remains subject to IUCN access and reuse conditions. The record-level Africa case-study dataset may be provided by the corresponding author upon reasonable request, subject to applicable licensing and data-use requirements.

## Contact

Diego Ellis-Soto  
Department of Environmental Science, Policy, and Management  
University of California, Berkeley  
diego.ellissoto@berkeley.edu