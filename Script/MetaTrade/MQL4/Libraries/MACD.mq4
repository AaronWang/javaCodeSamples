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
class MACD
  {
private:
   double            mainValue[10];
   double            signalValue[10];
   double            currentMarketInfo;
   int               updatePeriod;
   double            updateTime;
public:
   void MACD()
     {
      currentMarketInfo=0;
      mainValue[0]=0;
      mainValue[1]=0;
      mainValue[2]=0;
      mainValue[3]=0;
      mainValue[4]=0;
      mainValue[5]=0;
      mainValue[6]=0;
      mainValue[7]=0;
      mainValue[8]=0;
      mainValue[9]=0;
      signalValue[0]=0;
      signalValue[1]=0;
      signalValue[2]=0;
      signalValue[3]=0;
      signalValue[4]=0;
      signalValue[5]=0;
      signalValue[6]=0;
      signalValue[7]=0;
      signalValue[8]=0;
      signalValue[9]=0;
     }
   void updateMACDValue()
     {

      mainValue[0]=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
      mainValue[1] =     iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
      mainValue[2] =     iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,2);
      mainValue[3] =     iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,3);
      mainValue[4] =     iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,4);
      mainValue[5] =     iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,5);
      mainValue[6] =     iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,6);
      mainValue[7] =     iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,7);
      mainValue[8] =     iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,8);
      mainValue[9] =     iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,9);

      signalValue[0] =   iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
      signalValue[1] =   iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
      signalValue[2] =   iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,2);
      signalValue[3] =   iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,3);
      signalValue[4] =   iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,4);
      signalValue[5] =   iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,5);
      signalValue[6] =   iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,6);
      signalValue[7] =   iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,7);
      signalValue[8] =   iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,8);
      signalValue[9] =   iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,9);
     }

   double MarketInfomation_MACD()
     {
      double predict=0.0;
      updatePeriod=Period()*10;//一个周期 更新六次
      if(TimeCurrent()-updateTime>=updatePeriod)//以秒 计算时间周期
        {
         updateTime=TimeCurrent();
         updateMACDValue();

         predict=LineCrossPoint(mainValue[0],mainValue[1],signalValue[0],signalValue[1]);
         if(mainValue[0]>0 && signalValue[0]>0 && predict==-1)
           {
            predict=0;
           }
         if(mainValue[0]<0 && signalValue[0]<0 && predict==1)
           {
            predict=0;
           }
         if(predict==0 && currentMarketInfo!=0)
           {
            if(currentMarketInfo==1)
              {
               if(mainValue[0]-signalValue[0]>mainValue[1]-signalValue[1])
                  predict=1;
               else predict=0;
              }
            if(currentMarketInfo==-1)
              {
               if(mainValue[0]-signalValue[0]<mainValue[1]-signalValue[1])
                  predict=-1;
               else predict=0;
              }
           }
         currentMarketInfo=predict;
         return predict;
        }
      return currentMarketInfo;
     }
  };
//+------------------------------------------------------------------+
