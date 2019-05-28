public class Timeline implements UIElement
{
  // Position and dimensions
  private final int _timeline_Width = 320;
  private final int _timeline_Height = 25;
  private final int _timeline_startX = 920;
  private final int _timeline_startY = 315;
  
  public Timeline()
  {
    
  }
  
  // Check if this element was clicked on
  public boolean checkClick()
  {
    return (mouseX >= _timeline_startX && mouseX <= _timeline_startX + _timeline_Width
            && mouseY >= _timeline_startY - 6 && mouseY <= _timeline_startY + 6);
  }
  
  // We only handle clicks in the timeline when the mouse is released, not pressed
  public void handleClick()
  {
    // Not Implemented
  }
  
  // Check if the mouse was dragged over this element
  public void checkDragged()
  {
    // If the overlay isn't being shown or the video is over then we aren't dragging
    if(!player.getShowOverlay() || player.getIsOver())
      return;
    
    if(checkClick())
       player.setIsDragging(true);
     else
       player.setIsDragging(false);
  }
  
  // Checks if the mouse was released over this element
  public void checkReleased()
  {
    // If the video isn't loaded or it is over or the mouse wasn't released over
    // the timeline then we don't want to jump
    if(!player.getIsVideoLoaded() || player.getIsOver() || !checkClick())
      return;
    
    player.setIsDragging(false);
    
    // Map the click's position in the timeline to a timestamp
    float time = map(mouseX, _timeline_startX, _timeline_startX + _timeline_Width, 0, player.getDuration());
  
    // Jump and draw next frame
    player.jump(time);
    player.drawNextFrame(); // Useful if the video is paused - we want to display the frame from the new timestamp
  }
  
  // Draws this element
  public void drawElement()
  {
    // If the user dragged the mouse in the bottom area of the video player then draw the overlay
    if(player.getShowOverlay())
    {
      push();
      noStroke();
      textAlign(CENTER);
      fill(0, 150);
      
      // Draw the bottom bar background
      rect(_timeline_startX, _timeline_startY, _timeline_Width, _timeline_Height);
      
      fill(255, 0, 0);
      
      // Get the current video time in minutes and seconds
      float time;
      
      // If the mouse isn't being dragged we want to display the current timestamp
      if(!player.getIsDragging())
        time = map(player.getTime(), 0, player.getDuration(), 0, _timeline_Width);
        
      // If the mouse is being dragged we want to display the timestamp equivalent to the
      // mouse's current position over the timeline
      else
        time = mouseX - _timeline_startX;
        
      // Draw the timeline
      rect(_timeline_startX, _timeline_startY, time, 3);
      
      // Draw a white circle in the timeline over the current timestamp
      fill(255);
      circle(_timeline_startX + time, _timeline_startY + 2, 6);
      
      // Convert the video's current time from seconds to the correct formatting
      int current_hours = 0;
      int current_minutes = 0;
      int current_seconds = floor(player.getTime());
      current_hours = floor(current_seconds / 3600);
      current_seconds -= current_hours * 3600;
      current_minutes = floor(current_seconds / 60);
      current_seconds -= current_minutes * 60;
      
      // Convert the video's duration from seconds to the correct formatting
      int total_hours = 0;
      int total_minutes = 0;
      int total_seconds = floor(player.getDuration());
      total_hours = floor(total_seconds / 3600);
      total_seconds -= total_hours * 3600;
      total_minutes = floor(total_seconds / 60);
      total_seconds -= total_minutes * 60;
      
      // Build a string depending on the time to display (if the video is
      // less than an hour long we don't display the number of hours, ...)
      String str = "";
      
      if(current_hours > 0)
        str += current_hours + ":";
        
      str += current_minutes + ":";
      
      if(current_seconds < 10)
        str += "0" + current_seconds;
      else
        str += current_seconds;
        
      if(total_hours > 0)
        str += " / " + total_hours + ":";
      else
        str += " / " + total_minutes + ":";
        
      if(total_seconds < 10)
        str += "0" + total_seconds;
      else
        str += total_seconds;
      
      // Write "current time / total time" in the bottom bar
      textSize(10);
      text(str, _timeline_startX + 40, _timeline_startY + 16);
      pop();
    }
  }
}
