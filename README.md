# Shiny Site Aggregator

[Contact](mailto:wvp3@cdc.gov)


Setup
------
Run the prep_data.R script on your PEPFAR MER structured dataset (site-level data).  You will also need geospatial shape files compatible with leaflet, such as those created for ArcGIS or QGIS. At least two shape files are needed, a polygon shape file with borders of priority subnational units (SNU), a .csv file containing their centroids, and a point coordinate shape file with standard facility names matching those in PEPFAR information systems (DATIM).  https://datim.zendesk.com/hc/en-us


Purpose
------
We created this tool to allow country team users to define groups (clusters) of sites based on geographic proximity and other known group attributes, such as site types and known referral patterns.  



How to use
------
There are three primary applications in this tool.

*Cluster aggregated results:* 
Use the site selection box tool in the map to define a customized cluster of sites. The aggregate results of nearby sites within a user-defined cluster will be displayed.  

*Outlier analysis:* 
Use the scatterplot to visually identify outlier sites that are especially high in one attribute but low in another attribute, or vice versa.  For example, sites with a high number of HIV positives identified, but low numbers of positives newly initiated on treatment.  Then use the scatterplot brush tool (marquee selection box) to select the outlier site to isolate it on the map.  Zoom to that site on the map to select nearby sites and determine whether the outlier could be explained by offsetting patients initiated at nearby sites.  

*Filter-based searching:* 
Use the table filters to select sites within a specific range in a numeric result, using filter boxes in the table column headers.  (E.g.: achievement of site target below 20%).  The table will be filtered based on your criteria.  You can identify of the filtered sites on the map by clicking them on the table.  Hold the contrl (ctrl) key to select multiple sites from the table.

To clear your selection of sites, either click on the scatterplot outside the current selection, or click on the "X" button in the map.


Data source
------
This tool draws from the ICPI MER structured dataset (formerly "factview"), site by implementing mechanism level data.  South Africa is used as an example.  


Known issues
------
There may some issues displaying scatterplot legends completely after switching between districts.  

Caveats and limitations
------
Please keep in mind that offsetting linkage numbers between two adjacent sites do not necessarily prove that patients were referred between those sites.  Patient-level data is needed to definitively demonstrate patient transfers


Last update
------
These data were updated using the MER structured dataset, fiscal year 2018 Q2 clean data.  
