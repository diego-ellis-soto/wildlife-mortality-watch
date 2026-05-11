---
title: Wildlife Mortality Watch
emoji: 🐾
colorFrom: green
colorTo: blue
sdk: docker
app_port: 7860
pinned: false
license: bsd-2-clause
---

# Wildlife Mortality Watch

**Wildlife Mortality Watch** is an independent Shiny application for querying, visualizing, and summarizing wildlife mortality records from iNaturalist.

The app supports near-real-time live queries through the iNaturalist API and broader retrospective analyses using a precompiled Parquet archive of mortality-annotated observations.

## What the app does

- Queries mortality records by taxon, date range, and spatial extent
- Supports spatial queries from bounding boxes, uploaded study areas, or iNaturalist Places
- Visualizes mortality records through interactive maps, temporal summaries, and taxonomic summaries
- Allows users to inspect individual records with associated metadata and images
- Provides downloadable results and query metadata for reproducibility

## Spatial query options

Users can define spatial extent using:

1. a drawn bounding box,
2. an uploaded spatial file, or
3. an iNaturalist Place, enabling queries for named geographies such as cities, national parks, species ranges, or administrative jurisdictions.

## Data source

Mortality records are retrieved from public iNaturalist observations annotated as dead. Live queries use the iNaturalist API, while large-scale retrospective analyses can use a precompiled Parquet archive for faster performance.

## Disclaimer

Wildlife Mortality Watch is an independent research tool and is not affiliated with or endorsed by iNaturalist. Observation data and media remain subject to their original iNaturalist user licenses.