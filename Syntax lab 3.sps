* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.
RECODE Sex ('male'=1) (ELSE=0) INTO male.
EXECUTE.

RECODE Pclass (1=1) (ELSE=0) INTO first_class_ticket.
EXECUTE.

RECODE Pclass (2=1) (ELSE=0) INTO Second_class_ticket.
EXECUTE.

RECODE Embarked ('C'=1) (ELSE=0) INTO Embark_Cherbourg.
EXECUTE.

RECODE Embarked ('Q'=1) (ELSE=0) INTO Embark_Queenstown.
EXECUTE.

RECODE Cabin (MISSING=0) (ELSE=1) INTO Got_cabin.
EXECUTE.

CROSSTABS
  /TABLES=Embark_Cherbourg Embark_Queenstown BY Embarked
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

CROSSTABS
  /TABLES=Sex BY male
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

CROSSTABS
  /TABLES=Pclass BY Second_class_ticket first_class_ticket
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

FREQUENCIES VARIABLES=Survived Pclass Sex Age SibSp Parch Fare Embarked
  /STATISTICS=STDDEV VARIANCE RANGE MINIMUM MAXIMUM MEAN SKEWNESS SESKEW KURTOSIS SEKURT
  /ORDER=ANALYSIS.

CROSSTABS
  /TABLES=Cabin BY Got_cabin
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

FREQUENCIES VARIABLES=Got_cabin
  /STATISTICS=STDDEV VARIANCE RANGE MINIMUM MAXIMUM MEAN SKEWNESS SESKEW KURTOSIS SEKURT
  /ORDER=ANALYSIS.

FREQUENCIES VARIABLES=Survived Pclass Sex Age SibSp Parch Fare Cabin Embarked
  /STATISTICS=STDDEV VARIANCE RANGE MINIMUM MAXIMUM MEAN SKEWNESS SESKEW KURTOSIS SEKURT
  /HISTOGRAM NORMAL
  /ORDER=ANALYSIS.

CORRELATIONS
  /VARIABLES=Survived Pclass Age SibSp Parch Fare male Embark_Cherbourg Embark_Queenstown Got_cabin
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.
* Pearson's r requires continous variabels, some of the above is not analyzed via the command as they are on a nominal scale.

* added missing values to the data points that had missing values. 

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Survived Age MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  DATA: Age=col(source(s), name("Age"))
  DATA: id=col(source(s), name("$CASENUM"), unit.category())
  GUIDE: axis(dim(1), label("Survived"))
  GUIDE: axis(dim(2), label("Age"))
  GUIDE: text.title(label("Simple Boxplot of Age by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: schema(position(bin.quantile.letter(Survived*Age)), label(id))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Survived Fare MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  DATA: Fare=col(source(s), name("Fare"))
  DATA: id=col(source(s), name("$CASENUM"), unit.category())
  GUIDE: axis(dim(1), label("Survived"))
  GUIDE: axis(dim(2), label("Passenger fare (in Pounds)"))
  GUIDE: text.title(label("Simple Boxplot of Passenger fare (in Pounds) by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: schema(position(bin.quantile.letter(Survived*Fare)), label(id))
END GPL.

* not ideal to see class as a continous variable but I will do that here for the sake of testing correlations

CORRELATIONS
  /VARIABLES=Pclass Fare
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

* now I will run som regressions to identify a good model according to the instructions. 

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH first_class_ticket Second_class_ticket Age SibSp 
    Parch Fare male Embark_Cherbourg Embark_Queenstown Got_cabin
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC. 

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH Parch
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH Parch SibSp
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH Parch SibSp Age male first_class_ticket 
    Second_class_ticket Embark_Cherbourg Embark_Queenstown Got_cabin
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH Fare
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.

* three passengers paid over 500£ and survivied... what happens if I exclude these?
*Answer.. not much at all, I will not exlude these!

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH first_class_ticket Second_class_ticket Age SibSp 
    Parch Fare male Embark_Cherbourg Embark_Queenstown Got_cabin
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH SibSp
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.


* three regressions below is my best bet...

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH SibSp Parch Age male first_class_ticket 
    Second_class_ticket
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH SibSp Parch Age male Got_cabin
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.

* The following model is my choice for this task:

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH SibSp Parch Age male first_class_ticket 
    Second_class_ticket Got_cabin
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.





