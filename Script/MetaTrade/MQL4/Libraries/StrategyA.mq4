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


class StrategyA
  {
private:
   int               lostTime;
   int               currentType;
   double            currentLots;
   int               maxLostOrderNum;
   order            *currentOrder;
   order            *previousOrder;
   //int               profitPoint;
   int               stateMachine;
   int               trend;

public:
   void StrategyA()
     {
      stateMachine=1;
      trend=0;// 顺势，刚变方向。 1 逆市，坚持同一个方向
     }
   void setTrend(int t)
     {
      trend=t;
     }
   void ~StrategyA()
     {
      delete currentOrder;
     }
   void Run(double marketInfo,int profitPoint)
     {
      if(stateMachine==1)
        {
         currentType=0;
         if(marketInfo == 0)return;
         if(marketInfo == 1)currentType=OP_BUY;
         if(marketInfo == -1)currentType=OP_SELL;
         lostTime=0;
         currentLots = 0.01;
         currentOrder= new order;
         previousOrder=NULL;
         currentOrder.open(currentType,currentLots,profitPoint,profitPoint);
         stateMachine=2;
        }
      if(stateMachine==2)
        {
         if(currentOrder.isClosed())
           {
            if(previousOrder!=NULL)
               delete previousOrder;
            previousOrder=currentOrder;
            if(previousOrder.getResult()<0.01 && previousOrder.getLots()*2<5.5)// lost Money
              {
               lostTime++;
               currentOrder=new order;
               if(trend==0)
                 {
                  if(previousOrder.getType()==OP_BUY)
                     currentOrder.open(OP_SELL,previousOrder.getLots()*2,profitPoint,profitPoint);

                  if(previousOrder.getType()==OP_SELL)
                     currentOrder.open(OP_BUY,previousOrder.getLots()*2,profitPoint,profitPoint);
                 }
               if(trend==1)
                 {
                  currentOrder.open(previousOrder.getType(),previousOrder.getLots()*2,profitPoint,profitPoint);
                 }

              }
            else// won Money
              {
               if(currentOrder!=previousOrder)
                  delete previousOrder;
               delete currentOrder;
               stateMachine=1;
              }
           }
        }
     }
  };
//+------------------------------------------------------------------+
