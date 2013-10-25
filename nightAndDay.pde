final color night = color(150,150,190);
final color day = color(255,255,250);
final color dusk = color(230,190,180);

int[] cycleTimes = {
  0,
  
  6*3600000,
  8*3600000,
  
  17*3600000,
  18*3600000,
  19*3600000,
  
  24*3600000,
};

color[] cylceColors = {
  night,
  
  night,
  day,
  
  day,
  dusk,
  night,
  
  night,
};

int findCycle(int daystamp) {
  int lastI = 0;
  for (int i=0; i<cycleTimes.length-1; i++) {
    if (daystamp < cycleTimes[i]) {
      return lastI;
    }
    lastI = i;
  }
  return lastI;
}

color nightAndDay(int time) {
  time = (time + timeOffset) % (24*3600000);
  
  int cycle = findCycle(time);
  color from = cylceColors[cycle];
  color to = cylceColors[cycle+1];
  
  float start = cycleTimes[cycle];
  float end = cycleTimes[cycle+1];
  
  float amt = (time - start) / (end - start);
  
  return lerpColor(from, to, amt);
}
