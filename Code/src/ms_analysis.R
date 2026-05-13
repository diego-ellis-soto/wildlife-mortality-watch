# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
#
# Global, near real-time ecological forecasting of mortality events through participatory science
#
# Author: Diego Ellis Soto
# Department of Environmental Science Policy & Management, University of California, Berkeley, USA
# diego.ellissoto@berkeley.edu

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

library(tidyverse)
library(ggplot2)
library(scales)
library(forcats)
library(sf)
library(raster)
library(units)
library(tidycensus)
library(tigris)
library(mapview)
library(viridis)
library(cowplot)
library(patchwork)
library(gridExtra)
library(ggimage)
library(rnaturalearth)
library(rnaturalearthdata)
library(arrow)
library(treemapify)
library(tidygraph)
library(ggraph)
library(dplyr)
library(tibble)
library(ggimage)
library(ineq)
library(sp)
require(tigris)
library(mapview)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(scales)
library(forcats)
library(dplyr)
library(ggplot2)
library(scales)
library(stringr)
library(jsonlite)
library(dplyr)
library(tibble)
library(ggplot2)
library(scales)
library(stringr)
library(httr2)
library(jsonlite)
library(dplyr)
library(tibble)
library(scales)
library(glue)
library(httr2)
library(jsonlite)
library(dplyr)
library(tidyr)
library(tibble)
library(purrr)
library(ggplot2)
library(scales)
library(stringr)
library(glue)
library(forcats)
library(lubridate)
library(purrr)
library(tibble)
sf_use_s2(TRUE)  # geodesic distances in meters for lon/lat data
options(tigris_use_cache = TRUE)

# census_api_key('XXX', install = TRUE, overwrite = TRUE)


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Figure 2 California ####
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Download road data for counties in California
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

ca_counties <- tigris::counties(state = "CA", year = 2022)
county_names <- ca_counties$NAME

# Get roads from California
california_roads <- roads(state = "CA",county = county_names, year = 2022)

# Get the spatial boundary for California
california <- states(year = 2022) %>%
  filter(NAME == "California") %>%
  st_transform(3310)  # Keep in lat/lon (same as inat_sf)

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# read iNaturalist .csv downloaded from the app
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

inat <- read.csv('indir/resubmission_case_studies/California/California_mammals_inat_dead_filtered_2026-05-12.csv', 
                 stringsAsFactors = FALSE)

inat_sf <- inat %>%
  filter(!is.na(.data$location)) %>%
  separate(.data$location, into = c("latitude", "longitude"), sep = ",", convert = TRUE) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

# Reproject roads to EPSG:3310
california_roads_3310 <- st_transform(california_roads, 3310)

# Reproject inat points
inat_sf_3310 <- st_transform(inat_sf, 3310)

# Intersection:
inat_sf_3310_cali_only = inat_sf_3310 |> st_intersection(california)

# Convert sf object to a dataframe for ggplot binning
inat_df <- as.data.frame(st_coordinates(inat_sf_3310_cali_only))

# Hexbin visualization
sampling_across_cali = ggplot() +
  geom_sf(data = california, fill = "lightgray", color = "black") +  # Base California map
  stat_bin_hex(
    data = inat_df,
    aes(X, Y),
    bins = 50,  # Adjust for desired granularity
    color = "black",
    alpha = 0.8
  ) +
  scale_fill_viridis_c(option = "plasma", name = "Number of samples") +  # Color scale
  labs(
    title = "iNaturalist Observations in California (Hexbins)",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_minimal()+
  theme_classic() + ylab('Longitude') + xlab('Latitude') +
  theme(axis.text.x = element_text(face = "bold", size = 16 ,color='black'),
        axis.title.x = element_text(face = "bold", size = 16 ,color='black'),
        axis.text.y = element_text(face = "bold", size = 16 ,color='black'),
        axis.title.y = element_text(face = "bold", size = 16 ,color='black'))
ggsave(sampling_across_cali, file = 'outdir/resubmission_mortality_sampling_cali_v2.png')

# --- --- --- --- --- --- --- --- --- --- ---
# Distance to nearest road:
# --- --- --- --- --- --- --- --- --- --- ---

# For each point, get the index of the nearest road
nearest_idx <- st_nearest_feature(inat_sf_3310_cali_only, california_roads_3310)

# Extract geometry of the nearest roads
nearest_roads <- st_geometry(california_roads_3310)[nearest_idx]

# Calculate distance for each point to its nearest road (in meters)
inat_sf_3310_cali_only$dist_to_road_m <- st_distance(inat_sf_3310_cali_only, nearest_roads, by_element = TRUE)

# Ensure 0 has same unit as dist_to_road_m
inat_sf_3310_cali_only$dist_to_road_m = as.numeric(inat_sf_3310_cali_only$dist_to_road_m)

dist2road = ggplot(inat_sf_3310_cali_only, aes(x = (dist_to_road_m))) +
  geom_histogram(aes(y = ..density..), 
                 bins = 100, 
                 fill = "#0072B2", 
                 color = "black", 
                 alpha = 0.7) +
  # geom_density(color = "red") +  # Overlay density plot
  labs(
    #   title = "Density Histogram of Distance to Road",
    x = "Distance to \n Nearest Road km",
    y = "Density"
  ) +
  theme_classic() + ylab('Sampling density') + xlab('Distance to road in m') +
  theme(axis.text.x = element_text(face = "bold", size = 22 ,color='black'),
        axis.title.x = element_text(face = "bold", size = 22 ,color='black'),
        axis.text.y = element_text(face = "bold", size = 22 ,color='black'),
        axis.title.y = element_text(face = "bold", size = 22 ,color='black'))+ # +
  xlim( c(as.numeric(0), as.numeric(round(quantile(inat_sf_3310_cali_only$dist_to_road_m, 0.99)))  ) )+
  xlim(0, 500)
# theme(legend.position="none") # Remove legend

ggsave(dist2road, file = 'outdir/resubmission_dist2road_cali_v2.png')


# total number of records
n_total <- nrow(inat_sf_3310_cali_only)

# % within thresholds
pct_10m  <- mean(inat_sf_3310_cali_only$dist_to_road_m <= 10) * 100
pct_100m  <- mean(inat_sf_3310_cali_only$dist_to_road_m <= 100) * 100
pct_250m  <- mean(inat_sf_3310_cali_only$dist_to_road_m <= 250) * 100
pct_500m  <- mean(inat_sf_3310_cali_only$dist_to_road_m <= 500) * 100
pct_1000m <- mean(inat_sf_3310_cali_only$dist_to_road_m <= 1000) * 100
n_100m <- sum(inat_sf_3310_cali_only$dist_to_road_m <= 100)
quantile(inat_sf_3310_cali_only$dist_to_road_m, probs = c(0.25, 0.5, 0.75, 0.9))

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Human modification
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

human_mod_americas_masked = raster('indir/hmod_americas_masked.tif')


hmod_hist_cali = ggplot(inat_california_3310, aes(x = human_mod)) +
  geom_histogram(aes(y = ..density..), 
                 bins = 10, 
                 fill = "#0072B2", 
                 color = "black", 
                 alpha = 0.7) +
  # geom_density(color = "red") +  # Overlay density plot
  labs(
    #   title = "Density Histogram of Human Modification",
    x = "Human Landscape Modification",
    y = "Density"
  ) +
  theme_minimal()+ 
  theme(axis.text.x = element_text(face = "bold", size = 22 ,color='black'),
        axis.title.x = element_text(face = "bold", size = 22 ,color='black'),
        axis.text.y = element_text(face = "bold", size = 22 ,color='black'),
        axis.title.y = element_text(face = "bold", size = 22 ,color='black'))
ggsave(hmod_hist_cali, file = 'outdir/resubmission_hmod_hist_cali_cali_v2.png')

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Create a buffer around roads (e.g., 100 m)
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

road_buffer <- st_buffer(california_roads_3310, dist = 100)

# Get only iNaturalist points that intersect (i.e. are near) the road buffer
inat_california_3310_trans = st_transform(inat_california_3310, st_crs(road_buffer))
inat_near_roads <- st_intersection(inat_california_3310_trans, road_buffer)

# Convert the points to a data frame for plotting using hexbin
inat_near_df <- as.data.frame(st_coordinates(inat_near_roads))
# Rename columns to X and Y for consistency with ggplot aesthetics
colnames(inat_near_df) <- c("X", "Y")

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Hexbin visualization: iNaturalist mortality observations overlapping with road networks
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


hexbin_by_road <- ggplot(inat_near_roads, 
                         aes(x = st_coordinates(inat_near_roads)[,1], y = st_coordinates(inat_near_roads)[,2])) +
  stat_bin_hex(bins = 50, color = "black", alpha = 0.8) +
  facet_wrap(~ RTTYP) +
  scale_fill_viridis_c(option = "plasma", name = "Observation Count") +
  geom_sf(data = california, fill = NA, color = "gray40", inherit.aes = FALSE) +
  labs(
    title = "iNaturalist Mortality Observations Near Different Road Types",
    x = "Easting (m)",
    y = "Northing (m)"
  ) +
  theme_minimal()

ggsave(hexbin_by_road, filename = 'outdir/resubmission_hexbin_by_road_v2.png', width = 10, height = 8)
# Patchwork them together for Figure 2 of the MS:

years_keep <- 2022:2025

# Keep all taxonomic ranks
inat_top_taxa <- inat %>%
  mutate(
    year = as.integer(observed_on_details.year),
    taxon_label = taxon.name
  ) %>%
  filter(
    !is.na(taxon_label),
    !is.na(year),
    year %in% years_keep
  ) %>%
  count(taxon_label, year, name = "n")

# Top 20 taxa across all selected years
top20_taxa <- inat_top_taxa %>%
  group_by(taxon_label) %>%
  summarise(total_n = sum(n), .groups = "drop") %>%
  slice_max(total_n, n = 20, with_ties = FALSE)

# Fill in missing taxon-year combinations with 0
plot_df <- inat_top_taxa %>%
  semi_join(top20_taxa, by = "taxon_label") %>%
  complete(
    taxon_label,
    year = years_keep,
    fill = list(n = 0)
  ) %>%
  left_join(top20_taxa, by = "taxon_label") %>%
  mutate(
    year = factor(year, levels = years_keep),
    taxon_label = fct_reorder(taxon_label, total_n)
  )

# Plot
inat_top20_dead_plot <- ggplot(
  plot_df,
  aes(x = taxon_label, y = n, fill = year)
) +
  geom_col(
    position = position_dodge(width = 0.85),
    width = 0.75
  ) +
  coord_flip() +
  scale_fill_manual(
    values = c(
      "2022" = "#440154",
      "2023" = "#31688E",
      "2024" = "#35B779",
      "2025" = "#B8DE29"
    ),
    name = "Year"
  ) +
  labs(
    title = "Top 20 Taxa with Dead Wildlife Observations",
    x = "Taxon",
    y = "Number of dead wildlife observations"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    text = element_text(color = "black"),
    plot.title = element_text(face = "bold", hjust = 0.5, size = 18, color = "black"),
    axis.title.x = element_text(face = "bold", size = 16, color = "black"),
    axis.title.y = element_text(face = "bold", size = 16, color = "black"),
    axis.text.x = element_text(size = 15, color = "black"),
    axis.text.y = element_text(size = 14, color = "black"),
    legend.title = element_text(face = "bold", size = 13, color = "black"),
    legend.text = element_text(size = 16, color = "black"),
    panel.grid.major.y = element_blank(),
    legend.position = "right"
  )

inat_top20_dead_plot

ggsave(
  filename = "outdir/top20_taxa_dead_wildlife_observations_inat_v2.png",
  plot = inat_top20_dead_plot,
  width = 10,
  height = 5,
  dpi = 600
)


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Analysis 3 - Åfrica
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

animalia = read.csv('indir/resubmission_case_studies/Endangered_species/Africa_inat_dead_filtered_2026-05-12.csv')

table(animalia$taxon.conservation_status.status_name)

animalia |> filter(taxon.conservation_status.status_name == 'critically endangered') |>
  distinct(taxon.name)

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Figure 3 Puma ####
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

world <- ne_countries(scale = "medium", returnclass = "sf")
americas <- ne_countries(continent = c("South America", 'North America', 'Central America'))

puma = read.csv('indir/resubmission_case_studies/Puma/puma_case_study_2inat_dead_filtered_2026-05-12.csv',
                stringsAsFactors = FALSE)


puma_range <- st_read('indir/redlist_species_data_0df88387-092f-4347-a28b-a17db80c88bc/data_0.shp')

puma_inat <- puma %>% 
  filter(grepl("Puma concolor", taxon.name, ignore.case = TRUE))

# Convert to an sf object assuming the 'location' column holds "lat,lon"
puma_sf <- puma_inat %>%
  filter(!is.na(location)) %>%
  separate(location, into = c("latitude", "longitude"), sep = ",", convert = TRUE) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) |>
  mutate(year = year(time_observed_at))# WGS84


# Add a dummy column to puma_range for legend
puma_range$layer <- "Range Map"

bbox <- st_bbox(puma_sf)

# Expand by ~0.9 degrees (~100 km)
expand_deg <- 6

bbox_expanded <- bbox
bbox_expanded["xmin"] <- bbox["xmin"] - expand_deg
bbox_expanded["xmax"] <- bbox["xmax"] + expand_deg
bbox_expanded["ymin"] <- bbox["ymin"] - expand_deg
bbox_expanded["ymax"] <- bbox["ymax"] + expand_deg

# Create plot
puma_map <- ggplot() +
  # Light grey world background
  geom_sf(data = world, fill = "grey90", color = "white", size = 0.2) +
  
  # Puma range map with fill mapped to legend
  geom_sf(data = puma_range, aes(fill = layer), color = NA, alpha = 0.4) +
  scale_fill_manual(name = "", values = c("Range Map" = "goldenrod2")) +
  
  # Americas boundaries
  geom_sf(data = americas, fill = NA, color = "black", size = 0.5) +
  
  # Puma mortality points colored by year
  geom_sf(data = puma_sf, aes(color = year), size = 2) +
  scale_color_viridis_c(name = "Year", na.value = "darkgrey") +
  
  # Crop extent to points
  coord_sf(
    xlim = c(bbox_expanded["xmin"], bbox_expanded["xmax"]),
    ylim = c(bbox_expanded["ymin"], bbox_expanded["ymax"]),
    expand = FALSE
  )+
  # Labels and theme
  labs(
    #  title = expression("Political biogeography of "*italic("Puma concolor")*" mortalities"),
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 15, hjust = 0.5),
    axis.title = element_text(face = "bold", size = 15),
    legend.title = element_text(face = "bold")
  )+
  theme(
    plot.title = element_text(face = "bold", size = 13, hjust = 0.5),
    
    # Axis titles
    axis.title = element_text(face = "bold", size = 16),
    
    # Axis tick labels
    axis.text = element_text(face = "bold", size = 12),
    
    # Legend title
    legend.title = element_text(face = "bold", size = 14),
    
    # Legend text
    legend.text = element_text(face = "bold", size = 13),
    
    # Optional: transparent background
    plot.background = element_rect(fill = "transparent", color = NA),
    panel.background = element_rect(fill = "transparent", color = NA),
    legend.background = element_rect(fill = "transparent", color = NA),
    legend.box.background = element_rect(fill = "transparent", color = NA)
  )

puma_map

ggsave("outdir/resubmission_puma_map_highres_v2.png", plot = puma_map,
       width = 12, height = 10, units = "in", dpi = 1000, bg = "transparent")


# Now death by country:
world_countries <- ne_countries(scale = "medium", returnclass = "sf")

# Make sure both layers use the same CRS
puma_sf <- st_transform(puma_sf, crs = st_crs(world_countries))

# 1. Spatial join — run only once
puma_sf_with_country <- st_join(
  puma_sf,
  world_countries[, c("admin", "iso_a3")],
  left = TRUE
)

# 2. Hard-code unmatched point(s) to USA only if that is biologically/geographically correct
puma_sf_with_country <- puma_sf_with_country %>%
  mutate(
    admin  = if_else(is.na(admin), "United States of America", admin),
    iso_a3 = if_else(is.na(iso_a3), "USA", iso_a3)
  )

# 3. Count records by country
df <- puma_sf_with_country %>%
  st_drop_geometry() %>%
  count(country = admin, name = "count") %>%
  arrange(desc(count)) %>%
  as_tibble()

# 4. Recode France -> French Guiana if that is the intended geographic label
df <- df %>%
  mutate(
    country = if_else(country == "France", "French Guiana", country)
  )

# 5. Complete flag lookup
flag_lookup <- tibble(
  country = c(
    "Argentina", "Belize", "Brazil", "Canada", "Chile",
    "Colombia", "Costa Rica", "Ecuador", "French Guiana",
    "Mexico", "Paraguay", "United States of America", "Venezuela"
  ),
  code = c(
    "ar", "bz", "br", "ca", "cl",
    "co", "cr", "ec", "gf",
    "mx", "py", "us", "ve"
  )
)

# 6. Join lookup and create flag URL
df <- df %>%
  left_join(flag_lookup, by = "country") %>%
  mutate(
    flag = if_else(
      is.na(code),
      NA_character_,
      paste0("https://flagcdn.com/w40/", code, ".png")
    )
  )

# 7. Check unmatched countries before plotting
unmatched <- df %>% filter(is.na(code))
print(unmatched)

# 8. Create barplot
puma_death <- ggplot(df, aes(x = reorder(country, count), y = count)) +
  geom_col(fill = "grey") +
  geom_image(
    aes(y = count + 1, image = flag),
    size = 0.08,
    na.rm = TRUE
  ) +
  geom_text(
    aes(y = count + 5, label = count),
    size = 6,
    fontface = "bold",
    color = "black"
  ) +
  coord_flip() +
  labs(
    x = "Country",
    y = "Mortality Count",
    title = "Mountain Lion Deaths (2022–2026)"
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(face = "bold", size = 16, color = "black"),
    axis.text.y = element_text(face = "bold", size = 16, color = "black"),
    axis.title.x = element_text(face = "bold", size = 16, color = "black"),
    axis.title.y = element_text(face = "bold", size = 16, color = "black"),
    plot.title = element_text(face = "bold", size = 18, hjust = 0.5, color = "black")
  )

puma_death

ggsave(puma_death, file = "outdir/resubmission_puma_death.png", width = 10, height = 6, dpi = 600)


# Taxonomic breakdown of the parquet file ####
# =========================================================
# 1. READ ARCHIVE: Taxonomic breakdown ####
# =========================================================

parquet_path <- "https://huggingface.co/datasets/diegoellissoto/inat_observations-2026-04-21.parquet/resolve/main/inat_mortality_observations-2026-04-21.parquet?download=true"

inat_all_raw <- arrow::read_parquet(parquet_path)

inat_all <- inat_all_raw %>%
  collect()

# Top Panel Figure 1
records_by_year <- inat_all %>%
  mutate(
    year = year(as.Date(observed_on))
    # if observed_on is missing in your file, use:
    # year = year(as.POSIXct(time_observed_at))
  ) %>%
  filter(!is.na(year)) %>%
  count(year, name = "n_records")

growth_by_year_v2 = ggplot(records_by_year, aes(x = year, y = n_records)) +
  geom_col(
    fill = "darkolivegreen4",
    width = 0.85
  ) +
  scale_x_continuous(
    limits = c(2000, 2027),
    breaks = seq(2000, 2025, by = 5),
    expand = expansion(mult = c(0.01, 0.03))
  ) +
  scale_y_continuous(
    labels = label_comma(),
    expand = expansion(mult = c(0, 0.08))
  ) +
  labs(
    x = "Year",
    y = "Number of records"
  ) +
  theme_classic() +
  theme(
    axis.text.x = element_text(size = 28, color = "black"),
    axis.text.y = element_text(size = 28, color = "black"),
    
    axis.title.x = element_text(face = "bold", size = 28),
    axis.title.y = element_text(face = "bold", size = 28),
    
    plot.title = element_text(face = "bold", size = 28),
    
    axis.line = element_line(linewidth = 1),
    axis.ticks = element_line(linewidth = 1),
    axis.ticks.length = unit(0.25, "cm")
  )

growth_by_year_v2

ggsave(growth_by_year_v2, file = "outdir/fig1_top_left_v2.png", width = 10, height = 6, dpi = 600)


taxon_summary <- inat_all %>%
  transmute(
    iconic_taxon_name = na_if(`taxon.iconic_taxon_name`, ""),
    iconic_taxon_name = coalesce(iconic_taxon_name, "Unknown")
  ) %>%
  count(iconic_taxon_name, name = "n") %>%
  mutate(prop = n / sum(n)) %>%
  arrange(desc(n))


taxon_summary

inat_all <- inat_all %>%
  dplyr::mutate(
    broad_group = case_when(
      taxon.iconic_taxon_name %in% c("Mammalia", "Aves", "Reptilia", "Amphibia", "Actinopterygii") ~ "Vertebrates",
      taxon.iconic_taxon_name %in% c("Insecta", "Arachnida", "Mollusca") ~ "Invertebrates",
      TRUE ~ "Other"
    )
  )

# group_summary <- inat_all %>%
#   count(broad_group, taxon.iconic_taxon_name) %>%
#   group_by(broad_group) %>%
#   mutate(prop = n / sum(n))
# 
# taxa_counts <- inat_all %>%
#   count(taxon.iconic_taxon_name) %>%
#   pull(n)

inat_all <- inat_all %>%
  mutate(
    taxon.iconic_taxon_name = coalesce(taxon.iconic_taxon_name, "Unknown"),
    broad_group = case_when(
      taxon.iconic_taxon_name %in% c("Mammalia", "Aves", "Reptilia", "Amphibia", "Actinopterygii") ~ "Vertebrates",
      taxon.iconic_taxon_name %in% c("Insecta", "Arachnida", "Mollusca") ~ "Invertebrates",
      TRUE ~ "Other"
    )
  )
# 
# taxon_counts <- inat_all %>%
#   filter(!taxon.iconic_taxon_name %in% c("Unknown")) %>%
#   filter(!broad_group %in% c("Other")) %>%
#   count(broad_group, taxon.iconic_taxon_name, name = "n")
# 

plot_df <- inat_all %>%
  mutate(taxon.iconic_taxon_name = coalesce(taxon.iconic_taxon_name, "Unknown")) %>%
  filter(!taxon.iconic_taxon_name %in% c("Unknown", "Animalia")) %>%
  count(taxon.iconic_taxon_name, broad_group, name = "n") %>%
  mutate(prop = n / sum(n))


# starting totals
n_total <- nrow(inat_all)

# define what will be excluded from the plot
filtered_out_df <- inat_all %>%
  mutate(taxon.iconic_taxon_name = coalesce(taxon.iconic_taxon_name, "Unknown")) %>%
  filter(taxon.iconic_taxon_name %in% c("Unknown", "Animalia"))

n_filtered_out <- nrow(filtered_out_df)
prop_filtered_out <- n_filtered_out / n_total

n_total
n_filtered_out
prop_filtered_out

filtered_out_df <- inat_all %>%
  mutate(taxon.iconic_taxon_name = coalesce(taxon.iconic_taxon_name, "Unknown")) %>%
  filter(taxon.iconic_taxon_name %in% c("Unknown", "Animalia") | broad_group == "Other")

n_filtered_out <- nrow(filtered_out_df)
prop_filtered_out <- n_filtered_out / n_total


n_total <- nrow(inat_all)

plot_df <- inat_all %>%
  mutate(taxon.iconic_taxon_name = coalesce(taxon.iconic_taxon_name, "Unknown")) %>%
  filter(!taxon.iconic_taxon_name %in% c("Unknown", "Animalia")) %>%
  count(taxon.iconic_taxon_name, broad_group, name = "n") %>%
  mutate(prop = n / n_total)


taxon_comp_loliplot <- ggplot(
  plot_df,
  aes(x = fct_reorder(taxon.iconic_taxon_name, prop),
      y = prop,
      color = broad_group)
) +
  geom_segment(
    aes(xend = taxon.iconic_taxon_name, y = 0, yend = prop),
    linewidth = 1, alpha = 0.7
  ) +
  geom_point(size = 6) +
  geom_text(
    aes(label = scales::percent(prop, accuracy = 0.1)),
    hjust = -0.25,
    size = 4
  ) +
  coord_flip() +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 1),
    expand = expansion(mult = c(0, 0.12))
  ) +
  scale_color_viridis_d(option = "E", end = 0.85) +
  labs(
    x = NULL,
    y = "Percentage of archive",
    color = "Major group",
    title = "Taxonomic composition of mortality records"
  ) +
  theme_classic() +
  theme(
    plot.title = element_text(face = "bold", size = 18),
    axis.text = element_text(size = 14, color = "black"),
    axis.title = element_text(face = "bold", size = 14)
  )


ggsave(taxon_comp_loliplot, file = 'outdir/resubmission_parquet_taxon_composition_viridis.png')


taxon_comp_loliplot_v2 = ggplot(
  plot_df,
  aes(x = fct_reorder(taxon.iconic_taxon_name, n),
      y = n,
      color = broad_group)
) +
  geom_segment(
    aes(xend = taxon.iconic_taxon_name, y = 0, yend = n),
    linewidth = 5, alpha = 0.7   # thicker sticks
  ) +
  geom_point(size = 18) +            # bigger dots
  coord_flip() +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.12))
  ) +
  scale_color_viridis_d(option = "E", end = 0.85) +
  labs(
    x = NULL,
    y = "Number of records",
    color = "Major group"
  ) +
  theme_classic() +
  theme(
    plot.title = element_text(face = "bold", size = 36),
    axis.text.x = element_text(size = 36, color = "black"),
    axis.text.y = element_text(size = 42, color = "black"),
    axis.title.x = element_text(face = "bold", size = 36),
    legend.position = c(0.65, 0.48),
    legend.justification = c(0, 0.5),
    legend.title = element_text(size = 42, face = "bold"),
    legend.text  = element_text(size = ),
    legend.key.size = unit(0.8, "cm"),
    legend.background = element_rect(
      fill = scales::alpha("white", 0.8),
      colour = NA
    )
  )


ggsave(taxon_comp_loliplot_v2, file = 'outdir/resubmission_parquet_taxon_composition_viridis_v2.png')

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Africa endangered species March 2026:
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

inat <- read.csv('indir/resubmission_case_studies/Endangered_species/Africa_inat_dead_filtered_2026-05-12.csv', 
                 stringsAsFactors = FALSE)

table(inat$taxon.conservation_status.status)


# ---------------------------------------------------
#  Load mortality data directly from iNaturalist API to get estimates
# about how much data we are talking about
# ---------------------------------------------------

api_url <- "https://api.inaturalist.org/v1/observations/iconic_taxa_counts?term_id=17&term_value_id=19"

cat("\nLoading data from iNaturalist API...\n")
json_file <- fromJSON(api_url, flatten = TRUE)

# ---------------------------------------------------
# 2. Make full dataframe BEFORE filtering
# ---------------------------------------------------

mortality_all <- json_file$results %>%
  transmute(
    common_name = taxon.preferred_common_name,
    taxon_name = taxon.name,
    taxon_id = taxon_id,
    dead_records = count
  ) %>%
  mutate(
    common_name = ifelse(is.na(common_name), taxon_name, common_name)
  ) %>%
  arrange(desc(dead_records))

cat("\nAll categories returned by API:\n")
print(mortality_all)

cat("\nTotal mortality records BEFORE filtering:\n")
print(sum(mortality_all$dead_records, na.rm = TRUE))

# ---------------------------------------------------
# 3. Define selected categories
# ---------------------------------------------------

keep_categories <- c(
  "Insects",
  "Molluscs",
  "Mammals",
  "Birds",
  "Reptiles",
  "Ray-finned Fishes",
  "Amphibians",
  "Arachnids"
)

excluded_categories <- mortality_all %>%
  filter(!common_name %in% keep_categories)

cat("\nCategories EXCLUDED by keep_categories filter:\n")
print(excluded_categories)

cat("\nTotal mortality records EXCLUDED:\n")
print(sum(excluded_categories$dead_records, na.rm = TRUE))

# ---------------------------------------------------
# 4. Filtered dataframe: selected categories only
# ---------------------------------------------------

plot_df <- mortality_all %>%
  filter(common_name %in% keep_categories) %>%
  mutate(
    major_group = case_when(
      common_name %in% c("Insects", "Molluscs", "Arachnids") ~ "Invertebrates",
      common_name %in% c("Mammals", "Birds", "Reptiles",
                         "Ray-finned Fishes", "Amphibians") ~ "Vertebrates",
      TRUE ~ "Other"
    ),
    common_name = factor(common_name, levels = rev(common_name))
  )

cat("\nTotal mortality records AFTER filtering:\n")
print(sum(plot_df$dead_records, na.rm = TRUE))


plot_df_clean <- plot_df %>%
  mutate(
    major_group = str_remove(major_group, "^[ab]\\s*")
  )

p_count_kept <- ggplot(
  plot_df_clean,
  aes(x = dead_records, y = common_name, color = major_group)
) +
  geom_segment(
    aes(x = 0, xend = dead_records, y = common_name, yend = common_name),
    linewidth = 1.8,
    alpha = 0.7
  ) +
  geom_point(size = 10) +
  scale_x_continuous(
    labels = comma,
    limits = c(0, max(plot_df_clean$dead_records, na.rm = TRUE) * 1.10),
    expand = expansion(mult = c(0, 0.02))
  ) +
  scale_color_manual(
    values = c(
      "Invertebrates" = "#0b2c66",
      "Vertebrates"   = "#d4bf57",
      "Other"         = "grey50"
    )
  ) +
  labs(
    title = "Taxonomic composition of mortality records",
    x = "Number of mortality records",
    y = NULL,
    color = "Major group"
  ) +
  theme_classic(base_size = 18) +
  theme(
    plot.title = element_text(size = 28, face = "bold", hjust = 0.5),
    axis.title.x = element_text(size = 22, face = "bold"),
    axis.text.x = element_text(size = 18),
    axis.text.y = element_text(size = 22),
    legend.title = element_text(size = 20),
    legend.text = element_text(size = 18),
    legend.position = "right"
  )

# ---------------------------------------------------
# 1. Choose whether to count by upload year or observed year
# ---------------------------------------------------

date_field <- "created"   # "created" = stored/added to iNat
# date_field <- "observed" # "observed" = date organism was observed

api_url <- paste0(
  "https://api.inaturalist.org/v1/observations/histogram?",
  "term_id=17&term_value_id=19",
  "&date_field=", date_field,
  "&interval=year"
)

cat("\nAPI URL:\n")
cat(api_url, "\n\n")

json_file <- fromJSON(api_url, flatten = TRUE)

# ---------------------------------------------------
# 2. Convert histogram JSON into a dataframe
# ---------------------------------------------------

mortality_by_year <- enframe(
  unlist(json_file$results$year),
  name = "year_raw",
  value = "mortality_records"
) %>%
  mutate(
    year = as.integer(str_extract(year_raw, "^\\d{4}")),
    mortality_records = as.numeric(mortality_records)
  ) %>%
  select(year, mortality_records) %>%
  arrange(year)

cat("\nMortality records per year:\n")
print(mortality_by_year)

cat("\nTotal mortality records across all years:\n")
print(sum(mortality_by_year$mortality_records, na.rm = TRUE))

inat_green <- "#74AC00"


# p_year <- ggplot(mortality_by_year, aes(x = year, y = mortality_records)) +
#   # geom_col(width = 0.8) +
#   geom_col(
#     width = 0.8,
#     fill = inat_green,
#     colour = inat_green,
#     linewidth = 0.3
#   )+
#   scale_y_continuous(labels = comma) +
#   scale_x_continuous(
#     breaks = pretty_breaks(),
#     labels = function(x) as.integer(x)
#   ) +
#   labs(
#     title = "iNaturalist mortality records per year",
#     #  subtitle = paste("Date field:", date_field),
#     x = "Year",
#     y = "Number of mortality records"
#   ) +
#   theme_classic(base_size = 16) +
#   theme(
#     plot.title = element_text(face = "bold"),
#     axis.title = element_text(face = "bold")
#   )
# 
# p_year
# 
# 
# ggsave(
#   "outdir/inat_mortality_records_per_year.png",
#   p_year,
#   width = 10,
#   height = 6,
#   dpi = 300
# )



# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Percent dead or alive
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

# ------------------------------------------------------------
# Core API helper
# ------------------------------------------------------------

inat_api <- "https://api.inaturalist.org/v1"

get_total_results <- function(endpoint, params = list()) {
  req <- request(paste0(inat_api, endpoint)) |>
    req_user_agent("iNat mortality summary R script")
  
  req <- do.call(req_url_query, c(list(req), params))
  
  resp <- req |>
    req_retry(max_tries = 3) |>
    req_perform()
  
  out <- resp_body_json(resp, simplifyVector = TRUE)
  
  out$total_results
}

# ------------------------------------------------------------
# Annotation IDs
# ------------------------------------------------------------
# iNaturalist controlled terms:
# Alive or Dead = term_id 17
# Alive = term_value_id 18
# Dead = term_value_id 19
# Cannot Be Determined = term_value_id 20

alive_dead_term <- 17
alive_value <- 18
dead_value <- 19
cannot_determine_value <- 20

animalia_taxon_id <- 1

# ------------------------------------------------------------
# Shared parameters
# ------------------------------------------------------------
# verifiable = "any" avoids silently restricting counts to only
# verifiable observations.

base_params <- list(
  per_page = 0,
  verifiable = "any"
)

dead_params <- c(
  base_params,
  list(
    term_id = alive_dead_term,
    term_value_id = dead_value
  )
)

alive_params <- c(
  base_params,
  list(
    term_id = alive_dead_term,
    term_value_id = alive_value
  )
)

cannot_determine_params <- c(
  base_params,
  list(
    term_id = alive_dead_term,
    term_value_id = cannot_determine_value
  )
)

animalia_params <- c(
  base_params,
  list(taxon_id = animalia_taxon_id)
)

dead_animalia_params <- c(
  dead_params,
  list(taxon_id = animalia_taxon_id)
)

# ------------------------------------------------------------
# API calls
# ------------------------------------------------------------

query_date <- Sys.Date()

total_observations <- get_total_results(
  endpoint = "/observations",
  params = base_params
)

animalia_observations <- get_total_results(
  endpoint = "/observations",
  params = animalia_params
)

dead_observations <- get_total_results(
  endpoint = "/observations",
  params = dead_params
)

dead_animalia_observations <- get_total_results(
  endpoint = "/observations",
  params = dead_animalia_params
)

alive_observations <- get_total_results(
  endpoint = "/observations",
  params = alive_params
)

cannot_determine_observations <- get_total_results(
  endpoint = "/observations",
  params = cannot_determine_params
)

dead_species <- get_total_results(
  endpoint = "/observations/species_counts",
  params = dead_params
)

dead_observers <- get_total_results(
  endpoint = "/observations/observers",
  params = dead_params
)

dead_identifiers <- get_total_results(
  endpoint = "/observations/identifiers",
  params = dead_params
)

summary_df <- tibble(
  query_date = query_date,
  total_observations = total_observations,
  animalia_observations = animalia_observations,
  dead_observations = dead_observations,
  dead_animalia_observations = dead_animalia_observations,
  alive_observations = alive_observations,
  cannot_determine_observations = cannot_determine_observations,
  alive_or_dead_annotated_observations = alive_observations + dead_observations,
  alive_dead_or_uncertain_annotated_observations =
    alive_observations + dead_observations + cannot_determine_observations,
  dead_species = dead_species,
  dead_observers = dead_observers,
  dead_identifiers = dead_identifiers
) |>
  mutate(
    pct_dead_of_all_inat =
      dead_observations / total_observations,
    pct_dead_of_animalia =
      dead_animalia_observations / animalia_observations,
    pct_dead_of_alive_or_dead_annotated =
      dead_observations / alive_or_dead_annotated_observations,
    pct_dead_of_alive_dead_or_uncertain_annotated =
      dead_observations / alive_dead_or_uncertain_annotated_observations
  )

summary_df

paper_sentence <- glue_data(
  summary_df,
  "As of {format(query_date, '%B %d, %Y')}, iNaturalist contained ",
  "{comma(total_observations)} total observations, including ",
  "{comma(animalia_observations)} Animalia observations. ",
  "There were {comma(dead_observations)} observations annotated as 'dead' ",
  "for {comma(dead_species)} species, representing ",
  "{percent(pct_dead_of_all_inat, accuracy = 0.01)} of all iNaturalist observations and ",
  "{percent(pct_dead_of_animalia, accuracy = 0.01)} of Animalia observations. "
)

cat(paper_sentence)

inat_api <- "https://api.inaturalist.org/v1"

inat_green <- "#74AC00"
inat_dark <- "#4D7C00"

# Colorblind-friendly palette for taxa
taxon_cols <- c(
  "Insects" = "#009E73",
  "Molluscs" = "#56B4E9",
  "Mammals" = "#0072B2",
  "Birds" = "#E69F00",
  "Reptiles" = "#CC79A7",
  "Ray-finned Fishes" = "#8A5FD3",
  "Amphibians" = "#D55E00",
  "Arachnids" = "#7F7F7F"
)

inat_get <- function(endpoint, params = list()) {
  req <- request(paste0(inat_api, endpoint)) |>
    req_user_agent("iNat mortality figures R script")
  
  req <- do.call(req_url_query, c(list(req), params))
  
  resp <- req |>
    req_retry(max_tries = 3) |>
    req_perform()
  
  resp_body_json(resp, simplifyVector = TRUE)
}

get_total_results <- function(endpoint, params = list()) {
  out <- inat_get(endpoint, params)
  out$total_results
}

get_year_histogram <- function(params, value_name) {
  out <- inat_get("/observations/histogram", params)
  
  enframe(
    unlist(out$results$year),
    name = "year_raw",
    value = value_name
  ) |>
    mutate(year = as.integer(str_extract(year_raw, "^\\d{4}"))) |>
    select(year, all_of(value_name)) |>
    arrange(year)
}


dead_by_year <- get_year_histogram(
  params = list(
    term_id = 17,
    term_value_id = 19,
    taxon_id = 1,            # Animalia
    date_field = "created",
    interval = "year",
    verifiable = "any"
  ),
  value_name = "dead_records"
)

animalia_by_year <- get_year_histogram(
  params = list(
    taxon_id = 1,            # Animalia
    date_field = "created",
    interval = "year",
    verifiable = "any"
  ),
  value_name = "animalia_records"
)

rate_df <- dead_by_year |>
  left_join(animalia_by_year, by = "year") |>
  mutate(
    dead_per_100k_animalia = dead_records / animalia_records * 100000,
    current_year = year == max(year)
  )

p_rate <- ggplot(rate_df, aes(x = year, y = dead_per_100k_animalia)) +
  geom_col(
    aes(alpha = current_year),
    fill = inat_green,
    colour = inat_dark,
    width = 0.8
  ) +
  #  geom_smooth()+
  scale_alpha_manual(values = c("FALSE" = 1, "TRUE" = 0.5), guide = "none") +
  scale_y_continuous(labels = comma) +
  scale_x_continuous(breaks = pretty_breaks()) +
  labs(
    title = "Mortality records relative to Animalia",
    # subtitle = "Dead-annotated observations ",
    x = "Year added to iNaturalist",
    y = "Dead-annotated observations \n per 100,000 Animalia observations"
  ) +
  theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold")
  )+xlim(2007, 2027)

p_rate

ggsave(
  "outdir/relative__mortality_records_per_year.png",
  p_rate,
  width = 10,
  height = 6,
  dpi = 300
)

taxa <- tribble(
  ~common_name, ~taxon_id,
  "Insects", 47158,
  "Molluscs", 47115,
  "Mammals", 40151,
  "Birds", 3,
  "Reptiles", 26036,
  "Ray-finned Fishes", 47178,
  "Amphibians", 20978,
  "Arachnids", 47119
)

taxon_year <- taxa |>
  mutate(
    data = map2(common_name, taxon_id, \(nm, tx) {
      get_year_histogram(
        params = list(
          term_id = 17,
          term_value_id = 19,
          taxon_id = tx,
          date_field = "created",
          interval = "year",
          verifiable = "any"
        ),
        value_name = "dead_records"
      ) |>
        mutate(common_name = nm)
    })
  ) |>
  select(data) |>
  unnest(data)

taxon_year_prop <- taxon_year |>
  group_by(year) |>
  mutate(
    total_year = sum(dead_records, na.rm = TRUE),
    proportion = dead_records / total_year
  ) |>
  ungroup()

p_taxon <- ggplot(taxon_year_prop, aes(x = factor(year), y = proportion, fill = common_name)) +
  geom_col(width = 0.9, colour = "white", linewidth = 0.15) +
  scale_y_continuous(labels = percent_format()) +
  scale_fill_manual(values = taxon_cols) +
  labs(
    title = "Taxonomic composition of iNaturalist mortality records through time",
    # subtitle = "Annual proportional composition of dead-annotated records",
    x = "Year added to iNaturalist",
    y = "Share of annual dead-annotated records",
    fill = "Taxon"
  ) +
  theme_classic(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

p_taxon

ggsave(
  "outdir/relative__mortality_by_taxon_per_year.png",
  p_taxon,
  width = 10,
  height = 6,
  dpi = 300
)

require(patchwork)
Suppl_Fig_1 = p_rate / p_taxon
ggsave(
  "outdir/suppl_fig_v2.png",
  Suppl_Fig_1,
  width = 10,
  height = 10,
  dpi = 300
)




# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Check for pptential duplicates: same person may have seen the same dead puma again ####
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

# ---- Parameters ----
dist_threshold_m <- 2000
time_threshold_days <- 7

# ---- Add row IDs, coordinates, parsed dates ----
puma_check <- puma_sf %>%
  mutate(
    obs_row = row_number(),
    obs_datetime = parse_date_time(
      time_observed_at,
      orders = c("ymd HMS z", "ymd HMS", "ymd HM z", "ymd HM", "ymd")
    ),
    obs_date = as.Date(obs_datetime)
  )

coords <- st_coordinates(puma_check)

puma_check <- puma_check %>%
  mutate(
    lon = coords[, 1],
    lat = coords[, 2]
  )

# ---- Try to identify observer column automatically ----
observer_candidates <- c(
  "user.login", "user_login", "user.id", "user_id",
  "observer", "observer_id", "login"
)

observer_col <- observer_candidates[observer_candidates %in% names(puma_check)][1]

if (is.na(observer_col)) {
  warning("No observer/user column found. Duplicate check will ignore observer identity.")
  puma_check$observer_key <- NA_character_
} else {
  puma_check$observer_key <- as.character(puma_check[[observer_col]])
}

# ---- Optional: check exact duplicated iNaturalist IDs, if an ID column exists ----
id_candidates <- c("id", "observation.id", "observation_id", "uuid")
id_col <- id_candidates[id_candidates %in% names(puma_check)][1]

if (!is.na(id_col)) {
  exact_id_duplicates <- puma_check %>%
    st_drop_geometry() %>%
    count(.data[[id_col]], name = "n") %>%
    filter(!is.na(.data[[id_col]]), n > 1)
  
  print(exact_id_duplicates)
} else {
  message("No obvious observation ID column found.")
}

# ---- Spatial prefilter: all pairs within 2 km ----
near_list <- st_is_within_distance(
  puma_check,
  puma_check,
  dist = dist_threshold_m
)

near_pairs <- tibble(
  i = rep(seq_along(near_list), lengths(near_list)),
  j = unlist(near_list)
) %>%
  filter(i < j)

# ---- Calculate pairwise distance and time difference ----
candidate_pairs <- near_pairs %>%
  mutate(
    obs_row_1 = puma_check$obs_row[i],
    obs_row_2 = puma_check$obs_row[j],
    
    id_1 = if (!is.na(id_col)) as.character(puma_check[[id_col]][i]) else NA_character_,
    id_2 = if (!is.na(id_col)) as.character(puma_check[[id_col]][j]) else NA_character_,
    
    observer_1 = puma_check$observer_key[i],
    observer_2 = puma_check$observer_key[j],
    
    same_observer = observer_1 == observer_2,
    
    date_1 = puma_check$obs_datetime[i],
    date_2 = puma_check$obs_datetime[j],
    
    days_apart = abs(as.numeric(difftime(date_1, date_2, units = "days"))),
    
    distance_m = map2_dbl(
      i, j,
      ~ as.numeric(st_distance(puma_check[.x, ], puma_check[.y, ], by_element = TRUE))
    ),
    
    lon_1 = puma_check$lon[i],
    lat_1 = puma_check$lat[i],
    lon_2 = puma_check$lon[j],
    lat_2 = puma_check$lat[j]
  )

# ---- Strict likely duplicates: same observer, <= 2 km, <= 7 days ----
likely_duplicate_pairs <- candidate_pairs %>%
  filter(
    same_observer,
    !is.na(days_apart),
    days_apart <= time_threshold_days,
    distance_m <= dist_threshold_m
  ) %>%
  arrange(observer_1, days_apart, distance_m)

# ---- Broader suspicious pairs: ignore observer identity ----
spatiotemporal_pairs_any_observer <- candidate_pairs %>%
  filter(
    !is.na(days_apart),
    days_apart <= time_threshold_days,
    distance_m <= dist_threshold_m
  ) %>%
  arrange(days_apart, distance_m)

# View results
likely_duplicate_pairs
spatiotemporal_pairs_any_observer

suspicious_rows <- unique(c(
  spatiotemporal_pairs_any_observer$obs_row_1,
  spatiotemporal_pairs_any_observer$obs_row_2
))

suspicious_records <- puma_check %>%
  filter(obs_row %in% suspicious_rows) %>%
  arrange(obs_datetime) %>%
  st_drop_geometry() %>%
  select(
    obs_row,
    any_of(c(
      "id", "uuid", "uri",
      "user.login", "user.id",
      "observer_key",
      "time_observed_at", "observed_on", "created_at",
      "taxon.name", "species_guess",
      "location", "lat", "lon",
      "place_guess",
      "description",
      "positional_accuracy",
      "public_positional_accuracy",
      "taxon_geoprivacy",
      "geoprivacy",
      "quality_grade",
      "comments_count",
      "identifications_count"
    ))
  )

puma_pair_points <- puma_check %>%
  filter(obs_row %in% suspicious_rows) %>%
  mutate(
    review_group = case_when(
      obs_row %in% likely_dup_rows ~ "same observer, <=2 km, <=7 days",
      TRUE ~ "any observer, <=2 km, <=7 days"
    ),
    label = paste0(
      "obs_row: ", obs_row,
      "<br>id: ", id,
      "<br>observer: ", observer_key,
      "<br>date: ", time_observed_at
    )
  )

mapview(
  puma_pair_points,
  zcol = "review_group"
)

# https://gis.stackexchange.com/questions/119993/convert-line-shapefile-to-raster-value-total-length-of-lines-within-cell
# https://catalog.data.gov/dataset/enviroatlas-road-density-metrics-by-12-digit-huc-for-the-conterminous-united-states3
