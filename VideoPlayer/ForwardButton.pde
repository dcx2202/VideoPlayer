// Responsible for the fast forward button and its functionality
public class ForwardButton implements UIElement
{
  // Position and dimensions
  private final int _forwardButton_Width = 16;
  private final int _forwardButton_Height = 16;
  private final int _forwardButton_startX = 1095;
  private final int _forwardButton_startY = 348;
  
  // Icon
  PImage forward_icon;
  
  public ForwardButton()
  {
    forward_icon = loadImage("resources/forward_icon.png"); // Load image
  }
  
  // Check if this element was clicked on
  public boolean checkClick()
  {
    // If the video is over then don't allow fast forwarding
    if(player.getIsOver())
      return false;
    
    // Return whether or not this element was clicked
    return (mouseX >= _forwardButton_startX && mouseX <= _forwardButton_startX + _forwardButton_Width
     && mouseY >= _forwardButton_startY && mouseY <= _forwardButton_startY + _forwardButton_Height);
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
  
  // Handles the click by fast forwarding 10 seconds
  public void handleClick()
  {
    float seconds;
    
    // Get the duration we will jump to
    if(player.getTime() + 10 >= player.getDuration()) // If there isn't 10 seconds left
      seconds = player.getDuration(); // We will jump to the end
    else
      seconds = player.getTime() + 10; // We fast forward 10 seconds
      
    player.jump(seconds);
    
    // Draw the next frame. Needed if the video is paused
    player.drawNextFrame();
  }
  
  // Draw this element
  public void drawElement()
  {
    // Draw the image in this element's position
    image(forward_icon, _forwardButton_startX, _forwardButton_startY);
  }
}
