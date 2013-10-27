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

// homography estimation
float[] homest(double[][] x, double[][] X) {
  // equation system to solve for h
  double[][] A = new double[8][];
  double[][] b = new double[8][];
  for (int i=0; i<4; i++) {
    // coefficients
    A[2*i+0] = new double[] { x[i][0], x[i][1], 1, 0, 0, 0, -X[i][0]*x[i][0], -X[i][0]*x[i][1] }; 
    A[2*i+1] = new double[] { 0, 0, 0, x[i][0], x[i][1], 1, -X[i][1]*x[i][0], -X[i][1]*x[i][1] };
    // constant terms
    b[2*i+0] = new double[] { X[i][0] };
    b[2*i+1] = new double[] { X[i][1] };
  };    
  
  // solve Ah = b
  double[][] h = new LUD(A).solve(b);

  // convert to homography matrix
  return new float[] {
    (float) h[0][0], (float) h[1][0], (float) h[2][0],
    (float) h[3][0], (float) h[4][0], (float) h[5][0],
    (float) h[6][0], (float) h[7][0], 1,
  };  
}

public class LUD {
  
  /**
   * LU Decomposition
   * directly operates on 2D arrays
   * can be used to solve linear equation systems, invert (squared) matrices, etc.
   * derived from http://math.nist.gov/javanumerics/jama/
   * (removed dependency to the rest of the library)
   */

  private double[][] LU; // internal array storage
  private int m, n, pivsign; // matrix dimensions and pivot sign
  private int[] piv; // pivot vector

  public LUD(double[][] M) {

    // Use a "left-looking", dot-product, Crout/Doolittle algorithm.
    LU = M;
    m = M.length;
    n = M[0].length;
    piv = new int[m];
    for (int i = 0; i < m; i++) {
      piv[i] = i;
    }
    pivsign = 1;
    double[] LUrowi;
    double[] LUcolj = new double[m];

    // Outer loop.
    for (int j = 0; j < n; j++) {

      // Make a copy of the j-th column to localize references.
      for (int i = 0; i < m; i++) {
        LUcolj[i] = LU[i][j];
      }

      // Apply previous transformations.
      for (int i = 0; i < m; i++) {
        LUrowi = LU[i];

        // Most of the time is spent in the following dot product.
        int kmax = Math.min(i, j);
        double s = 0.0;
        for (int k = 0; k < kmax; k++) {
          s += LUrowi[k] * LUcolj[k];
        }

        LUrowi[j] = LUcolj[i] -= s;
      }

      // Find pivot and exchange if necessary.
      int p = j;
      for (int i = j + 1; i < m; i++) {
        if (Math.abs(LUcolj[i]) > Math.abs(LUcolj[p])) {
          p = i;
        }
      }
      if (p != j) {
        for (int k = 0; k < n; k++) {
          double t = LU[p][k];
          LU[p][k] = LU[j][k];
          LU[j][k] = t;
        }
        int k = piv[p];
        piv[p] = piv[j];
        piv[j] = k;
        pivsign = -pivsign;
      }

      // Compute multipliers.
      if (j < m & LU[j][j] != 0.0) {
        for (int i = j + 1; i < m; i++) {
          LU[i][j] /= LU[j][j];
        }
      }
    }
  }

  public boolean isNonsingular() {
    for (int j = 0; j < n; j++) {
      if (LU[j][j] == 0)
        return false;
    }
    return true;
  }

  public int[] getPivot() {
    int[] p = new int[m];
    for (int i = 0; i < m; i++) {
      p[i] = piv[i];
    }
    return p;
  }   

  // Return pivot permutation vector as a one-dimensional double array
  public double[] getDoublePivot() {
    double[] vals = new double[m];
    for (int i = 0; i < m; i++) {
      vals[i] = (double) piv[i];
    }
    return vals;
  }
  
  public double det() {
    if (m != n) {
      throw new IllegalArgumentException("Matrix must be square.");
    }
    double d = (double) pivsign;
    for (int j = 0; j < n; j++) {
      d *= LU[j][j];
    }
    return d;
  }  
  
  private double[][] identity(int m) {
    double[][] I = new double[m][m];
    for (int i = 0; i < m; i++) {
      for (int j = 0; j < m; j++) {
        I[i][j] = i == j ? 1 : 0;
      }
    }
    return I;
  }    
  
  public double[][] inverse() {
    return solve(identity(m));
  }
   
  private double[][] submat(double[][] A, int[] r, int j0, int j1) {
    double[][] B = new double[r.length][j1 - j0 + 1];
    for (int i = 0; i < r.length; i++) {
      for (int j = j0; j <= j1; j++) {
        B[i][j - j0] = A[r[i]][j];
      }
    }
    return B;
  }
  
  public double[][] getL() {
    double[][] L = new double[m][n];
    for (int i = 0; i < m; i++) {
      for (int j = 0; j < n; j++) {
        if (i > j) {
          L[i][j] = LU[i][j];
        } else if (i == j) {
          L[i][j] = 1.0;
        } else {
          L[i][j] = 0.0;
        }
      }
    }
    return L;
  }

  public double[][] getU() {
    double[][] U = new double[m][n];
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (i <= j) {
          U[i][j] = LU[i][j];
        } else {
          U[i][j] = 0.0;
        }
      }
    }
    return U;
  }  

  /** Solve A*X = B
  @param  B   A Matrix with as many rows as A and any number of columns.
  @return     X so that L*U*X = B(piv,:)
  @exception  IllegalArgumentException Matrix row dimensions must agree.
  @exception  RuntimeException  Matrix is singular.
  */
  public double[][] solve(double[][] B) {
    if (B.length != m) {
      throw new IllegalArgumentException("Matrix row dimensions must agree.");
    }
    if (!this.isNonsingular()) {
      throw new RuntimeException("Matrix is singular.");
    }

    // Copy right hand side with pivoting
    int nx = B[0].length;
    double[][] X = submat(B, piv, 0, nx - 1);

    // Solve L*Y = B(piv,:)
    for (int k = 0; k < n; k++) {
      for (int i = k + 1; i < n; i++) {
        for (int j = 0; j < nx; j++) {
          X[i][j] -= X[k][j] * LU[i][k];
        }
      }
    }
    // Solve U*X = Y;
    for (int k = n - 1; k >= 0; k--) {
      for (int j = 0; j < nx; j++) {
        X[k][j] /= LU[k][k];
      }
      for (int i = 0; i < k; i++) {
        for (int j = 0; j < nx; j++) {
          X[i][j] -= X[k][j] * LU[i][k];
        }
      }
    }
    return X;
  }
}
