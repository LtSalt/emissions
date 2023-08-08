################################################################################
# CO2 EMISSIONS IN GERMANY
#
# R Prep
################################################################################


# Dependencies ------------------------------------------------------------

if(!"pacman" %in% installed.packages()) install.packages("pacman")
pacman::p_load(here, tidyverse, readxl, janitor, jsonlite)


# Import ------------------------------------------------------------------

emissions_raw <- read_excel(here("data", "emissions.xlsx"), 
                        sheet = "Daten", 
                        skip = 13)


# Cleaning ----------------------------------------------------------------

emissions <- emissions_raw %>% 
  slice(-c(1, 2)) %>% 
  select(year = 1, 
         `Energy Industry`, 
         Transport, 
         Buildings, 
         Industry, 
         Agriculture, 
         `Waste and Waste Water`, 
         `Greenhouse gas emissions total...15`) %>% 
  clean_names() %>% 
  mutate(across(everything(), as.numeric),
         year = row_number() + 1989) %>% 
  filter(year <= 2022) %>% 
  rename(energy = energy_industry, 
         waste = waste_and_waste_water,
         total = greenhouse_gas_emissions_total_15)

toJSON(emissions)


# Export ------------------------------------------------------------------

write_json(emissions,
           here("svelte", "src", "lib", "data", "emissions.json"))

  
  

