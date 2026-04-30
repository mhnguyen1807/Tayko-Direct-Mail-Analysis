# Customer Purchase Prediction – Tayko Direct Mail Campaign

> Predicting catalog purchase behavior using Logistic Regression and Neural Network models in SAS | Academic Project – MIS 4560 (Introduction to Data Science), Oakland University

---

## Business Problem

Tayko Software, a software catalog company, wants to maximize the return on its direct mail campaigns by identifying which customers are most likely to make a purchase when they receive a new catalog. Sending catalogs to unlikely buyers wastes marketing budget; missing likely buyers means lost revenue.

**Goal:** Build and compare predictive models that classify customers as *likely purchaser* or *unlikely purchaser*, then recommend the better model based on **precision** — the metric that directly reflects mailing efficiency.

---

## Dataset

**Source:** TaykoSoftware.csv  
**Records:** ~2,000 customer records (60% train / 40% validation split)  
**Target Variable:** `Purchase` (1 = purchased, 0 = did not purchase)

| Feature | Type | Description |
|---|---|---|
| Freq | Interval | Purchase frequency |
| Last_Update | Interval | Days since last account update |
| Web | Nominal | Web order indicator |
| Gender | Nominal | Customer gender |
| Address_RES | Nominal | Residential address flag |
| Address_US | Nominal | US address flag |

---

## Methods

### 1. Data Preparation
- Imported raw CSV into SAS Work library
- Dropped non-predictive `ID` variable
- Partitioned data: **60% training / 40% validation** using `PROC SURVEYSELECT` (seed = 12345, SRS method)

### 2. Logistic Regression (`PROC LOGISTIC`)
- Fit on training set with no variable selection (all 6 predictors retained)
- Scored on validation set using saved model object
- Classification threshold: **0.5**

### 3. Neural Network (`PROC HPNEURAL`)
- Single hidden layer with **5 nodes**
- Categorical inputs: `Web`, `Gender`, `Address_RES`, `Address_US`
- Continuous inputs: `Freq`, `Last_Update`
- Scoring code saved and applied to validation set

---

## Results

| Metric | Logistic Regression | Neural Network |
|---|---|---|
| **Accuracy** | 75.62% | 75.37% |
| **Sensitivity (Recall)** | 78.69% | 75.18% |
| **Specificity** | 72.56% | 75.56% |
| **Precision** | 74.05% | **75.37%** |

### Business Conclusion

Both models achieve comparable overall accuracy (~75%). However, **precision is the decision metric** for Tayko's use case — the company only mails to customers predicted as purchasers, so minimizing false positives directly reduces wasted catalog spend.

The **Neural Network model edges out Logistic Regression on precision (75.37% vs. 74.05%)**, meaning for every 100 catalogs mailed to predicted buyers, the neural network saves approximately 1 unnecessary mailing compared to logistic regression. At scale, this difference compounds meaningfully across large customer lists.

**Recommendation:** Deploy the Neural Network model for catalog targeting.

---

## Skills Demonstrated

| Category | Skills |
|---|---|
| **Analytical** | Binary classification, model comparison, business-driven metric selection |
| **Statistical Modeling** | Logistic Regression, Neural Networks, confusion matrix interpretation |
| **Data Preparation** | Data partitioning, feature selection, variable transformation |
| **Tools** | SAS (PROC LOGISTIC, PROC HPNEURAL, PROC SURVEYSELECT, PROC FREQ) |
| **Business Thinking** | Translating model metrics into actionable marketing recommendations |

---

## Repository Structure

```
tayko-direct-mail-prediction/
│
├── README.md                   ← You are here
│
├── code/
│   └── tayko_purchase_prediction.sas   ← Full SAS pipeline (prep → modeling → evaluation)
│
├── docs/
│   └── HW4_DirectMailing_Report.docx   ← Written analysis and findings
│
├── outputs/
│   └── confusion_matrices.png          ← (Add screenshot of your SAS output)
│
└── data/
    └── README_data.md                  ← Note: raw data not included (proprietary)
```

---

## How to Run

1. Place `TaykoSoftware.csv` in your working directory
2. Open `code/tayko_purchase_prediction.sas` in SAS Studio or SAS Viya
3. Update the `FILENAME REFFILE` path on **line 8** to match your local file path
4. Run all — sections are clearly labeled `01. Data Preparation`, `02. Logistic Regression`, `03. Neural Network`

---

## Academic Context

This project was completed as **Homework 4** for **MIS 4560 – Introduction to Data Science** at **Oakland University** (Rochester, MI). It applies real-world business framing to a standard classification problem, emphasizing model selection based on business-relevant metrics rather than raw accuracy alone.

---

## Author

**Minh Nguyen**  
MIS Senior | Cybersecurity Analytics & Management Concentration  
Oakland University — Expected Graduation: May 2026  
[LinkedIn](https://www.linkedin.com/in/minh-nguyen-mis/) · [GitHub](https://github.com/mhnguyen1807)
