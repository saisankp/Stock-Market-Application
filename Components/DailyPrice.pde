// daily prices class created - M.Dowse @17:40 12/03/2020
// renamed DailyPrices to DailyPrice - C. Mawhinney @13:00 15/03/2020

/*
  The DailyPrice class holds a specific price record from the daily_pricesXX.csv file
  Author: Matthew Dowse
*/

import java.util.Comparator;
import java.util.Collections;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.ParseException;

public class DailyPrice implements Comparable<DailyPrice>
{
  private double openPrice;
  private double closePrice;
  private double adjustedClose;
  private double low;
  private double high;
  private int volume;
  private Date date;
  
  
  // Matthew Dowse (class)
  DailyPrice(double openPrice, double closePrice, double adjustedClose, 
  double low, double high, int volume, String date)
  {
    this.openPrice = openPrice;
    this.closePrice = closePrice;
    this.adjustedClose = adjustedClose;
    this.low = low;
    this.high = high;
    this.volume = volume;
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    try
    {
      this.date = sdf.parse(date);
    }
    catch (ParseException e)
    {
      println("Could not parse date from file");
    }
  }
  
  double getOpenPrice()
  { 
    return openPrice;
  }
  
  void setOpenPrice(double openPrice)
  {
    this.openPrice = openPrice;
  }
  
  double getClosePrice()
  {
    return closePrice;
  }
  
  void setClosePrice(double closePrice)
  {
    this.closePrice = closePrice;
  }
  
  double getAdjustedClose()
  {
    return adjustedClose;
  }
  
  void setAdjustedlose(double adjustedClose)
  {
    this.adjustedClose = adjustedClose;
  }
  
  double getLow()
  {
    return low;
  }
  
  void setLow(double low)
  {
    this.low = low;
  }
  
  double getHigh()
  {
    return high;
  }
  
  void setHigh(double high)
  {
    this.high = high;
  }
  
  int getVolume()
  {
    return volume;
  }
  
  void setVolume(int volume)
  {
    this.volume = volume;
  }
  
  Date getDate()
  {
    return date;
  }
  
  void setDate(Date date)
  {
    this.date = date;
  }
  
  // default sorting order
  int compareTo(DailyPrice o)
  {
    return this.getDate().compareTo(o.getDate());
  }
  
}

/*
  DailyPriceSortByDate object
  Role: Allows for sorting of an array of DailyPrice objects by the date they occurred on
  Author: Cian Mawhinney
*/
class DailyPriceSortByDate implements Comparator<DailyPrice>
{
  public int compare(DailyPrice o1, DailyPrice o2)
  {
    return o1.getDate().compareTo(o2.getDate());
  }
}

/*
  DailyPriceSortByAdjClose object
  Role: Allows for sorting of an array of DailyPrice objects by adjusted closing price
  Author: Cian Mawhinney
*/
class DailyPriceSortByAdjClose implements Comparator<DailyPrice>
{
  public int compare(DailyPrice o1, DailyPrice o2)
  {
    Double adjClose1 =  o1.getAdjustedClose();
    Double adjClose2 =  o2.getAdjustedClose();
    return adjClose1.compareTo(adjClose2);
  }
}
