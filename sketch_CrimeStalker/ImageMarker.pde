import processing.core.PConstants;
import processing.core.PGraphics;
import processing.core.PImage;
import de.fhpotsdam.unfolding.geo.Location;
import de.fhpotsdam.unfolding.marker.AbstractMarker;

/** This marker displays an image at its location. */
class ImageMarker extends AbstractMarker
{
    PImage img;

    String id;

    public ImageMarker(Location location, String accidentNum, PImage img)
    {
	super(location);
        id = accidentNum;
  	this.img = img;
    }

    @Override
    public void draw(PGraphics pg, float x, float y)
    {
	pg.pushStyle();
	  pg.imageMode(PConstants.CORNER);
	  // The image is drawn in object coordinates, i.e. the marker's origin (0,0) is at its geo-location.
	  pg.image(img, x - 11, y - 37);

          //fill(255,255,255,140);
          //ellipseMode(RADIUS);
          //ellipse(x, y, 40, 20);

	pg.popStyle();

        if ( this.isInside(mouseX, mouseY, x, y))
        {
          println("Hovering over: " + id);
          String details = this.generateAccidentDetails(id);
          pg.fill(color(255, 255, 255));
          pg.rect(mouseX, mouseY, pg.textWidth(details) + 10 * 1.5f, 12 * 3 + 10);
          pg.fill(color(0, 0, 0));
          pg.text(details, mouseX, mouseY + 12);
          
        }
    }

    @Override
    protected boolean isInside(float checkX, float checkY, float x, float y)
    {
        return checkX > x && checkX < x + img.width && checkY > y && checkY < y + img.height;
    }
    
    private String generateAccidentDetails(String id) {
      String query = "SELECT `ACCIDENT_DATE`, `ACCIDENT_TIME`, `ACCIDENT_TYPE`, `DCA_CODE` FROM `accidents` WHERE `ACCIDENT_NO`='" + id + "'";
      dbConnection.query(query);

      dbConnection.next();
      String result = "Time: " + dbConnection.getString("ACCIDENT_DATE") + " " + dbConnection.getString("ACCIDENT_TIME") + "\n"
                        + "Type: " + dbConnection.getString("ACCIDENT_TYPE") + "\n" 
                        + "Nature: " + dbConnection.getString("DCA_CODE");
      return result;
    }

}
