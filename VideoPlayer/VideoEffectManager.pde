// Filters for the sharpen, edge detection and blur effects
private final float[][] _sharpenFilter = {{-1,-1,-1},{-1,9,-1},{-1,-1,-1}};
private final float[][] _edgeDetectionFilter = {{-1,-1,-1},{-1,8,-1},{-1,-1,-1}};//{{0,-1,0},{-1,4,-1},{0,-1,0}};
private final float[][] _blurFilter = {{1/9f,1/9f,1/9f},{1/9f,1/9f,1/9f},{1/9f,1/9f,1/9f}};//{{1/16f,1/8f,1/16f},{1/8f,1/4f,1/8f},{1/16f,1/8f,1/16f}};

// Resizes a given frame to the player's size
private void resizeFrame(PImage frame)
{
  if(frame.width != player.getWidth() || frame.height != player.getHeight())
    frame.resize(player.getWidth(), player.getHeight());
}

// Applies a given effect to a given frame
public void applyEffect(PImage frame, int selectedEffect)
{
  // Try to resize it first so that we don't waste time manipulating pixels we don't have to
  resizeFrame(frame);
  
  // Apply the selected effect
  switch(selectedEffect)
  {
    case 1: applyBlackAndWhite(frame); break;
    case 2: applyNegative(frame); break;
    case 3: applyMovementDifference(frame); break;
    case 4: applyFilter(frame, _sharpenFilter); break;
    case 5: applyEdgeDetection(frame); break;
    case 6: applyFilter(frame, _blurFilter); break;
    default: break;
  }
}

// Applies the edge detection filter to a given frame
public void applyEdgeDetection(PImage frame)
{
  // Apply the edge detection filter
  applyFilter(frame, _edgeDetectionFilter);
  
  // Convert to black and white
  applyBlackAndWhite(frame);
}

// Converts a given frame to black and white
private void applyBlackAndWhite(PImage frame)
{
  // For each pixel, set each of the three rgb components with a value equal to their average
  frame.loadPixels();
  for(int i = 0; i < frame.pixels.length; i++)
  {
    float avg = (red(frame.pixels[i]) + green(frame.pixels[i]) + blue(frame.pixels[i])) / 3;
    frame.pixels[i] = color(avg);
  }
  frame.updatePixels();
}

// Converts a given frame to its negative
private void applyNegative(PImage frame)
{
  // For each pixel, change each of the rgb components to its complement
  frame.loadPixels();
  for(int i = 0; i < frame.pixels.length; i++)
    frame.pixels[i] = color(255 - red(frame.pixels[i]), 255 - green(frame.pixels[i]), 255 - blue(frame.pixels[i]));
  frame.updatePixels();
}

// Applies a given filter to a given frame
private void applyFilter(PImage frame, float[][] filter)
{
  PImage filteredFrame = createImage(frame.width, frame.height, RGB);
  filteredFrame.copy(frame, 0, 0, frame.width, frame.height, 0, 0, filteredFrame.width, filteredFrame.height);
  
  frame.loadPixels();
  filteredFrame.loadPixels();

  for (int r = 1; r < (frame.height-1); r++) //traverse each image line, excludes first and last that are special case
  {
    for(int c = 1; c < (frame.width-1); c++) //traverse each image columns, excludes first and last that are special case
    {
      float red = applyFilterbyChannel(c,r,0, filter, frame);
      float green = applyFilterbyChannel(c,r,1, filter, frame);
      float blue = applyFilterbyChannel(c,r,2, filter, frame);
     
      filteredFrame.pixels[c+(frame.width*r)] = color(red,green,blue);
         
      }
    }
  
  frame.updatePixels();
  filteredFrame.updatePixels();
  
  frame.copy(filteredFrame, 0, 0, frame.width, frame.height, 0, 0, filteredFrame.width, filteredFrame.height);
}

//apply filter in a particular color channel
private float applyFilterbyChannel(int col, int row,int channel, float[][] filter, PImage frame)
{

  float channelTotal = 0; //weighted sum
  int coltrans = col-1; //starts filter cycle in left column of 3x3 matrix
  int rowtrans = row-1; //starts filter cycle in top row of 3x3 matrix
  int filterSize = filter.length;

  for (int r = 0; r < filterSize; r++)
  {
    for(int c = 0; c < filterSize; c++)
    {
      switch(channel){
        case 0:
          channelTotal += red(frame.pixels[(coltrans+c)+(frame.width*(rowtrans+r))])*filter[r][c]; //filter[r][c] - r row and c column of filter 
          break;
        case 1:
          channelTotal += green(frame.pixels[(coltrans+c)+(frame.width*(rowtrans+r))])*filter[r][c]; 
          break;
        case 2:
          channelTotal += blue(frame.pixels[(coltrans+c)+(frame.width*(rowtrans+r))])*filter[r][c]; 
          break;
        default:
         break;
     }
    }
  }
  return min(255.0,max(0.0,channelTotal)); //final value cannot be less than 0 and more than 255
}

// Applies movement difference to a given frame relative to the previously read frame, converting to black and white
private void applyMovementDifference(PImage frame)
{
  frame.loadPixels();
  previousFrame.loadPixels();
  
  // For each pixel, calculate the movement difference for each rgb component, average them and set it as the pixel's brightness
  for(int i = 0; i < frame.pixels.length; i++) { 
                            
      float r = abs(red(frame.pixels[i])-red(previousFrame.pixels[i]));
      float g = abs(green(frame.pixels[i])-green(previousFrame.pixels[i]));
      float b = abs(blue(frame.pixels[i])-blue(previousFrame.pixels[i]));
      float avg = (r + g + b) / 3;
      frame.pixels[i] = color(avg, avg, avg);
  }
       
  previousFrame.updatePixels();
  frame.updatePixels();
}

// Applies movement difference to a given frame relative to another given frame
public void applyMovementDifference(PImage frame, PImage prevFrame)
{
  // Try to resize them first so that we don't waste time manipulating pixels we don't have to
  resizeFrame(frame);
  resizeFrame(prevFrame);
  
  frame.loadPixels();
  prevFrame.loadPixels();
  
  // For each pixel, calculate the movement difference for each rgb component, average them and set it as the pixel's brightness
  for(int i = 0; i < frame.pixels.length; i++) { 
                            
      float r = abs(red(frame.pixels[i])-red(prevFrame.pixels[i]));
      float g = abs(green(frame.pixels[i])-green(prevFrame.pixels[i]));
      float b = abs(blue(frame.pixels[i])-blue(prevFrame.pixels[i]));
      float avg = (r + g + b) / 3;
      frame.pixels[i] = color(avg, avg, avg);
  }
  
  prevFrame.updatePixels();
  frame.updatePixels();
}
