import processing.video.*;

// Responsible for the video/camera player and its elements, checking for and
// handling/delegating user interaction with them 
public class Player implements UIElement
{
  // Position and dimensions
  private final int _videoPlayer_Width = 320;
  private final int _videoPlayer_Height = 240;
  private final int _videoPlayer_startX = 920;
  private final int _videoPlayer_startY = 100;
  
  // Flags
  private boolean _isOver; // Video over
  private boolean _isPlaying; // Video playing
  private boolean _showOverlay; // Overlay shown
  private boolean _isDragging; // Mouse being dragged
  private boolean _videoLoaded; // Video/Camera loaded
  
  // Image
  private PImage restart_icon_big;
  
  // Media
  Movie video = null;
  Capture cam = null;
  
  // UI Elements
  ArrayList<UIElement> elements;
  
  UIElement playButton;
  UIElement rewindButton;
  UIElement forwardButton;
  UIElement topbar;
  UIElement timeline;
  UIElement videoPicker;
  
  // Other variables
  int selectedEffect;
  
  public Player(int tab)
  {
    // Initialize the selected effect with the current one
    selectedEffect = tab;
    
    // Load a big restart icon image that overlays the whole video when it is over
    restart_icon_big = loadImage("resources/restart_icon_big.png");
    
    // Initialize the previousFrame PImage that's used to apply
    // the movement difference effect. Updated on movieEvent()
    previousFrame = createImage(_videoPlayer_Width, _videoPlayer_Height, RGB);
    
    // Initialize this player's UI elements
    elements = new ArrayList<UIElement>(); // Holds all the elements
    playButton = new PlayButton(); // Play/Pause/Restart button
    rewindButton = new RewindButton(); // Rewind button
    forwardButton = new ForwardButton(); // Fast forward button
    timeline = new Timeline(); // Video timeline that shows the current time and allows changing it
    topbar = new Topbar(); // Overlay top bar that allows the video to be closed
    videoPicker = new VideoPicker(); // Video picker interface that is presented when
                                     // a video/camera isn't loaded, allowing to load one.
    
    // Add the elements to the list
    elements.add(playButton);
    elements.add(rewindButton);
    elements.add(forwardButton);
    elements.add(timeline);
    elements.add(topbar);
    
    // Initialize flags
    _videoLoaded = false;
    _isOver = false;
    _isPlaying = false;
    _isDragging = false;
    _showOverlay = false;
  }
  
  // Check if this element was clicked on
  public boolean checkClick()
  {
    // If the user clicked inside the video player area
    return (mouseX >= _videoPlayer_startX && mouseX <= _videoPlayer_startX + _videoPlayer_Width
     && mouseY >= _videoPlayer_startY && mouseY <= _videoPlayer_startY + _videoPlayer_Height);
  }
  
  // Check if the mouse was moved over this element
  public void checkMove()
  {
    // If the user moved the mouse in the bottom area of the video player
    _showOverlay = ((mouseX >= player.getStartX() && mouseX <= player.getStartX() + player.getWidth()
                   && mouseY >= player.getStartY() + player.getHeight() - 30 && mouseY <= player.getStartY() + player.getHeight() && cam == null)
                   ||
                   (mouseX >= player.getStartX() && mouseX <= player.getStartX() + player.getWidth()
                   && mouseY >= player.getStartY() && mouseY <= player.getStartY() + 30));
  }
  
  // Check if the mouse was dragged over this element
  public void checkDragged()
  {
    timeline.checkDragged(); // Delegate to the timeline
  }
  
  // Check if the mouse was released over this element
  public void checkReleased()
  {
    timeline.checkReleased(); // Delegate to the timeline
  }
  
  // Handle clicks in the video area
  public void handleClick()
  {
    // If a video hasn't been loaded
    if(!_videoLoaded)
    {
      // Check and handle video picker clicks
      if(videoPicker.checkClick())
        videoPicker.handleClick();
      
      // Nothing else was clicked and we can return
      return;
    }
    
    // If the camera is loaded and the topbar was clicked (closes the video/camera)
    if(cam != null && topbar.checkClick())
    {
      // Handle the click
      topbar.handleClick();
      return;
    }
    // If the topbar wasn't clicked and the camera is loaded then we can return here
    // as there are no other possible interactions with the player while the camera is
    // loaded
    else if (cam != null)
      return;
    
    // If the click was outside the video window, check if it was in a button
    if(!checkClick())
    {
      for(UIElement element : elements)
      {
        // Check and handle clicks in each element until we find the clicked one
        if(element.checkClick())
        {
          element.handleClick();
          break; // If we found the element that was clicked and handled it then we can
                 // return as it's not possible to click more than an element at the same time
        }
      }
        
      return;
    }
      
    // If the click was in the video window
    // If the overlay is not showing then the click wasn't in the overlay
    if(!_showOverlay)
    {
      // If the video is over a click will restart the video
      if(_isOver)
      {
        jump(0);
        play();
        _isOver = false;
        return;
      }
      
      // If the user clicked in the left edge then rewind 10 seconds
      if(mouseX <= _videoPlayer_startX + 25)
      {
        float seconds;
        
        if(getTime() - 10 <= 0)
          seconds = 0;
        else
          seconds = getTime() - 10;
          
        jump(seconds);
        drawNextFrame();
      }
      // If the user clicked in the right edge then go forward 10 seconds
      else if(mouseX >= _videoPlayer_startX + _videoPlayer_Width - 25)
      {
        float seconds;
        
        if(getTime() + 10 >= getDuration())
          seconds = getDuration();
        else
          seconds = getTime() + 10;
          
        jump(seconds);
        drawNextFrame();
      }
      // Toggle the state
      else
      {
        if(_isPlaying)
          pause();
        else
          play();
      }
    }
    // If the overlay is being shown then check and handle clicks
    // in the timeline or in the topbar
    else if(timeline.checkClick())
      timeline.handleClick();
    else if(topbar.checkClick())
      topbar.handleClick();
  }
  
  // Draws this element
  public void drawElement()
  {
    // If the a video isn't loaded then draw the video picker UI
    if(!_videoLoaded)
    {
      videoPicker.drawElement();
      return;
    }
    
    // If the cam is loaded then we only need to draw the frame
    // and, if the overlay is shown, the topbar
    if(cam != null)
    {
      PImage nextFrame = getFrame(); // Get the current frame
      applyEffect(nextFrame, selectedEffect); // Apply the selected effect and display it
      image(nextFrame, _videoPlayer_startX, _videoPlayer_startY, _videoPlayer_Width, _videoPlayer_Height);
      
      topbar.drawElement(); // Try to draw the topbar (drawn if overlay should be shown)
      
      return; // We can return here since we won't draw any other UI elements
    }
    
    // Get next frame, apply effect and display it
    PImage nextFrame = getFrame();
    
    while(nextFrame.width <= 0)
      delay(1);
    
    applyEffect(nextFrame, selectedEffect);
    image(nextFrame, _videoPlayer_startX, _videoPlayer_startY, _videoPlayer_Width, _videoPlayer_Height);
    
    // If the video is over then we draw an overlay with a big restart icon
    if(_isOver)
    {
      push();
      noStroke();
      fill(0, 150);
      rect(_videoPlayer_startX, _videoPlayer_startY, _videoPlayer_Width, _videoPlayer_Height);
      image(restart_icon_big, _videoPlayer_startX + _videoPlayer_Width / 2 - restart_icon_big.width / 2, _videoPlayer_startY + _videoPlayer_Height / 2 - restart_icon_big.height / 2);
      pop();
    }
    
    // Draw each of the other elements
    for(UIElement element : elements)
      element.drawElement();
  }
  
  // Draws the next frame. Useful if the video is paused and then
  // the user rewinds or fasts forward
  public void drawNextFrame()
  {
    // If the video is already playing, isn't loaded or the camera
    // is loaded then we don't need/can't draw the next frame
    if(_isPlaying || !_videoLoaded || cam != null)
      return;
    
    // Play and pause to get the next frame available for reading
    play();
    pause();
    
    // Get the frame, apply the selected effect and display it
    PImage nextFrame = getFrame();
    
    while(nextFrame.width <= 0)
      delay(1);
    
    applyEffect(nextFrame, selectedEffect);
    image(nextFrame, _videoPlayer_startX, _videoPlayer_startY, _videoPlayer_Width, _videoPlayer_Height);
  }
  
  // Checks if the video is over
  public void update()
  {
    // If the video isn't loaded or a camera is then we don't need to check further
    if(!_videoLoaded || cam != null)
      return;

    // If the video is over then update the flags
    if(abs(player.getDuration() - player.getTime()) < 0.1) // Margin to prevent rare bugs
    {
      _isOver = true;
      _isPlaying = false;
    }
  }
  
  // Sets the isOver flag
  public void setIsOver(boolean b)
  {
    _isOver = b;
  }
  
  // Sets the isPlaying flag
  public void setIsPlaying(boolean b)
  {
    _isPlaying = b;
  }
  
  // Sets the isDragging flag
  public void setIsDragging(boolean b)
  {
    _isDragging = b;
  }
  
  // Sets the videoLoaded flag
  public void setIsVideoLoaded(boolean b)
  {
    _videoLoaded = b;
  }
  
  // Sets the selected effect
  public void setSelectedEffect(int effect)
  {
    selectedEffect = effect;
  }
  
  // Returns the selected effect
  public int getSelectedEffect()
  {
    return selectedEffect;
  }
  
  // Returns the isOver flag
  public boolean getIsOver()
  {
    return _isOver;
  }
  
  // Returns the isPlaying flag
  public boolean getIsPlaying()
  {
    return _isPlaying;
  }
  
  // Returns the showOverlay flag
  public boolean getShowOverlay()
  {
    return _showOverlay;
  }
  
  // Returns the isDragging flag
  public boolean getIsDragging()
  {
    return _isDragging;
  }
  
  // Returns the videoLoaded flag
  public boolean getIsVideoLoaded()
  {
    return _videoLoaded;
  }
  
  // Sets this player's video
  public void setVideo(Movie m)
  {
    // Set video and update flags
    video = m;
    _videoLoaded = true;
    _isPlaying = false;
    _isOver = false;
  }
  
  // Sets this player's camera
  public void setCapture(Capture c)
  {
    // Set camera and update flags
    cam = c;
    _videoLoaded = true;
    _isPlaying = false;
    _isOver = false;
  }
  
  // Plays the video
  public void play()
  {
    // If the video is already playing or not loaded then return
    if(_isPlaying || !_videoLoaded || video == null)
      return;
    
    // Play/Resume and update flags
    video.play();
    _isPlaying = true;
    _isOver = false;
  }
  
  // Pauses the video
  public void pause()
  {
    // If the video is already paused or not loaded then return
    if(!_isPlaying || !_videoLoaded || video == null)
      return;
      
    // Pause the video and update flag
    video.pause();
    _isPlaying = false;
  }
  
  // Closes and disposes of the video/camera
  public void stop()
  {
    // If a video/camera isn't loaded then return
    if(!_videoLoaded)
      return;
    
    // Reset flags
    _isPlaying = false;
    _videoLoaded = false;
    
    // If a video was loaded
    if(video != null)
    {
      video.stop(); // Dispose
      video = null;
    }
    
    // If a camera was loaded
    if(cam != null)
    {
      cam.stop(); // Dispose
      cam = null;
    }
    
    // Reset flags
    loadingVideo = false;
    
    // If we were loading thumbnails then stop that process
    if(loadingThumbnails)
      stopThumbnailThreads = true;
      
    // While those processes haven't stopped we wait
    while(loadingThumbnails)
      delay(1);
    
    // After being canceled we can clear the thumbnails and flag for a redraw
    thumbnails.clear();
    redraw = true; // Clear the UI to get rid of the thumbnails
  }
  
  // Jumps to a given time in the video
  public void jump(float time)
  {
    // If a video is loaded then jump
    if(video != null)
      video.jump(time);
  }
  
  // Returns the player's video duration
  public float getDuration()
  {
   if(video == null)
     return 0; // If a video isn't loaded
    return video.duration();
  }
  
  // Returns the player's video current time
  public float getTime()
  {
    if(video == null)
       return 0; // If a video isn't loaded
    return video.time();
  }
  
  // Returns the player's video current frame
  public PImage getFrame()
  {
    // Get the current frame from whatever is loaded (video/camera)
    PImage image = createImage(0, 0, RGB);
    
    if(video != null)
      image = video.get();
    else if(cam != null)
      image = cam.get();
    else
      return image;
    
    // Resize the frame before returning it
    if(image != null && image.width > 0)
      image.resize(_videoPlayer_Width, _videoPlayer_Height);
    
    return image;
  }
  
  // Returns this element's starting X coordinate
  public int getStartX()
  {
    return _videoPlayer_startX;
  }
  
  // Returns this element's starting Y coordinate
  public int getStartY()
  {
    return _videoPlayer_startY;
  }
  
  // Returns this element's width
  public int getWidth()
  {
    return _videoPlayer_Width;
  }
  
  // Returns this element's height
  public int getHeight()
  {
    return _videoPlayer_Height;
  }
}
