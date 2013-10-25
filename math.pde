PVector transform(float[] h, float x, float y) {
  float u = h[0]*x + h[1]*y + h[2];
  float v = h[3]*x + h[4]*y + h[5];
  float w = h[6]*x + h[7]*y + h[8];
  return new PVector(u/w, v/w, 0);
}

PImage gauss(int r, float sigmasq) { // normalized gauss distribution
  int w = 2*r+1;
  //float[] v = new float[w*w];
  PImage img = createImage(w,w,ALPHA);
  float a = 255.0;
  for (int i=-r; i<r; i++) {
    for (int j=-r; j<r; j++) {
      float dstSq = i*i + j*j;
      //v[(i+r) + (j+r)*w] = 1;
      //v[(i+r) + (j+r)*w] = a * exp(-dstSq / (2*sigmasq));
      img.pixels[(i+r) + (j+r)*w] = (int) (a * exp(-dstSq / (2*sigmasq)));
      //v[(i+r) + (j+r)*w] = exp(-dstSq / (2*c));
    }
  }  
  img.updatePixels();
  return img;
}
