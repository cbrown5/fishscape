# readme for the fishscape database

CJ Brown, Andrew Broadley 12 Dec 2017

Provided in support of the submitted paper:
Brown, Broadley, Adame, Branch, Turschwell, Connolly. 2017. "The status of fisheries depends on changes in fish habitats". Submitted

Please cite that paper if you use this resource. We would also like to hear how you are using this. 

License: [MIT](https://opensource.org/licenses/MIT) + file LICENSE

## Description
This is a database of fish associations with their habitats. We (primarily Andrew) reviewed the peer-reviewed and grey literatures for evidence of fish associations with particular habitats.

It is a long-form database, where each row corresponds to one observation of a fish habitat association. A single paper can have multiple rows if for instance it reports on multiple species, or it has measured fish-habitat relationships for a single species in multiple different ways.
"Fish" includes bony and cartilaginous fish and fished invertebrates.

Currently we have focussed on species included in the [RAM Legacy database](http://ramlegacy.org/). We plan to expand the database to all species in the FAO catch series in 2018.

## Files
The database itself is under: `data-raw/fish-hab-db_v1.csv`
Metadata are in `meta-data.md`
A complete bibliography of reviewed papers is under `fish-hab-db-refs.bib`
R code used to generate figures in the submitted paper is in `GlobalFishStatus/`
`data-raw/priority-fish-stocks.csv` contains a list of RAM Legacy stocks that we cross referenced with our database.
