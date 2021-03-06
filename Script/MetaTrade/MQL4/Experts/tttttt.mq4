//+------------------------------------------------------------------+
//|                                                       tttttt.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include "../Libraries/BasicFunc.mq4"
#include "../Libraries/MovingAverage.mq4"
#define ABC 100
#define PI 3.141592

extern double externDouble=1.1;
extern double movePoint=50;
double marketInformation=0; //0波动，1上涨  -1下跌

double askOrigin=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Print("000000000000000000000000000000000000000000 OnInit");
   askOrigin=Ask;

   Print("My Max Lots: "+maxLots());

//iDrawLine(Red,13,Close[13],6,Close[6]);
   iDrawSign("Buy",Close[6]);
   iDrawSign("Sell",Close[12]);
//iDrawSign("GreenMark",Close[24]);
//iDrawSign("RedMark",Close[48]);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("1111111111111111111111111111111111111111111 OnDeInit");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick()
  {
//Print("Close[0]: "+Close[0]+"Close[1]: "+"      Bid: "+Bid);

   getMarketInformation();
//marketInformation=-1;
//stopLossTakeProfit();
//myOrderStrategy();

//if(test == 5)
//ChartSetSymbolPeriod(0,NULL,PERIOD_M1);
//if(test == 10)
//ChartSetSymbolPeriod(0,NULL,PERIOD_MN1);

//Print("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT OnTick");
//Print((Ask-Bid)/Point);
//Print(askOrigin);
//askOrigin = Ask;
//myStrategy(movePoint);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
/* 
   鳄鱼三线 + Force
   函数：返回市场信息 获取技术指标参数，通过比对，返回市场信息： 
      Buy -买入信号，
      sell-卖出信号，
      Rise-涨势行情，
      Fall-跌势行情， 
      UpCross-向上翻转，
      DownCross-向下反转,反转信号为平仓信号 */
double Filter=0.35;//Force指标过滤参数 
double Alligator_jaw,Alligator_teeth,Alligator_lips,Envelops21_upper,Envelops21_lower,Force3;
//+------------------------------------------------------------------+
string ReturnMarketInfomation1()
  {
   string MktInfo="N/A"; //读取指标数值 
   Alligator_jaw=NormalizeDouble(iAlligator("EURUSD",30,8,0,5,0,3,0,MODE_EMA,PRICE_WEIGHTED,MODE_GATORJAW,0),4);
   Alligator_teeth=NormalizeDouble(iAlligator("EURUSD",30,8,0,5,0,3,0,MODE_EMA,PRICE_WEIGHTED,MODE_GATORTEETH,0),4);
   Alligator_lips=NormalizeDouble(iAlligator("EURUSD",30,8,0,5,0,3,0,MODE_EMA,PRICE_WEIGHTED,MODE_GATORLIPS,0),4);
   double Alligator_jaw_1=NormalizeDouble(iAlligator("EURUSD",30,8,0,5,0,3,0,MODE_EMA,PRICE_WEIGHTED,MODE_GATORJAW,1),4);
   double Alligator_teeth_1=NormalizeDouble(iAlligator("EURUSD",30,8,0,5,0,3,0,MODE_EMA,PRICE_WEIGHTED,MODE_GATORTEETH,1),4);
   double Alligator_lips_1=NormalizeDouble(iAlligator("EURUSD",30,8,0,5,0,3,0,MODE_EMA,PRICE_WEIGHTED,MODE_GATORLIPS,1),4);
   Force3=NormalizeDouble(iForce("EURUSD",30,3,MODE_EMA,PRICE_WEIGHTED,0),4);

//指标分析，返回市场信息 || Force3<-FilterForce3>Filter || 
   if(Alligator_lips>Alligator_teeth && Alligator_lips_1<=Alligator_teeth_1)
      MktInfo="UpCross";
   if(Alligator_lips<Alligator_teeth && Alligator_lips_1>=Alligator_teeth_1)
      MktInfo="DownCross";
   if(Alligator_lips>Alligator_teeth && Alligator_teeth>Alligator_jaw)
      MktInfo="Rise";
   if(Alligator_lips<Alligator_teeth && Alligator_teeth<Alligator_jaw)
      MktInfo="Fall";
   if(Force3>Filter && MktInfo=="Rise")
      MktInfo="Buy";
   if(Force3<-Filter && MktInfo=="Fall")
      MktInfo="Sell";
   return(MktInfo);
  }
//+------------------------------------------------------------------+
/* 判断MACD以及市场价格，提交"Buy"和"Sell"信号 */
string ReturnMarketInfomation2()
  {
   string MktInfo="N/A";
   double MACD_0=iMACD(NULL,0,10,60,1,PRICE_CLOSE,MODE_SIGNAL,0);
   double MACD_2=iMACD(NULL,0,10,60,1,PRICE_CLOSE,MODE_SIGNAL,10);
   double price_0=Close[0];
   double price_high_2=High[2];
   double price_low_2=Low[2];
   if(MACD_0>(MACD_2+0.00003) && price_0>price_high_2)
     {
      MktInfo="Sell";
     }
   else if(MACD_0<(MACD_2-0.00003) && price_0<price_low_2)
     {
      MktInfo="Buy";
     }
   return(MktInfo);
  }
//+------------------------------------------------------------------+

int market;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getMarketInformation()
  {
   market=0;
//indicator 1
//indicator 2
//indicator 3
//indicator 4
//indicator 5
   string in1=ReturnMarketInfomation1();
   string in2=ReturnMarketInfomation2();
   string in3=MarketInfomation_MovingAverage();
   if(in1 == "Rise"||in1 == "Buy")market++;
   if(in1 == "Fall"||in1 == "Sell")market--;
   if(in2 == "Buy")market++;
   if(in2 == "Sell")market--;
   if(in3 == "Buy")market++;
   if(in3 == "Sell")market--;
   if(market==3)
     {
      marketInformation=0.7;
      iDrawSign("GreenMark",Close[0]);
     }
   if(market==-3)
     {
      marketInformation=-0.7;
      iDrawSign("RedMark",Close[0]);
     }
   if(market>-3 && market<3) marketInformation=0;
//marketInformation = market/2;
//
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void stopLossTakeProfit()
  {
   for(int G_Count=OrdersTotal();G_Count>=0;G_Count--)
     {
      if(OrderSelect(G_Count,SELECT_BY_POS)==false)continue;
      else
        {
         if(marketInformation>=-1 && marketInformation<-0.3)//下跌行情
           {
            iCloseOrders("Buy");
            OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0);
           }
         else if(marketInformation>=-0.3 && marketInformation<=0.3)//波动
           {
            //关闭下跌order
            OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0);
           }
         else if(marketInformation>0.3 && marketInformation<=1)//上涨行情
           {
            iCloseOrders("Sell");
            //关闭上涨order
            OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0);
           }
        }
      // perProfit=perProfit+OrderProfit();//利润累加 
     }
  }
//+------------------------------------------------------------------+

int orderPeriod=1200;// 20 minutes;
int minOrderPeriod=60;//1 minute;
int maxOrderPeriod=10800;//3hours
//+------------------------------------------------------------------+

double takeprofit;
double stoploss;
double originalPrice;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int stopLossPoint=100;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void myOrderStrategy()
  {
   if(OrdersTotal()==0)//订单量为0,根据行情下单
     {
      //OrderSelect(OrdersTotal()-1,SELECT_BY_POS);//选择当前订单
      //OrderOpenTime();//没有订单时，返回0
      //if(TimeCurrent()-OrderOpenTime()<=orderPeriod)//default 10分钟
      //  return; //小于最小下单周期，返回
      if(marketInformation>=-1 && marketInformation<-0.3)//下跌行情
        {
         iOpenOrders("Sell",NewLots(),stopLossPoint,0);
        }
      else if(marketInformation>=-0.3 && marketInformation<=0.3)//波动
        {
         //iOpenOrders("Buy",getMyLots(1),0,0);
        }
      else if(marketInformation>0.3 && marketInformation<=1)//上涨行情
        {
         iOpenOrders("Buy",NewLots(),stopLossPoint,0);
        }
     }
   else //根据行情修改订单，或平仓
     {
      OrderSelect(OrdersTotal()-1,SELECT_BY_POS);
      takeprofit=OrderTakeProfit();
      stoploss=OrderStopLoss();
      originalPrice=(OrderStopLoss()+OrderTakeProfit())/2;

      if(OrderType()==OP_SELL)
        {
         if(OrderStopLoss()-Ask>stopLossPoint*Point)//盈利
            //OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss() -(originalPrice-Ask),OrderTakeProfit()-(originalPrice-Ask),0,Blue);
            OrderModify(OrderTicket(),OrderOpenPrice(),Ask+stopLossPoint*Point,OrderTakeProfit(),0,Blue);
        }
      if(OrderType()==OP_BUY)
        {
         if(Bid-OrderStopLoss()>stopLossPoint*Point)//盈利
            //OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()+(Bid-originalPrice),OrderTakeProfit()+(Bid-originalPrice),0,Red);
            OrderModify(OrderTicket(),OrderOpenPrice(),Bid-stopLossPoint*Point,OrderTakeProfit(),0,Red);
        }

      if(marketInformation>=-1 && marketInformation<-0.3)//下跌行情
        {
         if(OrderType()==OP_BUY)
           {
            OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0);
           }
         else if(OrderType()==OP_SELL)
           {
            //if(originalPrice-Ask>0)//盈利
            //OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss() -(originalPrice-Ask),OrderTakeProfit()-(originalPrice-Ask),0,Blue);
            //OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss() -(originalPrice-Ask),OrderTakeProfit(),0,Blue);
           }
        }
      else if(marketInformation>=-0.3 && marketInformation<=0.3)//波动
        {

         //iOpenOrders("Buy",getMyLots(1),0,0);
         //if(OrderProfit()>0)
         // OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0);
        }
      else if(marketInformation>0.3 && marketInformation<=1)//上涨行情
        {
         if(OrderType()==OP_BUY)
           {
            //if(Bid-originalPrice>0)//盈利
            //OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()+(Bid-originalPrice),OrderTakeProfit()+(Bid-originalPrice),0,Red);
            // OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()+(Bid-originalPrice),OrderTakeProfit(),0,Red);
           }
         else if(OrderType()==OP_SELL)
           {
            OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0);
           }
        }
     }
  }
//+------------------------------------------------------------------+
