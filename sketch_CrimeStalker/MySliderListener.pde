//MySliderListener mySliderListener;
//
//class MySliderListener implements ControlListener
//{
//  public boolean sliderBeingDragged = false;
//  private int currentValue = 0;
//  
//  public void controlEvent(ControlEvent theEvent) {
//    sliderBeingDragged = true;
//   
//    // Round the slider value to the nearest int (we don't want to use fractional values - these are week numbers!)
//    int  val = Math.round( theEvent.getController().getValue() );
//    
//    // If our slider value is different to the value that we previously had...
//    if (val != this.currentValue)
//    {
//        // Update our current slider value
//        this.currentValue = val;
//        
//        println("i got an event from mySlider, gotvalue: " + val);
//      
//        // Map the slider value (in range 0 to 259) into the unix time range from our earliest record to our most recent record
//        long mappedTime = Math.round( map(val, 0, 259, minUnixTime, maxUnixTime) );
//      
//        // Update the sliderUnixTime which we use in our SQL query for a slice of data
//        // Note: sliderUnixTime is declared in the main sketch
//        sliderUnixTime = mappedTime;
//    
//        //println("Mapped unix time is: " + mappedTime);
//      
//        // Update our marker data for this new time period
//        getFilteredAccidentsFromDB();
//
//    }
//  }
//}

MySliderListener mySliderListener;

class MySliderListener implements ControlListener
{
  public boolean sliderBeingDragged = false;
  private int currentValue = 0;
  
  public void controlEvent(ControlEvent theEvent) {
    sliderBeingDragged = true;
   
    int  val = Math.round( theEvent.getController().getValue() );
    if (val != this.currentValue) {
      this.currentValue = val;
      println("i got an event from mySlider, gotvalue: " + val);
      
      long mappedTime = Math.round( map(val, 0, 259, minUnixTime, maxUnixTime) );
      
    // This is in the main sketch
    sliderUnixTime = mappedTime;
    
      println("Mapped unix time is: " + mappedTime);
      
      // Update our marker data for this new time period
      getFilteredAccidentsFromDB();
      
      // Get strings for record range
      Date startDate = new Date(sliderUnixTime * 1000L);
      Date endDate   = new Date( (sliderUnixTime + ONE_WEEK_IN_SECONDS) * 1000L ); // End date is current date plus 7 days worth of seconds
      String startDateString = dfm.format(startDate);
      String endDateString   = dfm.format(endDate);
      
      
      
     // getAccidentsByTimePeriod(mappedTime);
      theEvent.getController().getCaptionLabel().setText("Data range: " + startDateString + " to " + endDateString + ". Records: " + currentAccidentRecordCount);
    }
  }
}
