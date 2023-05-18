library(xlsx)
library(stringr)
library(dplyr)
library(tidyr)
library(rvest)
library(xml2)

# Set-up ----
# These data are downloaded from the Data Science Track Viz page:
# https://sciencetracker.deltacouncil.ca.gov/visualizations
df <- read.xlsx("data/dst_collaborations_and_connections_by_organizations_2023-2-27.xlsx", sheetIndex = 1)
# This is the base URL of all nodes (including organizations and projects)
url_base <- str_remove(df$Links.to.Common.Projects[1], "\\d{5}$")

# 1. Take provided data as a projection ----
el_projected <- df %>% 
  # Get just the project ids as lists
  mutate(project_id = str_extract_all(Links.to.Common.Projects, "\\d{5}")) %>% 
  select(-Links.to.Common.Projects) %>% 
  # Then unnest the lists 
  unnest(project_id, keep_empty = T) %>% 
  select(-Number.of.Common.Projects)

colnames(el_projected)[1:2] <- c('from', 'to')

# There is an issue of truncated names from the downloaded form
# Identify those
trunc_names <- c(unique(el_projected$from[which(str_detect(el_projected$from, 
                                                           "\\.{3}$"))]),
                 unique(el_projected$to[which(str_detect(el_projected$to, 
                                                           "\\.{3}$"))]))
trunc_names <- unique(trunc_names)
trunc_names <- str_remove(trunc_names, '\\.{3}$')

el_projected$from <- str_remove(el_projected$from, '\\.{3}$')
el_projected$to <- str_remove(el_projected$to, '\\.{3}$')

# 2. Extract organization ID  ----
# Visit each organization page to match their name and ID 
# and also to get the attributes of their connection: lead or contribute

# Guessing: ID 49778 starts the projects, so this is our endpoint
# and from a manual look, it looks like 49589 begins them

start <- 49589 
stop <- 49777
diff <- stop-start

# Scrape info from webpages
roles <- vector("list", (stop-start))
for(i in 1:diff){
  page <- read_html(paste0(url_base, ((start+i)-1)))
  # Verify: is this an organization node?
  supertitle <- page %>% 
    xml_find_all(  '//*[(@id = "detail-page-supertitle")]') %>% 
    html_text()
  if(str_detect(supertitle, "Organization")){
    # Org name
    name <- page %>% 
      xml_find_all('//h2') %>% 
      html_text() %>% 
      trimws()
    name <- name[3]
    org_name <- ifelse(str_detect(name, '\\['), str_extract(name, '(?<=\\[).*(?=\\])'), name)
    # Leadership on some projects
    lead <- page %>% 
      xml_find_all('//*[(@id = "data-table")]//td[(((count(preceding-sibling::*) + 1) = 1) and parent::*)]//a') %>% 
      html_text() %>% 
      trimws() %>% 
      str_remove('#')
    # Contribution on some projects
    cont <- page %>% 
      xml_find_all('//*[(@id = "data-table2")]//td[(((count(preceding-sibling::*) + 1) = 1) and parent::*)]//a') %>% 
      html_text() %>% 
      trimws() %>% 
      str_remove('#')
    org_id <- (start+i)-1
    roles[[i]] <- list(org_name, org_id, lead, cont)
  } else { 
    roles[[i]] <- list('not an org')}
  Sys.sleep(.2)
}

# Unlist and unnest
roles_df <- do.call("rbind", roles) %>% 
  data.frame() %>% 
  unnest(cols = X3, keep_empty = T) %>% 
  unnest(cols = X4, keep_empty = T) %>% 
  mutate(across(everything(), ~ as.character(.x))) %>% 
  # Only keep organizations that are connected to a project
  filter(!(is.na(X3) & is.na(X4)))
colnames(roles_df) <- c("org_name", "org_id", "leadership", "contribution")

orgs <- select(roles_df, org_name, org_id) %>% unique()

# Want to replace the truncated names from the downloaded edgelist with 
# the full names I've gathered here, using a bit of string matching
orgs$trunc_name <- NA
for(i in 1:length(trunc_names)){
  for(j in 1:nrow(orgs)){
    orgs$trunc_name[j] <- ifelse(str_detect(orgs$org_name[j], trunc_names[i]),
                                 trunc_names[i], next)
  }
}

orgs_trunc <- filter(orgs, !is.na(trunc_name))
for(i in 1:nrow(orgs_trunc)){
  for(j in 1:nrow(el_projected)){
    el_projected$to[j] <- ifelse(str_detect(el_projected$to[j],
                                            orgs_trunc$trunc_name[i]),
                                 orgs_trunc$org_name[i], el_projected$to[j])
    el_projected$from[j] <- ifelse(str_detect(el_projected$from[j],
                                            orgs_trunc$trunc_name[i]),
                                 orgs_trunc$org_name[i], el_projected$from[j])
  }
}

# 3. Set up two-mode edgelist w attribute ----
# I could also get two-mode by reversing the downloaded data from the page, 
# which I do in Step 4, but I think this is actually more comprehensive?
el_twomode_lead <- roles_df %>% 
  select(org_id, leadership) %>% 
  filter(!is.na(leadership)) %>% 
  unique() %>% 
  rename('project_id' = leadership) %>% 
  mutate(leadership = T)

el_twomode_cont <- roles_df %>% 
  select(org_id, contribution) %>% 
  filter(!is.na(contribution)) %>% 
  unique() %>% 
  rename('project_id' = contribution) %>% 
  mutate(contribution = T)

el_twomode <- full_join(el_twomode_cont, el_twomode_lead) %>% unique()
el_twomode$contribution <- ifelse(is.na(el_twomode$contribution), F,
                                  el_twomode$contribution)
el_twomode$leadership <- ifelse(is.na(el_twomode$leadership), F,
                                el_twomode$leadership)

# 4. Check: Make two-mode from online data ----
# Unsure why this is different than what I scraped from the internet 
# but I will use the other because it feels more comprehensive
el_twomode2 <- el_projected %>% 
  pivot_longer(cols = c(from, to),
               names_to = "direction", values_to = "org_name") %>% 
  select(-direction) %>% 
  unique()

# 5. Extract project attributes ----
# From my own data there are way more than the downloaded data (eltwomode)
length(unique(el_twomode$project_id)) # 299
length(unique(el_twomode2$project_id)) #163

projs <- el_twomode %>% 
  select(project_id) %>% 
  unique() %>% 
  mutate(url = paste0(url_base, project_id))

# Make these blank to fill in
projs$proj_name = NA
projs$funds = NA
projs$funding_org = NA
projs$startdate = NA
projs$enddate = NA
projs$n_years = NA
# Removing this sequence for which there is no page: these came from errors
# in the loop: 203, 286
projs <- projs[-c(203,286),]

for(i in 1:nrow(projs)){
  page <- read_html(projs$url[i])
  name <- page %>% 
    xml_find_all('//h2') %>% 
    html_text()
  projs$proj_name[i] <- name[3]
  funds <- page %>% 
    xml_find_all('//*[(@id = "activity-funding")]//p') %>% 
    html_text() %>% 
    str_remove('Total allocated funding: ')
  projs$funds[i] <- funds[1]
  funding_org <- page %>% 
    xml_find_all('//*[(@id = "funding-accordion")]//tr[(((count(preceding-sibling::*) + 1) = 3) and parent::*)]//td') %>% 
    html_text()
  projs$funding_org[i] <- funding_org[1]
  startdate <- page %>% 
    xml_find_all('//*[(@id = "activity-status")]//li[(((count(preceding-sibling::*) + 1) = 1) and parent::*)]') %>% 
    html_text() %>% 
    str_extract('\\d{4}') %>% 
    as.numeric()
  projs$startdate[i] <- as.numeric(startdate[1])
  enddate <- page %>% 
    xml_find_all('//*[(@id = "activity-status")]//li[(((count(preceding-sibling::*) + 1) = 2) and parent::*)]') %>% 
    html_text() %>% 
    str_extract('\\d{4}\\s?\\-?\\s?\\d{4}') %>% 
    str_extract('\\d{4}$')
  projs$enddate[i] <- as.numeric(enddate[1])
  projs$n_years[i] <- (projs$enddate[i] - projs$startdate[i]) + 1
}

# I want to scrape again but now for attributes of different lengths (themes),
# so I am using a list approach

themes <- vector("list", nrow(projs))
for(i in 1:nrow(projs)){
  page <- read_html(projs$url[i])
  sci_themes <- page %>% 
    xml_find_all('//*[contains(concat( " ", @class, " " ), concat( " ", "col-md-6", " " )) and (((count(preceding-sibling::*) + 1) = 1) and parent::*)]//*[contains(concat( " ", @class, " " ), concat( " ", "type-context-item", " " )) and (((count(preceding-sibling::*) + 1) = 6) and parent::*)]//a') %>% 
    html_text()
  mgmt_themes <- page %>% 
    xml_find_all('//*[contains(concat( " ", @class, " " ), concat( " ", "col-md-6", " " )) and (((count(preceding-sibling::*) + 1) = 1) and parent::*)]//*[contains(concat( " ", @class, " " ), concat( " ", "type-context-item", " " )) and (((count(preceding-sibling::*) + 1) = 4) and parent::*)]//a') %>% 
    html_text()
  themes[[i]] <- list(projs$project_id[i], sci_themes, mgmt_themes)
}

themes_df <- do.call("rbind", themes) %>% 
  data.frame() %>% 
  unnest(cols = X2, keep_empty = T) %>% 
  unnest(cols = X3, keep_empty = T) %>% 
  mutate(X1 = as.character(X1))
colnames(themes_df) <- c("project_id", "sci_theme", "mgmt_theme")

projs <- full_join(projs, themes_df, multiple = 'all')

projs <- projs %>% 
  mutate(val = T) %>% 
  pivot_wider(names_from = sci_theme, values_from = val) %>% 
  mutate(across(10:ncol(.), ~replace_na(.x, FALSE))) %>% 
  select(-`NA`)
colnames(projs)[10:ncol(projs)] <- paste0('sci_', str_remove_all(colnames(projs)[10:ncol(projs)], "\\s|\\,|\\/|\\-"))

projs <- projs %>%  
  mutate(val = T) %>% 
  pivot_wider(names_from = mgmt_theme, values_from = val) %>% 
  mutate(across(32:ncol(.), ~replace_na(.x, FALSE))) %>% 
  select(-`NA`)
colnames(projs)[32:ncol(projs)] <- paste0('mgmt_', str_remove_all(colnames(projs)[32:ncol(projs)], "\\s|\\,|\\/|\\-"))

# 6. Create full node list ----

colnames(orgs) <- c("name", "id", "trunc_name")
orgs$mode = 1
colnames(projs)[c(1,3)] <- c("id", "name")
projs$mode = 0

nl <- full_join(projs, orgs)

# These should all be true
table(nl$id %in% c(el_twomode$org_id, el_twomode$project_id))
which(!(el_twomode$org_id %in% nl$id))
which(!(el_twomode$project_id %in% nl$id))
# Remove those from the edge list so we don't deal with them
rm <- el_twomode$project_id[which(!(el_twomode$project_id %in% nl$id))]
el_twomode <- el_twomode[-which(!(el_twomode$project_id %in% nl$id)),]

# 7. Projecting edge attributes ----
# This gets a bit funny, but we want to project a project attribute onto 
# an organization so that we can have some node attributes for
# organizatons. So here it goes: 

el_projected <- nl %>% 
  # Use project node features to join with the projected network, which
  # still has project connections
  select(id, startdate, enddate, n_years) %>% 
  left_join(el_projected, ., by = c("project_id" = "id"), multiple = 'all')

# Then this is an ugly conditional to pull out a date range: If any year the
# project was going is within one of these categories, group it

for(i in 1:nrow(el_projected)){
  el_projected$daterange[i] <- ifelse(is.na(el_projected$startdate[i]), NA,
                                ifelse(unique(is.na(el_projected$enddate[i]) & 
                                      el_projected$startdate[i] %in% 2010:2024)[1] == T,
                                "Y2010_2024",
                                ifelse(unique(el_projected$startdate[i]:el_projected$enddate[i] %in% 1950:1979)[1] == T,
                                       "before_1980",
                                ifelse(unique(el_projected$startdate[i]:el_projected$enddate[i] %in% 1980:1994)[1] == T,
                                       "Y1980_1994",
                                ifelse(unique(el_projected$startdate[i]:el_projected$enddate[i]  %in% 1995:2009)[1] == T,
                                       "Y1995_2009",
                                ifelse(unique(el_projected$startdate[i]:el_projected$enddate[i]  %in% 2010:2024)[1] == T,
                                       "Y2010_2024", NA))))))
}

table(el_projected$daterange)
table(is.na(el_projected$daterange))

# Widen it out to make our lives easier later
el_projected <- select(el_projected, to, from, daterange) %>% 
  filter(!is.na(daterange)) %>% 
  # Not including wedights of collaborations
  unique() %>% 
  mutate(val = T) %>% 
  pivot_wider(names_from = daterange, values_from = val) %>% 
  mutate(across(3:ncol(.), ~replace_na(.x, FALSE)))

# And replace the names with Ids
el_projected <- left_join(el_projected, select(nl, id, name), 
                              by = c("from" = "name")) %>% 
  rename("from_org_id" = id) %>% 
  left_join(select(nl, id, name), 
            by = c("to" = "name")) %>% 
  rename("to_org_id" = id) %>% 
  filter(!is.na(from_org_id), !is.na(to_org_id)) %>% 
  select(from_org_id, to_org_id, colnames(el_projected)[3:6])

# 8. Final cleaning ----
nl$url <- paste0(url_base, nl$id)

# made a one-mode (organization) nodelist
nl_onemode <- filter(nl, mode == 1)

# remove the columns that don't matter
nl_onemode <- select(nl_onemode, id, name, url, mode)

#nl_onemode <- filter(nl, id %in% el_projected$from_org_id |
#                         id %in% el_projected$to_org_id)

nl_twomode <- filter(nl, id %in% el_twomode$org_id |
                         id %in% el_twomode$project_id)

# Assign attributes
#nl_onemode <- read.csv("data/nodelist_onemode.csv")
nl_onemode$org_type <- NA

growers <- c("Agricultural Coalitions: Landowners membership fees",
             "California Rice Commission", "Ducks Unlimited")
nl_onemode$org_type <- ifelse(nl_onemode$name %in% growers,
                              "NGO", NA)

unis_p <- c("University|Laboratory|UC\\s\\w|PRISM Climate Group")
unis <- c("Caltech", "Texas A&M", "UCLA", "UCSB", "UCSC",
          "UCSD", "CSU", "CWU", "DRI", "LBNL", "MLML", 
          "SFEI", "SFSU", "SCCWRP", 
          "Southwest Climate Adaptation Science Center", 
          "The Institute for Bird Populations", "UBC", "UW", 
          "Virginia Institute of Marine Science")
nl_onemode$org_type <- ifelse(str_detect(nl_onemode$name, unis_p) |
                                nl_onemode$name %in% unis, 
                              "University / Institute", nl_onemode$org_type)

incs <- c("Anchor QEA", "Bachand and Associates", "DigitalGlobe",
          "EcoMetric Consulting", "RMA", "Land IQ")
incs_p <- "Inc\\.|Cramer"
nl_onemode$org_type <- ifelse(str_detect(nl_onemode$name, incs_p) |
                                nl_onemode$name %in% incs ,
                              "Consultant", nl_onemode$org_type)

org <- c("Audubon Canyon Ranch", "Central Valley Joint Venture",
         "Conservation Farms and Ranches", "Fishery Foundation of California",
         "MarineTraffic", "National Audubon Society", "NatureServe",
         "Pacific Flyway Council", "Point Blue Conservation Science",
         "San Francisco Bay Bird Observatory",
         "San Joaquin County Resource Conservation District",
         "Solano Land Trust", "SWC", "Suisun Resource Conservation District",
         "The Nature Conservancy", "UNAVCO", "WSWC",
         "Westside San Joaquin River Watershed Coalition", "ICWP")
nl_onemode$org_type <- ifelse(nl_onemode$name %in% org,
                              "NGO", nl_onemode$org_type)

gov_fed <- c("BLM", "BTS", "DoD", "DOE", "DOE-BER", "DoT", "NASS", "NAIP", "NASA", "NMFS", "NOAA", "NPS", "NSF", "USACE", "USBR", "USDA", "USEPA", "USFS", "USGS", "National Wetlands Inventory - Many Supporting Organizations", "BIA", "U.S. Census Bureau", "EIA", "USFWS", "Goddard Space Flight Center", "European Space Agency")
nl_onemode$org_type <- ifelse(nl_onemode$name %in% gov_fed,
                              "Federal Government", nl_onemode$org_type)

gov_state <- c("CALCC", "CalEPA", "CALFIRE", "CalFish", "California State Board of Equalization", "California State Coastal Conservancy", "California Water Board - Central Valley Region", "Caltrans", "CAMT", "CCWD", "CDFA", "CDFW", "CDPH", "CEC", "Central Valley RWQCB", "Delta Conservancy", "Delta Stewardship Council", "Delta Stewardship Council - Delta Science Program", "DFG", "CNRA", "CSLC", "CVFPB", "DOC", "DPR", "DWR", "OEHHA", "PARKS", "RMP", "SJCDWQC", "SWRCB", "Sacramento-San Joaquin Delta Conservancy", "East Bay Municipal Utilities District", "FESSRO", "Metropolitan Water District of Southern California", "PSMFC", "Port of Stockton Board of Commissioners", "Regional San",
               "BCDC", "San Joaquin Valley Drainage Authority", "SMC",
               "Woodland-Davis Clean Water Agency", "Yuba River Management Team")
nl_onemode$org_type <- ifelse(nl_onemode$name %in% gov_state,
                              "State & Local Government", nl_onemode$org_type)

nl_twomode <- read.csv("data/nodelist_twomode.csv")
nl_twomode <- left_join(nl_twomode, nl_onemode)

#el_twomode <- read.csv("data/edgelist_twomode.csv")
el_twomode$collaborative_role <- ifelse(el_twomode$leadership == T, "Leader", "Contributor")

# Write data ----
write.csv(nl_twomode, "data/nodelist_twomode.csv", row.names = F)
write.csv(nl_onemode, "data/nodelist_onemode.csv", row.names = F)
write.csv(el_twomode, "data/edgelist_twomode.csv", row.names = F)
write.csv(el_projected, "data/edgelist_onemode_projected.csv", row.names = F)
