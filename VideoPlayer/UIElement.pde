// Implemented by all UI elements
public interface UIElement
{
  public boolean checkClick();
  public void checkDragged();
  public void checkReleased();
  public void handleClick();
  public void drawElement();
}
