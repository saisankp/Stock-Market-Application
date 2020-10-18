// text class to display all the text
// text class created 18/03/2020 by :
// Prathamesh Sai 
// Subrahmanyam Rayanapati

/*
  The Text class is a wrapper class for text properties, so that a piece of text can be stored as a Widget
  Authors: Subrahmanyam Rayanapati & Prathamesh Sai
*/


public class Text extends Widget {
  
  // variables used for the text class
  private String text;
  private int alignX, alignY;
  private PFont font;
  private color textColor;
  private int size;
    
  //constructor for text
  Text(String text, float x, float y, float elemWidth, float elemHeight, int alignX, int alignY, PFont font, color textColor, int size) {
    this.text = text;
    this.font = font;
    this.size = size;
    this.elemWidth = elemWidth;
    this.elemHeight = elemHeight;
    this.alignX = alignX;
    this.alignY = alignY;
    this.x = x;
    this.y = y; 
    this.textColor = textColor;
  }
    
  void draw(float xOffset, float yOffset) {
    float x = this.x + xOffset;
    float y = this.y + yOffset; 
    fill(textColor); //set color
    textFont(font);  // set the font
    textSize(size);  // set the size
    textAlign(alignX, alignY);
    text(text, x, y); // display the text.
  }
  
  String getLabelText() {
    return this.text;
  }
}
