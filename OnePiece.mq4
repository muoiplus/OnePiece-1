#property copyright ""
#property link		""
#property description "Displays Supply and Demand zones more-or-less in accordance with Sam Seidens teachings."
#property version     "2.33" //updated from 2.32, ZigZag bug fixes, by Big Be 09/2014

#property indicator_chart_window
#property indicator_buffers 6
input ENUM_TIMEFRAMES       TimeFrame                        = PERIOD_CURRENT;
input bool                  DrawZones                        = true;
input bool                  SolidZones                       = true;
input bool                  SolidRetouch                     = true;
input bool                  RecolorRetouch                   = true;
input bool                  RecolorWeakRetouch               = true;
input bool                  ZoneStrength                     = true;
input bool                  NoWeakZones                      = true;
input bool                  DrawEdgePrice                    = false;
input int                   ZoneWidth                        = 1;
input bool                  ZoneFibs                         = false;
input int                   FibStyle                         = 0;
input bool                  HUDOn                            = false;
input bool                  TimerOn                          = true;
input int                   LayerZone                        = 0;
input int                   LayerHUD                         = 20;
input ENUM_BASE_CORNER      CornerHUD                        = 2;
input int                   PosX                             = 100;
input int                   PosY                             = 20;
input bool                  AlertOn                          = false;
input bool                  AlertPopup                       = false;
input string                AlertSound                       = "alert.wav";
input color                 ColorSupStrong                   = clrSlateGray;
input color                 ColorSupWeak                     = clrGainsboro;
input color                 ColorSupRetouch                  = clrGainsboro;
input color                 ColorDemStrong                   = clrSlateGray;
input color                 ColorDemWeak                     = clrGainsboro;
input color                 ColorDemRetouch                  = clrGainsboro;
input color                 ColorFib                         = clrDodgerBlue;
input color                 ColorHUDTF                       = clrNavy;
input color                 ColorArrowUp                     = clrSeaGreen;
input color                 ColorArrowDn                     = clrCrimson;
input color                 ColorTimerBack                   = clrDarkGray;
input color                 ColorTimerBar                    = clrRed;
input color                 ColorShadow                      = clrDarkSlateGray;
input bool                  LimitZoneVis                     = false;
input bool                  SameTFVis                        = true;
input bool                  ShowOnM1                         = false;
input bool                  ShowOnM5                         = true;
input bool                  ShowOnM15                        = false;
input bool                  ShowOnM30                        = false;
input bool                  ShowOnH1                         = false;
input bool                  ShowOnH4                         = false;
input bool                  ShowOnD1                         = false;
input bool                  ShowOnW1                         = false;
input bool                  ShowOnMN                         = false;
input int                   PriceWidth                       = 1;
input int                   TimeOffset                       = 0;
input bool                  GlobalVars                       = false;

double BufferSupport1[];
double BufferSupport2[];
double BufferSupport3[];
double BufferResistance1[];
double BufferResistance2[];
double BufferResistance3[];

double SupRR[4];
double DemRR[4];
double SupWidth,DemWidth;

string lhud,lzone;
int HUDx,LayerHUD0,LayerZone0;
ENUM_BASE_CORNER CornerHUD0;
string FontHUD = "Comic Sans MS";
int FontHUDsize = 20;
string FontHUDprice = "Arial Bold";
int FontHUDPriceSize = 12;
int ArrowUP = 0x70;
int ArrowDN = 0x71;
string FontArrow = "WingDings 3";
int FontArrowSize = 40;
int FontPairSize = 8;


string ArrowGlance;
color ColorArrow;
int visible;
int rotation=270;
int lenbase;
string s_base="|||||||||||||||||||||||";
string TimerFont="Arial";
int SizeTimerFont=8;

double min,max;
double iPeriod[4] = {3,8,13,34}; 
int Dev[4] = {2,5,8,13};
int Step[4] = {2,3,5,8};
datetime h1,h2;
double p1,p2;
string pair;
double point;
int digits;
ENUM_TIMEFRAMES tf;
string TAG;

double FibSup,FibDem;
int SupCount,DemCount;
int SupAlert,DemAlert;
double UpCur,DnCur;
double FibLevelArray[13]={0,0.236,0.386,0.5,0.618,0.786,1,1.276,1.618,2.058,2.618,3.33,4.236};
string FibLevelDesc[13]={"0","23.6%","38.6%","50%","61.8%","78.6%","100%","127.6%","161.8%","205.8%","261.80%","333%","423.6%"};

int HUDTimerX,HUDTimerY,HUDArrowX,HUDArrowY,HUDTFX,HUDTFY;
int HUDsupX,HUDsupY,HUDdemX,HUDdemY;
int HUDtimersX,HUDtimersY,HUDarrowsX,HUDarrowsY,HUDtfsX,HUDtfsY;
int HUDsupsX,HUDsupsY,HUDdemsX,HUDdemsY;

void OnInit()
{int t1;

t1=0; SetIndexBuffer(t1,BufferResistance1); SetIndexEmptyValue(t1,0.0); SetIndexStyle(t1,DRAW_NONE);
t1+=1; SetIndexBuffer(t1,BufferResistance2); SetIndexEmptyValue(t1,0.0); SetIndexStyle(t1,DRAW_NONE);
t1+=1; SetIndexBuffer(t1,BufferResistance3); SetIndexEmptyValue(t1,0.0); SetIndexStyle(t1,DRAW_NONE);
t1+=1; SetIndexBuffer(t1,BufferSupport1); SetIndexEmptyValue(t1,0.0); SetIndexStyle(t1,DRAW_NONE);
t1+=1; SetIndexBuffer(t1,BufferSupport2); SetIndexEmptyValue(t1,0.0); SetIndexStyle(t1,DRAW_NONE);
t1+=1; SetIndexBuffer(t1,BufferSupport3); SetIndexEmptyValue(t1,0.0); SetIndexStyle(t1,DRAW_NONE);

LayerHUD0=MathMin(LayerHUD,25); 
lhud = CharToStr(0x61+LayerHUD0);
LayerZone0=MathMin(LayerZone,25);   
lzone = CharToStr(0x61+LayerZone0);
CornerHUD0=CornerHUD;
   pair=Symbol(); 
     
   if(TimeFrame != 0) tf = TimeFrame;
      else tf = PERIOD_CURRENT;
   point = Point;
   digits = MarketInfo(Symbol(), MODE_DIGITS);  //Digits;
   if(digits == 3 || digits == 5) point*=10;
   
   if(HUDOn && !DrawZones) TAG = "II_HUD"+tf;
   else TAG = "II_SupDem"+tf;
   lenbase=StringLen(s_base);
   
   if(HUDOn) setHUD();
   if(LimitZoneVis) setVisibility();
   ObDeleteObjectsByPrefix(lhud+TAG);
   ObDeleteObjectsByPrefix(lzone+TAG);
   DoLogo();}

void OnDeinit(const int reason)
{
   ObDeleteObjectsByPrefix(lhud+TAG);
   ObDeleteObjectsByPrefix(lzone+TAG);
   Comment("");}

int start()
{
   if (NewBar())
   {
      SupAlert = 1;
      DemAlert = 1;
      ObDeleteObjectsByPrefix(lzone+TAG);
      CountZZ(BufferSupport1,BufferResistance1,iPeriod[0],Dev[0],Step[0]);
      // Comment("iPeriod[0]",iPeriod[0]);
      GetValid(BufferSupport1,BufferResistance1);
      Draw();
      if(HUDOn) HUD();
   }
   if(HUDOn && TimerOn) {BarTimer();}
   if(AlertOn) {CheckAlert();}
   return(0);
}

void CheckAlert(){
//   SupCount DemCount
//   SupAlert DemAlert
   double price = ObjectGet(lzone+TAG+"UPAR"+SupAlert,OBJPROP_PRICE1);
   if(Close[0] > price && price > point){
      if(AlertPopup) Alert(pair+" "+TimeFrameToString(tf)+" Supply Zone Entered at "+DoubleToStr(price,Digits));
      PlaySound(AlertSound);
      SupAlert++;
   }
   price = ObjectGet(lzone+TAG+"DNAR"+DemAlert,OBJPROP_PRICE1);
   if(Close[0] < price){
      Alert(pair+" "+TimeFrameToString(tf)+" Demand Zone Entered at "+DoubleToStr(price,Digits));
      PlaySound(AlertSound);
      DemAlert++;
   }
}

void Draw()
{
   int FibSupHIT=0;
   int FibDemHIT=0;

   int sc=0,dc=0; 
   int i,j,countstrong,countweak;
   color c;
   string s;
   bool exit,draw,fle,fhe,retouch;
   bool valid;
   double val;
   fhe=false;
   fle=false;
   SupCount=0;
   DemCount=0;
   FibSup=0;
   FibDem=0;
   for(i=0;i<iBars(pair,tf);i++){
      if(BufferResistance1[i] > point){
         retouch = false;
         valid = false;
         h1 = iTime(pair,tf,i);
         h2 = Time[0];
         p2 = MathMin(iClose(pair,tf,i),iOpen(pair,tf,i));
         if(i>0) p2 = MathMax(p2,MathMax(iLow(pair,tf,i-1),iLow(pair,tf,i+1)));
         if(i>0) p2 = MathMax(p2,MathMin(iOpen(pair,tf,i-1),iClose(pair,tf,i-1)));
         p2 = MathMax(p2,MathMin(iOpen(pair,tf,i+1),iClose(pair,tf,i+1)));
         
         draw=true;
         if(RecolorRetouch || !SolidRetouch){
            exit = false;
            for(j=i;j>=0;j--){
               if(j==0 && !exit) {draw=false; break;}
               if(!exit && iHigh(pair,tf,j)<p2) {exit=true; continue;}
               if(exit && iHigh(pair,tf,j)>p2) {
                  retouch = true;
                  if(ZoneFibs && FibSupHIT==0){ FibSup = p2; FibSupHIT = j;}
                  break;
               }
            }
         }
         if(SupCount != 0) val = ObjectGet(TAG+"UPZONE"+SupCount,OBJPROP_PRICE2); //final sema cull
            else val=0;
         if(draw && BufferResistance1[i]!=val) {
            valid=true;
            c = ColorSupStrong;
            if(ZoneStrength && (retouch || !RecolorRetouch)){
               countstrong=0;
               countweak=0;
               for(j=i;j<1000000;j++){
                  if(iHigh(pair,tf,j+1)<p2) countstrong++;
                  if(iHigh(pair,tf,j+1)>BufferResistance1[i]) countweak++;
                  if(countstrong > 1) break;
                     else if(countweak > 1){
                        c=ColorSupWeak;
                        if(NoWeakZones) draw = false;
                        break;
                     }                 
               }
            }
//         if(c == ColorSupWeak && !NoWeakZones) draw = false;
BufferResistance2[i]=(BufferResistance1[i]>0)*p2; BufferResistance3[i]=(BufferResistance1[i]>0)*draw;

         if(DrawZones && draw){
            if(RecolorRetouch && retouch && countweak<2) c = ColorSupRetouch;
               else if(RecolorWeakRetouch && retouch && countweak>1) c = ColorSupRetouch;
            SupCount++;
            if(DrawEdgePrice){
               s = lzone+TAG+"UPAR"+SupCount;
               ObjectCreate(s,OBJ_ARROW,0,0,0);
               ObjectSet(s,OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
               ObjectSet(s, OBJPROP_TIME1, h2);
               ObjectSet(s, OBJPROP_PRICE1, p2);
               ObjectSet(s,OBJPROP_COLOR,c);
               ObjectSet(s,OBJPROP_WIDTH,PriceWidth);
               if(LimitZoneVis) ObjectSet(s,OBJPROP_TIMEFRAMES,visible);
            }
            s = lzone+TAG+"UPZONE"+SupCount;
            ObjectCreate(s,OBJ_RECTANGLE,0,0,0,0,0);
            ObjectSet(s,OBJPROP_TIME1,h1);
            ObjectSet(s,OBJPROP_PRICE1,BufferResistance1[i]);
            ObjectSet(s,OBJPROP_TIME2,h2);
            ObjectSet(s,OBJPROP_PRICE2,p2);
            ObjectSet(s,OBJPROP_COLOR,c);
            ObjectSet(s,OBJPROP_BACK,true);
            if(LimitZoneVis) ObjectSet(s,OBJPROP_TIMEFRAMES,visible);
            if(!SolidZones) {ObjectSet(s,OBJPROP_BACK,false);ObjectSet(s,OBJPROP_WIDTH,ZoneWidth);}
            if(!SolidRetouch && retouch) {ObjectSet(s,OBJPROP_BACK,false);ObjectSet(s,OBJPROP_WIDTH,ZoneWidth);}
            
            if(GlobalVars){
               GlobalVariableSet(TAG+"S.PH"+SupCount,BufferResistance1[i]);
               GlobalVariableSet(TAG+"S.PL"+SupCount,p2);
               GlobalVariableSet(TAG+"S.T"+SupCount,iTime(pair,tf,i));
            }
            if(!fhe && c!=ColorDemRetouch){fhe=true; GlobalVariableSet(TAG+"GOSHORT",p2);}
            }
         }
         if(draw && sc<4 && HUDOn && valid){
            if(sc==0) SupWidth = BufferResistance1[i] - p2;
            SupRR[sc] = p2;
            sc++;
         }

      }
      
      if(BufferSupport1[i] > point){
         retouch = false;
         valid=false;
         h1 = iTime(pair,tf,i);
         h2 = Time[0];
         p2 = MathMax(iClose(pair,tf,i),iOpen(pair,tf,i));
         if(i>0) p2 = MathMin(p2,MathMin(iHigh(pair,tf,i+1),iHigh(pair,tf,i-1)));
         if(i>0) p2 = MathMin(p2,MathMax(iOpen(pair,tf,i-1),iClose(pair,tf,i-1)));
         p2 = MathMin(p2,MathMax(iOpen(pair,tf,i+1),iClose(pair,tf,i+1)));
         
         c = ColorDemStrong;
         draw=true;
         if(RecolorRetouch || !SolidRetouch){
            exit = false;
            for(j=i;j>=0;j--) {
               if(j==0 && !exit) {draw=false;break;}
               if(!exit && iLow(pair,tf,j)>p2) {exit=true;continue;}
               if(exit && iLow(pair,tf,j)<p2) {
                  retouch = true;
                  if(ZoneFibs && FibDemHIT==0){FibDem = p2; FibDemHIT = j; }
                  break;
               }
            }
         }
         if(DemCount != 0) val = ObjectGet(TAG+"DNZONE"+DemCount,OBJPROP_PRICE2); //final sema cull
            else val=0;
         if(draw && BufferSupport1[i]!=val){
            valid = true;
            if(ZoneStrength && (retouch || !RecolorRetouch)){
               countstrong=0;
               countweak=0;
               for(j=i;j<1000000;j++){
                  if(iLow(pair,tf,j+1)>p2) countstrong++;
                  if(iLow(pair,tf,j+1)<BufferSupport1[i]) countweak++;
                  if(countstrong > 1) break;
                     else if(countweak > 1){
                        if(NoWeakZones) draw = false;
                        c=ColorDemWeak;
                        break;
                     }                 
               }
            }
BufferSupport2[i]=(BufferSupport1[i]>0)*p2; BufferSupport3[i]=(BufferSupport1[i]>0)*draw; 
       
            if(DrawZones && draw){
            if(RecolorRetouch && retouch && countweak<2) c = ColorDemRetouch;
               else if(RecolorWeakRetouch && retouch && countweak>1) c = ColorDemRetouch;

            DemCount++;
            if(DrawEdgePrice){
               s = lzone+TAG+"DNAR"+DemCount;
               ObjectCreate(s,OBJ_ARROW,0,0,0);
               ObjectSet(s,OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
               ObjectSet(s, OBJPROP_TIME1, h2);
               ObjectSet(s, OBJPROP_PRICE1, p2);
               ObjectSet(s,OBJPROP_COLOR,c);
               ObjectSet(s,OBJPROP_WIDTH,PriceWidth);  
               if(LimitZoneVis) ObjectSet(s,OBJPROP_TIMEFRAMES,visible);
            }
            s = lzone+TAG+"DNZONE"+DemCount;
            ObjectCreate(s,OBJ_RECTANGLE,0,0,0,0,0);
            ObjectSet(s,OBJPROP_TIME1,h1);
            ObjectSet(s,OBJPROP_PRICE1,p2);
            ObjectSet(s,OBJPROP_TIME2,h2);
            ObjectSet(s,OBJPROP_PRICE2,BufferSupport1[i]);
            ObjectSet(s,OBJPROP_COLOR,c);
            ObjectSet(s,OBJPROP_BACK,true);
            if(LimitZoneVis) ObjectSet(s,OBJPROP_TIMEFRAMES,visible);
            if(!SolidZones) {ObjectSet(s,OBJPROP_BACK,false);ObjectSet(s,OBJPROP_WIDTH,ZoneWidth);}
            if(!SolidRetouch && retouch) {ObjectSet(s,OBJPROP_BACK,false);ObjectSet(s,OBJPROP_WIDTH,ZoneWidth);}
            if(GlobalVars){
               GlobalVariableSet(TAG+"D.PL"+DemCount,BufferSupport1[i]);
               GlobalVariableSet(TAG+"D.PH"+DemCount,p2);
               GlobalVariableSet(TAG+"D.T"+DemCount,iTime(pair,tf,i));
            }
            if(!fle && c!=ColorDemRetouch){fle=true;GlobalVariableSet(TAG+"GOLONG",p2);}
            }
         }
         if(draw && dc<4 && HUDOn && valid){
            if(dc==0) DemWidth = p2-BufferSupport1[i];
            DemRR[dc] = p2;
            dc++;
         }
      }
   }
   if(ZoneFibs || HUDOn){
      double a,b;
      int dr=0;
      int sr=0;
      int d1=0;
      int s1=0;
      
      for(i=0;i<100000;i++){
         if(iHigh(pair,tf,i)>FibSup && sr==0) sr = i;
         if(iHigh(pair,tf,i)>SupRR[0] && s1==0) s1 = i;
         if(iLow(pair,tf,i)<FibDem && dr==0) dr = i;
         if(iLow(pair,tf,i)<DemRR[0] && d1==0) d1 = i;
         if(sr!=0&&s1!=0&&dr!=0&&d1!=0) break;
      }
   }
      
      if(ZoneFibs){
      
         if(dr<sr) {b = FibDem;a = SupRR[0];}
            else {b = FibSup;a = DemRR[0];}

      
         s = lzone+TAG+"FIBO";
         ObjectCreate(s, OBJ_FIBO, 0,Time[0],a,Time[0],b);
	      ObjectSet(s, OBJPROP_COLOR, CLR_NONE);
	      ObjectSet(s, OBJPROP_STYLE, FibStyle);
	      ObjectSet(s, OBJPROP_RAY, true);
	      ObjectSet(s, OBJPROP_BACK, true);
         if(LimitZoneVis) ObjectSet(s,OBJPROP_TIMEFRAMES,visible);
         int level_count=ArraySize(FibLevelArray);
   
         ObjectSet(s, OBJPROP_FIBOLEVELS, level_count);
         ObjectSet(s, OBJPROP_LEVELCOLOR, ColorFib);
   
         for(j=0; j<level_count; j++){
            ObjectSet(s, OBJPROP_FIRSTLEVEL+j, FibLevelArray[j]);
            ObjectSetFiboDescription(s,j,FibLevelDesc[j]);
         }
      }
      if(HUDOn) {
         if(d1<s1) {b = DemRR[0];a = SupRR[0]; ArrowGlance = CharToStr(ArrowUP); ColorArrow = ColorArrowUp;}
            else {b = SupRR[0];a = DemRR[0]; ArrowGlance = CharToStr(ArrowDN); ColorArrow = ColorArrowDn;}      
         min = MathMin(a,b);
         max = MathMax(a,b);
      }
   
   
}

bool NewBar() {
	static datetime LastTime = 0;
	if (iTime(pair,tf,0)+TimeOffset != LastTime) {
		LastTime = iTime(pair,tf,0)+TimeOffset;		
		return (true);
	} else
		return (false);
}

void ObDeleteObjectsByPrefix(string Prefix){
   int L = StringLen(Prefix);
   int i = 0; 
   while(i < ObjectsTotal()) {
      string ObjName = ObjectName(i);
      if(StringSubstr(ObjName, 0, L) != Prefix) {
         i++;
         continue;
      }
      ObjectDelete(ObjName);
   }
}

void CountZZ( double& ExtMapBuffer[], double& ExtMapBuffer2[], int ExtDepth, int ExtDeviation, int ExtBackstep ){ // based on code (C) metaquote{
   int    t1, back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;
   int count = iBars(pair,tf)-ExtDepth;

   for(t1=count; t1>=0; t1--){
      val = iLow(pair,tf,iLowest(pair,tf,MODE_LOW,ExtDepth,t1));
      if(val==lastlow) val=0.0;
      else { 
         lastlow=val; 
         if((iLow(pair,tf,t1)-val)>(ExtDeviation*point)) val=0.0;
         else{
            for(back=1; back<=ExtBackstep; back++){
               res=ExtMapBuffer[t1+back];
               if((res!=0)&&(res>val)) ExtMapBuffer[t1+back]=0.0; 
              }
           }
        } 
        
          ExtMapBuffer[t1]=val;
      //--- high
      val=iHigh(pair,tf,iHighest(pair,tf,MODE_HIGH,ExtDepth,t1));
      
      if(val==lasthigh) val=0.0;
      else {
         lasthigh=val;
         if((val-iHigh(pair,tf,t1))>(ExtDeviation*point)) val=0.0;
         else{
            for(back=1; back<=ExtBackstep; back++){
               res=ExtMapBuffer2[t1+back];
               if((res!=0)&&(res<val)) ExtMapBuffer2[t1+back]=0.0; 
              } 
           }
        }
      ExtMapBuffer2[t1]=val;
     }
   // final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;

   for(t1=count; t1>=0; t1--){
      curlow=ExtMapBuffer[t1];
      curhigh=ExtMapBuffer2[t1];
      if((curlow==0)&&(curhigh==0)) continue;
      //---
      if(curhigh!=0){
         if(lasthigh>0) {
            if(lasthigh<curhigh) ExtMapBuffer2[lasthighpos]=0;
            else ExtMapBuffer2[t1]=0;
           }
         //---
         if(lasthigh<curhigh || lasthigh<0){
            lasthigh=curhigh;
            lasthighpos=t1;
           }
         lastlow=-1;
        }
      //----
      if(curlow!=0){
         if(lastlow>0){
            if(lastlow>curlow) ExtMapBuffer[lastlowpos]=0;
            else ExtMapBuffer[t1]=0;
           }
         //---
         if((curlow<lastlow)||(lastlow<0)){
            lastlow=curlow;
            lastlowpos=t1;
           } 
         lasthigh=-1;
        }
     }
     
  /* // useless section deleted  //

  */

}
 
void GetValid(double& ExtMapBuffer[], double& ExtMapBuffer2[]){
   UpCur = 0;
   int upbar = 0;
   DnCur = 0;
   int dnbar = 0;
   double CurHi = 0;
   double CurLo = 0;
   double LastUp = 0;
   double LastDn = 0;
   double LowDn = 0;
   double HiUp = 0;
   int i;
   for(i=0;i<iBars(pair,tf);i++) if(ExtMapBuffer[i] > 0){
      UpCur = ExtMapBuffer[i];
      CurLo = ExtMapBuffer[i];
      LastUp = CurLo;
      break;
   }
   for(i=0;i<iBars(pair,tf);i++) if(ExtMapBuffer2[i] > 0){
      DnCur = ExtMapBuffer2[i];
      CurHi = ExtMapBuffer2[i];
      LastDn = CurHi;
      break;
   }

   for(i=0;i<iBars(pair,tf);i++) // remove higher lows and lower highs
   {
      if(ExtMapBuffer2[i] >= LastDn) {
         LastDn = ExtMapBuffer2[i];
         dnbar = i;
      }
         else ExtMapBuffer2[i] = 0.0;
      if(ExtMapBuffer2[i] <= DnCur && ExtMapBuffer[i] > 0.0) ExtMapBuffer2[i] = 0.0;
      if(ExtMapBuffer[i] <= LastUp && ExtMapBuffer[i] > 0) {
         LastUp = ExtMapBuffer[i];
         upbar = i;
      }
         else ExtMapBuffer[i] = 0.0;
      if(ExtMapBuffer[i] > UpCur) ExtMapBuffer[i] = 0.0;
   }
   LowDn = MathMin(iOpen(pair,tf,dnbar),iClose(pair,tf,dnbar));
   HiUp = MathMax(iOpen(pair,tf,upbar),iClose(pair,tf,upbar));         
   for(i=MathMax(upbar,dnbar);i>=0;i--) {// work back to zero and remove reentries into s/d
      if(ExtMapBuffer2[i] > LowDn && ExtMapBuffer2[i] != LastDn) ExtMapBuffer2[i] = 0.0;
         else if(ExtMapBuffer2[i] > 0) {
            LastDn = ExtMapBuffer2[i];
         LowDn = MathMin(iClose(pair,tf,i),iOpen(pair,tf,i));
         if(i>0) LowDn = MathMax(LowDn,MathMax(iLow(pair,tf,i-1),iLow(pair,tf,i+1)));
         if(i>0) LowDn = MathMax(LowDn,MathMin(iOpen(pair,tf,i-1),iClose(pair,tf,i-1)));
         LowDn = MathMax(LowDn,MathMin(iOpen(pair,tf,i+1),iClose(pair,tf,i+1)));
         }
      if(ExtMapBuffer[i] <= HiUp && ExtMapBuffer[i] > 0 && ExtMapBuffer[i] != LastUp) ExtMapBuffer[i] = 0.0;
         else if(ExtMapBuffer[i] > 0){
            LastUp = ExtMapBuffer[i];
            HiUp = MathMax(iClose(pair,tf,i),iOpen(pair,tf,i));
            if(i>0) HiUp = MathMin(HiUp,MathMin(iHigh(pair,tf,i+1),iHigh(pair,tf,i-1)));
            if(i>0) HiUp = MathMin(HiUp,MathMax(iOpen(pair,tf,i-1),iClose(pair,tf,i-1)));
            HiUp = MathMin(HiUp,MathMax(iOpen(pair,tf,i+1),iClose(pair,tf,i+1)));
         }
   }
}

void HUD()
{
   string s = TimeFrameToString(tf);
   string u = DoubleToStr(ObjectGet(lzone+TAG+"UPAR"+1,OBJPROP_PRICE1),Digits);
   string d = DoubleToStr(ObjectGet(lzone+TAG+"DNAR"+1,OBJPROP_PRICE1),Digits);
   string l = "b";
   DrawText(l,s,HUDTFX,HUDTFY,ColorHUDTF,FontHUD,FontHUDsize,CornerHUD0);
   DrawText(l,ArrowGlance,HUDArrowX,HUDArrowY,ColorArrow,FontArrow,FontArrowSize,CornerHUD0,0,true);
   DrawText(l,u,HUDsupX,HUDsupY,ColorSupStrong,FontHUDprice,FontHUDPriceSize,CornerHUD0);
   DrawText(l,d,HUDdemX,HUDdemY,ColorDemStrong,FontHUDprice,FontHUDPriceSize,CornerHUD0);

   l = "a";
   DrawText(l,s,HUDtfsX,HUDtfsY,ColorShadow,FontHUD,FontHUDsize,CornerHUD0);
   DrawText(l,ArrowGlance,HUDarrowsX,HUDarrowsY,ColorShadow,FontArrow,FontArrowSize,CornerHUD0,0,true);
   DrawText(l,u,HUDsupsX,HUDsupsY,ColorShadow,FontHUDprice,FontHUDPriceSize,CornerHUD0);
   DrawText(l,d,HUDdemsX,HUDdemsY,ColorShadow,FontHUDprice,FontHUDPriceSize,CornerHUD0);
   
}

void BarTimer() // Original Code by Vasyl Gumenyak
{
   int i=0,sec=0;
   double pc=0.0;
   string time="",s_end="",s;
   s = lhud+TAG+"btimerback";
   if (ObjectFind(s) == -1) {
      ObjectCreate(s , OBJ_LABEL,0,0,0);
      ObjectSet(s, OBJPROP_XDISTANCE, HUDTimerX);
      ObjectSet(s, OBJPROP_YDISTANCE, HUDTimerY);
      ObjectSet(s, OBJPROP_CORNER, CornerHUD0);
      ObjectSet(s, OBJPROP_ANGLE, rotation);
      ObjectSetText(s, s_base, SizeTimerFont, TimerFont, ColorTimerBack);
   }

   sec=TimeCurrent()-iTime(pair,tf,0);
   i=(lenbase-1)*sec/(tf*60);
   pc=100-(100.0*sec/(tf*60));
   if(i>lenbase-1) i=lenbase-1;
   if(i<lenbase-1) s_end=StringSubstr(s_base,i+1,lenbase-i-1);
   time=StringConcatenate("|",s_end);

   s = lhud+TAG+"timerfront";
   if (ObjectFind(s) == -1) {
     ObjectCreate(s , OBJ_LABEL,0,0,0);
     ObjectSet(s, OBJPROP_XDISTANCE, HUDTimerX);
     ObjectSet(s, OBJPROP_YDISTANCE, HUDTimerY);
     ObjectSet(s, OBJPROP_CORNER, CornerHUD0);
     ObjectSet(s, OBJPROP_ANGLE, rotation);
   }
   ObjectSetText(s, time, SizeTimerFont, TimerFont, ColorTimerBar);   
}

void DrawText(string l, string t, int x, int y, color c, string f, int s, int k=0, int a=0, bool b=false)
{
   string tag = lhud+TAG+l+x+y;
   ObjectDelete(tag);
   ObjectCreate(tag,OBJ_LABEL,0,0,0);
   ObjectSetText(tag,t,s,f,c);
   ObjectSet(tag,OBJPROP_XDISTANCE,x);
   ObjectSet(tag,OBJPROP_YDISTANCE,y);
   ObjectSet(tag,OBJPROP_CORNER,k);
   ObjectSet(tag,OBJPROP_ANGLE,a);
   if(b) ObjectSet(tag,OBJPROP_BACK,true);
}

string TimeFrameToString(int x1) //code by TRO
{
   string tfs;
   switch(x1) {
      case PERIOD_M1:  tfs="M1"  ; break;
      case PERIOD_M5:  tfs="M5"  ; break;
      case PERIOD_M15: tfs="M15" ; break;
      case PERIOD_M30: tfs="M30" ; break;
      case PERIOD_H1:  tfs="H1"  ; break;
      case PERIOD_H4:  tfs="H4"  ; break;
      case PERIOD_D1:  tfs="D1"  ; break;
      case PERIOD_W1:  tfs="W1"  ; break;
      case PERIOD_MN1: tfs="MN";
   }
   return(tfs);
}

void setHUD()
{
   switch(tf) {
      case PERIOD_M1:  HUDx=7 ; break;
      case PERIOD_M5:  HUDx=7 ; break;
      case PERIOD_M15: HUDx=3 ; break;
      case PERIOD_M30: HUDx=2 ; break;
      case PERIOD_H1:  HUDx=12 ; break;
      case PERIOD_H4:  HUDx=8 ; break;
      case PERIOD_D1 : HUDx=12 ; break;
      case PERIOD_W1:  HUDx=8 ; break;
      case PERIOD_MN1: HUDx=7 ; break;
   }
   if(CornerHUD0 > 3) {CornerHUD0=0;}
   if(CornerHUD0 == 0 || CornerHUD0 == 2) rotation = 90;
   switch(CornerHUD0){
      case 0 : HUDTFX = PosX-HUDx+10;
               HUDTFY = PosY+18;
               HUDArrowX = PosX-2;
               HUDArrowY = PosY+7;
               HUDsupX = PosX;
               HUDsupY = PosY;
               HUDdemX = PosX;
               HUDdemY = PosY+56;
               HUDTimerX = PosX+50;
               HUDTimerY = PosY+72;
               HUDtfsX = HUDTFX+1;
               HUDtfsY = HUDTFY+1;
               HUDarrowsX = HUDArrowX+1;
               HUDarrowsY = HUDArrowY+1;
               HUDsupsX = HUDsupX+1;
               HUDsupsY = HUDsupY+1;
               HUDdemsX = HUDdemX+1;
               HUDdemsY = HUDdemY+1;
               break;
      case 1 : HUDTFX = PosX+HUDx;
               HUDTFY = PosY+18;
               HUDArrowX = PosX+2;
               HUDArrowY = PosY+7;
               HUDsupX = PosX;
               HUDsupY = PosY;
               HUDdemX = PosX;
               HUDdemY = PosY+56;
               HUDTimerX = PosX-15;
               HUDTimerY = PosY+71;
               HUDtfsX = HUDTFX-1;
               HUDtfsY = HUDTFY+1;
               HUDarrowsX = HUDArrowX-1;
               HUDarrowsY = HUDArrowY+1;
               HUDsupsX = HUDsupX-1;
               HUDsupsY = HUDsupY+1;
               HUDdemsX = HUDdemX-1;
               HUDdemsY = HUDdemY+1;
               break;
      case 2 : HUDTFX = PosX-HUDx;
               HUDTFY = PosY+20;
               HUDArrowX = PosX-2;
               HUDArrowY = PosY+7;
               HUDsupX = PosX;
               HUDsupY = PosY+56;
               HUDdemX = PosX;
               HUDdemY = PosY;
               HUDTimerX = PosX+62;
               HUDTimerY = PosY+3;
               HUDtfsX = HUDTFX+1;
               HUDtfsY = HUDTFY-1;
               HUDarrowsX = HUDArrowX+1;
               HUDarrowsY = HUDArrowY-1;
               HUDsupsX = HUDsupX+1;
               HUDsupsY = HUDsupY-1;
               HUDdemsX = HUDdemX+1;
               HUDdemsY = HUDdemY-1;
               break;
      case 3 : HUDTFX = PosX+HUDx;
               HUDTFY = PosY+20;
               HUDArrowX = PosX+2;
               HUDArrowY = PosY+7;
               HUDsupX = PosX;
               HUDsupY = PosY+56;
               HUDdemX = PosX;
               HUDdemY = PosY;
               HUDTimerX = PosX-2;
               HUDTimerY = PosY+3;
               HUDtfsX = HUDTFX-1;
               HUDtfsY = HUDTFY-1;
               HUDarrowsX = HUDArrowX-1;
               HUDarrowsY = HUDArrowY-1;
               HUDsupsX = HUDsupX-1;
               HUDsupsY = HUDsupY-1;
               HUDdemsX = HUDdemX-1;
               HUDdemsY = HUDdemY-1;
               break;
   }
}

void DoLogo(){
   string s7 = CharToStr(0x61+27)+"II_Logo";
   if( ObjectFind(s7+"ZZ"+0) >= 0 && ObjectFind(s7+"ZZ"+1) >= 0 && ObjectFind(s7+"ZZ"+2) >= 0  && 
       ObjectFind(s7+"AZ"+0) >= 0 && ObjectFind(s7+"AZ"+1) >= 0 && ObjectFind(s7+"AZ"+2) >= 0 ) return;
   string str[3] = {".","."};
   int Size[3] = {0,0,0};
   int PositionX[3] = {0,0,0};
   int PositionY[3] = {0,0,0};
   int PosXs[3] = {0,0,0};
   int PosYs[3] = {0,0,0};
   for(int i=0;i<3;i++){
      string n = s7+"ZZ"+i;
      ObjectDelete(n);
      ObjectCreate(n,OBJ_LABEL,0,0,0);
      ObjectSetText(n,str[i],Size[i],"Pieces Of Eight",AliceBlue);
      ObjectSet(n,OBJPROP_XDISTANCE,PositionX[i]);
      ObjectSet(n,OBJPROP_YDISTANCE,PositionY[i]);
      ObjectSet(n,OBJPROP_CORNER,3);
      n = s7+"AZ"+i;
      ObjectDelete(n);
      ObjectCreate(n,OBJ_LABEL,0,0,0);
      ObjectSetText(n,str[i],Size[i],"Pieces Of Eight",Black);
      ObjectSet(n,OBJPROP_XDISTANCE,PosXs[i]);
      ObjectSet(n,OBJPROP_YDISTANCE,PosYs[i]);
      ObjectSet(n,OBJPROP_CORNER,3);
   }
}

void setVisibility()
{
   int per = Period();
   visible=0;
   if(SameTFVis){
  	   if(TimeFrame == per || TimeFrame == 0){
  	      switch(per){
            case PERIOD_M1:  visible= 0x0001 ; break;
            case PERIOD_M5:  visible= 0x0002 ; break;
            case PERIOD_M15: visible= 0x0004 ; break;
            case PERIOD_M30: visible= 0x0008 ; break;
            case PERIOD_H1:  visible= 0x0010 ; break;
            case PERIOD_H4:  visible= 0x0020 ; break;
            case PERIOD_D1:  visible= 0x0040 ; break;
            case PERIOD_W1:  visible= 0x0080 ; break;
            case PERIOD_MN1: visible= 0x0100 ;  	   
  	      }
  	   }
  	} else {
  	  if(ShowOnM1) visible += 0x0001;
	  if(ShowOnM5) visible += 0x0002;
	  if(ShowOnM15) visible += 0x0004;
	  if(ShowOnM30) visible += 0x0008;
	  if(ShowOnH1) visible += 0x0010;
	  if(ShowOnH4) visible += 0x0020;
	  if(ShowOnD1) visible += 0x0040;
	  if(ShowOnW1) visible += 0x0080;
	  if(ShowOnMN) visible += 0x0100;
   }

}