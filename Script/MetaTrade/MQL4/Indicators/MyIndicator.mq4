//+------------------------------------------------------------------+
//|                                                  MyIndicator.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1

//--- plot Label1
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1


//--- input parameters
input color    RED=clrOrangeRed;
//--- indicator buffers
double         Label1Buffer[];
double         ExtMapBuffer1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//SetIndexBuffer(0,Label1Buffer);


   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_LINE);
   string short_name="我的第一个指标正在运行!";
   IndicatorShortName(short_name);

   Print(AccountBalance());
   Print(MODE_OPEN);
   Print(MODE_HIGH);
   Print(MODE_CLOSE);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---

//--- return value of prev_calculated for next call
   int counted_bars=IndicatorCounted();
//----check for possible errors
   if(counted_bars<0)return(-1);
//----last counted bar will be recounted
   if(counted_bars>0)counted_bars--;
   int pos=Bars-counted_bars-1;
//pos = 4040;
   double dHigh,dLow,dResult;
   Comment("Hi!I'm here on the main chart windows!");
//----main calculation loop

   double sell= Ask;
   double buy = Bid;

   while(pos>=0)
     {
      dHigh=High[pos];
      dLow=Low[pos];
      dResult=dHigh-dLow;
      ExtMapBuffer1[pos]=dResult;
      pos--;
     }
//return(rates_total);
   return(0);
  }
//+------------------------------------------------------------------+
