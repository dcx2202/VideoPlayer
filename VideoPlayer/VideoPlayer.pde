import java.util.*;
import processing.video.*;

// Constants
final int NUMBER_THUMBNAILS = 10;
final int NUMBER_THUMB_ROWS = 2;
final int NUMBER_THUMB_COLUMNS = 5;
final int MIN_NUMBER_SAMPLES = 10;

// Flags
boolean loadingVideo;
boolean loadingThumbnails;
boolean stopThumbnailThreads; // Indicates whether or not to cancel the current thumbnail request
boolean drawingThumbs;
boolean redraw;

// Filenames
String filename;
String loadedFilename;

// UI Elements
Player player;
ArrayList<Tab> tabs;
ArrayList<Thumbnail> thumbnails;

// Other variables
int selectedTab = 0;
PImage previousFrame;
float progress;

void setup()
{
  size(1280, 720);
  
  // Initialize UI Elements
  player = new Player(selectedTab);
  tabs = new ArrayList<Tab>();
  thumbnails = new ArrayList<Thumbnail>();
  
  tabs.add(new Tab("None", 0));
  tabs.add(new Tab("Black and White", 1));
  tabs.add(new Tab("Negative", 2));
  tabs.add(new Tab("Movement", 3));
  tabs.add(new Tab("Sharpen", 4));
  tabs.add(new Tab("Edge Detection", 5));
  tabs.add(new Tab("Blur", 6));
  
  // Initialize flags
  loadingThumbnails = false;
  loadingVideo = false;
  stopThumbnailThreads = false;
  drawingThumbs = false;
  redraw = true;
  
  // Initialize variables
  loadedFilename = "";
  progress = 0;
}

// Redraws the base UI
void clearUI()
{
  push();
  noStroke();
  textAlign(CENTER);
  
  // Set background
  background(90);
  
  // Top rectangle
  fill(30);
  rect(0, 0, width, 60);
  fill(90);
  textSize(30);
  text("Video Player++", 125, 40);
  
  // Left rectangle
  fill(60);
  rect(0, 60, 250, height);
  pop();

  // Draw tabs
  for(Tab tab : tabs)
    tab.drawElement();
  
  redraw = false;
}

void drawUI()
{
  // If we need to clear the UI
  if(redraw)
    clearUI();
    
  // If the thumbnails are ready to draw
  if(!loadingVideo && thumbnails.size() == 10 && !loadingThumbnails)
  {
    drawingThumbs = true; // Makes sure thumbnails can't be accessed at the same time by another thread
    for(Thumbnail thumbnail : thumbnails)
      thumbnail.drawElement(); // Draw thumbnail
    drawingThumbs = false;  
  }
      
  // Else let the user know the thumbnails are loading
  else if(loadingThumbnails)
  {
    push();
    // Clear loading feedback area
    // We don't clear the whole UI to avoid noticeable flickering
    noStroke();
    fill(90);
    rect(590, 500, 355, 70);
    
    // Draw loading feedback
    textSize(20);
    textAlign(CENTER);
    fill(200);
    text("Loading thumbnails, please wait...", 765, 518);
    strokeWeight(8);
    stroke(120);
    line(600, 560, 600 + 335, 560); // Progress bar background
    stroke(60);
    line(600, 560, 600 + map(progress, 0, 1, 0, 335), 560); // Progress bar
    textSize(15);
    text(floor(progress * 100) + " %", 765, 550); // Draw current %
    noStroke();
    pop();
  }
    
  // Draw the player and all its elements
  player.drawElement();
}

void draw()
{
  // Draw the UI
  drawUI();
  
  // Update the player (check if video is over, ...)
  player.update();
}

void mouseReleased()
{
  player.checkReleased();
}

void mouseDragged()
{
  player.checkDragged();
}

void mouseMoved()
{
  player.checkMove();
}

void mousePressed()
{
  // Check and handle clicks in any of the player elements
  player.handleClick();
  
  // Check and handle clicks in the tabs area
  for(Tab tab : tabs)
  {
    if(!tab.checkClick())
      continue;
      
    tab.handleClick();
    break;
  }
  
  // If the video isn't loaded yet then there aren't thumbnails to check for clicks
  if(loadingVideo)
    return;
  
  // Check and handle clicks in the thumbnails area
  for(Thumbnail thumbnail : thumbnails)
  {
    if(!thumbnail.checkClick())
      continue;
      
    thumbnail.handleClick();
    break;
  }
}

// Callback for when the user selects a file
void fileSelected(File selection) 
{
  // It it was aborted then return
  if (selection == null)
    return;
    
  try
  {
    // Load the video in a separate thread
    loadedFilename = selection.getAbsolutePath();
    thread("loadVideoAsync");
  }
  catch(Exception e) {}
}

// Queues a thumbnail loading request
void queueLoadThumbnails()
{
  // If we are loading thumbnails then cancel that request
  if(loadingThumbnails)
  {
    // Flag the cancelation
    stopThumbnailThreads = true;
    
    // Wait for it to be canceled
    while(stopThumbnailThreads)
      delay(1);
  }
  
  // Start new request
  loadingThumbnails = true;
  thread("loadThumbnails");
}

// Loads thumbnails for the current video and current selected effect
// Goes through the video in intervals of 1 second, getting a sample thumbnail for each
// Sorts these sample thumbnails according to the selected effect's relevance criterion
// Adds the selected thumbnails and places them in the correct position
void loadThumbnails()
{
  // Reset progress bar
  progress = 0;
  
  // Flag that we are loading thumbnails
  loadingThumbnails = true;
  
  // Clear the previous thumbnails (if a video was loaded before)
  thumbnails.clear();
  
  // Video used to get the thumbnails.
  // Not the same video that is being displayed while loading thumbnails.
  Movie v = new Movie(this, loadedFilename);
  
  // Get the selected effect before applying it to the sample thumbnails
  // so that even if the user selects another effect it won't break this selection
  int effect = player.getSelectedEffect();
  
  // Will hold sample thumbnails for posterior selection
  ArrayList<SampleThumbnail> thumbs = new ArrayList<SampleThumbnail>();
  
  v.playbin.setVolume(0); // Set volume to 0 so this video doesn't play audio
  v.play();
  
  // Wait for video to load
  while(v.width <= 0)
    delay(1);
    
  int duration = floor(v.duration());
  
  // If an effect is selected then we have to select the most relevant thumbnails
  if(effect != 0)
  {
    // Jump through the video in 1 second intervals to get sample thumbnails
    for(float i = 0; i <= duration;)
    {
      // If there is a new request to load thumbnails then cancel this one
      if(stopThumbnailThreads)
      {
        v.pause();
        v.stop();
        
        // Reset progress
        thumbnails.clear();
        progress = 0;
        
        // Update flags
        stopThumbnailThreads = false;
        loadingThumbnails = false;
        return;
      }
      
      // If the selected effect is movement detection
      // then we need to compare two frames for each thumbnail
      if(effect == 3)
      {
        // Get two frames
        v.jump(i - 0.05);
        PImage prevFrame = v.get();
        v.jump(i);
        PImage frame = v.get();
        
        // Apply the movement difference effect between these two frames
        applyMovementDifference(frame, prevFrame);
        
        // Add it to the sample thumbnails
        thumbs.add(new SampleThumbnail(frame, i));
        
        // Update progress
        if(!stopThumbnailThreads)
        progress = (float) i / duration;
        
        // Continue to the next timestamp
        if(duration > MIN_NUMBER_SAMPLES) i++; else i+= duration / (float) MIN_NUMBER_SAMPLES;
        continue;
      }
      
      // For all the other effects we only need one frame
      v.jump(i);
      PImage f = v.get();
      applyEffect(f, effect);
      thumbs.add(new SampleThumbnail(f, i));
      
      // Update progress
      if(!stopThumbnailThreads)progress = (float) i / duration;
      
      if(duration > MIN_NUMBER_SAMPLES) i++; else i+= duration / (float) MIN_NUMBER_SAMPLES;
    }
  }
  // If an effect isn't being applied then we just select 10 thumbnails
  // that divide the video in equal intervals
  else
  {
    for(int i = 0; i < 10; i++)
    {
      // If there is a new request to load thumbnails then cancel this one
      if(stopThumbnailThreads)
      {
        v.pause();
        v.stop();
        
        // Reset progress
        thumbnails.clear();
        progress = 0;
        
        // Update flags
        stopThumbnailThreads = false;
        loadingThumbnails = false;
        return;
      }
      
      // Get the frame
      float time = (duration / 10f) * i;
      v.jump(time);
      PImage frame = v.get();
      resizeFrame(frame);

      // Add it to the sample thumbnails
      thumbs.add(new SampleThumbnail(frame, time));
      
      // Update progress
      if(!stopThumbnailThreads)progress = (float) time / duration;
    }
  }
  
  // Dispose the video
  v.pause();
  v.stop();
  
  // Sort depending on the selected effect
  switch(effect)
  {
    case 0: break;
    case 1: sortByBlackAndWhite(thumbs); break;
    case 2: sortByNegative(thumbs); break;
    case 3: sortByMovement(thumbs); break;
    case 4: sortBySharpness(thumbs); break;
    case 5: sortByEdges(thumbs); break;
    case 6: sortByBlur(thumbs); break;
  }
  
  // Remove the less relevant samples
  while(thumbs.size() > NUMBER_THUMBNAILS)
    thumbs.remove(thumbs.get(0));

  // Sort the selected thumbnails by chronological order
  sortByChronologicalOrder(thumbs);

  // Add the selected thumbnails from the samples
  // and place them in the correct position
  int j = 0;
  int k = 0;
  int thumb_width = thumbs.get(0).getFrame().width;
  int thumb_height = thumbs.get(0).getFrame().height;
  
  for(int i = 0; i < thumbs.size(); i++)
  {
    int x = floor(295 + j * thumb_width * 0.5f + j * 30);
    int y = floor(410 + k * thumb_height * 0.5f + k * 30);
    
    // Wait for any thread that might be accessing the thumbnails ArrayList
    while(drawingThumbs)
      delay(1);
    
    // Instantiate and add a new thumbnail from this sample
    thumbnails.add(new Thumbnail(thumbs.get(i).getFrame(), thumbs.get(i).getTime(), thumbs.get(i).getScore(), x, y));
    j++;
    
    if(j == NUMBER_THUMB_COLUMNS)
    {
      j = 0;
      k++;
      if(k == NUMBER_THUMB_ROWS)
        break;
    }
  }
  
  // If by unlucky timing we missed the stop flag then cancel now
  if(stopThumbnailThreads)
  {
    thumbnails.clear();
    stopThumbnailThreads = false;
  }
  
  // Update flags
  loadingThumbnails = false;
  redraw = true;
}

// Loads a video asynchronously so the program doesn't get blocked
void loadVideoAsync()
{
  loadingVideo = true; // Update flag
  
  // Start loading thumbnails on another thread so that this
  // video loading process doesn't have to wait for that
  thread("loadThumbnails");
  
  Movie v = new Movie(this, loadedFilename); // Load the selected video
  
  v.playbin.setVolume(0); // Mute it while it's not ready
  v.play();
  
  // Wait for it to load
  while(v.width <= 0)
    delay(1);
  
  // Prepare it for playback
  v.pause();
  v.jump(0);
  v.playbin.setVolume(1);
  
  player.setVideo(v); // Set this video as the player's
  player.play(); // Play the video through the player
  loadingVideo = false; // Update flag that we finished loading this video
}

// Tries to load a camera connected to the computer running this sketch
void loadCapture()
{
  String[] cameras = Capture.list(); // Get all the cameras connected
  
  // If there are any available try using it
  if (cameras.length > 0) 
  {
    // Try using the first one.
    // However, in some cases this camera might not be supported and
    // if that happens we just don't load any camera
    Capture c = new Capture(this, cameras[0]);
    c.start();
    
    while(c.width <= 0)
      delay(1);
    
    player.pause();
    player.setCapture(c);
    player.setIsVideoLoaded(true);
  }
}

// Updates the previous stored frame for applying the movement difference
// effect when it is selected (has to always be updated, even if another
// effect is selected)
void updatePreviousFrame()
{
  if(player.getFrame().width > 0)
  {
    previousFrame = player.getFrame(); // Get frame
    previousFrame.resize(player.getWidth(), player.getHeight()); // Resize it
  }
}

// Called automatically when there is a new movie frame available for reading
void movieEvent(Movie m) 
{
  updatePreviousFrame(); // Update previous frame
  m.read();
}

// Called automatically when there is a new capture frame available for reading
void captureEvent(Capture c) 
{
  updatePreviousFrame(); // Update previous frame
  c.read();
}
