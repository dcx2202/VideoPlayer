// Responsible for the rewind button and its functionality
public class RewindButton implements UIElement
{
  // Position and dimensions
  private final int _rewindButton_Width = 16;
  private final int _rewindButton_Height = 16;
  private final int _rewindButton_startX = 1049;
  private final int _rewindButton_startY = 348;
  
  // Rewind button image
  PImage rewind_icon;
  
  public RewindButton()
  {
    rewind_icon = loadImage("resources/rewind_icon.png"); // Load image
  }
  
  // Check if this element was clicked on
  public boolean checkClick()
  {
    if(player.getIsOver())
      return false;
      
    return (mouseX >= _rewindButton_startX && mouseX <= _rewindButton_startX + _rewindButton_Width
     && mouseY >= _rewindButton_startY && mouseY <= _rewindButton_startY + _rewindButton_Height);
  }
  
  // Check if the mouse was dragged over this element
  public void checkDragged()
  {
    // Not Implemented
  }
  
  // Check if the mouse was released over this element
  public void checkReleased()
  {
    // Not Implemented
  }
  
  // Tries to rewind by 10 seconds
  public void handleClick()
  {
    // Get the time we will jump to
    float seconds;
      
    if(player.getTime() - 10 <= 0)
      seconds = 0;
    else
      seconds = player.getTime() - 10;
      
    player.jump(seconds); // Jump
    player.drawNextFrame(); // Draw the next frame. Useful when the video is paused
  }
  
  // Draw this element
  public void drawElement()
  {
    image(rewind_icon, _rewindButton_startX, _rewindButton_startY);
  }
}
