//class CrimeStalker_DropDown {
//  private ControlP5 parent;
//  private int positionX;
//  private int positionY;
//  private String label;
//  private String[] checkboxList;
//  private int sizeX;
//  private int sizeY;
//  private ControlListener listener;
//  private Group g;
//  private CheckBox cb;
//  
//  public CrimeStalker_DropDown(ControlP5 cp5) {
//    this.parent = cp5;
//    this.checkboxList = new String[0];
//  }
//  
//  public void setPosition(int x, int y) {
//    this.positionX = x;
//    this.positionY = y;
//  }
//  
//  public void setLabel(String label) {
//    this.label = label;
//  }
//  
//  public void setSize(int x, int y) {
//    this.sizeX = x;
//    this.sizeY = y;
//  }
//  
//  public void setCheckBoxList(String[] list) {
//    this.checkboxList = list;
//  }
//  
//  public void setControlListener(ControlListener l) {
//    this.listener = l;
//  }
//  
//  public CheckBox getCheckBox() {
//    return this.cb;
//  }
//  
//  public void initialize() {
//    this.g = this.parent.addGroup(this.label + "_group")
//                  .setPosition(this.positionX, this.positionY)
//                  .setWidth(this.sizeX)
//                  .setBackgroundColor(color(0,76,153,180))
//                  .close();
//    this.g.captionLabel().set(this.label);
//    this.g.setBackgroundHeight(15 * this.checkboxList.length);
//    this.cb = this.parent.addCheckBox(this.label + "_checkbox")
//                  .setColorForeground(color(150))
//                  .setColorBackground(color(202, 225, 255))
//                  .setColorActive(color(0, 151, 35))
//                  .setColorLabel(color(119, 119, 119))
//                  .setColorValue(color(150, 0, 0))
//                  .setSize(20, 20)
//                  .setItemWidth(10)
//                  .setItemHeight(10)
//                  .setItemsPerRow(1)
//                  .setSpacingColumn(10)
//                  .setSpacingRow(5)
//                  .setGroup(this.g);
//    // add data into checkbox
//    for (int i = 0; i < this.checkboxList.length; i++) {
//      this.cb.addItem(this.checkboxList[i], float(i));
//    }
//  }
//}

class CrimeStalker_DropDown
{
  private ControlP5 parent;
  private int positionX;
  private int positionY;
  private String label;
  private String[] checkboxList;
  private int sizeX;
  private int sizeY;
  private ControlListener listener;
  private Group group;
  private CheckBox cb;
  
  public CrimeStalker_DropDown(ControlP5 cp5) {
    this.parent = cp5;
    this.checkboxList = new String[0];
  }
  
  public void setPosition(int x, int y) {
    this.positionX = x;
    this.positionY = y;
  }
  
  public void setLabel(String label) {
    this.label = label;
  }
  
  public void setSize(int x, int y) {
    this.sizeX = x;
    this.sizeY = y;
  }
  
  public void setCheckBoxList(String[] list) {
    this.checkboxList = list;
  }
  
  public void setControlListener(ControlListener l) {
    this.listener = l;
  }
  
  public CheckBox getCheckBox() {
    return this.cb;
  }
  
  public void initialize() {
    
    this.parent.setFont(font);
    
    this.group = this.parent.addGroup(this.label + "_group")
                  .setPosition(this.positionX, this.positionY)
                  .setWidth(this.sizeX + 100)
                  .setBarHeight(this.sizeY + 10)
                  .setBackgroundColor(color(0,0,0, 225)) // Black at with high, but not full opacity
                  .close();
                  
    this.group.captionLabel().set(this.label);
    
    this.group.setBackgroundHeight(17 * this.checkboxList.length);
    
    this.cb = this.parent.addCheckBox(this.label + "_checkbox")
                  .setColorForeground(color(150))
                  .setColorBackground(color(202, 225, 255))
                  .setColorActive(color(0, 151, 35))
                  .setColorLabel(color(255, 255, 255))
                  .setColorValue(color(150, 0, 0))
                  .setSize(20, 20)
                  .setItemWidth(10)
                  .setItemHeight(12)
                  .setItemsPerRow(1)
                  .setSpacingColumn(10)
                  .setSpacingRow(5)
                  .setGroup(this.group);
                  
    // add data into checkbox
    for (int i = 0; i < this.checkboxList.length; i++) {
      this.cb.addItem(this.checkboxList[i], float(i));
    }
  }
}

