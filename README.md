#Introduction
This is a crime/accident visualization application, written in Processing 2.2.1

#Purpose:
Crime can be the result of different negative behaviours, such as heavy drinking, drugs, accidents, etc. Our website will display user-selected layers on top of each others over Victoria map to shed some light into the connection between crime and other behaviours.

Basic layers include accidents, drug use, various crime type. If an area has a higher density of incidents, it may indicate that something needs to be done in that area.
	
#Data is obtained from various sources:
Victoria Suburb boundary: http://data.gov.au/dataset/vic-suburb-locality-boundaries-psma-administrative-boundaries

5-year accident: http://vicroadsopendata.vicroadsmaps.opendata.arcgis.com/datasets/fcb3777cac7d4dda9e9a8b890a14aa61_0

Crime statistics: http://www.crimestatistics.vic.gov.au/

#Development Installation Instruction
1. Download and install Processing 2.2.1 from https://www.processing.org/download/

2. Install the following additional libraries(you can install it in Processing IDE): BezierSQLLib, ControlP5, Unfolding Maps

3. Make sure you have MySQL server installed

4. create a database named govhack2015 (or any other name, the settings is inside the code (sketch_CrimeStalker.pde))

5. execute query.sql in the package, which will insert all data into the database

6. change the settings in sketch_CrimeStalker.pde to make the software communicates with the database

7. Open sketch_CrimeStalker.pde and run it in Processing IDE.