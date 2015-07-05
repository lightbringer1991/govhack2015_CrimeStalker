class Filter{
   ArrayList<Column> columnList;
   
   Filter(){
     columnList = new ArrayList<Column>();
   }
   
   void addColumn(String name){
     columnList.add(new Column(name));
   }
   
   void addColumn(String name, String desc){
     columnList.add(new Column(name, desc));
   }
   
   ArrayList<Column> getColumnList(){
     return columnList;
   }
   
  String getColumnNameByIndex(int i){
    return columnList.get(i).getName();
  }
  
  String getColumnDescByIndex(int i){
    return columnList.get(i).getDesc();
  }

  void setCheckByIndex(int i, boolean check){
    columnList.get(i).setCheck(check);
  }
  
  int getSize(){
     return columnList.size();
  }
}

class Column{
  String name;
  String desc;
  boolean isChecked;
 
  Column(String name){
    this.name = name;
    this.desc = "";
    isChecked = false;
  }
 
  Column(String name, String desc){
    this.name = name;
    this.desc = desc;
    isChecked = false;
  }
 
  void setCheck(boolean check){
    isChecked = check;
  }
 
  String getName(){
    return name;
  }
 
  String getDesc(){
    return desc;
  }
  
  boolean isChecked(){
    return isChecked;
  } 
}
