public class Button extends Widget { //<>//
  /*
    The Button class is used to draw and handle interactions with buttons.
    Author: Cian Mawhinney
  */
  
  private color btnColor;
  private String label;
  
  Button(String label, float x, float y, float elemWidth, float elemHeight, color btnColor) {
    this.label = label;
    this.x = x;
    this.y = y;
    this.elemWidth = elemWidth;
    this.elemHeight = elemHeight;
    this.btnColor = btnColor;
  }
  
  void draw(float xOffset, float yOffset) {
    float x = this.x + xOffset;
    float y = this.y + yOffset;
    fill(btnColor);
    rect(x, y, elemWidth, elemHeight);
    textAlign(CENTER, CENTER);
    fill(0); //<>//
    text(label, x + elemWidth/2, y + elemHeight/2);
  }
  
}
