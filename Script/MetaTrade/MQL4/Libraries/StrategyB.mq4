//+------------------------------------------------------------------+
//|                                                    StrategyA.mq4 |
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
//|                                                                  |
//+------------------------------------------------------------------+


class StrategyB
  {
private:
   order            *currentOrder;
   datetime          currentorderTime;
   int               trailingStopPoint;
   int               stateMachine;
   int               orderPeriod;
public:
   void StrategyB()
     {
      stateMachine=1;
      orderPeriod=Period()*30;//  一个柱子，两个周期
      currentorderTime=0;
     }
   void ~StrategyB()
     {
      delete currentOrder;
     }

   void Run(double marketInfo,int trailingStopPoint,double lots)
     {
      if(stateMachine==1)//  no order
        {
         if(TimeCurrent()-currentorderTime<=orderPeriod)//以秒 计算时间周期
            return;
         int currentType;
         if(marketInfo == 0)return;
         if(marketInfo == 1) currentType=OP_BUY;
         if(marketInfo == -1)currentType=OP_SELL;
         currentOrder=new order;
         currentorderTime=TimeCurrent();
         currentOrder.open(currentType,lots,trailingStopPoint,0);
         stateMachine=2;
         return;
        }
      if(stateMachine==2)
        {
         if(currentOrder.isClosed())
           {
            stateMachine=1;
            return;
           }
         currentOrder.TrailingStop(trailingStopPoint);
         if((currentOrder.getType()==OP_BUY && marketInfo==-1) || (currentOrder.getType()==OP_SELL && marketInfo==1))
           {
            currentOrder.close();
            stateMachine=1;
            return;
           }
        }
     }
  };
//+------------------------------------------------------------------+
