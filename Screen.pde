import java.util.ArrayList;

public class Screen {
  /*
    The Screen class is used to hold a collection of widgets and their arrangements.
    It will handle scrolling the active viewport in the case that content goes over the edge.
    Author: Cian Mawhinney
  */
  
  private ArrayList<Widget> widgets;
  
  private Scrollbar xScrollbar;
  private Scrollbar yScrollbar;
  private Scrollbar draggedScrollbar;
  
  private float screenWidth;
  private float screenHeight;
  
  private color bgColor;

  Screen(color bgColor) {
    this.bgColor = bgColor;
    
    // set inital values for the screen dimensions
    this.screenWidth = width;
    this.screenHeight = height;
    
    this.widgets = new ArrayList<Widget>();
  }
  
  /*
    add
    Role: Adds a widget to the screen, and also ensures
          the screen grows accordingly
    Author: Cian Mawhinney
  */
  void add(Widget widget) {
    widget.setEventID(widgets.size());
    widgets.add(widget);
    calculateScreenSize();

  }
  
  /*
    remove
    Role: Adds a widget to the screen, and also ensures
          the screen shrinks accordingly
    Author: Cian Mawhinney
  */
  void remove(int index) {
    widgets.remove(index);
    
    // recalculate screen size
    this.screenWidth = width;
    this.screenHeight = height;
    calculateScreenSize();
  }
  
  /*
    calculateScreenSize
    Role: Ensures the screen size is large enough to view the content on it
    Author: Cian Mawhinney
  */
  void calculateScreenSize() {
    for (Widget widget : widgets) {
      if (widget.getX() + widget.getElementWidth() > screenWidth) {
        screenWidth = widget.getX() + widget.getElementWidth();
      }
      if (widget.getY() + widget.getElementHeight() > screenHeight) {
        screenHeight = widget.getY() + widget.getElementHeight();
      }
    }
    calculateScrollbars();
  }
  
  /*
    calculateScrollbars
    Role: Calculates the dimensions for the scrollbars
    Author: Cian Mawhinney
  */
  void calculateScrollbars() {
      // calculate appropriate handle length for horizontal scrollbar
      float xHandleLength = width/screenWidth * (width - 2*SCROLLBAR_WIDTH);
      this.xScrollbar = new Scrollbar("horizontal", 0, height - SCROLLBAR_WIDTH, SCROLLBAR_WIDTH, width - SCROLLBAR_WIDTH, xHandleLength);
      
      // calculate appropriate handle length for vertical scrollbar
      float yHandleLength = height/screenHeight * (height - 2*SCROLLBAR_WIDTH);
      this.yScrollbar = new Scrollbar("vertical", width - SCROLLBAR_WIDTH, 0, SCROLLBAR_WIDTH, height, yHandleLength);
  }
  
  /*
    getWidgets
    Role: Returns an array of the widgets stored on the screen
    Author: Cian Mawhinney
  */
  Widget[] getWidgets() {
    return widgets.toArray(new Widget[0]);
  }
  
  /*
    draw
    Role: Draws each widget associated with the screen, and scrollbars if necessary
    Author: Cian Mawhinney
  */
  void draw() {
    background(bgColor);
    // values of `width` and `height` are not correct until the main draw method is run, so instantiate them here instead.
    if (this.xScrollbar == null || this.yScrollbar == null) {
      calculateScrollbars();
    }
    
    // loop through all elements in widget list and draw them
    for (Widget widget : widgets) {
      widget.draw(getXScrollOffset(), getYScrollOffset()); 
    }
    
    // if the viewport isn't wide/long enough to show everything, draw scrollbars
    if (xScrollbarNeeded()) {
      xScrollbar.draw();
    }
    if (yScrollbarNeeded()) {
      yScrollbar.draw();
    }

  }
  
  /*
    xScrollbarNeeded
    Role: Helper function determining if the horizontal scrollbar needs shown.
    Author: Cian Mawhinney
  */
  boolean xScrollbarNeeded() {
    return screenWidth > width;
  }
  
  /*
    yScrollbarNeeded
    Role: Helper function determining if the vertical scrollbar needs shown.
    Author: Cian Mawhinney
  */
  boolean yScrollbarNeeded() {
    return screenHeight > height;
  }
  
  /*
    getMouseOver
    Role: Returns the event ID for the widget that was clicked on.
          See `Widget event identifiers` in constants file for
          special cases.
    Author: Cian Mawhinney
  */
  int getMouseOver(float xMouse, float yMouse) {
    // elements later in the widget list are drawn on top of earlier ones
    // so work through widget list in reverse order
    int event = EVENT_NULL;
    if (xScrollbarNeeded()) {
      if (xScrollbar.isMouseOverUpArrow(xMouse, yMouse)) event = SCROLLBAR_LEFT;
      if (xScrollbar.isMouseOverDownArrow(xMouse, yMouse)) event = SCROLLBAR_RIGHT;
      if (xScrollbar.isMouseOverHandle(xMouse, yMouse)) event = SCROLLBAR_HORIZONTAL_HANDLE;
    }
    
    if (yScrollbarNeeded()) {
      if (yScrollbar.isMouseOverUpArrow(xMouse, yMouse)) event = SCROLLBAR_UP;
      if (yScrollbar.isMouseOverDownArrow(xMouse, yMouse)) event = SCROLLBAR_DOWN;
      if (yScrollbar.isMouseOverHandle(xMouse, yMouse)) event = SCROLLBAR_VERTICAL_HANDLE;
    }
    
    if (event != EVENT_NULL) {
      return event;
    }
    
    for (int index = widgets.size() - 1; index >= 0; index--) {
      Widget widget = widgets.get(index);
      event = widget.isMouseOver(xMouse - getXScrollOffset(), yMouse - getYScrollOffset());
      if (event != EVENT_NULL) {
        return event;
      }
    }
    
    // for loop has finished without finding a widget
    return event;
  }
  
  /*
    getXScrollbar
    Role: Helper function which returns the horizontal scrollbar.
    Author: Cian Mawhinney
  */
  Scrollbar getXScrollbar() {
    return this.xScrollbar;
  }
  
  /*
    getYScrollbar
    Role: Helper function which returns the vertical scrollbar.
    Author: Cian Mawhinney
  */
  Scrollbar getYScrollbar() {
    return this.yScrollbar;
  }
  
  /*
    setDraggedScrollbar
    Role: Stores the scrollbar whose handle is currently being dragged
    Author: Cian Mawhinney
  */
  void setDraggedScrollbar(Scrollbar sb) {
    this.draggedScrollbar = sb;
  }
  
  /*
    getDraggedScrollbar
    Role: Returns the scrollbar whose handle is currently being dragged
    Author: Cian Mawhinney
  */
  Scrollbar getDraggedScrollbar() {
    return this.draggedScrollbar;
  }
  
  /*
    getXScrollOffset
    Role: Helper function which calculates how much the widgets should be shifted
          left or right because of the current scroll position
    Author: Cian Mawhinney
  */
  float getXScrollOffset() {
    return lerp(xScrollbar.getCurrentPosition(), 0, screenWidth - width);
  }
  
  /*
    getYScrollOffset
    Role: Helper function which calculates how much the widgets should be shifted
          up or down because of the current scroll position
    Author: Cian Mawhinney
  */
  float getYScrollOffset() {
    return lerp(yScrollbar.getCurrentPosition(), 0, screenHeight - height);
  }
  
  /*
    scrollVerticalByAmount
    Role: Scrolls the screen vertically by the passed number of units
    Author: Cian Mawhinney
  */
  void scrollVerticalByAmount(int lines) {
    // doesn't work like I'd want it to at the minute
    // TODO: account for different screen size when updating progres
    yScrollbar.setCurrentPosition(yScrollbar.getCurrentPosition() + ((float) (lines * 80) / (float) height));
  }
  
  /*
    scrollHorizontalByAmount
    Role: Scrolls the screen horixontally by the passed number of units
    Author: Cian Mawhinney
  */
  void scrollHorizontalByAmount(int lines) {
    // doesn't work like I'd want it to at the minute
    // TODO: account for different screen size when updating progres
    xScrollbar.setCurrentPosition(xScrollbar.getCurrentPosition() + ((float) (lines * 80) / (float) height));
  }
  
  /*
    scrollUp
    Role: Scrolls the screen up by 1 unit
    Author: Cian Mawhinney
  */
  void scrollUp() {
    scrollVerticalByAmount(-1);
  }
  
  /*
    scrollDown
    Role: Scrolls the screen down by 1 unit
    Author: Cian Mawhinney
  */
  void scrollDown() {
    scrollVerticalByAmount(1);
  }
  
  /*
    scrollLeft
    Role: Scrolls the screen left by 1 unit
    Author: Cian Mawhinney
  */
  void scrollLeft() {
    scrollHorizontalByAmount(-1);
  }
  
  /*
    scrollRight
    Role: Scrolls the screen right by 1 unit
    Author: Cian Mawhinney
  */
  void scrollRight() {
    scrollHorizontalByAmount(1);
  }
}
