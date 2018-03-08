class GaussianFilter {
  
  private double[] kernel;
  private int kernelSize;
  private int width;
  private int height;
  
  public GaussianFilter(float sigma, int kernelSize, int width, int height) {
    this.kernelSize = kernelSize;
    this.width = width;
    this.height = height;
    
    kernel = new double[kernelSize * kernelSize];
    for (int y = 0; y < kernelSize; y++) {
      double y2c = y - (kernelSize - 1) / 2;
      for (int x = 0; x < kernelSize; x++) {
        double x2c = x - (kernelSize - 1) / 2; 
        kernel[x + y * kernelSize] = 1 / (2 * Math.PI * sigma * sigma) 
                    * Math.exp(- (x2c * x2c + y2c * y2c) / (2 * sigma * sigma));
      }
    }
    
  }
  
  public int[] filter(int[] input) {
    int[] result = new int[input.length];
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int value = 0;
        int overflow = 0;
        int kernelHalf = (kernelSize - 1) / 2;
        for (int j = -kernelHalf; j <= kernelHalf; j++) {
          for (int i = -kernelHalf; i <= kernelHalf; i++) {
            int searchX = x + i;
            int searchY = y + j;
            int kernelIndex = i + j * kernelSize + ((kernelSize * kernelSize) - 1) / 2;
            if (searchX < 0 || searchX >= width || searchY < 0 || searchY >= height) {
              overflow += kernel[kernelIndex];
              continue;
            }
            int v = input[searchX + searchY * width];
            if (v == 0) {
              v = 4500;
            }
            value += (int)(v * kernel[kernelIndex]);
          }
        }
        
        if (overflow > 0) {
          value = 0;
          for (int j = -kernelHalf; j <= kernelHalf; j++) {
            for (int i = -kernelHalf; i <= kernelHalf; i++) {
              int searchX = x + i;
              int searchY = y + j;
              int kernelIndex = i + j * kernelSize + ((kernelSize * kernelSize) - 1) / 2;
              if (searchX < 0 || searchX >= width || searchY < 0 || searchY >= height) {
                continue;
              }
              int v = input[searchX + searchY * width];
              if (v == 0) {
                v = 4500;
              }
              value += (int)(v * kernel[kernelIndex] * (1 / (1 - overflow)));
            }
          }
        }
        result[x + y * width] = value;
      }
    }
    //println("Here i am");
    return result;
  }
}