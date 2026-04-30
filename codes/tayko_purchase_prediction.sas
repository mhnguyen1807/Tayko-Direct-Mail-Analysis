/******************************************/
/******************************************/
/** Direct Mailing to Airline Customers **/
/******************************************/
/******************************************/


/* Importing TTaykoSoftware.csv */
/* DO NOT FORGET to change the file directory */
FILENAME REFFILE '/export/viya/homes/mhnguyen@oakland.edu/MIS-4560/TaykoSoftware.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.TaykoSoftware
     replace;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.TaykoSoftware; 
RUN;

/******************************************/
/********** 01. Data Preparation *********/
/******************************************/

/* Drop ID variable */
data WORK.TaykoSoftware_final;
    set WORK.TaykoSoftware;
    drop id;
run;

proc contents data=work.TaykoSoftware_final;
run;

/* Data partitioning */
proc surveyselect data=WORK.TaykoSoftware_final outall
    out=WORK.Tayko_partitioned seed=12345
    samprate=0.6
    method=srs; 
    /* Randomly partition the data set with a 60:40 split */
run;

data WORK.Tayko_train WORK.Tayko_valid;
    set WORK.Tayko_partitioned;
    if selected then output WORK.Tayko_train;   /* 60% training */
    else output WORK.Tayko_valid;               /* 40% validation */
run;


/****************************************/
/******* 02. LOGISTIC REGRESSION ********/
/****************************************/

/* 2.1 Fit the training data with a logistic regression */
proc logistic data=WORK.Tayko_train 
              outmodel=WORK.Tayko_model_noselect;
    model Purchase(event='1') = Freq Last_Update Web Gender Address_RES Address_US
                                / selection=none;
    output out=pred_train p=probabilities;   /* store predicted probs */
    ods output FitStatistics=fitstats_train; /* capture AIC, -2LL, etc. */
run;

/* 2.2  Print the fit statistics to display the AIC score */
proc print data=fitstats_train;
run;

/* 2.3 Confusion Matrix */
/** Scoring validation dataset using saved model **/
proc logistic inmodel=WORK.Tayko_model_noselect;
    score data=WORK.Tayko_valid
    out=WORK.Tayko_scored_valid;
run;

/** 2.4 Creating the confusion matrix using threshold of 0.5 **/
data WORK.Tayko_scored_valid;
    set WORK.Tayko_scored_valid;
    if P_1 >= 0.5 then predicted = 1;
    else predicted = 0;
run;

proc freq data=WORK.Tayko_scored_valid;
    tables Purchase * Predicted / nopercent norow nocol;
    title 'Confusion Matrix';
run;


/****************************************/
/************ 03. NEURAL NETWORK ********/
/****************************************/

/* 3.1 Creating a NN model with a single layer and 5 nodes */
proc hpneural data=Tayko_train;
    /* Categorical predictors */
    input Web Gender Address_RES Address_US / level=nominal;

    /* Numeric predictors */
    input Freq Last_Update / level=interval;

    /* Target variable */
    target Purchase / level=nominal;

    hidden 5;   /* Number of hidden neurons */

    train;      /* Train the neural network */

    score out=WORK.Tayko_nn_scored;  /* Score the training data */
    performance details;             /* Show training performance */
    code file="%sysfunc(getoption(work))/Tayko_nn_score.sas"; /* Save scoring code */
run;

/* 3.2 Score the NN model on the validation data */
data Tayko_valid_scored;
    set WORK.Tayko_valid;
    %include "%sysfunc(getoption(work))/Tayko_nn_score.sas";
run;

proc contents data=Tayko_valid_scored;
run;

/* Create predicted class from NN probabilities */
data Tayko_valid_scored;
    set Tayko_valid_scored;
    if P_Purchase1 >= 0.5 then Predicted = 1;
    else Predicted = 0;
run;

/* 3.3 Generate confusion matrix for NN model */
proc freq data=Tayko_valid_scored;
    tables Purchase * Predicted / norow nocol nopercent;
run;
