// load homography matrix from CSV
float[] loadHomography(String fname) {
  Table table = loadTable(fname);
  float[] h = new float[9];
  for (int row=0; row<3; row++) {
    for (int col=0; col<3; col++) {
      h[row*3+col] = table.getRow(row).getFloat(col);
    }  
  }
  return h;
}

// load calibration coords from csv
double[][] loadCoords(String fname) {
  Table table = loadTable(fname);
  double[][] coords = new double[4][2];
  for (int row=0; row<4; row++) {
    for (int col=0; col<2; col++) {
      coords[row][col] = table.getRow(row).getFloat(col);
    }  
  }
  return coords;
}

List<Location> loadLocations(String fname) {
  JSONObject json = loadJSONObject(fname);
  JSONArray items = json.getJSONArray("locations");
  List<Location> locations = new LinkedList<Location>();
  for (int i=0; i<items.size(); i++) {
    JSONObject item = items.getJSONObject(i);
    locations.add(new Location(
      item.getFloat("longitudeE7") / 1E7,
      item.getFloat("latitudeE7") / 1E7,
      item.getLong("timestampMs"),
      item.getInt("accuracy")
    ));    
  }
  return locations;
}
