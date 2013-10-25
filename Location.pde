class Location {
  // data from log
  float longitude;
  float latitude;
  long timestamp;
  int accuracy;
  
  // generated data
  int day, month, year;
  int second, minute, hour, millisecond;
  int daystamp;
  String date, time; 
  
  public Location(float longitude, float latitude, long timestamp, int accuarcy) {
    this.longitude = longitude;
    this.latitude = latitude;
    this.timestamp = timestamp;
    this.accuracy = accuracy;
    
    // calculate date
    Calendar calender = GregorianCalendar.getInstance();
    calender.setTimeInMillis(timestamp - timeOffset);
    day = calender.get(Calendar.DAY_OF_MONTH);
    month = calender.get(Calendar.MONTH)+1;
    year = calender.get(Calendar.YEAR);
    date = String.format("%02d", day)+"."+String.format("%02d", month)+"."+year;
    
    // calculate time
    millisecond = calender.get(Calendar.MILLISECOND);
    second = calender.get(Calendar.SECOND);
    minute = calender.get(Calendar.MINUTE);
    hour = calender.get(Calendar.HOUR_OF_DAY);
    time = hour+":"+String.format("%02d", minute)+":"+String.format("%02d", second)+"'"+String.format("%03d", millisecond);
    
    // calculate daystamp (millisecond timestamp starting at each day)
    daystamp = millisecond + 1000*(second + 60*(minute + 60*hour));
  }
  
  String toString() {
    return longitude + " " + latitude;  
  }
}
