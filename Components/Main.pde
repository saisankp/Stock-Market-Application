/*
  This file is the starting point for our program, and displays the necessary Widgets,
  and handles user interaction
  Authors: Everyone
*/

import java.util.Collections;
import java.util.Arrays;

ArrayList<Company> companies;
Screen homeScreen;
Screen currentScreen;
Screen secondScreen;
PFont defaultFont;
Date now;

CompaniesFilter companiesFilter;
String companiesFilterArg;

CompaniesSorter companiesSorter;
Object companiesSorterArg1;
Object companiesSorterArg2;

int selectFrom;
int selectTo;

Company currentCompany;

void settings() {
  size(MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT);
}

void setup() {
  defaultFont = loadFont("Montserrat-Bold-48.vlw");
  now = new Date();
  
  companies = new ArrayList<Company>();

  // populate companies array
  BufferedReader companiesFile = createReader("stocks.csv");
  readLineFromCSVFile(companiesFile); // move past headers row
  String[] companyFields;
  while ((companyFields = readLineFromCSVFile(companiesFile)) != null) {
    // format of file is ticker, exchange, name, sector, industry
    companies.add(new Company(companyFields[0], companyFields[1], companyFields[2], companyFields[3], companyFields[4]));
  }
  
  // add stock price data to each company
  BufferedReader dailyPricesFile = createReader("daily_prices1k.csv");
  String[] dailyPricesFields;
  while ((dailyPricesFields = readLineFromCSVFile(dailyPricesFile)) !=  null) {
    // format of file is ticker, open, close, adj close, low, high, volume, date
    Company company = getCompanyByTicker(dailyPricesFields[0]);
    double openPrice = Double.valueOf(dailyPricesFields[1]);
    double closePrice = Double.valueOf(dailyPricesFields[2]);
    double adjClose = Double.valueOf(dailyPricesFields[3]);
    double low = Double.valueOf(dailyPricesFields[4]);
    double high = Double.valueOf(dailyPricesFields[5]);
    int volume = Integer.valueOf(dailyPricesFields[6]);
    String date = dailyPricesFields[7];
    
    company.addDailyStockPrice(new DailyPrice(openPrice, closePrice, adjClose, low, high, volume, date));
  }
  // set Default values.
  companiesFilter = CompaniesFilter.BY_NOTHING;
  companiesFilterArg = "";
  
  companiesSorter = CompaniesSorter.BY_BIGGEST_GAIN;
  companiesSorterArg1 = 365 * 30; // compare 30 years ago to now
  companiesSorterArg2 = now;
  
  selectFrom = 0;
  selectTo = 20;
  
  // build home screen
  homeScreen = new Screen(MAIN_BG);
  buildHomeScreen();
  
  // default screen when the program opens is the home screen 
  currentScreen = homeScreen;
}

/* Function Made by Prathamesh Sai 31/03/2020 
Role: The function filterComapanies filters the companies from the Company[] array 
which comply with the filterMethod passed into the function (i.e by stock exchange or by nothing)
*/
Company[] filterCompanies(Company[] companies, CompaniesFilter filterMethod, String filterArgument) {
  Company [] filteredCompanies;
  switch(filterMethod) {
      case BY_NOTHING: 
      filteredCompanies = companies;
      break;
    case BY_STOCK_EXCHANGE:  
      filteredCompanies = getCompaniesOnStockExchange(filterArgument); 
      break;
    default:
      println("Filter type not recognised, defaulting to not filtering"); 
      filteredCompanies = companies;
    }
    return filteredCompanies;
  }

/* Function made by Subrahmanyam Rayanapati
Role: The sortCompanies sorts the companies from the company[] according to the
sorterMethod passed into the function (eg: BY_TICKER, BY_NAME )
*/
void sortCompanies(Company[] filteredCompanies, CompaniesSorter sorterMethod, Object sortArgument1, Object sortArgument2)
{
  switch(sorterMethod)
  {
    case BY_TICKER:
      Arrays.sort(filteredCompanies, new CompanySortByTicker());
      break;
    case BY_NAME:
      Arrays.sort(filteredCompanies, new CompanySortByName());
      break;
    case BY_BIGGEST_CHANGE:
      Arrays.sort(filteredCompanies, new CompanySortByBiggestChange((int) companiesSorterArg1, (Date) companiesSorterArg2));
      break;
    case BY_BIGGEST_GAIN:
      Arrays.sort(filteredCompanies, new CompanySortByBiggestGain((int) companiesSorterArg1, (Date) companiesSorterArg2));
      break;
    case BY_BIGGEST_LOSS:
      Arrays.sort(filteredCompanies, new CompanySortByBiggestLoss((int) companiesSorterArg1, (Date) companiesSorterArg2));
      break;
    default:
      println("Sort type not recognised, defaulting to sorting by ticker");
      Arrays.sort(filteredCompanies, new CompanySortByTicker());
  }
}

/* Function made by Subrahmanyam Rayanapati
Role: The addCompaniesToHomeScreen displays the flitered/ sorted companies in the home screen 
*/
void addCompaniesToHomeScreen(Company[] filteredCompanies, int selectFrom, int selectTo)
{
  for (int index = selectFrom, position = 0; index < selectTo && index < filteredCompanies.length; index++, position++) {
    Company company = filteredCompanies[index];
    float priceChange = company.getPriceChange((int) companiesSorterArg1, (Date) companiesSorterArg2);
    String percentageChange = String.format("%.3f%%", priceChange * 100);
   
    homeScreen.add(new Text(company.getCompanyTicker(),   10,  690 + (position * (40 + 10)), 120, 30, LEFT, TOP, defaultFont, color(0), 18));
    homeScreen.add(new Text(company.getCompanyName(),     115, 690 + (position * (40 + 10)), 470, 30, LEFT, TOP, defaultFont, color(0), 18));
    homeScreen.add(new Text(company.getCompanyExchange(), 835, 690 + (position * (40 + 10)), 120, 30, LEFT, TOP, defaultFont, color(0), 18));
    homeScreen.add(new Text(percentageChange,             965, 690 + (position * (40 + 10)), 90,  30, LEFT, TOP, defaultFont, color(0), 18));
  }
}

/*
  buildHomeScreen
  Role: Adds widgets to the homeScreen global variable
  Author: Cian Mawhinney
*/
void buildHomeScreen() {
  // build and add graph  
  Calendar start = Calendar.getInstance();
  start.add(Calendar.DAY_OF_MONTH, -30 * 365);
  
  Calendar end = Calendar.getInstance();
  end.setTime(now);
  
  ArrayList<Float> xValues = new ArrayList<Float>();
  ArrayList<Float> yValues = new ArrayList<Float>();
  // looping over dates adapted from https://stackoverflow.com/a/4535239
  for (Date date = start.getTime(); start.before(end); start.add(Calendar.MONTH, 3), date = start.getTime()) {
    yValues.add((float) getAverageStockPrice(companies.toArray(new Company[0]), date));
    Calendar cal = Calendar.getInstance();
    cal.setTime(date);
    int year = cal.get(Calendar.YEAR);
    int month = cal.get(Calendar.MONTH);
    int day = cal.get(Calendar.DAY_OF_MONTH);
    xValues.add(getDateAsFloat(year, month, day));
  }
  
  // Manually convert from ArrayList<Float> to float[]
  float[] newX = new float[xValues.size()];
  float[] newY = new float[yValues.size()];
  for (int index = 0; index < newX.length; index++) {
    newX[index] = xValues.get(index);
    newY[index] = yValues.get(index);
  }
  
  Graph averagePriceGraph = new Graph(this, (width/4)-40, 10, width/2, 300, "Quarterly Average Stock Price", "Date", "Average Price/$");
  averagePriceGraph.setPoints(newX, newY);
  homeScreen.add(averagePriceGraph);
  
  // Filtering buttons
  homeScreen.add(new Text("Filter By:",  310, 335, 100, 25, LEFT, TOP, defaultFont, color(0), 18));
  homeScreen.add(new Button("No filter", 300, 360 + (40 + 10) * 0, 100, 40, BUTTON_BG));
  homeScreen.add(new Button("NASDAQ",    300, 360 + (40 + 10) * 1, 100, 40, BUTTON_BG));
  homeScreen.add(new Button("NYSE",      300, 360 + (40 + 10) * 2, 100, 40, BUTTON_BG));
  
  // Sorting buttons
  homeScreen.add(new Text("Sort By:",         490, 335, 200, 25, LEFT, TOP, defaultFont, color(0), 18));
  homeScreen.add(new Button("Ticker",         430, 360 + (40 + 10) * 0, 200, 40, BUTTON_BG));
  homeScreen.add(new Button("Name",           430, 360 + (40 + 10) * 1, 200, 40, BUTTON_BG));
  homeScreen.add(new Button("Biggest change", 430, 360 + (40 + 10) * 2, 200, 40, BUTTON_BG));
  homeScreen.add(new Button("Biggest gain",   430, 360 + (40 + 10) * 3, 200, 40, BUTTON_BG));
  homeScreen.add(new Button("Biggest loss",   430, 360 + (40 + 10) * 4, 200, 40, BUTTON_BG));
  
  
  // Number of records buttons
  homeScreen.add(new Text("# Records:", 660, 335, 100, 25, LEFT, TOP, defaultFont, color(0), 18));
  homeScreen.add(new Button("5",        660, 360 + (40 + 10) * 0, 100, 40, BUTTON_BG));
  homeScreen.add(new Button("10",       660, 360 + (40 + 10) * 1, 100, 40, BUTTON_BG));
  homeScreen.add(new Button("20",       660, 360 + (40 + 10) * 2, 100, 40, BUTTON_BG));
  homeScreen.add(new Button("50",       660, 360 + (40 + 10) * 3, 100, 40, BUTTON_BG));
  
  // Title for each column.
  homeScreen.add(new Text("Ticker", 7,  640 , 120, 30, LEFT, TOP, defaultFont, color(0), 21));
  homeScreen.add(new Text("Company", 480, 640, 470, 30, LEFT, TOP, defaultFont, color(0), 21));
  homeScreen.add(new Text("Exchange", 825, 640, 120, 30, LEFT, TOP, defaultFont, color(0), 21));
  homeScreen.add(new Text("% Change", 957, 640, 90,  30, LEFT, TOP, defaultFont, color(0), 21));
   
  updateCompanyRows();
}

/*
  updateCompanyRows
  Role: Updates the company rows to be filtered and sorted in the right way.
  Author: Cian Mawhinney
*/
void updateCompanyRows() {
  // remove any companies from the home screen
  for (int index = homeScreen.getWidgets().length - 1; index > HOME_SCREEN_STATIC_ELEMENTS; index--) {
    homeScreen.remove(index);
  }
  
  // 1) filter the companies array in the right way 
  Company[] filteredCompanies = filterCompanies(companies.toArray(new Company[0]), companiesFilter, companiesFilterArg);
  // 2) sort the filtered array with the right sorter
  sortCompanies(filteredCompanies, companiesSorter, companiesSorterArg1, companiesSorterArg2);  
  // 3) select the top number of records
  addCompaniesToHomeScreen(filteredCompanies, selectFrom, selectTo);
}

void draw() {
  currentScreen.draw();
}

/*
  mousePressed
  Role: Called when the mouse has been pressed. Used to allow widgets to be interactive.
  Authors: Cian Mawhinney - Home screen
           Matthew Dowse  - Second Screen
*/
void mousePressed() {
  int eventID = currentScreen.getMouseOver(mouseX, mouseY);
  if (eventID < 0) {
    // a 'special' element has been pressed ie. Scrollbars or EVENT_NULL
    switch (eventID) {
      case SCROLLBAR_UP:
        currentScreen.scrollUp();
        break;
      case SCROLLBAR_DOWN:
        currentScreen.scrollDown();
        break;
      case SCROLLBAR_VERTICAL_HANDLE:
        if (currentScreen.getDraggedScrollbar() == null) {
          Scrollbar sb = currentScreen.getYScrollbar();
          sb.setDraggedFrom(mouseX, mouseY);
          currentScreen.setDraggedScrollbar(sb);
        }
        break;
      case SCROLLBAR_LEFT:
        currentScreen.scrollLeft();
        break;
      case SCROLLBAR_RIGHT:
        currentScreen.scrollRight();
        break;
      case SCROLLBAR_HORIZONTAL_HANDLE:
        if (currentScreen.getDraggedScrollbar() == null) {
          Scrollbar sb = currentScreen.getXScrollbar();
          sb.setDraggedFrom(mouseX, mouseY);
          currentScreen.setDraggedScrollbar(sb);
        }
        break;
    }
  }
  else {
    if (currentScreen == homeScreen) {
      boolean homeScreenNeedsUpdating = true;
      switch (eventID) {
        case FILTER_BY_NOTHING_BUTTON:
          companiesFilter = CompaniesFilter.BY_NOTHING;
          break;
        case FILTER_BY_NASDAQ_BUTTON:
          companiesFilter = CompaniesFilter.BY_STOCK_EXCHANGE;
          companiesFilterArg = "NASDAQ";
          break;
        case FILTER_BY_NYSE_BUTTON:
          companiesFilter = CompaniesFilter.BY_STOCK_EXCHANGE;
          companiesFilterArg = "NYSE";
          break;
        case SORT_BY_TICKER_BUTTON:
          companiesSorter = CompaniesSorter.BY_TICKER;
          break;
        case SORT_BY_NAME_BUTTON:
          companiesSorter = CompaniesSorter.BY_NAME;
          break;
        case SORT_BY_BIGGEST_CHANGE_BUTTON:
          companiesSorter = CompaniesSorter.BY_BIGGEST_CHANGE;
          break;
        case SORT_BY_BIGGEST_GAIN_BUTTON:
          companiesSorter = CompaniesSorter.BY_BIGGEST_GAIN;
          break;
        case SORT_BY_BIGGEST_LOSS_BUTTON:
          companiesSorter = CompaniesSorter.BY_BIGGEST_LOSS;
          break;
        case NO_OF_RECORDS_5_BUTTON:
          selectTo = selectFrom + 5;
          break;
        case NO_OF_RECORDS_10_BUTTON:
          selectTo = selectFrom + 10;
          break;
        case NO_OF_RECORDS_20_BUTTON:
          selectTo = selectFrom + 20;
          break;
        case NO_OF_RECORDS_50_BUTTON:
          selectTo = selectFrom + 50;
          break;
        case EVENT_NULL:
          homeScreenNeedsUpdating = false;  // do nothing
          break;  
        default:
          homeScreenNeedsUpdating = false;
          if (eventID > HOME_SCREEN_STATIC_ELEMENTS) {
            int numberOfColumnsInCompanyResults = 4;
            int companyRow = (eventID - (HOME_SCREEN_STATIC_ELEMENTS + 1)) / numberOfColumnsInCompanyResults;
            int tickerWidgetIndex = HOME_SCREEN_STATIC_ELEMENTS + 1 + companyRow * numberOfColumnsInCompanyResults;
            Text tickerTextWidget = (Text) currentScreen.getWidgets()[tickerWidgetIndex];
            String ticker = tickerTextWidget.getLabelText();
            buildSecondScreen(getCompanyByTicker(ticker));
            currentScreen = secondScreen;
          }
          break;
      }
      if (homeScreenNeedsUpdating) {
        updateCompanyRows();
      }
    }
    else if (currentScreen == secondScreen) {
      // TODO: have buttons to specify the date range shown on the graph
      Graph secondScreenGraph;
      Calendar calendar;
      Date currentDay; 
      Date minusXDay;
      DailyPrice[] oneDayPriceData;
      GPointsArray points; 
      switch (eventID) {
        case SECOND_SCREEN_RETURN_BUTTON:
          currentScreen = homeScreen;
          break;
        case SECOND_SCREEN_5_YEAR:
         secondScreenGraph = (Graph) secondScreen.getWidgets()[SECOND_SCREEN_GRAPH];
         
         calendar = Calendar.getInstance();
         currentDay = calendar.getTime();
         calendar.add(Calendar.DAY_OF_MONTH, (-5*365));
         minusXDay = calendar.getTime();
         
         oneDayPriceData = currentCompany.getDailyStockPricesInDateRange(minusXDay, currentDay);
         
         points = convertDataToPoints(oneDayPriceData);
         
         secondScreenGraph.setPoints(points);     
          break;
        case SECOND_SCREEN_10_YEAR:
        //
        secondScreenGraph = (Graph) secondScreen.getWidgets()[SECOND_SCREEN_GRAPH];
         
         calendar = Calendar.getInstance();
         currentDay = calendar.getTime();
         calendar.add(Calendar.DAY_OF_MONTH, (-10*365));
         minusXDay = calendar.getTime();
         
         oneDayPriceData = currentCompany.getDailyStockPricesInDateRange(minusXDay, currentDay);
         
         points = convertDataToPoints(oneDayPriceData);
         
         secondScreenGraph.setPoints(points); 
          break;
        case SECOND_SCREEN_15_YEAR:
        //
        secondScreenGraph = (Graph) secondScreen.getWidgets()[SECOND_SCREEN_GRAPH];
         
         calendar = Calendar.getInstance();
         currentDay = calendar.getTime();
         calendar.add(Calendar.DAY_OF_MONTH, (-15*365));
         minusXDay = calendar.getTime();
         
         oneDayPriceData = currentCompany.getDailyStockPricesInDateRange(minusXDay, currentDay);
         
         points = convertDataToPoints(oneDayPriceData);
         
         secondScreenGraph.setPoints(points); 
          break;
        case SECOND_SCREEN_20_YEAR:
        //
         secondScreenGraph = (Graph) secondScreen.getWidgets()[SECOND_SCREEN_GRAPH];
         
         calendar = Calendar.getInstance();
         currentDay = calendar.getTime();
         calendar.add(Calendar.DAY_OF_MONTH, (-20*365));
         minusXDay = calendar.getTime();
         
         oneDayPriceData = currentCompany.getDailyStockPricesInDateRange(minusXDay, currentDay);
         
         points = convertDataToPoints(oneDayPriceData);
         
         secondScreenGraph.setPoints(points); 
          break;
        case SECOND_SCREEN_25_YEAR:
        //
         secondScreenGraph = (Graph) secondScreen.getWidgets()[SECOND_SCREEN_GRAPH];
         
         calendar = Calendar.getInstance();
         currentDay = calendar.getTime();
         calendar.add(Calendar.DAY_OF_MONTH, (-25*365));
         minusXDay = calendar.getTime();
         
         oneDayPriceData = currentCompany.getDailyStockPricesInDateRange(minusXDay, currentDay);
         
         points = convertDataToPoints(oneDayPriceData);
         
         secondScreenGraph.setPoints(points); 
          break;
        case SECOND_SCREEN_30_YEAR:
        //
         secondScreenGraph = (Graph) secondScreen.getWidgets()[SECOND_SCREEN_GRAPH];
         
         calendar = Calendar.getInstance();
         currentDay = calendar.getTime();
         calendar.add(Calendar.DAY_OF_MONTH, (-30*365));
         minusXDay = calendar.getTime();
         
         oneDayPriceData = currentCompany.getDailyStockPricesInDateRange(minusXDay, currentDay);
         
         points = convertDataToPoints(oneDayPriceData);
         
         secondScreenGraph.setPoints(points); 
          break;
        case SECOND_SCREEN_MAX:
        //
        secondScreenGraph = (Graph) secondScreen.getWidgets()[SECOND_SCREEN_GRAPH];       
        points = convertDataToPoints(currentCompany.getDailyStockPrices());
        secondScreenGraph.setPoints(points);
          break;    
        
        default:
          // do nothing
          break;
      }
    }
  }
}

void mouseDragged() {
  // currently the only thing we have planned that should be draggable are the scrollbars
  Scrollbar sb = currentScreen.getDraggedScrollbar();
  if (sb != null) {
    sb.moveHandle(mouseX, mouseY);
    sb.setDraggedFrom(mouseX, mouseY);
  }
}

void mouseReleased() {
  if (currentScreen.getDraggedScrollbar() != null) {
    currentScreen.setDraggedScrollbar(null);
  }
}

void mouseWheel(MouseEvent event) {
  currentScreen.scrollVerticalByAmount(event.getCount());
}

/*
  readLineFromCSV
  Role: Reads a single line from a file, handling any errors that may occur.
  Author: Cian Mawhinney
*/
String[] readLineFromCSVFile(BufferedReader file) {
  String line;
  try {
    line = file.readLine();
  } catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
  
  if (line != null) {
    return line.split(",");
  }
  else {
    return null;
  }
}

/* function made by Prathamesh Sai
Role: The function getCompanyByTicker returns the company that matches the 
ticker string passed into the function.
*/
Company getCompanyByTicker(String ticker) {
  for (Company company : companies) {
    if(company.ticker.equals(ticker)) {
      return company;
    }
  }
  // hasn't found anything
  return null;
}

/* function made by Prathamesh Sai 19.03.2020
Role: The function getCompaniesOnStockExchange returns a new array consisting of 
the companies that match the exchange string that is passed into the function.
*/
Company[] getCompaniesOnStockExchange(String exchange) {    
  ArrayList<Company> result = new ArrayList(); // create 'result' arraylist 

  for(int i = 0; i < companies.size() ; i++) { //loop through companies
    Company company = companies.get(i); // create an object of the company.
    if (company.getCompanyExchange().equals(exchange)) { //if the exchange matches
      result.add(company); //add company to result array.
    }
  }
  return result.toArray(new Company[0]); //converts from arraylist to array.
}

/*
  getDateAsFloat
  Role: Returns a non-exact representation of a date as a float.
  Author: Cian Mawhinney
*/
float getDateAsFloat(int year, int month, int day) {
  // Adapted from https://github.com/jagracar/grafica/blob/master/examples/OktoberfestExample/OktoberfestExample.pde#L76
  boolean leapYear = ((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0));
  
  int[] daysPerMonth = new int[] {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
  int[] daysPerMonthLeapYear = new int[] {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
  
  if (leapYear) {
    return year + (month + (day - 1f)/daysPerMonthLeapYear[month])/12f;
  }
  else {
    return year + (month + (day - 1f)/daysPerMonth[month])/12f;
  }
}

/*
  getAverageStockPrice
  Role: Returns the average stock price on a given day.
  Author: Cian Mawhinney
*/
double getAverageStockPrice(Company[] companies, Date date) {
  double total = 0.0;
  int count = 0;
  for (Company company : companies) {
    DailyPrice priceRecord = company.getPriceClosestToDate(date);
    if (priceRecord != null) {
      total += priceRecord.getClosePrice();
      count++;
    }
  }
  return total / (double) count;
}

// Matthew Dowse
void buildSecondScreen(Company company)
{
  currentCompany = company;
  
  secondScreen = new Screen(MAIN_BG);
   
  secondScreen.add(new Button("Return", 25, 25, 100, 50, color(BUTTON_BG))); //0
  
  secondScreen.add(new Button("5 Year", 200, 180, 90, 50, color(BUTTON_BG))); //1
  secondScreen.add(new Button("10 Year", 300, 180, 90, 50, color(BUTTON_BG)));//2
  secondScreen.add(new Button("15 Year", 400, 180, 90, 50, color(BUTTON_BG)));//3
  secondScreen.add(new Button("20 Year", 500, 180, 90, 50, color(BUTTON_BG)));//4
  secondScreen.add(new Button("25 Year", 600, 180, 90, 50, color(BUTTON_BG)));//5
  secondScreen.add(new Button("30 Year", 700, 180, 90, 50, color(BUTTON_BG)));//6
  secondScreen.add(new Button("MAX", 800, 180, 90, 50, color(BUTTON_BG))); //7
  
  
  // company information
  secondScreen.add(new Text("Company Name: " + company.getCompanyName(), 50, 100, 100, 50, LEFT, TOP, defaultFont, color(0), 20));  //8  
  secondScreen.add(new Text("Ticker: " + company.getCompanyTicker(), 50, 150, 100, 50, LEFT, TOP, defaultFont, color(0), 20)); //9
  
    // build graph
  DailyPrice[] priceData = company.getDailyStockPrices();
  Arrays.sort(priceData, new DailyPriceSortByDate());
  
  ArrayList<Float> xValues = new ArrayList<Float>();
  ArrayList<Float> yValues = new ArrayList<Float>();
  for (DailyPrice price : priceData) {
    yValues.add((float) price.getClosePrice());
    Date date = price.getDate();
    Calendar cal = Calendar.getInstance();
    cal.setTime(date);
    int year = cal.get(Calendar.YEAR);
    int month = cal.get(Calendar.MONTH);
    int day = cal.get(Calendar.DAY_OF_MONTH);
    xValues.add(getDateAsFloat(year, month, day));
  }
  
  // manually convert from ArrayList<Float> to float[]
  float[] newX = new float[xValues.size()];
  float[] newY = new float[yValues.size()];
  for (int index = 0; index < newX.length; index++) {
    newX[index] = xValues.get(index);
    newY[index] = yValues.get(index);
  }
  Graph companyGraph = new Graph(this, 125, 255, 800, 400, company.getCompanyName() + " Stock Price", "Date", "Price/$");
  companyGraph.setPoints(newX, newY);
  secondScreen.add(companyGraph);
  
  // stock price information
  DailyPrice latestPrice = company.getPriceClosestToDate(now);
  if (latestPrice != null) {
    secondScreen.add(new Text(String.format("Opening Price: $%.2f", latestPrice.getOpenPrice()),      280, 660, 100, 25, LEFT, TOP, defaultFont, color(0), 20));
    secondScreen.add(new Text(String.format("Closing Price: $%.2f", latestPrice.getClosePrice()),     280, 700, 100, 25, LEFT, TOP, defaultFont, color(0), 20));
    secondScreen.add(new Text(String.format("Adjusted Close: $%.2f", latestPrice.getAdjustedClose()), 280, 740, 100, 25, LEFT, TOP, defaultFont, color(0), 20));
    secondScreen.add(new Text(String.format("Daily Low: $%.2f", latestPrice.getLow()),                570, 660, 100, 25, LEFT, TOP, defaultFont, color(0), 20));
    secondScreen.add(new Text(String.format("Daily High: $%.2f", latestPrice.getHigh()),              570, 700, 100, 25, LEFT, TOP, defaultFont, color(0), 20));
    secondScreen.add(new Text(String.format("Volume: %s", latestPrice.getVolume()),                   570, 740, 100, 25, LEFT, TOP, defaultFont, color(0), 20));
  }
  else {
    secondScreen.add(new Text("No price data found for " + company.getCompanyTicker(), 370, 680, 100, 25, LEFT, TOP, defaultFont, #FF0D0D, 20));
  }

}

// Matthew Dowse
GPointsArray convertDataToPoints(DailyPrice priceData[])
{
  Arrays.sort(priceData, new DailyPriceSortByDate());
  
  ArrayList<Float> xValues = new ArrayList<Float>();
  ArrayList<Float> yValues = new ArrayList<Float>();
  for (DailyPrice price : priceData) {
    yValues.add((float) price.getClosePrice());
    Date date = price.getDate();
    Calendar cal = Calendar.getInstance();
    cal.setTime(date);
    int year = cal.get(Calendar.YEAR);
    int month = cal.get(Calendar.MONTH);
    int day = cal.get(Calendar.DAY_OF_MONTH);
    xValues.add(getDateAsFloat(year, month, day));
  }
  
  // manually convert from ArrayList<Float> to float[]
  float[] newX = new float[xValues.size()];
  float[] newY = new float[yValues.size()];
  for (int index = 0; index < newX.length; index++) {
    newX[index] = xValues.get(index);
    newY[index] = yValues.get(index);
  }
     return new GPointsArray(newX, newY);
  
}

 
 
