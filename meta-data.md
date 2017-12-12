# Meta-data for the Global Fish Habitat Use Database

CJ Brown, Andrew Broadley 15 May 2017

## Description
This is a database of fish associations with their habitats. It is a long-form database, where each row corresponds to one observation of a fish habitat association. A single paper can have multiple rows if for instance it reports on multiple species, or it has measured fish-habitat relationships for a single species in multiple different ways.
"Fish" includes bony and cartilaginous fish and fished invertebrates.

We include peer-reviewed and grey literature.

## Data entry process
Keep track of time taken and number of pubs and species entered (e.g. time yourself from start to finish). We will use this info to decide when to stop adding species!
Choose unentered species from "priority-fish-stocks.xlsx"
Focus on benthic/demersal species for now. We still need to work out how to code pelagic habitats.
Find publications on web.
Download pdf.
Unentered pdfs can be saved in that folder.
Copy citation info from google scholar and insert into bibtex library.
Rename pdf using bibtex cite-key.
Enter data into database.
Add new field codes if neccessary.
Please use all lower case in field entries, including for taxonomic names.
Check species off in "priority-fish-stocks.xlsx"

## Associated files
Also included in this folder are:
**/pubs** a folder which contains pdfs of publications that have been entered.
file names should be the same as the bibtex cite-key.
**/pubs-not-entered** a folder which contains pdfs of publications to check/enter.
**fish-hab-db-refs.bib** bibtex library with citation info.
**priority-fish-stocks** priority fish species and stocks for data entry.
Try to get every species. If you see multiple studies for the same species in different areas, try to get the different fish stocks.
You can annotate this with species entered to keep track of what is happening.
However, if you happen across other species in study, please enter them too.
**RAM-Legacy-spreadsheet-snapshot-20110815.xlsx** copy of the 2011 RAM legacy stock assessment database.
We are focussing on stocks in this database initially.
**other-resources.md** list of resources to check for data.

## Variables

### cite-key
This should match the cite-key in the bibtex library.
pdfs should have the same name as their entry to the bibtex cite-key.

### lat
Latitude of approximate study site (or centre of region). Use decimal degrees,
and -ve values for degrees south.  If using study centre, make sure it is in the ocean.
You can convert from degrees minutes here: https://data.aad.gov.au/aadc/calc/dms_decimal.cfm

### lon
Longitude of approximate study site (or centre of region). Use decimal degrees,
and -ve values for degrees west. If using study centre, make sure it is in the ocean.

### Class
Taxonomic Class
**Fields:**
[actinopterygii, chondrichthyes ]

### fish-family
Family of the fish species.

### fish-sp
Fish species. If species unknown, or includes multiple species then just genus.
Leave blank if family known but genus unknown, or species were grouped.

### spp-grouped
Does the observation included multiple species grouped together?
**Fields:**
[y, n]
(leave blank if N)

### highly-migratory-species
Species that have a wide geographic distribution and migrate for food and reprodcution of vast distances both inside and outside of a countries exclusive economic zone.
**Fields:**
[y, n]
(leave blank if N)

### hab-zone
Species broad habitat zone type.
**Fields:**
[benthic, benthopelagic, neritic, epipelagic, mesopelagic...]
Benthic rests on the bottom (e.g. stingrays)
benthopelagic moves near the bottom (e.g. cod)
neritic is the shallow coastal zone before drop-off to continental shelf
epipelagic from the surface to 200m
mesopelagic 200m to 1000m
Use fishbase entry for environment if unsure.

### lifestage
Life stage of the fish species. Leave blank if multiple grouped.
**Fields:**
[adult, juvenile, post-larvae, larvae, egg, spawning]
post-larvae refers to settlement habitats.

### habitat-type
Type of habitat. Seperate multiple entries with ;
**Fields:**
[seagrass, mangroves, coral, reef, soft-sediment, sand, mud, macroalgae, rock ...]
soft-sediment is a generalisation of sand and mud mixed (if unknown)

### habitat-species
Lowest taxonomic ID of habitat if available (genus, species etc...)

### hab-function
If known, how does the fish species use the habitat?
**Fields:**
[NA, pred-refuge, food, shelter, physiochem, other]
NA refers to not described in this study.
pred-refuge refers to refuge from predation
Where shelter refers to sheltering functions other than avoiding predation.
physiochem refers to physiochemical properties (e.g. desired temperature)


### micro-habitat
if known, type of micro-habitat used by a species.

### obstype
How did the researchers identify this habitat association?
**Fields:**
[direct, catch-survey, catch, e-tag, stomach, isotopes, ...]
direct refers to direct observation ie you saw it there while diving.
catch-survey refers to catching a fish in a habitat using scientific surveys
catch refers to catch in commercial/recreational fisheries.

e-tag is an electronic tag.
Stomach means habitat was inferred from dietry analysis. Similar for isotopes.

### depthzone
Depth zone of habitat association.
**Fields:**
[intertidal, <20, <50, <100, <150, <200, >200, >50, <500, <1000; <3000; mesophotic ,...].

### area-of-study
If known, approx. area that was surveyed
**Fields:**
[<10m2, <100m2, <1000m2, <1ha, <10ha, <100ha, >100ha].


### fishery-impact
Flag to indicate that the study reported that a change in the habitat had an impact on a fishery.
**Fields:**
[y, n]
(leave blank if N)

### fish-stock
If known, indicates if there is a change fish stock because of a change in habitat.
**Fields:**
[decline, increase, stable]
(leave blank if unknown)

### fish-stock-reason
Describe the reason for a change in the fish-stock.
**Fields:**
[climate change, artificial habitat]
(leave blank if unknown)


### notes-fishery
Any notes relating to an impact on a fishery.



### notes
Any other notes
