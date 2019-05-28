public class Topbar implements UIElement
{
  // Position and dimensions
  private final int _topbar_Width = 320;
  private final int _topbar_Height = 25;
  private final int _topbar_startX = 920;
  private final int _topbar_startY = 100;
  
  public Topbar()
  {
    
  }
  
  public void checkReleased()
  {
    // Not Implemented
  }
  
  public void checkDragged()
  {
    // Not Implemented
  }
  
  // Check if this element was clicked on
  public boolean checkClick()
  {
    return (mouseX >= _topbar_startX + _topbar_Width - 17 && mouseX <= _topbar_startX + _topbar_Width - 7
            && mouseY >= _topbar_startY + 7 && mouseY <= _topbar_startY + 17);
  }
  
  // Stop the video and clear the UI
  public void handleClick()
  {
    player.stop();
    clearUI();
  }
  
  // Draws this element
  public void drawElement()
  {
    // If the user dragged the mouse in the bottom or top area of the video player
    if(player.getShowOverlay())
    {
      push();
      noStroke();
      fill(0, 150);
      rect(_topbar_startX, _topbar_startY, _topbar_Width, _topbar_Height); // Top bar background
      
      strokeWeight(2);
      stroke(200);
      
      // Draw an "X" representing the close video/camera button
      line(_topbar_startX + _topbar_Width - 17, _topbar_startY + 7, _topbar_startX + _topbar_Width - 7, _topbar_startY + 17);
      line(_topbar_startX + _topbar_Width - 7, _topbar_startY + 7, _topbar_startX + _topbar_Width - 17, _topbar_startY + 17);
      pop();
    }
  }
}
