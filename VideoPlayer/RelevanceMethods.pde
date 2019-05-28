//
// Methods for picking the most relevant moments according to the selected effect
//

// Movement: Thumbnails are chosen based on how much movement there is relative to the
// previous frame. Usually these moments represent cuts in a scene and we opted not to
// filter them out as we think it's an interesting outcome.

// Black and white: Thumbnails are chosen based on how dark they are. The darker the
// thumbnail the more likely it is to be chosen.

// Sharpness: Thumbnails are chosen based on how sharp they are. The sharper the image
// the more likely it is to be chosen. To get a measure for how sharp an image is, we
// first apply edge detection to it and then count how many edges were detected.
// Edge detection is a good way to measure how sharp an image is since a blurry image
// is characterized by blurred/non-sharp edges.
// It can be difficult to see as all thumbnails are sharpened and typically it's difficult
// to distinguish between them. However, in a video with some portions pre-blurred it is clear
// that those don't get chosen.

// Negative: Thumbnails are chosen based on how much difference in color there is between
// the original image and their negative counterpart. Might be difficult to perceive as
// it's not particularly intuitive.

// Edge detection: Thumbnails are chosen based on how many edges are detected. After that we
// convert it to black and white. The more edges detected, the more likely it is to be chosen.

// Blur: Thumbnails are chosen based on how blurred they are. The more blurred the image
// the more likely it is to be chosen. To get a measure for how blurred an image is, we
// first apply edge detection to it and then count how many edges were detected, for the
// same reason as in the sharpness method.
// It can be difficult to see as all thumbnails are blurred and typically it's difficult
// to distinguish between them. However, in a video with some portions pre-blurred it is clear
// that those are blurrier and get chosen.

// The resulting ArrayList from these methods is ordered from the less relevant sample to
// the most relevant. The next step in the loadingThumbnails() process is to keep removing
// the first element of the ArrayList until we are left with the number of thumbnails needed


// Sorts the given ArrayList of sample thumbnails with the black and white method
void sortByBlackAndWhite(ArrayList<SampleThumbnail> t)
{
  // Calculate the scores for each sample
  int n = t.size();
  for(int i = 0; i < n; i++)
  {
    int score = 0;
    PImage frame = t.get(i).getFrame();
      
    // Sums the rgb components of each pixel
    // The brighter the frame, the higher the final sum
    frame.loadPixels();
    for(int k = 0; k < frame.pixels.length; k++)
      score += red(frame.pixels[k]) + green(frame.pixels[k]) + blue(frame.pixels[k]);
    frame.updatePixels();
    
    // Set the score as negative so that the frames with
    // more light colored pixels have a worse score since
    // we want to keep the darkest samples
    t.get(i).setScore(-score);
  }
  
  // Sort the scores in ascending order
  sortByScore(t);
}

// Sorts the given ArrayList of sample thumbnails with the movement method
void sortByMovement(ArrayList<SampleThumbnail> t)
{
  // Calculate the scores for each sample
  int n = t.size();
  for(int i = 0; i < n; i++)
  {
    int score = 0;
    PImage frame = t.get(i).getFrame();
    
    // Count the number of pixels that aren't totally black
    // These non-black pixels result from a difference between frames
    // and represent movement
    frame.loadPixels();
    for(int k = 0; k < frame.pixels.length; k++)
    {
      if(red(frame.pixels[k]) > 0 || green(frame.pixels[k]) > 0 || blue(frame.pixels[k]) > 0)
        score += 1;
    }
    frame.updatePixels();
    
    t.get(i).setScore(score);
  }
  
  // Sort the scores in ascending order
  sortByScore(t);
}

// Sorts the given ArrayList of sample thumbnails with the sharpness method
void sortBySharpness(ArrayList<SampleThumbnail> t)
{
  // Calculate the scores for each sample
  int n = t.size();
  for(int i = 0; i < n; i++)
  {
    PImage sample = t.get(i).getFrame();
    PImage frame = createImage(sample.width, sample.height, RGB);
    frame.copy(sample, 0, 0, sample.width, sample.height, 0, 0, sample.width, sample.height);
    applyEdgeDetection(frame);
    
    int score = 0;
    
    // After applying edge detection we count the number of pixels that have one of the three
    // rgb components higher than 100. Essentially, all the pixels with some brightness.
    // The more pixels we count the more edges there are and the sharper the image is.
    frame.loadPixels();
    for(int k = 0; k < frame.pixels.length; k++)
    {
      if(red(frame.pixels[k]) > 100 || green(frame.pixels[k]) > 100 || blue(frame.pixels[k]) > 100)
        score += 1;
    }
    frame.updatePixels();
    
    t.get(i).setScore(score);
  }
  
  // Sort the scores in ascending order
  sortByScore(t);
}

// Sorts the given ArrayList of sample thumbnails with the negative method
void sortByNegative(ArrayList<SampleThumbnail> t)
{
  // Calculate the scores for each sample
  int n = t.size();
  for(int i = 0; i < n; i++)
  {
    // Get the sample's frame
    PImage sample = t.get(i).getFrame();
    
    // Get a copy of the sample's frame and apply the negative effect again, obtaining the original image
    PImage frame = createImage(sample.width, sample.height, RGB);
    frame.copy(sample, 0, 0, sample.width, sample.height, 0, 0, sample.width, sample.height);
    applyNegative(frame);
    
    int score = 0;
    
    // For each pixel sum up the difference in color between the original frame and the negative
    sample.loadPixels();
    frame.loadPixels();
    for(int k = 0; k < frame.pixels.length; k++)
      score += abs(red(sample.pixels[k]) - red(frame.pixels[k])) + abs(green(sample.pixels[k]) - green(frame.pixels[k])) + abs(blue(sample.pixels[k]) - blue(frame.pixels[k]));
    frame.updatePixels();
    sample.updatePixels();
    
    t.get(i).setScore(score);
  }
  
  // Sort the scores in ascending order
  sortByScore(t);
}

void sortByEdges(ArrayList<SampleThumbnail> t)
{
  // Calculate the scores for each sample
  int n = t.size();
  for(int i = 0; i < n; i++)
  {
    int score = 0;
    PImage frame = t.get(i).getFrame();
    
    // We count the number of pixels that have one of the three rgb components higher
    // than 100. Essentially, all the pixels with some brightness. The more pixels we
    // count the more edges there are.
    frame.loadPixels();
    for(int k = 0; k < frame.pixels.length; k++)
    {
      if(red(frame.pixels[k]) > 100 || green(frame.pixels[k]) > 100 || blue(frame.pixels[k]) > 100)
        score += 1;
    }
    frame.updatePixels();
    
    t.get(i).setScore(score);
  }
  
  // Sort the scores in ascending order
  sortByScore(t);
}

void sortByBlur(ArrayList<SampleThumbnail> t)
{
  // Calculate the scores for each sample
  int n = t.size();
  for(int i = 0; i < n; i++)
  {
    PImage sample = t.get(i).getFrame();
    PImage frame = createImage(sample.width, sample.height, RGB);
    frame.copy(sample, 0, 0, sample.width, sample.height, 0, 0, sample.width, sample.height);
    applyEdgeDetection(frame);
    
    int score = 0;
    
    // Identical to the sharpness method. After applying edge detection we count the number of
    // pixels that have one of the three rgb components higher than 50 (we look for pixels less
    // bright than in the sharpness method to compensate for the fact that there are way less edges.
    // The more pixels we count the more edges there are and the sharper the image is, so we set the
    // score as negative so that the sharper images are assigned the worse scores.
    frame.loadPixels();
    for(int k = 0; k < frame.pixels.length; k++)
    {
      if(red(frame.pixels[k]) > 50 || green(frame.pixels[k]) > 50 || blue(frame.pixels[k]) > 50)
        score += 1;
    }
    frame.updatePixels();
    
    t.get(i).setScore(-score);
  }
  
  // Sort the scores in ascending order
  sortByScore(t);
}

// Sorts the given ArrayList by score in ascending order
void sortByScore(ArrayList<SampleThumbnail> t)
{
  // Sort the scores in ascending order
  int n = t.size();
  for(int i = 0; i < n - 1; i++)
  {
    for(int j = 0; j < n - i - 1; j++)
    {
      SampleThumbnail sampleA = t.get(j);
      SampleThumbnail sampleB = t.get(j + 1);
      
      if(sampleA.getScore() > sampleB.getScore())
      {
        // Swap
        SampleThumbnail temp = new SampleThumbnail(sampleA.getFrame(), sampleA.getTime(), sampleA.getScore());
        sampleA.set(sampleB);
        sampleB.set(temp);
      }
    }
  }
}

// Sorts the given ArrayList of sample thumbnails by their timestamps.
// The samples from an earlier part of the video end up in the beginning
// of the ArrayList
void sortByChronologicalOrder(ArrayList<SampleThumbnail> t)
{
  int n = t.size();
  for(int i = 0; i < n - 1; i++)
  {
    for(int j = 0; j < n - i - 1; j++)
    {
      SampleThumbnail sampleA = t.get(j);
      SampleThumbnail sampleB = t.get(j + 1);
      
      if(sampleA.getTime() > sampleB.getTime())
      {
        // Swap
        SampleThumbnail temp = new SampleThumbnail(sampleA.getFrame(), sampleA.getTime(), sampleA.getScore());
        sampleA.set(sampleB);
        sampleB.set(temp);
      }
    }
  }
}
