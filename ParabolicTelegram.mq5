#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Telegram.mqh>//включаем файл телеграм (общие переменные, функции)

//--- Input parameters
input string InpChannelName="@MQL5SignalsChannel";//Channel Name
input string InpToken="5055292970:AAFcTFDJPhsyX5lMdT09Wa9zaqaKYRG0h6U";//Token

//--- Global variables
CCustomBot bot;
datetime time_signal=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() //ноль означает успешную инициализацию (после запуска проги, инициализации глобальных перпеменных, смены инструмента, периода, счета)
  {
   time_signal=0;

//--- set token
   bot.Token(InpToken);

//--- done
   return(INIT_SUCCEEDED);
  }
//
//
void OnTick()
  {
//--- get time
   datetime time[1];
   if(CopyTime(NULL,0,0,1,time)!=1)
      return;
   MqlRates PriceArray [];
   ArraySetAsSeries(PriceArray, true);
   int Data= CopyRates(_Symbol, _Period, 0, 3, PriceArray);
   double MySRAArray []; //массив для параболика
   int SARDefinition = iSAR(_Symbol, _Period, 0.02, 0.2);
   ArraySetAsSeries(MySRAArray, true);
   CopyBuffer(SARDefinition,0,0,3,MySRAArray);//скопировать в буффер последние 3 точки
   double LastSARValue = NormalizeDouble(MySRAArray[1],5);
   double LastSARValue2 = NormalizeDouble(MySRAArray[2],5);
   
   //сигнал на покупку
   if((LastSARValue<PriceArray[1].low)&&(LastSARValue2>PriceArray[2].high))//сравниваются последние значения стохастика с ценой
     {string msg=StringFormat("Name: Grail Signal\nSymbol: %s\nTimeframe: %s\nType: Buy\nPrice: %s\nTime: %s",
                                 _Symbol,
                                 StringSubstr(EnumToString(_Period),7),
                                 DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits),
                                 TimeToString(time[0]));
         Print ("Отправлен сигнал", msg);                        
         int res=bot.SendMessage(InpChannelName,msg);
         if(res!=0)
            Print("Error: ",GetErrorDescription(res));}

   //сигнал на продажу
   if((LastSARValue>PriceArray[1].high)&&(LastSARValue2<PriceArray[2].low))
     {string msg=StringFormat("Name: Grail Signal\nSymbol: %s\nTimeframe: %s\nType: Sell\nPrice: %s\nTime: %s",
                                 _Symbol,
                                 StringSubstr(EnumToString(_Period),7),
                                 DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits),
                                 TimeToString(time[0]));
         Print ("Отправлен сигнал", msg); 
         int res=bot.SendMessage(InpChannelName,msg);
         if(res!=0)
            Print("Error: ",GetErrorDescription(res));}
     
   // сделать проверку на новую свечу, чтобы сигнал не отправлялся каждый тик?
  }

