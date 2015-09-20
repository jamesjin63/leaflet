library(leaflet)
# https://rstudio.github.io/leaflet/map_widget.html

m <- leaflet() %>%
        addTiles() %>%  # Add default OpenStreetMap map tiles
        addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")
m  # Print the map

install.packages("jsonlite")

# example
df = data.frame(Lat = 1:10, Long = rnorm(10))
leaflet() %>% addCircles(data = df, lat = ~ Lat, lng = ~ Long)

# example
library(maps)
mapStates = map("state", fill = TRUE, plot = FALSE)
leaflet(data = mapStates) %>% addTiles() %>%
        addPolygons(fillColor = topo.colors(10, alpha = NULL), stroke = FALSE)

# example
df <- data.frame(
        lat = rnorm(100),
        lng = rnorm(100),
        size = runif(100, 5, 20),
        color = sample(colors(), 100)
)
m <- leaflet(df) %>% addTiles()
m <- leaflet(df) %>% 
        addTiles() %>%
        addCircleMarkers(radius = ~size, color = ~color, fill = FALSE)
m %>% addCircleMarkers(radius = runif(100, 4, 10), color = c('red'))

# example
# see here for provider tiles: http://leaflet-extras.github.io/leaflet-providers/preview/index.html
m <- leaflet() %>% setView(lng = -71.0589, lat = 42.3601, zoom = 12)
m %>% addTiles()

m %>% addProviderTiles("Stamen.Toner")
m %>% addProviderTiles("Stamen.Watercolor")
m %>% addProviderTiles("NASAGIBS.ViirsEarthAtNight2012")

# cirlces example
df <- read.csv("datafile_20150827.csv", stringsAsFactors = FALSE)
names(df)[38] <- "lng"
df1 <- df[1:5, ]
df1$radius <- c(10, 20, 30, 40, 50)

m <- leaflet(df1) %>%
        addTiles() %>%
        addCircleMarkers(radius = ~radius, color = c("red"))
m

# markers example
m <- leaflet(df1) %>%
        addTiles() %>%
        addMarkers(lat = ~lat, lng = ~lng, popup = ~EDA.Program)
m

# custom markers example for very few specified options
greenLeafIcon <- makeIcon(
        iconUrl = "http://leafletjs.com/docs/images/leaf-green.png",
        iconWidth = 38, iconHeight = 95,
        iconAnchorX = 22, iconAnchorY = 94,
        shadowUrl = "http://leafletjs.com/docs/images/leaf-shadow.png",
        shadowWidth = 50, shadowHeight = 64,
        shadowAnchorX = 4, shadowAnchorY = 62
)

leaflet(data = quakes[1:4,]) %>% addTiles() %>%
        addMarkers(~long, ~lat, icon = greenLeafIcon)

# personal test with different icon url
google_icon <- makeIcon(
        iconUrl = "http://chart.googleapis.com/chart?chst=d_map_pin_letter&chld=%7c5680FC%7c000000&.png"
)

leaflet(data = quakes[1:4,]) %>% addTiles() %>%
        addMarkers(~long, ~lat, icon = google_icon)



# custom markers example using ifelse logic for few options 
quakes1 <- quakes[1:10,]

leafIcons <- icons(
        iconUrl = ifelse(quakes1$mag < 4.6,
                         "http://leafletjs.com/docs/images/leaf-green.png",
                         "http://leafletjs.com/docs/images/leaf-red.png"
        ),
        iconWidth = 38, iconHeight = 95,
        iconAnchorX = 22, iconAnchorY = 94,
        shadowUrl = "http://leafletjs.com/docs/images/leaf-shadow.png",
        shadowWidth = 50, shadowHeight = 64,
        shadowAnchorX = 4, shadowAnchorY = 62
)

leaflet(data = quakes1) %>% addTiles() %>%
        addMarkers(~long, ~lat, icon = leafIcons)

# customized marker example using marker lookup tables for many options
# Make a list of icons. We'll index into it based on name.
oceanIcons <- iconList(
        ship = makeIcon("ferry.png"),
        pirate = makeIcon("watercraft.png")
)

# Some fake data
df <- sp::SpatialPointsDataFrame(
        cbind(
                (runif(20) - .5) * 10 - 90.620130,  # lng
                (runif(20) - .5) * 3.8 + 25.638077  # lat
        ),
        data.frame(type = factor(
                ifelse(runif(20) > 0.75, "pirate", "ship"),
                c("ship", "pirate")
        ))
)

leaflet(df) %>% addTiles() %>%
        # Select from oceanIcons based on df$type
        addMarkers(icon = ~oceanIcons[type])

# same example adding in cluster options instead of custom markers
leaflet(df) %>% addTiles() %>%
        addMarkers(clusterOptions = markerClusterOptions())

# example Create a palette that maps factor levels to colors
pal <- colorFactor(c("navy", "red"), domain = c("ship", "pirate"))

leaflet(df) %>% addTiles() %>%
        addCircleMarkers(
                radius = ~ifelse(type == "ship", 6, 10),
                color = ~pal(type),
                stroke = FALSE, fillOpacity = 0.5
        )

# example - add free-floating pop-ups
content <- paste(sep = "<br/>",
                 "<b><a href='http://www.samurainoodle.com'>Samurai Noodle</a></b>",
                 "606 5th Ave. S",
                 "Seattle, WA 98138"
)

leaflet() %>% addTiles() %>%
        addPopups(-122.327298, 47.597131, content,
                  options = popupOptions(closeButton = FALSE)
        )

# example - spatial polygons with census shape file
install.packages("rgeos")
library(rgdal)
library(ggplot2)
library(rgeos)

library(rgdal)
library(maptools)
if (!require(gpclib)) install.packages("gpclib", type="source")
gpclibPermit()

# http://stackoverflow.com/questions/30790036/error-istruegpclibpermitstatus-is-not-true

# From https://www.census.gov/geo/maps-data/data/cbf/cbf_state.html
# first argument in readOGR is just the file path
# can also use dsn = ".", if the working directory is set to file with shapefiles
states <- readOGR("shp/cb_2014_us_state_20m.shp",
                  layer = "cb_2014_us_state_20m", verbose = FALSE)

# to find variable name to use
names(states)

neStates <- subset(states, states$STUSPS %in% c(
        "CT","ME","MA","NH","RI","VT","NY","NJ","PA"
))

leaflet(neStates) %>%
        addPolygons(
                stroke = FALSE, fillOpacity = 0.5, smoothFactor = 0.5,
                color = ~colorQuantile("YlOrRd", states$AWATER)(AWATER)
        )

# to fortify as a dataframe for viewing or use with other non-leaflet programs
states2 <- fortify(states, region = "GEOID")


# add fixed-size circles to map
cities <- read.csv(textConnection("
City,Lat,Long,Pop
                                  Boston,42.3601,-71.0589,645966
                                  Hartford,41.7627,-72.6743,125017
                                  New York City,40.7127,-74.0059,8406000
                                  Philadelphia,39.9500,-75.1667,1553000
                                  Pittsburgh,40.4397,-79.9764,305841
                                  Providence,41.8236,-71.4222,177994
                                  "))

leaflet(cities) %>% addTiles() %>%
        addCircles(lng = ~Long, lat = ~Lat, weight = 1,
                   radius = ~sqrt(Pop) * 30, popup = ~City
        )

# colors
library(rgdal)

# From http://data.okfn.org/data/datasets/geo-boundaries-world-110m
countries <- readOGR("json/countries.geojson", "OGRGeoJSON")
map <- leaflet(countries)

names(countries)
head(countries$gdp_md_est)
head(countries$geounit)

# Create a continuous palette function using color scheme from color Brewer
pal <- colorNumeric(
        palette = "Blues",
        domain = countries$gdp_md_est
)

# Apply the function to provide RGB colors to addPolygons
map %>%
        addPolygons(stroke = FALSE, smoothFactor = 0.2, fillOpacity = 1,
                    color = ~pal(gdp_md_est)
        )

# using bins
binpal <- colorBin("Blues", countries$gdp_md_est, 6, pretty = FALSE)

map %>%
        addPolygons(stroke = FALSE, smoothFactor = 0.2, fillOpacity = 1,
                    color = ~binpal(gdp_md_est)
        )

# using quantiles
qpal <- colorQuantile("Blues", countries$gdp_md_est, n = 4)
map %>%
        addPolygons(stroke = FALSE, smoothFactor = 0.2, fillOpacity = 1,
                    color = ~qpal(gdp_md_est)
        )

# coloring factors
# Make up some random levels. (TODO: Better example)
countries$category <- factor(sample.int(5L, nrow(countries), TRUE))

# only five fake factors used
factpal <- colorFactor(topo.colors(5), countries$category)

# or, sticking with Color Brewer pallette Blues
factpal <- colorFactor("Blues", countries$category)


leaflet(countries) %>%
        addPolygons(stroke = FALSE, smoothFactor = 0.2, fillOpacity = 1,
                    color = ~factpal(category)
        )

# legends
map <- leaflet(countries) %>% addTiles()

pal <- colorNumeric(
        palette = "Blues",
        domain = countries$gdp_md_est
)
map %>%
        addPolygons(stroke = FALSE, smoothFactor = 0.2, fillOpacity = 1,
                    color = ~pal(gdp_md_est)
        ) %>%
        addLegend("bottomright", pal = pal, values = ~gdp_md_est,
                  title = "Est. GDP (2010)",
                  labFormat = labelFormat(prefix = "$"),
                  opacity = 1
        )

# interactive layers
outline <- quakes[chull(quakes$long, quakes$lat),]

map <- leaflet(quakes) %>%
        # Base groups
        addTiles(group = "OSM (default)") %>%
        addProviderTiles("Stamen.Toner", group = "Toner") %>%
        addProviderTiles("Stamen.TonerLite", group = "Toner Lite") %>%
        # Overlay groups
        addCircles(~long, ~lat, ~10^mag/5, stroke = F, group = "Quakes") %>%
        addPolygons(data = outline, lng = ~long, lat = ~lat,
                    fill = F, weight = 2, color = "#FFFFCC", group = "Outline") %>%
        # Layers control
        addLayersControl(
                baseGroups = c("OSM (default)", "Toner", "Toner Lite"),
                overlayGroups = c("Quakes", "Outline"),
                options = layersControlOptions(collapsed = FALSE)
        )
map



