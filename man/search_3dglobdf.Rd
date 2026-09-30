library(gloBFPr)
library(sf)

# Load your study area boundary
study_area <- st_read("https://geo.datav.aliyun.com/areas_v3/bound/500000_full.json")

# Filter to the nine central districts
central_districts <- c("渝中区", "江北区", "南岸区", "沙坪坝区", 
                       "九龙坡区", "大渡口区", "北碚区", "渝北区", "巴南区")

# Assuming the GeoJSON has a 'name' column with district names
study_area_9 <- study_area[study_area$name %in% central_districts, ]

# Get bounding box from the study area
bbox_9 <- st_bbox(study_area_9)
print(bbox_9)

# Download buildings using the bounding box
buildings_cq <- search_3dglobdf(
  bbox = as.numeric(bbox_9),  # Convert bbox to numeric vector
  crop = TRUE,
  data_source = "GBF",
  keep_source_id = TRUE,
  out_type = "poly",
  quiet = FALSE
)

# Clip precisely to the nine districts
buildings_cq_final <- st_intersection(buildings_cq, study_area_9)

# Save
st_write(buildings_cq_final, "chongqing_9districts_buildings.gpkg",
         driver = "GPKG", delete_dsn = TRUE)

# Report
cat("Downloaded", nrow(buildings_cq_final), "buildings\n")
cat("Total footprint area:", sum(st_area(buildings_cq_final)) / 1e6, "km²\n")
