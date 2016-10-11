class DataPoint {
  private int [] data;
  private String name;
  private int redVal;
  private int blueVal;
  private int greenVal;
  public DataPoint(String name, int[] inputData) {
    this.redVal = 0;
    this.greenVal = 0;
    this.blueVal = 0;
    this.name = name;
    data = new int[inputData.length];
    for (int i = 0; i < inputData.length; i++) {
      data[i] = inputData[i];
    }
  }
}


public DataPoint[] fileToDataPoints(String filename) {
  Table data = loadTable(filename);
  DataPoint[] allData = new DataPoint[data.getRowCount()-1];
  for (int i = 1; i < data.getRowCount(); i++) { //for each datapoint (skip first row of colNames)
    String name = data.getString(i, 0); //gets name
    int [] dataForDataPoint = new int [data.getColumnCount()-1];
    for (int j = 1; j <data.getColumnCount(); j++) { //for each col of actual data in datapoint
      dataForDataPoint[j-1] = data.getInt(i, j); //stores int data into data array
    }
    allData[i-1] = new DataPoint(name, dataForDataPoint);
  }
  return allData;
}

public String[] getColNames(String filename) {
  Table data = loadTable(filename);
  String[] colNames = new String[data.getColumnCount()];
  for (int j = 0; j < data.getColumnCount(); j++) { //for each col in first row
    colNames[j] = data.getString(0, j);
  }
  return colNames;
}

public float getMaxValFromCol(DataPoint[] data, int col){
  float max = 0;
  for (DataPoint d : data) {
    if (d.data[col] > max) max = d.data[col];
  }
  return max;
}

public float getMinValFromCol(DataPoint[] data, int col){
  float min = data[0].data[col]; //sets min as first cell
  for (DataPoint d : data) {
    if (d.data[col] < min) {
      min = d.data[col];
    }
  }
  return min;
}

public void updateColorVals(DataPoint[] dataSet, int col) {
  float max = getMaxValFromCol(dataSet, col);
  float min = getMinValFromCol(dataSet, col);
  for (DataPoint d : dataSet) {
    float percentMax = (d.data[col]-min)/(max-min);
    d.redVal = (int)(percentMax*255);
    d.blueVal = (int)((1-percentMax)*255);
  }
}

//use pGraphics to draw bars on top of lines so you click on the right thing...

void setup() {
  size(800, 600);
  background(250);
  stroke(0);
  fill(50);
  surface.setResizable(true); // allows you to resize the canvas
}

int numBars;
float barSeparation;
boolean[] isAscending;
boolean firstRun = true;
int selectedCol = 0;
boolean dragging = false;
float initX;
float initY;
float finalX;
float finalY;



void draw() {
  clear();
  background(250);
  //import data and get values
  String fileName = "data.csv";
  DataPoint[] allData = fileToDataPoints(fileName);
  String[] colNames = getColNames(fileName);
  if (firstRun) {
    isAscending = new boolean[colNames.length];
    for (int k = 0; k < isAscending.length; k++) {
      isAscending[k] = true;
    }
    firstRun = false;
  }
  boolean[] mouseOverLine = new boolean[allData.length];
  for (int l = 0; l < allData.length; l++) {
    mouseOverLine[l] = false;
  }
  //draw rect
  if (dragging) {
    rect(initX, initY, mouseX-initX, mouseY-initY);
  } else {
    rect (initX, initY, finalX-initX, finalY-initY);
  }
  
  //draw graph lines and names
  strokeWeight(5);
  float zeroXpx = width*.15;
  float zeroYpx = height*.85;
  float maxXpx = width*.85;
  float maxYpx = height*.15;
  float graphHeightpx = zeroYpx-maxYpx;
  float graphWidthpx = maxXpx - zeroXpx;
  float barSeparationWidth = graphWidthpx/(colNames.length-2);
  float currentX = zeroXpx;
  float[] colXpx = new float[colNames.length-1];
  numBars = colNames.length;
  barSeparation = barSeparationWidth;
  for (int i = 1; i < colNames.length; i++) {
    colXpx[i-1] = currentX; //stores x coord of each bar for later...
    line(currentX, zeroYpx, currentX, maxYpx);
    text(colNames[i], currentX, zeroYpx+height*.1);
    currentX +=barSeparationWidth;
  }
  strokeWeight(1);
  updateColorVals(allData, selectedCol);
  for (int d = 0; d < allData.length; d++) { //for each datapoint
    for (int i = 1; i < allData[d].data.length; i++) { //starting at second value, "for each column in data..."
      int currentVal = allData[d].data[i];
      float currentMax = getMaxValFromCol(allData, i);
      float currentMin = getMinValFromCol(allData, i);
      int prevVal = allData[d].data[i-1];
      float prevMax = getMaxValFromCol(allData, i-1);
      float prevMin = getMinValFromCol(allData, i-1);
      if (i == 1) {
        if (isAscending[0]) {
          text(prevMin, colXpx[0], zeroYpx+height*.05);
          text(prevMax, colXpx[0], maxYpx-height*.05);
        } else {
          text(prevMin, colXpx[0], maxYpx-height*.05);
          text(prevMax, colXpx[0], zeroYpx+height*.05);
        }
      }
      if (isAscending[i]) {
        text(currentMin, colXpx[i], zeroYpx+height*.05);
        text(currentMax, colXpx[i], maxYpx-height*.05);
      } else {
        text(currentMin, colXpx[i], maxYpx-height*.05);
        text(currentMax, colXpx[i], zeroYpx+height*.05);
      }
      float currentValpx;
      float prevValpx;
      if (isAscending[i]) { //if current col is ascending
        float fractionAlongLine = (currentVal-currentMin)/(currentMax-currentMin);
        currentValpx = zeroYpx + (maxYpx-zeroYpx)*fractionAlongLine;
      } else { //FIXME
        float fractionAlongLine = (currentVal-currentMin)/(currentMax-currentMin);
        currentValpx = maxYpx - (maxYpx-zeroYpx)*fractionAlongLine;
      }
      if (isAscending[i-1]) {
        float fractionAlongPrevLine = (prevVal-prevMin)/(prevMax-prevMin);
        prevValpx = zeroYpx + (maxYpx-zeroYpx)*fractionAlongPrevLine;
      } else { //FIXME
        float fractionAlongPrevLine = (prevVal-prevMin)/(prevMax-prevMin);
        prevValpx = maxYpx - (maxYpx-zeroYpx)*fractionAlongPrevLine;
      }
      println(colXpx[i]);
      if (((prevValpx > initY && prevValpx < finalY) || (prevValpx < initY && prevValpx > finalY)) && ((colXpx[i-1]> initX && colXpx[i-1] < finalX)||(colXpx[i-1]<initX && colXpx[i-1] > finalX))){
        allData[d].greenVal = 255;
      } else if (((currentValpx > initY && currentValpx < finalY) || (currentValpx < initY && currentValpx > finalY)) && ((colXpx[i]> initX && colXpx[i] < finalX)||(colXpx[i]<initX && colXpx[i] > finalX))) {
        allData[d].greenVal = 255;
      }
    
      stroke(allData[d].redVal, allData[d].greenVal, allData[d].blueVal);
      //
      if (i == 1) {
        noFill();
        beginShape();
        curveVertex(colXpx[i-1], prevValpx);
        curveVertex(colXpx[i-1], prevValpx);
        curveVertex(colXpx[i], currentValpx);
      }
      else if (i != allData[d].data.length-1) {
        curveVertex(colXpx[i], currentValpx);
      }
      else {
        curveVertex(colXpx[i], currentValpx);
        curveVertex(colXpx[i], currentValpx);
        endShape();
      }
      //
      //line(colXpx[i-1], prevValpx, colXpx[i], currentValpx);  
    }
    stroke(0);
  }
  
  
}
void mousePressed() {
  dragging = true;
  initX = mouseX;
  initY = mouseY;
}
void mouseReleased() {
  float xVal = width*.15;
  for (int i = 0; i < numBars; i++) {
    if (mouseX > xVal-5 && mouseX < xVal+5 && mouseY > height*.15 && mouseY<height*.85) {
      isAscending[i] = !isAscending[i];
      selectedCol = i;
    }
    xVal += barSeparation;
  }
  finalX = mouseX;
  finalY = mouseY;
  dragging = false;
}