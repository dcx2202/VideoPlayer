public class VideoPicker implements UIElement
{
  // Position and dimensions
  private final int _videopicker_Width = 50;
  private final int _videopicker_Height = 25;
  private final int _videopicker_startX = 920;
  private final int _videopicker_startY = 108;
  
  public VideoPicker()
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
    return (mouseX >= _videopicker_startX && mouseX <= _videopicker_startX + 240
            && mouseY >= _videopicker_startY + 20 && mouseY <= _videopicker_startY + 50);
  }
  
  // Handles clicks on this element
  public void handleClick()
  {
    // If a video is loaded
    if(player.getIsVideoLoaded())
      return;
    
    // If the browse files button was clicked
    if(mouseX <= _videopicker_startX + 110)
    {
      // Open a file dialog
      selectInput("Select a video", "fileSelected");
    }
    // Try to load a camera
    else if(mouseX >= _videopicker_startX + 130)
    {
      thread("loadCapture");
    }
  }
  
  // Draws this element
  public void drawElement()
  { 
    push();
    noStroke();
    fill(60);
    
    // Draw the video picker buttons' backgrounds
    rect(_videopicker_startX, _videopicker_startY + 20, 110, 30);
    rect(_videopicker_startX + 130, _videopicker_startY + 20, 110, 30);
    
    // Draw the button's text labels
    fill(90);
    rect(_videopicker_startX, _videopicker_startY - 10, 110, 20);
    fill(200);
    textSize(16);
    textAlign(LEFT);
    text("Open a video:", _videopicker_startX, _videopicker_startY + 5);
    
    textAlign(CENTER);
    textSize(12);
    text("Browse files...", _videopicker_startX + 55, _videopicker_startY + 39);
    text("Capture", _videopicker_startX + 130 + 55, _videopicker_startY + 39);
    pop();
  }
}
