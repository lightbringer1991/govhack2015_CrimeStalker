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

        

        if ( this.isInside(mouseX, mouseY, x, y) )
        {
          println("Hovering over: " + id);
          //text(x, y, id);
        }
    }

    @Override
    protected boolean isInside(float checkX, float checkY, float x, float y)
    {
        return checkX > x && checkX < x + img.width && checkY > y && checkY < y + img.height;
    }
}
