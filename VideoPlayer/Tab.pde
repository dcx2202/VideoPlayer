public class Tab implements UIElement
{
  // Position and dimensions
  private final int _tab_Width = 257;
  private final int _tab_Height = 80;
  private final int _tab_startX = -5;
  private int _tab_startY;
  
  private int _effect; // Tab's effect number
  private String _label; // Tab's text label
  
  public Tab(String label, int effect)
  {
    _label = label;
    _effect = effect;
    _tab_startY = 62 + effect * _tab_Height;
  }
  
  // Check if this element was clicked on
  public boolean checkClick()
  {
    return (mouseX >= _tab_startX && mouseX <= _tab_startX + _tab_Width
            && mouseY >= _tab_startY && mouseY <= _tab_startY + _tab_Height);
  }
  
  public void checkDragged()
  {
    // Not Implemented
  }
  
  public void checkReleased()
  {
    // Not Implemented
  }
  
  public void handleClick()
  {
    // If this effect is already selected then return
    if(_effect == player.getSelectedEffect())
      return;
    
    // Update the player's selected effect and draw the next frame
    player.setSelectedEffect(_effect);
    
    // Useful if the video is paused. We want the displayed frame to have the
    // new selected effect applied to it
    player.drawNextFrame();
    
    redraw = true;
    
    // Queue a new thumbnail loading process
    if(player.getIsVideoLoaded())
      queueLoadThumbnails();
  }
  
  // Draws this element
  public void drawElement()
  {
    push();
    textAlign(CENTER);
    stroke(90);
    strokeWeight(5);
    
    // Set the color depending on whether or not this tab is selected
    if(_effect == player.getSelectedEffect())
      fill(90);
    else
      fill(60);
    
    // Draw tab
    rect(_tab_startX, _tab_startY, _tab_Width, _tab_Height);
    noStroke();
    
    // Draw tab text
    textSize(20);
    fill(200);
    text(_label, 122, 108 + _effect * _tab_Height );
    pop();
  }
}
