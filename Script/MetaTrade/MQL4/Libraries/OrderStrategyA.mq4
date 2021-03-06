//+------------------------------------------------------------------+
//|                                               OrderStrategyA.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include "../Libraries/BasicFunc.mq4"
//+------------------------------------------------------------------+
double Init_Balance=AccountBalance();//账户初始余额变量 
double Profit_Rate=35; //目标盈利率 30%
double Init_Lots=0.01;//初始 0.01手
double Max_Bet_Lots=1.28;//允许最大开仓量（允许连赔7次），账户最大开仓量maxLots()
double xMax_Bet_Lots;//最大浮动开仓量变量 
double iLots;//浮动开仓量
double perProfit=0;
double lostTurn = 0;
int Order_Total=50; //最多下单个数
//+------------------------------------------------------------------+

/* 计算账户余额，返回最新开仓量(手数) */
//第一次开仓价（最低开仓）0.01，如果超过目标利润率 Profit_Rate（35%），最低开仓价按比例上涨。 
double NewLots(int lostTurn)//lostTurn 损失回合数
  {
//计算开仓翻倍倍数, xRate = 当前盈利率/目标盈利率，  xRate已完成目标的比例。1已完成100%目标盈利率，0.5已完成50%目标盈利率
   double xRate=((AccountBalance()-Init_Balance)/Init_Balance)/(Profit_Rate/100);//取倍率的整数部分 //计算开仓手数 
   double xLots=NormalizeDouble(Init_Lots*xRate,2);//未完成目标盈利率，xLots=最小标准手，如果完成目标，xLots加大最小标准手。
   if(xLots<0.01)
      xLots=0.01;
   if(lostTurn>=0)
      xLots=xLots*MathPow(2,lostTurn);
   if(xRate>1)//完成目标盈利率，完成目标盈利率，加大最大开仓变量。
      xMax_Bet_Lots=Max_Bet_Lots*xRate;//如果翻倍倍数大于1，才计算最大浮动开仓量变量 
   return(xLots);
  }
//+------------------------------------------------------------------+

//补仓下单量：根据亏损单子的个数更改下单量。亏损单子少，增加下单量，亏损单子个数超过最大允许值，不再补仓。
//补仓下单量 = 开仓下单量*(1-(亏损订单数/补仓系数));
//lostMax >=1 损失订单个数系数,如果损失订单数目超过这个系数，将不再进行补单。
//lostOrders，损失订单的个数
double getAddLots(int lostMax,double myLots,int lostOrders)
  {
   if(lostMax<1)
     {
      if(lostOrders>0)  return 0.0;
      else return myLots*2;
     }
   double result=myLots*(1-(lostOrders/lostMax));
   if(result<=0)return 0.0;
   else return NormalizeDouble(result,2);
  }
//+------------------------------------------------------------------+
bool inital=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void inital()
  {
   if(inital==false)
     {
      xMax_Bet_Lots=Max_Bet_Lots;
      iLots=Init_Lots;

      inital=true;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void dayOrderStrategy(string mktSignal)
  {
   inital();
   SetLabel("时间栏","星期"+DayOfWeek()+" 市场时间："+Year()+"-"+Month()+"-"+Day()+" "+Hour()+":"+Minute()+":"+Seconds(),300,0,9,"Verdana",Red);
   SetLabel("信息栏","市场信号："+mktSignal+" 最大开仓量："+DoubleToStr(xMax_Bet_Lots,2),5,60,10,"Verdana",Yellow);
   SetLabel("信息栏1","初始余额："+DoubleToStr(Init_Balance,2)+" 当前余额："+DoubleToStr(AccountBalance(),2),5,20,10,"Verdana",Yellow);
   SetLabel("信息栏2","最低开仓量："+DoubleToStr(NewLots(0),2)+" 浮动开仓量："+DoubleToStr(iLots,2),5,40,10,"Verdana",Yellow); //新开仓 
   if(OrdersTotal()==0)//订单量为0，前一批订单如果盈利ilots 不变，如果亏损 ilots 翻倍
     {
      iLots=NewLots(lostTurn);
      if(iLots>xMax_Bet_Lots)
         iLots=xMax_Bet_Lots;//限制最大开仓量 

      if(mktSignal=="Buy")
         iOpenOrders("Buy",iLots,300,300);
      if(mktSignal=="Sell")
         iOpenOrders("Sell",iLots,300,300);
      perProfit=0;//前一批订单盈利变量清0 
     }

//处理已有订单 
   if(OrdersTotal()>0)
     {
      //OrderSelect(OrdersTotal()-1,SELECT_BY_POS); 最近的order
      //OrderSelect(0,SELECT_BY_POS); 最久远的order
      OrderSelect(OrdersTotal()-1,SELECT_BY_POS);//选择当前订单 //新开仓订单时间不足一个时间周期，不做任何操作返回 

                                                 //test
      int period=Period();//30秒
      double timeNow=TimeCurrent();
      double openTime=OrderOpenTime();
      double orderPeriod=(timeNow-openTime);  //订单到 但当前时间的秒数

      if(TimeCurrent()-OrderOpenTime()<=Period()*60)//30分钟
         return; //30*60=1800秒=30分钟 , 小于最小下单周期，返回

      // if(OrderType()==OP_BUY && mktSignal=="Buy" && OrdersTotal()<=Order_Total && Bid>OrderOpenPrice())//追加买入订单 
      //  {
      //  OrderSend(Symbol(),OP_BUY,iLots,Ask,0,300,300);
      //}
      if(OrderType()==OP_BUY && OrdersTotal()<=Order_Total && Bid>OrderOpenPrice())//追加买入订单 
        {
         OrderSend(Symbol(),OP_BUY,iLots,Ask,0,300,300);
        }
      //止损平仓。如果出现反向信号，平掉所有订单 
      if(OrderType()==OP_BUY && mktSignal=="Sell")
        {
         for(int G_Count=OrdersTotal();G_Count>=0;G_Count--)
           {
            if(OrderSelect(G_Count,SELECT_BY_POS)==false) continue;
            else OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0);//平仓 
            perProfit=perProfit+OrderProfit();//利润累加 
           }
         if(perProfit>=0)
            lostTurn=0;
         else lostTurn++;
        }

      //if(OrderType()==OP_SELL && mktSignal=="Sell" && OrdersTotal()<=Order_Total && Ask<OrderOpenPrice())//追加卖出订单 
      //  {
      //   OrderSend(Symbol(),OP_SELL,iLots,Bid,0,300,300);
      //   }
      if(OrderType()==OP_SELL && OrdersTotal()<=Order_Total && Ask<OrderOpenPrice())//追加卖出订单 
        {
         OrderSend(Symbol(),OP_SELL,iLots,Bid,0,300,300);
        }

      if(OrderType()==OP_SELL && mktSignal=="Buy")
        {
         for(int G_Count=OrdersTotal();G_Count>=0;G_Count--)
           {
            if(OrderSelect(G_Count,SELECT_BY_POS)==false)continue;
            else OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0);//平仓 
            perProfit=perProfit+OrderProfit();//利润累加 
           }
         if(perProfit>=0)
            lostTurn=0;
         else lostTurn++;
        }
     }
  }
//+------------------------------------------------------------------+
