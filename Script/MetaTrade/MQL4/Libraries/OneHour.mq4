//+------------------------------------------------------------------+
//|                                                         MACD.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
#include "../Libraries/BasicFunc.mq4"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OneHour
//base on Moving Average,MACD,RSI, Stochastic
  {
private:
   double            mainValue[10];
   double            signalValue[10];
   double            MA5[10],MA15[10];
   double            rsi;
   double            currentMarketInfo;
   int               updatePeriod;
   double            updateTime;
public:
   void OneHour()
     {
      currentMarketInfo=0;
      mainValue[0]=0;
      mainValue[1]=0;
      signalValue[0]=0;
      signalValue[1]=0;
      MA5[0] = 0;
      MA5[1] = 0;
      MA15[0] = 0;
      MA15[1] = 0;
      rsi=50;
     }
   void updateMACDValue()
     {
      mainValue[0] =     iMACD(NULL,PERIOD_H1,12,15,5,PRICE_CLOSE,MODE_MAIN,1);
      mainValue[1] =     iMACD(NULL,PERIOD_H1,12,15,5,PRICE_CLOSE,MODE_MAIN,2);
      signalValue[0] =   iMACD(NULL,PERIOD_H1,12,15,5,PRICE_CLOSE,MODE_SIGNAL,1);
      signalValue[1] =   iMACD(NULL,PERIOD_H1,12,15,5,PRICE_CLOSE,MODE_SIGNAL,2);

      MA5[0]  =   iMA(NULL,PERIOD_H1,5,0,MODE_SMMA,PRICE_CLOSE,1);
      MA5[1]  =   iMA(NULL,PERIOD_H1,5,0,MODE_SMMA,PRICE_CLOSE,2);
      MA15[0] =   iMA(NULL,PERIOD_H1,15,0,MODE_SMMA,PRICE_CLOSE,1);
      MA15[1] =   iMA(NULL,PERIOD_H1,15,0,MODE_SMMA,PRICE_CLOSE,2);

      rsi=iRSI(NULL,PERIOD_H1,5,PRICE_CLOSE,0);
     }

   double MarketInfomation()
     {
      double predict=0.0;
      updateMACDValue();
      //Print("main value 0:"+mainValue[0]+"    1:"+mainValue[1]+"main0-main1:"+(mainValue[0]-mainValue[1]));

      if(MA5[0]>MA5[1] && MA15[0]>MA15[1])
         predict=1;
      if(MA5[0]<MA5[1] && MA15[0]<MA15[1])
         predict=-1;

      //if(rsi>65 && predict==1)
      //   predict=0;
      //if(rsi<35 && predict==-1) //RSI 超过70, predict 预测上涨 ， 则 predict=0;
      //   predict=0;//RSI 低于 30 predict 预测下跌，则 predict=0;

      currentMarketInfo=predict;

      return currentMarketInfo;
     }
  };
//+------------------------------------------------------------------+
