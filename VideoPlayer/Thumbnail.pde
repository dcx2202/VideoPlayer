public class Thumbnail implements UIElement
{
  // Position and dimensions
  private final int _thumbnail_Width = 160;
  private final int _thumbnail_Height = 120;
  private final int _thumbnail_startX; // Defined when instantiating
  private int _thumbnail_startY;
  
  // Thumbnail's score, timestamp and frame
  private int score;
  private float time;
  private PImage frame;
  
  public Thumbnail(PImage frame, float time, int score, int startX, int startY)
  {
    this.frame = frame;
    this.time = time;
    this.score = score;
    _thumbnail_startX = startX;
    _thumbnail_startY = startY;
  }
  
  // Check if this element was clicked on
  public boolean checkClick()
  {
    return (mouseX >= _thumbnail_startX && mouseX <= _thumbnail_startX + _thumbnail_Width
           && mouseY >= _thumbnail_startY && mouseY <= _thumbnail_startY + _thumbnail_Height);
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
  
  // Jumps to the timestamp
  public void handleClick()
  {
    // If the video is over we don't want to jump
    if(!player.getIsOver())
    {
      player.jump(time);
      player.drawNextFrame(); // Draw the next frame. Useful when the video is paused
    }
  }
  
  // Draws this element
  public void drawElement()
  {
    image(frame, _thumbnail_startX, _thumbnail_startY, _thumbnail_Width, _thumbnail_Height);
  }
}
