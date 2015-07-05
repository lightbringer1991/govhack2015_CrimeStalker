// CrimeStalkers - visualised customisable car accident data over time and allows for
// comparison with crime data for regions.
// Created at GovHack 2015, Ballarat - 3rd July 2015 to 5th July 2015.
// Authors: Al Lansley, Minh Tuan Nguyen, Wentao Zhang
// This program is made available as a CC-BY licence:
// https://creativecommons.org/licenses/by/4.0/

// Standard java imports
import java.util.List;
import java.util.Map;
import java.util.Iterator;
import java.util.Random;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

// Import UnfoldingMaps classes as req'd
import de.fhpotsdam.unfolding.UnfoldingMap;
import de.fhpotsdam.unfolding.geo.Location;
import de.fhpotsdam.unfolding.utils.MapUtils;
import de.fhpotsdam.unfolding.events.EventDispatcher;
import de.fhpotsdam.unfolding.events.MapEventBroadcaster;
import de.fhpotsdam.unfolding.interactions.MouseHandler;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.marker.MarkerManager;

// Import UnfoldingMaps providers
import de.fhpotsdam.unfolding.providers.Google;
//import de.fhpotsdam.unfolding.providers.Microsoft; // Add providers as req'd...

// Import SQL database connectivity library
import de.bezier.data.sql.*;

// Import GUI controls lib
import controlP5.*;

// Our connection to the database
MySQL dbConnection;

// Our controlP5 object used for GUI widgets
ControlP5 cp5;
CrimeStalker_DropDown crashDropdown;
CrimeStalker_DropDown crimeDropdown;

String[] crashCheckboxNames = {"HIT_RUN_FLAG", "RUN_OFFROAD", "FATALITY", "SERIOUSINJURY", "MALES", "FEMALES", "BICYCLIST", "MOTORIST", "PEDESTRIAN", "OLD_DRIVER", "YOUNG_DRIVER", "ALCOHOL_RELATED"};

// Our array of which crash / crime data checkboxes are selected
// Note: This is updated by the relevant checkbox handler
List<String> crashCheckboxSelections = new ArrayList<String>();
List<String> crimeCheckboxSelections = new ArrayList<String>();


// Our hashmap of crash table column names and the condition required to display them i.e. ALCOHOLRELATED = "YES"
Map<String, String> toggleCrashData = new HashMap<String, String>();

// Define the latitude and longitude (in that order!) of Ballarat
Location ballaratLocation = new Location(-37.5621071f, 143.85614929999997f);

// A date format used for our human readable dates (when we convert back from unix time)
DateFormat dfm = new SimpleDateFormat("dd/MM/yyyy");

// Our data slices go in weeks, so we go from the current unix time to that time plus 7 days in seconds
static final long ONE_WEEK_IN_SECONDS = 60L * 60L * 24L * 7L;

// Declare our map and helper objects
UnfoldingMap map;
EventDispatcher mapEventDispatcher;
MouseHandler mapMouseHandler;
MarkerManager markerManager;

// We'll need to keep track of the sliders mapped-into-unix-time value so we can convert it back into
// a human-readable date to update the frame title.
long sliderUnixTime = 0;

// Our time slider which controls our timeslice view of our data
Slider timeSlider; 

// These will be the minimum and maximum (i.e. earliest and latest) times for our car accident records
// Note: We need these to map the slider values into the range of the accident records themselves
long minUnixTime = 0;
long maxUnixTime = 0;

// Keep a HashMap of all our ImageMarkers
Map<String, ImageMarker> markerData = new HashMap<String, ImageMarker>();

// The image for our markers
PImage markerImage;


// We'll keep track of whether the mouse is being dragged (i.e. LMB down + mouse movement)
boolean mouseIsDragging = false;

PFont font = createFont("LiberationSans-18.vlw", 14);

// How many accidents we've retrieved for this time period with the given filters
int currentAccidentRecordCount = 0;

// Set up our sketch - runs once at start of execution
void setup() {
    // Set the window size and use the OpenGL renderer
    // Note: If we want this fullscreen we can use displayWidth and displayHeight.
    //size(displayWidth, displayHeight, OPENGL);
    size(800, 600, OPENGL);
    
    frame.setTitle("App: Crime Stalker, Team: Sky Observer - GovHack 2015, Ballarat");
    
    // Enable resizing the sketch window
    frame.setResizable(true);
    
    // ***** IMPORTANT: Change these details to your own MySQL server credentials!!! *****
    // Connect to the MySQL database (MariaDB is also fine)
    String user = "root";
//    String pass = "testing123";
    String pass = "";
    String host = "localhost";
    String database = "govhack2015";  
    dbConnection = new MySQL(this, host, database, user, pass);
    dbConnection.connect();
    // TODO: Need to spit some debug here if the DB connection fails!
    
    // Get the lowest unix time from all our car accident records (i.e. the earliest record)
    dbConnection.query("SELECT MIN(`UNIX_TIME`) AS `min`FROM `accidents` WHERE `UNIX_TIME` != ''");
    dbConnection.next();
    minUnixTime = Long.parseLong( dbConnection.getString("min") );
    println("min unix: " + minUnixTime);
    
    // Get the highest unix time from all our car accident records (i.e. the latest record)
    dbConnection.query("SELECT MAX(`UNIX_TIME`) AS `max` FROM `accidents` WHERE `UNIX_TIME` != ''");
    dbConnection.next();
    maxUnixTime = Long.parseLong( dbConnection.getString("max") );
    println("max unix: " + maxUnixTime);
    
    sliderUnixTime = (minUnixTime + maxUnixTime) / 2L;
 
     // Instantiate our cp5 GUI controls object
     cp5 = new ControlP5(this);
//     
//     // Add our time slider
//     cp5.addSlider("Time (weeks)")
//     .setPosition(width * 0.1f, height * 0.9f) // Slider starts 10% across, 90% down
//     .setWidth( Math.round(width * 0.8f) )     // Slider is 80% width of the screen
//     .setRange(0, 259)                         // Week number (260 weeks in 5 years)
//     .setValue(130)                            // Default we'll start half way
//     .setNumberOfTickMarks(260)
//     .snapToTickMarks(true)
//     .setSliderMode(Slider.FLEXIBLE)           // Show grabable 'triangle' on slider
//     ;
     
     // Add our time slider
     timeSlider = cp5.addSlider("Time (weeks)")
     .setPosition(width * 0.1f, height * 0.87f) // Slider starts 10% across, 90% down
     .setWidth( Math.round(width * 0.8f) )     // Slider is 80% width of the screen
     .setHeight(20)
     .setRange(0, 259)                         // Week number (260 weeks in 5 years)
     .setValue(130)                            // Default we'll start half way
     .setNumberOfTickMarks(260)
     .snapToTickMarks(true)
     .setSliderMode(Slider.FLEXIBLE)           // Show grabable 'triangle' on slider
     ;
     timeSlider.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(20).setPaddingY(20);
       
     timeSlider.getCaptionLabel().setFont(font)
                         .setColor(color(255, 255, 255))
                         .enableColorBackground()
                         .setColorBackground(color(0, 0, 0, 200))
                         .setSize(20)
                        // .setHeight(30)
                         .setText("Drag the slider to change the time-slice of the data by weeks.");
    
    // ----- Map setup -----    
    
    /* Map providers:
      OpenStreetMap.OpenStreetMapProvider();
      OpenStreetMap.CloudmadeProvider(API KEY, STYLE ID);
      StamenMapProvider.Toner();
      Google.GoogleMapProvider();
      Google.GoogleTerrainProvider();
      Microsoft.RoadProvider();
      Microsoft.AerialProvider();
      Yahoo.RoadProvider();
      Yahoo.HybridProvider();
      
      Further reading about switching map styles / providers dynamically:
          http://unfoldingmaps.org/tutorials/mapprovider-and-tiles.html#map-styles
      */
  
    // Create our map
    // Note: the Unfolding maps API can be found here: http://unfoldingmaps.org/javadoc/index.html
    map = new UnfoldingMap( this, new Google.GoogleMapProvider() );
    
    // Instantiate our event dispatcher and mouse handler, tie the mouse handler to this sketch and this map,
    // then add the mouse handler to the map event dispatcher 
    mapEventDispatcher = new EventDispatcher();
    mapMouseHandler = new MouseHandler(this, map);
    mapEventDispatcher.addBroadcaster(mapMouseHandler);
    
    // Instantiate our marker manager and add it to the map
    // Note: We need a specific, named marker manager to be able to clear all the markers on the map
    // when the slider value changes
    markerManager = new MarkerManager();
    map.addMarkerManager(markerManager);
    
    // Specify our initial location and zoom level. Note: Higher zoom values are more zoomed in.
    map.zoomAndPanTo(8, ballaratLocation);
    
    // Enable tweening so we animate the map rather than jumping to location. Note: Default tweening flag value is false.
    map.setTweening(true);
    
    // Specify that we cannot pan to more than 20km away from this point
    //map.setPanningRestriction(ballaratLocation, 20.0f);
    
    // Register panning and zooming of the map
    mapEventDispatcher.register(map, "pan", map.getId());
    mapEventDispatcher.register(map, "zoom");
    
    // Load our marker image
    markerImage = loadImage("ui/marker_red.png");
    
    // Instantiate our slider listener and add it to the time slider
    mySliderListener = new MySliderListener();  
    cp5.getController("Time (weeks)").addListener(mySliderListener);

    smooth();
    cp5.getTooltip().setDelay(500);
    
    
    // Put all our crash table column names and the check we will perform to display them. 
    // This is used in our customised SQL query
    toggleCrashData.put("HIT_RUN_FLAG" , "= 'YES'");
    toggleCrashData.put("RUN_OFFROAD"  , "= 'YES'");
    toggleCrashData.put("FATALITY"     , "> 0");
    toggleCrashData.put("SERIOUSINJURY", "> 0");
    toggleCrashData.put("MALES"        , "> 0");
    toggleCrashData.put("FEMALES"      , "> 0");
    toggleCrashData.put("BICYCLIST"    , "> 0");
    toggleCrashData.put("MOTORIST"     , "> 0");
    toggleCrashData.put("PEDESTRIAN"   , "> 0");
    toggleCrashData.put("OLD_DRIVER"   , "> 0");
    toggleCrashData.put("YOUNG_DRIVER" , "> 0");
    toggleCrashData.put("ALCOHOL_RELATED", "= 'YES'");
  
    // Create accident filter checkbox drop down
    crashDropdown = new CrimeStalker_DropDown(cp5);
    crashDropdown.setPosition(20, 30);
    crashDropdown.setLabel("Crash Records");
    crashDropdown.setCheckBoxList(crashCheckboxNames);
    crashDropdown.setSize(120, 13);
    crashDropdown.initialize();
    
    // Create crime filter checkbox drop down
    crimeDropdown = new CrimeStalker_DropDown(cp5);
    crimeDropdown.setPosition(width - 450, 30);
    crimeDropdown.setLabel("Crime Records");
    crimeDropdown.setCheckBoxList(generateCrimeDropDownData(dbConnection));
    crimeDropdown.setSize(350, 13);
    crimeDropdown.initialize();
    
    // Populate the initial data
    getFilteredAccidentsFromDB();
  
} // End of setup method

// Runs once per frame
void draw()
{
    // Draw our map
    map.draw();
  
    // Only draw our target lines if the mouse is not being dragged
    if (!mouseIsDragging) { drawTargetOverlay(); }
}

void drawTargetOverlay()
{
    // Set stroke to red
    stroke(255,0,0);  
    
    // Draw a vertical line centred on mouseY and a horizontal line centred on mouseX
    line(mouseX, 0, mouseX, height);  
    line(0, mouseY, width, mouseY);
  
    // Draw an ellipse in the centre of the window in semi-transparent white
    fill(255,255,255,128);
    ellipse(mouseX, mouseY, 10, 10); 
}

void drawMarker(String accidentNo, Float lon, Float lat) {
  Location loc = new Location(lat, lon);
  ImageMarker m = new ImageMarker(loc, accidentNo, markerImage);
  map.addMarker(m);
  markerData.put(accidentNo, m);
}

// draw a list of marker data
int drawMarkerList(HashMap<String, Float[]> data) {
  int count = 0;
  Iterator it = data.entrySet().iterator();
  while (it. hasNext()) {
    Map.Entry pair = (Map.Entry)it.next();
    Float[] coord = (Float[])pair.getValue();
    drawMarker((String)pair.getKey(), coord[0], coord[1]);
    count++;
  }
  return count;
}


void getFilteredAccidentsFromDB()
{
    // Get the unix time for the slider unix time plus 7 days worth of seconds
    long oneWeekAhead = sliderUnixTime + (60L * 60L * 24L * 7L); 
  
    // Query the database
    String queryString = "SELECT `ACCIDENT_NO`, `LONGITUDE`, `LATITUDE` FROM `accidents` WHERE `UNIX_TIME`>" + sliderUnixTime + " AND `UNIX_TIME` < " + oneWeekAhead;
    
    // Are there any checkboxes selected? If so, the we need to add additional filter terms to our query
    if (crashCheckboxSelections.size() > 0)
    {
      for (String checkboxName : crashCheckboxSelections)
      {
          String queryCondition = toggleCrashData.get(checkboxName);
          queryString += " AND `" + checkboxName + "` " + queryCondition;
      }
    }
      
    // Now that we've constructed our query we can execute it!
    dbConnection.query(queryString);
  
    // Clear our marking data and the markers on the map
    markerData.clear();
    markerManager.clearMarkers();
    
    // While we have records...
    currentAccidentRecordCount = 0;
    while (dbConnection.next() )
    {  
      // Create a location object from the latitude and longitude
      float lat = parseFloat( dbConnection.getString("LATITUDE")  );  
      float lon = parseFloat( dbConnection.getString("LONGITUDE") );      
      Location loc = new Location(lat, lon);
      
      // Get the accident number, which is the primary key of the crash event
      String accidentNum = dbConnection.getString("ACCIDENT_NO");
    
      // Create an image marker at this location
      ImageMarker m = new ImageMarker(loc, accidentNum, markerImage);
       
      // Add the marker to the map
      map.addMarker(m);
    
      // Increase our marker count
      currentAccidentRecordCount++;
    }
    
    // Get strings for record range
    Date startDate = new Date(sliderUnixTime * 1000L);
    Date endDate   = new Date( (sliderUnixTime + ONE_WEEK_IN_SECONDS) * 1000L ); // End date is current date plus 7 days worth of seconds
    String startDateString = dfm.format(startDate);
    String endDateString   = dfm.format(endDate);
  
  timeSlider.getCaptionLabel().setText("Data range: " + startDateString + " to " + endDateString + ". Records: " + currentAccidentRecordCount);
  
  println("Got record count: " + currentAccidentRecordCount);
  
} // End of getAccidentsByTimePeriod method

void getFilteredCrimesFromDB()
{
    println("I SHOULD NOT BE RUNNING BUT I AM!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
  
    // Get the unix time for the slider unix time plus 7 days worth of seconds
    long oneWeekAhead = sliderUnixTime + (60L * 60L * 24L * 7L); 
    
    // Get the year of the slider
    Date date = new Date(sliderUnixTime * 1000L);
    DateFormat yearOnlyDFM = new SimpleDateFormat("yyyy");
    String crimeSliderYear = yearOnlyDFM.format(date);
  
    // Query the database
    String queryString = "SELECT `OFFENCE_COUNT` FROM `crimes` WHERE `APR_TO_MAR_YEAR` = " + crimeSliderYear;
    
    // Get crime radio region drop-down value here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!    
    String crimeRegionRadioButtonValue = "ALL";
    if ( crimeRegionRadioButtonValue.equals("ALL") )
    {
      // No filtering by region required! Move along!
    }
    else
    {
      queryString += " AND `POLICE_SERVICE_AREA` = " + crimeRegionRadioButtonValue;
    }
   
    // Get crime type radio button here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!      
    String crimeTypeRadioButtonValue = "A10_HOMICIDE_AND_RELATED_OFFENCES";  
    queryString += " AND `CSA_OFFENCE_SUBDIVISION` = " + crimeTypeRadioButtonValue;
      
      
    // Now that we've constructed our query we can execute it!
    dbConnection.query(queryString);
  
    // Clear our marking data and the markers on the map
    //markerData.clear();
    //markerManager.clearMarkers();
    
    // While we have records...
    int count = 0;
    while (dbConnection.next() )
    {  
      // Create a location object from the latitude and longitude
      float lat = parseFloat( dbConnection.getString("LATITUDE")  );  
      float lon = parseFloat( dbConnection.getString("LONGITUDE") );      
      Location loc = new Location(lat, lon);
      
      // Get the accident number, which is the primary key of the crash event
      String accidentNum = dbConnection.getString("ACCIDENT_NO");
    
      // Create an image marker at this location
      ImageMarker m = new ImageMarker(loc, accidentNum, markerImage);
       
      // Add the marker to the map
      map.addMarker(m);
    
      // Increase our marker count
      count++;
  }
  println("Got record count: " + count);
  
} // End of getAccidentsByTimePeriod method

// ----- Mouse handler functions -----
// Mouse dragged fires when a mouse button is held down and the mouse is moved while the button is still down
void mouseDragged()
{
    if (mouseButton == LEFT)
    {
        // Get the date from our sliders unix-time value
        Date startDate = new Date(sliderUnixTime * 1000L);
        Date endDate   = new Date( (sliderUnixTime + ONE_WEEK_IN_SECONDS) * 1000L ); // End date is current date plus 7 days worth of seconds
      
        String startDateString = dfm.format(startDate);
        String endDateString   = dfm.format(endDate);
        
        frame.setTitle("Crime Stalker - Date range: " + startDateString + " to " + endDateString);
    }
        
    // Set our flag so that we do not draw the crosshair
    mouseIsDragging = true;
        
        
    // Change the mouse cursor to the MOVE cursor while the mouse is being dragged 
    cursor(MOVE);
    
    // Can also get the LMB like this if req'd:
    // else if (mouseButton != RIGHT) { }
}

// Mouse clicked fires when a mouse button is released
void mouseReleased()
{
    // Return the mouse cursor to a standard arrow when a mouse button is released
    cursor(ARROW);
  
    // When the LMB is released then we reset the mouseIsDraggingFlag to false so we draw our target lines
    if (mouseButton == LEFT)
    {
        // Regist the map panning handler again when we release the LMB
        mapEventDispatcher.register(map, "pan", map.getId());
        mouseIsDragging = false;
    }
}

void mousePressed()
{
    if (mouseButton == LEFT)
    {
      // If we have pressed the mouse over the slider then unregister panning on the map
      if (cp5.getController("Time (weeks)").isMousePressed())
      {
          mapEventDispatcher.unregister(map, "pan", map.getId());
      }
    }
    
    // We can do stuff with the RMB if we want to...
    //if (mouseButton == RIGHT)
    //{ 
    //  // Do stuff...
    //}   
}

// We can do stuff if the mouse moves if we want to...
//void mouseMoved()
//{
// 
//}

void keyPressed()
{
  if (key == CODED) {
    
    if (keyCode == LEFT)
    {
        if (sliderUnixTime - ONE_WEEK_IN_SECONDS >= minUnixTime)
        {
          sliderUnixTime -= ONE_WEEK_IN_SECONDS;
          getFilteredAccidentsFromDB();
        }
    }
    else if (keyCode == RIGHT)
    {
      if (sliderUnixTime + ONE_WEEK_IN_SECONDS <= maxUnixTime)
      {
        sliderUnixTime += ONE_WEEK_IN_SECONDS;
        getFilteredAccidentsFromDB();
      }
    }
  }
}

void controlEvent(ControlEvent theEvent)
{
  if (theEvent.isGroup())
  {
    if ( theEvent.isFrom(crashDropdown.getCheckBox() ) )
    {
      crashCheckBoxHandler(crashDropdown.getCheckBox(), dbConnection);
      print("crash");
    } else if (theEvent.isFrom(crimeDropdown.getCheckBox())) {
      print("crime");
    }
  }
  //println(crashDropdown);

}

// Method to update our crash marker results based on what crash data checkboxes are selected
void crashCheckBoxHandler(CheckBox cb, MySQL connection)
{
  // Get a list of all the checkboxes
  List items = cb.getItems();
  
  // Clear our current list of selections
  crashCheckboxSelections.clear();
  
  // Loop over each checkbox...
  for (int i = 0; i < items.size(); i++)
  {
      // Get a toggle (i.e. checkbox)
      Toggle t = (Toggle)items.get(i);
      
      // If the checkbox is enabled then add it to the array
      if ( t.getState() )
      {
          crashCheckboxSelections.add( t.getName() );
      }
      
  } // End of loop over toggles / checkboxes
  
  // Get the filtered records fromthe database
  getFilteredAccidentsFromDB();
}

// Method to update our crime data overlays depending on which crime-data checkboxes are selected
void crimeCheckBoxHandler(CheckBox cb, MySQL connection)
{
  // Get a list of all the checkboxes
  List items = cb.getItems();
  
  // Clear our current list of selections
  crimeCheckboxSelections.clear();
  
  // Loop over each checkbox...
  for (int i = 0; i < items.size(); i++)
  {
      // Get a toggle (i.e. checkbox)
      Toggle t = (Toggle)items.get(i);
      
      // If the checkbox is enabled then add it to the array
      if ( t.getState() )
      {
          crimeCheckboxSelections.add( t.getName() );
      }
      
  } // End of loop over toggles / checkboxes
  
  // Get the filtered records fromthe database
  //getFilteredCrimesFromDB();
}



// Method to get a String array of all unique CSA offences from the crimes table
String[] generateCrimeDropDownData(MySQL dbConnection) {
  String query = "SELECT DISTINCT `CSA Offence Subdivision` FROM `crimes`";
  
  List<String> columnNameList = new ArrayList<String>();
  
  dbConnection.query(query);
  while (dbConnection.next())
  {
    columnNameList.add(dbConnection.getString("CSA Offence Subdivision"));
  }
  
  String[] columnNameArray = new String[ columnNameList.size() ];
  columnNameArray = columnNameList.toArray(columnNameArray);
  
  return columnNameArray;
}
