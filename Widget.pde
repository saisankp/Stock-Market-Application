public abstract class Widget {
  /*
    The Widget class is a parent class for all UI elements.
    Every element added to ArrayList of widgets on a screen must extend this class.
    In effect, this is a template for what every UI element should have.
    Author: Cian Mawhinney
  */

  float x;
  float y;
  float elemWidth;
  float elemHeight;
  int event;
  
  // the draw function should be implemented by the class extending Widget
  abstract void draw(float xOffset, float yOffset);
  
  /*
    isMouseOver
    Role: Returns the event ID for the given widget if the mouse is inside its' boundaries
    Author: Cian Mawhinney
  */
  int isMouseOver(float x, float y) {
    if (x >= this.x && x <= this.x + elemWidth &&
        y >= this.y && y <= this.y + elemHeight) {
      return this.event;
    }
    else {
      return EVENT_NULL;
    }
  }
  
  // getters
  float getX() {
    return this.x;
  }
  
  float getY() {
    return this.y;
  }
  
  float getElementWidth() {
    return this.elemWidth;
  }
  
  float getElementHeight() {
    return this.elemHeight;
  }
  
  int getEventID() {
    return this.event;
  }
  
  // setters
  void setX(float x) {
    this.x = x;
  }
  
  void setY(float y) {
    this.y = y;
  }
  
  void setElementWidth(float elemWidth) {
    this.elemWidth = max(elemWidth, 0);  // element width has to be positive
  }
  
  void setElementHeight(float elemHeight) {
    this.elemHeight = max(elemHeight, 0);  // element height has to be positive
  }
  
  void setEventID(int event) {
    this.event = event;
  }

}
