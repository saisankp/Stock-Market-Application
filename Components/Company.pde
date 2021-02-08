/*
  The Company class is used to store a specific company from the stocks.csv file
  Author: Cian Mawhinney
*/

import java.util.Date;
import java.util.Calendar;
import java.util.Comparator;
import java.util.Collections;

public class Company implements Comparable<Company>{
  private String ticker;
  private String exchange;
  private String name;
  private String sector;
  private String industry;
  
  private ArrayList<DailyPrice> dailyStockPrices;
  
  Company (String ticker, String exchange, String name, String sector, String industry) {
    this.ticker = ticker;
    this.exchange = exchange;
    this.name = name;
    this.sector = sector;
    this.industry = industry;
    this.dailyStockPrices = new ArrayList<DailyPrice>();
  }
  
  
  // getters
  String getCompanyName() {
    return this.name;
  }
  
  String getCompanyTicker() {
    return this.ticker;
  }
  
  String getCompanyExchange() {
    return this.exchange;
  }
  
  String getCompanySector() {
    return this.sector;
  }
  
  String getCompanyIndustry() {
    return this.industry;
  }
  
  DailyPrice[] getDailyStockPrices() {
    return this.dailyStockPrices.toArray(new DailyPrice[0]);
  }
  
  /*
    getDailyStockPricesByDate
    Role: Returns the DailyPrice record from a given day, or null if one isn't found.
    Author: Cian Mawhinney
  */
  DailyPrice getDailyStockPriceByDate(Date date) {
    Calendar cal1 = Calendar.getInstance();
    cal1.setTime(date);
    Calendar cal2 = Calendar.getInstance();
    for (DailyPrice record : this.dailyStockPrices) {
      cal2.setTime(record.getDate());
      if (cal1.get(Calendar.DAY_OF_YEAR) == cal2.get(Calendar.DAY_OF_YEAR) &&
          cal1.get(Calendar.YEAR) == cal2.get(Calendar.YEAR)) {
        return record;
      }
    }
    // hasn't found anything
    return null;
  }
  
  /*
    getPriceClosestToDate
    Role: Returns the DailyPrice record which is closest to the passed date, or null if the company has no records.
    Author: Cian Mawhinney
  */
  DailyPrice getPriceClosestToDate(final Date date) {
    // Adapted from:  https://stackoverflow.com/questions/3884644/find-nearest-date-among-several-dates-to-a-given-date
    if (this.dailyStockPrices.size() > 0) {
      return Collections.min(this.dailyStockPrices, new Comparator<DailyPrice>() {
        public int compare(DailyPrice o1, DailyPrice o2) {
          long diff1 = Math.abs(o1.getDate().getTime() - date.getTime());
          long diff2 = Math.abs(o2.getDate().getTime() - date.getTime());
          return Long.compare(diff1, diff2);
        }
      });
    }
    else {
      // no price records for company
      return null;
    }
  }
  
  // Matthew Dowse
  DailyPrice[] getDailyStockPricesInDateRange(Date startDate, Date endDate){
    
  //  Calendar theCalendar = Calendar.getInstance();
    
  //  theCalendar.set(startYear, startMonth -1, startDay, 0, 0);
  //  Date startDate = theCalendar.getTime();
    
  //  theCalendar.set(endYear, endMonth -1, endDay, 0, 0);
  //  Date endDate = theCalendar.getTime();
    
    ArrayList<DailyPrice> dailyStockPriceInDateRange = new ArrayList<DailyPrice>();
    
    for(int i = 0; i < dailyStockPrices.size(); i++)
    {
      Date recordDate = dailyStockPrices.get(i).getDate();  //error will remove after DailyPrices is set to type Date
    
      if(recordDate.after(startDate) && recordDate.before(endDate))
      {
        dailyStockPriceInDateRange.add(dailyStockPrices.get(i));
      }
    }
    
    return dailyStockPriceInDateRange.toArray(new DailyPrice[0]);
  }

  /*
    getPriceChange
    Role: Returns the percentage change of the stock price between two dates as a decimal (ie. returns 0.5 for a 50% increase)
    Author: Cian Mawhinney
  */
  float getPriceChange(Date earlierDate, Date laterDate) {
   DailyPrice earlierRecord = getPriceClosestToDate(earlierDate);
   DailyPrice laterRecord = getPriceClosestToDate(laterDate);
   
   float earlierPrice = (earlierRecord != null) ? (float) earlierRecord.getClosePrice() : 1.0;
   float laterPrice = (laterRecord != null) ? (float) laterRecord.getClosePrice() : 1.0;
   
   float change = (laterPrice - earlierPrice) / earlierPrice;
   return change;
  }
  
  float getPriceChange(int timePeriod, Date currentDate) {
    Date earlierDate = currentDate;
    Calendar cal = Calendar.getInstance();
    cal.add(Calendar.DAY_OF_MONTH, -timePeriod);
    earlierDate = cal.getTime();
    return getPriceChange(earlierDate, currentDate);
  }
  
  
  // setters (for the sake of completeness more than anything)
  void updateCompanyName(String name) {
    this.name = name;
  }
  
  void updateCompanyTicker(String ticker) {
    this.ticker = ticker;
  }
  
  void updateCompanyExchange(String exchange) {
    this.exchange = exchange;
  }
  
  void updateCompanySector(String sector) {
    this.sector = sector;
  }
  
  void updateCompanyIndustry(String industry) {
    this.industry = industry;
  }
  
  void addDailyStockPrice(DailyPrice price) {
    dailyStockPrices.add(price);
  }
  
  // default sorting order
  int compareTo(Company o) {
    return this.getCompanyTicker().compareTo(o.getCompanyTicker());
  }

}

/*
  CompanySortByTicker object
  Role: Allows for sorting of an array of company objects by the company's ticker
  Author: Cian Mawhinney
*/
class CompanySortByTicker implements Comparator<Company> {
  public int compare(Company o1, Company o2) {
    return o1.getCompanyTicker().compareTo(o2.getCompanyTicker());
  }
}

/*
  CompanySortByName object
  Role: Allows for sorting of an array of company objects by the name of the company
  Author: Cian Mawhinney
*/
class CompanySortByName implements Comparator<Company> {
  public int compare(Company o1, Company o2) {
    return o1.getCompanyName().compareTo(o2.getCompanyName());
  }
}

/*
  CompanySortByBiggestChange object
  Role: Allows for sorting of an array of company objects by the biggest
        absolute change of a company's stock price in a given time frame
  Author: Cian Mawhinney
*/
class CompanySortByBiggestChange implements Comparator<Company> {

  private int timePeriod;
  private Date currentDate;

  CompanySortByBiggestChange(int timePeriod, Date currentDate) {
    this.timePeriod = timePeriod;
    this.currentDate = currentDate;
  }
  
  public int compare(Company o1, Company o2) {
    Float o1Change = Math.abs(o1.getPriceChange(this.timePeriod, this.currentDate));
    Float o2Change = Math.abs(o2.getPriceChange(this.timePeriod, this.currentDate));
    return o2Change.compareTo(o1Change);
  }
}

/*
  CompanySortByBiggestGain object
  Role: Allows for sorting of an array of company objects by the biggest
        gain of a company's stock price in a given time frame
  Author: Cian Mawhinney
*/
class CompanySortByBiggestGain implements Comparator<Company> {

  private int timePeriod;
  private Date currentDate;

  CompanySortByBiggestGain(int timePeriod, Date currentDate) {
    this.timePeriod = timePeriod;
    this.currentDate = currentDate;
  }
  
  public int compare(Company o1, Company o2) {
    Float o1Change = o1.getPriceChange(this.timePeriod, this.currentDate);
    Float o2Change = o2.getPriceChange(this.timePeriod, this.currentDate);
    return o2Change.compareTo(o1Change);
  }
}

/*
  CompanySortByBiggestLoss object
  Role: Allows for sorting of an array of company objects by the biggest
        loss of a company's stock price in a given time frame
  Author: Cian Mawhinney
*/
class CompanySortByBiggestLoss implements Comparator<Company> {

  private int timePeriod;
  private Date currentDate;

  CompanySortByBiggestLoss(int timePeriod, Date currentDate) {
    this.timePeriod = timePeriod;
    this.currentDate = currentDate;
  }
  
  public int compare(Company o1, Company o2) {
    Float o1Change = o1.getPriceChange(this.timePeriod, this.currentDate);
    Float o2Change = o2.getPriceChange(this.timePeriod, this.currentDate);
    return o1Change.compareTo(o2Change);
  }
}
