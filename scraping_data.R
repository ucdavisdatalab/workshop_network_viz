library(xlsx)
library(stringr)
library(dplyr)
library(tidyr)
library(rvest)
library(xml2)

# Download data
df <- read.xlsx("data/dst_collaborations_and_connections_by_organizations_2023-2-27.xlsx", sheetIndex = 1)
url_base <- str_remove(df$Links.to.Common.Projects[1], "\\d{5}$")

el_projected <- df %>% 
  # Get just the project ids as lists
  mutate(project_id = str_extract_all(Links.to.Common.Projects, "\\d{5}")) %>% 
  select(-Links.to.Common.Projects) %>% 
  # Then unnest the lists 
  unnest(project_id) %>% 
  select(-Number.of.Common.Projects)

el_twomode <- el_projected %>% 
  pivot_longer(cols = c(Connection.From, Connection.To),
               names_to = "direction", values_to = "org_name") %>% 
  select(-direction) %>% 
  unique()

nl <- data.frame("name" = c(el_twomode$project_id, el_twomode$org_name),
                 "mode" = c(rep(1, length(el_twomode$project_id)), 
                            rep(2, length(el_twomode$org_name)))) %>% unique()
  

projs <- el_twomode %>% 
  select(project_id) %>% 
  unique() %>% 
  mutate(url = paste0(url_base, project_id))

projs$proj_name = NA
projs$funds = NA
projs$startdate = NA
projs$enddate = NA
projs$n_years = NA

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

# These are all different lengths, so I'll do this separately (? could merge eventually)
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
  unnest(cols = X2) %>% 
  unnest(cols = X3) %>% 
  mutate(X1 = as.character(X1))
colnames(themes_df) <- c("project_id", "sci_theme", "mgmt_theme")

projs <- full_join(themes_df, projs)

nl_twomode <- full_join(nl, projs, by = c("name" = "project_id"), 
                        multiple = "all") %>% 
  select(name, proj_name, mode, startdate, enddate,
         funds, n_years, sci_theme, mgmt_theme, url)

colnames(el_projected)[1:2] <- c('to', 'from')
write.csv(nl_twomode, "data/nodelist_twomode.csv", row.names = F)
write.csv(el_twomode, "data/edgelist_twomode.csv", row.names = F)
write.csv(el_projected, "data/edgelist_projected.csv", row.names = F)
