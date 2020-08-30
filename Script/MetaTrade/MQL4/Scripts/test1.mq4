//+------------------------------------------------------------------+
//|                                                        test1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//--- Inputs
input double Lots          =0.1;
input double MaximumRisk   =0.02;
input double DecreaseFactor=3;
input int    MovingPeriod  =12;
input int    MovingShift   =6;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
//---正确的变量

   uchar u_ch;
   for(char ch=-128;ch<=127;ch++)
     {
      u_ch=ch;
      Print("tttttttttttttttttttttttttttttttttttttttttttttt ch = ",ch," u_ch = ",u_ch);
      if(ch==127) break;
     }
  }
//+------------------------------------------------------------------+
