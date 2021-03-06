//+------------------------------------------------------------------+
//|                                                      AUD-CHF.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include "../../Libraries/BasicFunc.mq4"

//--- input parameters
input int   Gap = 100; //100个点距离, 每两个订单之间的距离
input double lotSize = 0.01;
input int buyLimit = 1;
static Order ordersBuy[300];
static Order buyLimitOrder[10];
static Order lowestOrder;

static int activeBuyOrderNumber;
static int pendingBuyOrderNumber;
static double pendingBuyOrderOpenPrice;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Print("current symbol : "+Symbol());
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      int total = OrdersTotal();
   //   Print("订单的总数：" + total);
   
//      part one
//      1. 获得所有订单
//      2. 如果没有设置获利，设置订单获利
      activeBuyOrderNumber = 0;
      pendingBuyOrderNumber = 0;
      pendingBuyOrderOpenPrice = 0;
      lowestOrder.openPrice = 1000000;
      for(int i = 0; i < total; i++)
      {
         if(OrderSelect(i,SELECT_BY_POS) == true && OrderSymbol() == Symbol())
         {
            if (OrderType() == OP_BUY)
            {
               ordersBuy[activeBuyOrderNumber].openPrice = OrderOpenPrice();
               ordersBuy[activeBuyOrderNumber].takeProfit = OrderTakeProfit();
               ordersBuy[activeBuyOrderNumber].ticket = OrderTicket();
               ordersBuy[activeBuyOrderNumber].type = OrderType();
               if(ordersBuy[activeBuyOrderNumber].takeProfit == 0)
               {
                  //Print("Digits:",Digits); // Digits 等于 5
                  ordersBuy[activeBuyOrderNumber].takeProfit = NormalizeDouble(ordersBuy[activeBuyOrderNumber].openPrice + Gap*1.5*Point,Digits);
                  Print("print take profit : ",ordersBuy[activeBuyOrderNumber].takeProfit);
                  if(Bid > ordersBuy[activeBuyOrderNumber].takeProfit)
                  {
                     if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,CLR_NONE)) 
                     return;
                  }
                  if(OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NormalizeDouble(ordersBuy[activeBuyOrderNumber].takeProfit,Digits),0))
                     Print("Modify order : adding takeprofit Successful.");
                  else
                  {
                     ordersBuy[activeBuyOrderNumber].takeProfit  = 0;
                     Print("modify order : adding takeprofit Failed.");
                  }
               }
               if(lowestOrder.openPrice> ordersBuy[activeBuyOrderNumber].openPrice)
               {
                     lowestOrder.ticket = ordersBuy[activeBuyOrderNumber].ticket;
                     lowestOrder.openPrice = ordersBuy[activeBuyOrderNumber].openPrice;
               }
               activeBuyOrderNumber++;
            }else if(OrderType() == OP_BUYLIMIT){
               pendingBuyOrderNumber++;
            }
         }
      }
      
      //特殊情况，1，没有一个active订单，也没有一个pending订单。新建一个lot = 0.01，takeprofit=gap*1.5 的订单
      //      2.没有一个active订单，但是有pending订单。新建一个Lots*2，takeprofit = gap*2的订单
      if(activeBuyOrderNumber == 0 && pendingBuyOrderNumber == 0)
      {
         if(OrderSend(Symbol(),OP_BUY,lotSize,Ask,3,0,NormalizeDouble(Ask + Gap*1.5*Point,Digits),NULL,0,0,CLR_NONE) == false)
            Print("first order send failed !");
            else Print("first order send sccessful !");
         Sleep(2000);
         return;
      }
      if(activeBuyOrderNumber == 0 && pendingBuyOrderNumber != 0) 
      {
         if(OrderSend(Symbol(),OP_BUY,lotSize*1,Ask,3,0,NormalizeDouble(Ask + Gap*2*Point,Digits),NULL,0,0,CLR_NONE) == false)
         {
            Print("pending Order Exist + new order send failed !");
         }
         Sleep(2000);
         return;
      }
      
//      part two
//      1. 获得最小订单,part one 已经获得
//      2. 获得所有预设订单，buylimit
//      3. 修改所有预设订单和获利位置    
      int s = 0;
      buyLimitOrder[0].ticket = 0;
      buyLimitOrder[1].ticket = 0;
      buyLimitOrder[2].ticket = 0;
      buyLimitOrder[3].ticket = 0;
      buyLimitOrder[4].ticket = 0;
      buyLimitOrder[0].openPrice = 0;
      buyLimitOrder[1].openPrice = 0;
      buyLimitOrder[2].openPrice = 0;
      buyLimitOrder[3].openPrice = 0;
      buyLimitOrder[4].openPrice = 0;
       //删除多余的pending order
      for(int i = 0; i < total; i++)
      {
         if(OrderSelect(i,SELECT_BY_POS) == true && OrderType() == OP_BUYLIMIT && OrderSymbol() == Symbol())
         {
            if( s >= buyLimit )
            {
               OrderDelete(OrderTicket());
               continue;
            }
            buyLimitOrder[s].ticket = OrderTicket();
            buyLimitOrder[s].openPrice = OrderOpenPrice();
            buyLimitOrder[s].takeProfit = OrderTakeProfit();
            s++;
         }
      }
      // buy limit order 排序，最小的 OpenPrice 在4上面
      for(int i = 4; i >= 1; i--)
      {
         for(int j = i-1; j >= 0; j--)
         {
            if(buyLimitOrder[i].openPrice > buyLimitOrder[j].openPrice)
            {
               int tmp = buyLimitOrder[i].ticket;
               buyLimitOrder[i].ticket = buyLimitOrder[j].ticket;
               buyLimitOrder[j].ticket = tmp;
               double tmp1 = buyLimitOrder[i].openPrice;
               buyLimitOrder[i].openPrice = buyLimitOrder[j].openPrice;
               buyLimitOrder[j].openPrice = tmp1;
               double tmp2 = buyLimitOrder[i].takeProfit;
               buyLimitOrder[i].takeProfit = buyLimitOrder[j].takeProfit;
               buyLimitOrder[j].takeProfit = tmp2;
            }
         }
      }
      // pending order number
      double pendingBuyOrderOpenPrice = 0;
      double pendingOrderOpenPriceProfit = 0;
      int realposition = 0;
      for(int i = 0; i < buyLimit; i++)
      {
         pendingBuyOrderOpenPrice = lowestOrder.openPrice-(i+1)*Gap*Point;
         pendingOrderOpenPriceProfit = NormalizeDouble(pendingBuyOrderOpenPrice+1.5*Gap*Point,Digits);
         //1. Pending order 是否存在 ，a,存在，移动或删除或不动。 b 不存在，创建或者不创建
         if(buyLimitOrder[realposition].ticket == 0)
         {
            // pending order 不存在，就先建一个pending order
               if(pendingBuyOrderOpenPrice < Ask)
               {
                  buyLimitOrder[realposition].ticket = OrderSend(Symbol(),OP_BUYLIMIT,lotSize,pendingBuyOrderOpenPrice,3,0,pendingOrderOpenPriceProfit,NULL,0,0,CLR_NONE);
                  realposition ++;
               }
         }
         else
         {
            if(pendingBuyOrderOpenPrice < Ask)
            {
               // pending order 在它应该在的地方，就不动，否则移动或者删除
               if(MathAbs(buyLimitOrder[realposition].openPrice-pendingBuyOrderOpenPrice) > Point*3)
               {//移动，移动不成功，就删除。
                  if(OrderModify(buyLimitOrder[realposition].ticket,pendingBuyOrderOpenPrice,0,pendingOrderOpenPriceProfit,0,CLR_NONE) == false)
                     OrderDelete(buyLimitOrder[realposition].ticket);
                 }
               realposition++;
            }
         }
      }
      //没有一个 pending 订单，并且Ask 已经大幅下跌。
      if(buyLimitOrder[1].ticket == 0 && buyLimitOrder[2].ticket == 0 && lowestOrder.openPrice - Gap*Point*2 > Ask)
      {
         OrderSend(Symbol(),OP_BUY,lotSize,Ask,3,0,0,NULL,0,0,CLR_NONE);
      }
  }
//+------------------------------------------------------------------+
