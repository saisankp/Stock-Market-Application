/* Constants relating to the main file */
final color MAIN_BG = color(255);
final color BUTTON_BG = #F7A566;
final int MAIN_SCREEN_WIDTH = 1100;
final int MAIN_SCREEN_HEIGHT = 800;

enum CompaniesFilter {
  BY_NOTHING,
  BY_STOCK_EXCHANGE
}

enum CompaniesSorter {
  BY_TICKER,
  BY_NAME,
  BY_BIGGEST_CHANGE,
  BY_BIGGEST_GAIN,
  BY_BIGGEST_LOSS
}

/* Scrollbar related constants */
final int SCROLLBAR_WIDTH = 20;
final color SCROLLBAR_BG = #F0ECE1;
final color SCROLLBAR_ARROW = #BFB9A9;
final color SCROLLBAR_HANDLE = #BFB9A9;

/* Widget event identifiers */
final int EVENT_NULL = -1;
final int SCROLLBAR_UP = -2;
final int SCROLLBAR_DOWN = -3;
final int SCROLLBAR_VERTICAL_HANDLE = -4;
final int SCROLLBAR_LEFT = -5;
final int SCROLLBAR_RIGHT = -6;
final int SCROLLBAR_HORIZONTAL_HANDLE = -7;

/* Home screen specific event identifiers */ 
final int TOP_GRAPH = 0;

final int FILTER_BY_LABEL = 1;
final int FILTER_BY_NOTHING_BUTTON = 2;
final int FILTER_BY_NASDAQ_BUTTON = 3;
final int FILTER_BY_NYSE_BUTTON = 4;

final int SORT_BY_LABEL = 5;
final int SORT_BY_TICKER_BUTTON = 6;
final int SORT_BY_NAME_BUTTON = 7;
final int SORT_BY_BIGGEST_CHANGE_BUTTON = 8;
final int SORT_BY_BIGGEST_GAIN_BUTTON = 9;
final int SORT_BY_BIGGEST_LOSS_BUTTON = 10;

final int NO_OF_RECORDS_LABEL = 11;
final int NO_OF_RECORDS_5_BUTTON = 12;
final int NO_OF_RECORDS_10_BUTTON = 13;
final int NO_OF_RECORDS_20_BUTTON = 14;
final int NO_OF_RECORDS_50_BUTTON = 15;

final int TICKER_TITLE = 16;
final int COMPANY_TITLE = 17;
final int EXCHANGE_TITLE = 18;
final int CHANGE_TITLE = 19;

final int HOME_SCREEN_STATIC_ELEMENTS = 19;

/* Second screen specific event identifiers*/
final int SECOND_SCREEN_RETURN_BUTTON = 0;
final int SECOND_SCREEN_5_YEAR = 1;
final int SECOND_SCREEN_10_YEAR = 2;
final int SECOND_SCREEN_15_YEAR = 3;
final int SECOND_SCREEN_20_YEAR = 4;
final int SECOND_SCREEN_25_YEAR = 5;
final int SECOND_SCREEN_30_YEAR = 6;
final int SECOND_SCREEN_MAX = 7;
final int SECOND_SCREEN_COMPANY_NAME = 8;
final int SECOND_SCREEN_TICKER = 9;
final int SECOND_SCREEN_GRAPH = 10;
