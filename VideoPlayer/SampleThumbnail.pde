// Sample thumbnail object used when looking for the most relevant moments
// in a video while loading thumbnails
public class SampleThumbnail
{
  PImage frame;
  float time; // Time of video where this frame is from
  int score; // Score of this frame according to a relevance
             // method. Set when loading thumbnails
  
  public SampleThumbnail(PImage f, float t)
  {
    frame = f;
    time = t;
    score = 0;
  }
  
  public SampleThumbnail(PImage f, float t, int s)
  {
    frame = f;
    time = t;
    score = s;
  }
  
  // Returns this sample's frame
  public PImage getFrame()
  {
    return frame;
  }
  
  // Returns this sample's video time
  public float getTime()
  {
    return time;
  }
  
  // Returns this sample's score
  public int getScore()
  {
    return score;
  }
  
  // Sets this sample's score
  public void setScore(int s)
  {
    score = s;
  }
  
  // Copies a given sample
  public void set(SampleThumbnail st)
  {
    frame = st.getFrame();
    time = st.getTime();
    score = st.getScore();
  }
}
