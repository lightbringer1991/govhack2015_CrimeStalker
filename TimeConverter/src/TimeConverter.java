import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.TimeZone;

/** Program to convert a large list of dates and times from the AU Traffic Accident Commission
 * "Crashes_Last_Five_Years" dataset into unix time for easy segmentation during visualisation.
 * 
 * Released under a CC-BY-A license by Al Lansley, GovHack 2015, Ballarat, Victoria.
 * https://creativecommons.org/licenses/by/4.0/
 */

public class TimeConverter
{
	public static String newLine = System.lineSeparator();
	
	// Specify the date format
	// Note: This handles zero-padding nicely for us
    DateFormat dfm = new SimpleDateFormat("dd/MM/yyyy/HH.mm.ss");
    
    public static void main(String[] args)
    {		
    	new TimeConverter();
    }
    
    // Constructor does the work. Poor show, I know.
    TimeConverter()
    {
    	
    	// Set the timezone for Melbourne
    	dfm.setTimeZone(TimeZone.getTimeZone("Australia/Melbourne"));
    	
    	// Test
    	//long foo = convert("2015/7/4/14.38.00"); //1435984680    	
    	//System.out.println(foo);
    	
    	System.out.println("Starting reading files...");
    	
    	// ----- Get all dates -----
    	
    	List<String> dateList = new ArrayList<String>();
    	
    	try (BufferedReader br = new BufferedReader(new FileReader("ACCIDENT_DATE.txt")))
    	{        
            String line = br.readLine();

            while (line != null)
            {
                dateList.add(line + "/");                
                line = br.readLine();
            }
        }
    	catch (Exception e)
    	{
			e.printStackTrace();
		}
    	
    	System.out.println("Date list size is: " + dateList.size() );
    	
    	
    	// ----- Get all times -----
    	
    	List<String> timeList = new ArrayList<String>();
    	
    	try (BufferedReader br = new BufferedReader(new FileReader("ACCIDENT_TIME.txt")))
    	{        
            String line = br.readLine();

            while (line != null)
            {
                timeList.add(line);                
                line = br.readLine();
            }
        }
    	catch (Exception e)
    	{
			e.printStackTrace();
		}
    	
    	System.out.println("Time list size is: " + timeList.size() );
    	
    	// ----- Convert to unix time and write to file -----
    	
    	try (BufferedWriter bw = new BufferedWriter(new FileWriter("UNIX_TIME.txt")))
    	{        
    		
    		int numRows = dateList.size();
            for (int loop = 0; loop < numRows; ++loop)
            {
            	String combinedDateTime = dateList.get(loop) + timeList.get(loop);
            	System.out.println(combinedDateTime);
            	
            	Long unixTime = this.convert(combinedDateTime);
            	System.out.println("In unix time is: " + unixTime);
            	
            	bw.append(unixTime.toString() + newLine);                
            }
        }
    	catch (Exception e)
    	{
			e.printStackTrace();
		}
    	
    	System.out.println("Conversion to unix time complete!");
	}
    
    private long convert(String time)
    {
    	long unixtime = 0;
    	try	    
	    {
	        unixtime = dfm.parse(time).getTime();
	        
	        unixtime = unixtime / 1000;
	    } 
	    catch (ParseException e) 
	    {
	        e.printStackTrace();
	    }
    	
	    return unixtime;
	}
	
}