// Responsible for the Play/Pause/Restart button and their functionality
public class PlayButton implements UIElement
{
  // Position and dimensions
  private final int _playButton_Width = 16;
  private final int _playButton_Height = 16;
  private final int _playButton_startX = 1072;
  private final int _playButton_startY = 348;
  
  // Images
  PImage play_icon;
  PImage pause_icon;
  PImage restart_icon_small;
  
  public PlayButton()
  {
    // Load images
    play_icon = loadImage("resources/play_icon.png");
    pause_icon = loadImage("resources/pause_icon.png");
    restart_icon_small = loadImage("resources/restart_icon_small.png");
  }
  
  // Check if this element was clicked on
  public boolean checkClick()
  {
    return (mouseX >= _playButton_startX && mouseX <= _playButton_startX + _playButton_Width
     && mouseY >= _playButton_startY && mouseY <= _playButton_startY + _playButton_Height);
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
  
  // Handles a click by restarting if the video is over, pausing if it's
  // playing or resuming if it's paused
  public void handleClick()
  {
    // Restart video
    if(player.getIsOver())
    {
      player.jump(0);
      player.setIsOver(false);
      player.play();
      return;
    }
    
    if(player.getIsPlaying())
      player.pause(); // Pause video
    else
      player.play(); // Resume video
  }
  
  // Draws this element according to its state
  public void drawElement()
  {
    push();
    noStroke();
    fill(90);
    rect(_playButton_startX, _playButton_startY, _playButton_Width, _playButton_Height);
    pop();
      
    if(player.getIsOver())
      image(restart_icon_small, _playButton_startX, _playButton_startY);
    else if(!player.getIsPlaying())
      image(play_icon, _playButton_startX, _playButton_startY);
    else
      image(pause_icon, _playButton_startX, _playButton_startY);
  }
}
