
' >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> script to compare RMSE of univariate models

' >>> load quarterly vintage GDP data  

wfcreate(page=gdp) q 1970q1 2025q4
import D:\FBE\data\GDP_vintages.xlsx range=sec79!$B$2:$AJ$110 colhead=1 na="#N/A" @freq Q 1970Q1 @smpl @all
import D:\FBE\data\GDP_vintages.xlsx range=sec95!$C$2:$AK$145 colhead=1 na="#N/A" @freq Q 1970Q1 @smpl @all 
import D:\FBE\data\GDP_vintages.xlsx range=chainindex!$C$2:$AK$180 colhead=1 na="#N/A" @freq Q 1970Q1 @smpl @all
import D:\FBE\data\GDP_vintages.xlsx range=newbrowser!$B$2:$AS$224 colhead=1 na="#N/A" @freq Q 1970Q1 @smpl @all

' >>> use only latest available GDP data 

genr gdp = y149 ' because 149 is the latest available series 
delete y*       ' drops (useless vintage data)

' preliminary analysis of logs
show log(gdp) 
close LOG(GDP)

' plot (levels and differences), dfuller test, full sample ---> report commands below
' the full sample is 1970q1 2025q2


' >>> recursive estimate/nowcast 

' first training sample

smpl 1972Q1 2013Q2

' AR(3) model in differences
equation eq_ar.ls dlog(gdp) c dlog(gdp(-1)) dlog(gdp(-2)) dlog(gdp(-3))

' from one to 4 steps ahead forecast (iterated forecast)

smpl 2013Q2+1 2013Q2+4
eq_ar.forecast(f=na) temp
show gdp temp

' save the different horizons in different series

' save 1 step (quarter) forecast series 
smpl 2013Q2+1 2013Q2+1
genr gdp_ar1 = temp

' save 2 step (quarter) forecast series 
smpl 2013Q2+2 2013Q2+2
genr gdp_ar2 = temp

' save 3 step (quarter) forecast series 
smpl 2013Q2+3 2013Q2+3
genr gdp_ar3 = temp

' save 4 step (quarter) forecast series 
smpl 2013Q2+4 2013Q2+4
genr gdp_ar4 = temp

smpl @all

show gdp temp gdp_ar1 gdp_ar2 gdp_ar3 gdp_ar4 

delete temp

' AR models for direct forecasts

smpl 1972Q1 2013Q2

equation eq_di1.ls log(gdp/gdp(-1)) c dlog(gdp(-1)) dlog(gdp(-2)) dlog(gdp(-3))  
equation eq_di2.ls log(gdp/gdp(-2)) c dlog(gdp(-2)) dlog(gdp(-3)) dlog(gdp(-4))  
equation eq_di3.ls log(gdp/gdp(-3)) c dlog(gdp(-3)) dlog(gdp(-4)) dlog(gdp(-5))   
equation eq_di4.ls log(gdp/gdp(-4)) c dlog(gdp(-4)) dlog(gdp(-5)) dlog(gdp(-6))   

'	nowcast direct (!train forecast rounds) 

smpl 2013Q2+1 2013Q2+1
eq_di1.forecast(f=na) temp
genr gdp_di1 = temp
delete temp

smpl 2013Q2+2 2013Q2+2
eq_di2.forecast(f=na) temp
genr gdp_di2 = temp
delete temp

smpl 2013Q2+3 2013Q2+3
eq_di1.forecast(f=na) temp
genr gdp_di3 = temp
delete temp

smpl 2013Q2+4 2013Q2+4
eq_di4.forecast(f=na) temp
genr gdp_di4 = temp
delete temp

smpl @all
show gdp gdp_ar1 gdp_ar2 gdp_ar3 gdp_ar4 gdp_di1 gdp_di2 gdp_di3 gdp_di4


' now you are ready for the full program!

wfsave(2) d:\fbe\data\primogiro


