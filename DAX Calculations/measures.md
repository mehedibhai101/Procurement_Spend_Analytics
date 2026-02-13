# 📊 Measures: Procurement Spend Analytics

This documentation provides the complete catalog of all DAX measures used in the Procurement Spend Analytics project.

---

## 💰 Purchases & Spend Performance

**Total PO Spend**: Total gross value of all Purchase Orders issued.
  * **Formula**: `SUM(Fact_PO_Header[po_value_bdt])`
  * **Format**: `#,0"৳";-#,0"৳";#,0"৳"`

**Total Purchases**: Total count of Purchase Order records.
  * **Formula**: `COUNTROWS(Fact_PO_Header)`
  * **Format**: `#,0`

**Avg Purchase Value**: The average monetary value of a single Purchase Order.
  * **Formula**: `DIVIDE( [Total PO Spend], [Total Purchases] )`
  * **Format**: `#,0.0"৳";-#,0.0"৳";#,0.0"৳"`

**Total Qty Purchased**: Total units of items ordered across all PO lines.
  * **Formula**: `SUM(Fact_PO_Lines[quantity])`
  * **Format**: `#,0`

**Spend under Management**: PO Spend that originated from a formal Purchase Requisition (PR).
  * **Formula**: `CALCULATE([Total PO Spend], Fact_PO_Header[pr_id]<>BLANK())`
  * **Format**: `General`

**Total PPV**: Total Purchase Price Variance (Actual Price vs. Standard Price).
  * **Formula**: `SUM(Fact_PO_Lines[Purchase Price Variance])`
  * **Format**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`

**PPV Rate**: Percentage of price variance relative to total spend.
  * **Formula**: `DIVIDE([Total PPV], [Total PO Spend])`
  * **Format**: `0.00%;-0.00%;0.00%`

**Cost Savings**: Total savings realized (inverse of PPV).
  * **Formula**: `-SUM(Fact_PO_Lines[Purchase Price Variance])`
  * **Format**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`

**Total Contracted Amount**: Sum of PO values linked to a pre-existing contract.
  * **Formula**: `SUM(Fact_PO_Lines[Contracted_Amount])`
  * **Format**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`

**Avg Spend/Day**: Average daily spend based on unique PO dates.
  * **Formula**: `DIVIDE([Total PO Spend], DISTINCTCOUNT(Fact_PO_Header[po_date]))`
  * **Format**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`

**Avg Spend**: Average value per individual Purchase Order.
  * **Formula**: `AVERAGE(Fact_PO_Header[po_value_bdt])`
  * **Format**: `General`

**Avg PO Cycle Time**: Average duration from PR to PO issuance.
  * **Formula**: `AVERAGE(Fact_PO_Header[PO Cycle Time])`
  * **Format**: `General`

**PO Consolidation Ratio**: Measure of lines per Purchase Order.
  * **Formula**:
  ```dax
  VAR Total_Lines = COUNTROWS('fact_po_lines')
  VAR Total_POs = DISTINCTCOUNT('fact_po_header'[po_id])
  RETURN 
      DIVIDE(Total_Lines, Total_POs, 0)
  ```
  * **Format**: `General`

---

## 🚨 Maverick & Compliance Analysis

**Maverick Purchases**: Count of POs created without a linked Purchase Requisition.
  * **Formula**: `CALCULATE([Total Purchases], Fact_PO_Header[pr_id]=BLANK())`
  * **Format**: `#,0`

**Maverick Purchase%**: Percentage of total orders that are unmanaged.

  * **Formula**: `DIVIDE([Maverick Purchases], [Total Purchases])`
  * **Format**: `0.00%;-0.00%;0.00%`

**Maverick Spend**: Monetary value of non-compliant/unmanaged spend.

  * **Formula**: `CALCULATE([Total PO Spend], Fact_PO_Header[pr_id]=BLANK())`
  * **Format**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`

**Maverick Spend%**: Percentage of total spend that is unmanaged.

  * **Formula**: `DIVIDE([Maverick Spend], [Total PO Spend])`
  * **Format**: `0.00%;-0.00%;0.00%`

**Emergency Purchase Rate**: Percentage of orders flagged as "Emergency."

  * **Formula**:
  
  ```dax
  VAR _emer = CALCULATE([Total Purchases], Fact_PO_Header[is_emergency_order]=1) 
  RETURN DIVIDE(_emer, [Total Purchases])
  ```
  
  * **Format**: `0.00%;-0.00%;0.00%`

**Emergency Spend**: Total spend on emergency orders.

  * **Formula**: `CALCULATE([Total PO Spend], Fact_PO_Header[is_emergency_order]=1)`
  * **Format**: `General`

**Contract Coverage Rate**: Percentage of spend covered by contracts.

  * **Formula**:
  
  ```dax
  VAR _coverage = 
      CALCULATE(
          SUM(Fact_PO_Lines[line_amount_bdt]), 
          Fact_PO_Lines[Contracted_Amount] <> BLANK()
      ) 
  RETURN DIVIDE(_coverage, [Total PO Spend])
  ```
  
  * **Format**: `0%;-0%;0%`

**Contract Compliance Rate**: Ratio of contracted PO lines against total contracts.

  * **Formula**:
  
  ```dax
  VAR _completed = 
      CALCULATE(
          DISTINCTCOUNT(Fact_PO_Lines[Contracted_Amount]), 
          Fact_PO_Lines[Contracted_Amount] <> BLANK()
      ) 
  RETURN DIVIDE(_completed, [Total Contracts])
  ```
  
  * **Format**: `General`

---

## 🧾 Invoices & Financials

**Total Acquisition Cost**: Total value of vendor invoices.

  * **Formula**: `SUM(Fact_Invoices[invoice_amount_bdt])`
  * **Format**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`

**Total Invoices**: Count of all invoice records.

  * **Formula**: `COUNTROWS(Fact_Invoices)`
  * **Format**: `0`

**Spend Variance**: The gap between Invoiced Amount and PO Amount.

  * **Formula**: `[Total Acquisition Cost] - [Total PO Spend]`
  * **Format**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`

**TCO**: Total Cost of Ownership (Acquisition + Damage Costs).

  * **Formula**: `[Total Acquisition Cost] + [Estimated Damage Cost]`
  * **Format**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`

**Avg Invoice Processing Time**: Average duration to process an invoice.

  * **Formula**: `AVERAGE(Fact_Invoices[Invoice Processing Time])`
  * **Format**: `General`

**Cost per Invoice**: Processing cost per invoice.

  * **Formula**: `DIVIDE([Total Acquisition Cost], COUNTROWS(Fact_Invoices))`
  * **Format**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`

---

## 🚚 Receives, Quality & Logistics

**Total Receives**: Count of unique Goods Received Notes (GRN).

  * **Formula**: `DISTINCTCOUNT(Fact_GRN_Lines[grn_id])`
  * **Format**: `#,0`

**Total Qty Received**: Total quantity successfully delivered to the warehouse.

  * **Formula**: `SUM(Fact_GRN_Lines[qty_received])`
  * **Format**: `#,0`

**Fill Rate**: Ratio of quantity received vs quantity ordered.

  * **Formula**: `DIVIDE([Total Qty Received], [Total Qty Purchased])`
  * **Format**: `0.00%;-0.00%;0.00%`

**Recieve Rate**: Ratio of receipts relative to Purchase Orders.

  * **Formula**: `DIVIDE([Total Receives], [Total Purchases])`
  * **Format**: `0.00%;-0.00%;0.00%`

**Avg Lead Time**: Average days from PO to receipt.

  * **Formula**: `AVERAGE(Fact_GRN_Lines[Lead Time])`
  * **Format**: `General`

**Avg Lead Time Variance**: Average deviation from the expected delivery date.

  * **Formula**: `AVERAGE(Fact_GRN_Lines[Lead Time Variance])`
  * **Format**: `General`

**OTD Rate**: On-Time Delivery rate.

  * **Formula**:
  
  ```dax
  VAR _ontime = 
      CALCULATE(
          DISTINCTCOUNT(Fact_GRN_Lines[grn_id]), 
          Fact_GRN_Lines[Lead Time Variance] <= 0
      ) 
  RETURN DIVIDE(_ontime, DISTINCTCOUNT(Fact_GRN_Lines[grn_id]), 0)
  ```
  
  * **Format**: `0.00%;-0.00%;0.00%`

**OTIF%**: On-Time In-Full percentage.

  * **Formula**:
  
  ```dax
  VAR _olif = 
      CALCULATE(
          [Total Receives], 
          Fact_GRN_Lines[Quantity Variance] >= 0 && Fact_GRN_Lines[Lead Time Variance] <= 0
      ) 
  RETURN IF(ISBLANK(_olif), 0, DIVIDE(_olif, [Total Purchases], 0))
  ```
  
  * **Format**: `0.00%;-0.00%;0.00%`

**Short Shipment Rate**: Percentage of receipts with quantity variance < 0.

  * **Formula**:
  
  ```dax
  VAR _short = 
      CALCULATE(COUNTROWS(Fact_GRN_Lines), Fact_GRN_Lines[Quantity Variance] < 0) 
  RETURN DIVIDE(_short, [Total Receives])
  ```
  
  * **Format**: `0%;-0%;0%`

**Late Delivery Count**: Total receipts arriving after the expected lead time.

  * **Formula**: `CALCULATE(DISTINCTCOUNT(Fact_GRN_Lines[grn_id]), Fact_GRN_Lines[Lead Time Variance]>0)`
  * **Format**: `#,0`

**Rejection Rate**: Percentage of quantity rejected.

  * **Formula**:
  
  ```dax
  VAR _rejected = CALCULATE(
      [Total Qty Received], 
      'fact_grn_lines'[quality_status] IN {
          "Dead on Arrival (DOA)", "Rejected - Quality Failure", 
          "Screen Damaged", "Service Disputed", "Wrong Item Sent"
      } 
  ) 
  RETURN IF(ISBLANK(_rejected), 0, DIVIDE(_rejected, [Total Qty Received]))
  ```
  
  * **Format**: `0.00%;-0.00%;0.00%`

**Quality Pass Rate**: Percentage of items in good condition.

  * **Formula**:
  
  ```dax
  VAR _passed = CALCULATE(
      [Total Qty Received], 
      'fact_grn_lines'[quality_status] IN {
          "Good Condition", "Service Accepted", 
          "Minor Defect - Accepted", "Packaging Damaged"
      } 
  ) 
  RETURN DIVIDE(_passed, [Total Qty Received])
  ```
  
  * **Format**: `0.00%;-0.00%;0.00%`

**Estimated Damage Cost**: Value of rejected goods based on PO unit price.

  * **Formula**:
  
  ```dax
  CALCULATE(
      SUMX(
          'fact_grn_lines', 
          'fact_grn_lines'[qty_received] * 'Fact_GRN_Lines'[PO Unit Price]
      ),
      'fact_grn_lines'[quality_status] IN {
          "Dead on Arrival (DOA)", "Rejected - Quality Failure",
          "Screen Damaged", "Wrong Item Sent", "Service Disputed"
      }
  )
  ```
  
  * **Format**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`

**Damage Rate**: Percentage of goods flagged with critical quality failures.

  * **Formula**:
  
  ```dax
  VAR _damage = CALCULATE(
      [Total Qty Received], 
      'fact_grn_lines'[quality_status] IN {
          "Dead on Arrival (DOA)", "Rejected - Quality Failure",
          "Screen Damaged", "Wrong Item Sent", "Service Disputed"
      }
  ) 
  RETURN DIVIDE(_damage, [Total Qty Received])
  ```
  
  * **Format**: `0.00%;-0.00%;0.00%`

---

## 📋 Requisitions & Vendors

**Total Requests**: Total number of Purchase Requisitions.

  * **Formula**: `COUNTROWS(Fact_PR_Header)`
  * **Format**: `#,0`

**Total Rejects**: Number of rejected requisitions.

  * **Formula**: `CALCULATE([Total Requests], Fact_PR_Header[status]="Rejected")`
  * **Format**: `0`

**PR Rejection Rate**: Ratio of rejected vs total requisitions.

  * **Formula**:
  
  ```dax
  VAR _rejected = CALCULATE([Total Requests], Fact_PR_Header[status]="Rejected") 
  RETURN DIVIDE(_rejected, [Total Requests])
  ```
  
  * **Format**: `0.00%;-0.00%;0.00%`

**Cost Avoidance**: Potential spend saved by rejecting unnecessary PRs.

  * **Formula**:

  ```dax
  CALCULATE( 
      SUMX(Fact_PR_Lines, RELATED(Dim_Items[avg_price])*Fact_PR_Lines[qty_requested]), 
      Fact_PR_Lines[is_rejected]=1
  )
  ```
  
  * **Format**: `#,0.00"৳";-#,0.00"৳";#,0.00"৳"`

**Total Contracts**: Count of formal contracts.

  * **Formula**: `COUNTROWS(Dim_Contracts)`
  * **Format**: `#,0`

**Total Vendors**: Count of unique suppliers.

  * **Formula**: `COUNTROWS(Dim_Vendors)`
  * **Format**: `#,0`

**Avg Vendor Rating**: Average supplier score.

  * **Formula**: `AVERAGE(Dim_Vendors[vendor_rating])`
  * **Format**: `General`

**Price Volatility %**: Item price stability over time.

  * **Formula**:
  
  ```dax
  VAR Avg_Price = AVERAGE('fact_po_lines'[unit_price_bdt]) 
  VAR StDev_Price = STDEV.P('fact_po_lines'[unit_price_bdt]) 
  RETURN IF(ISBLANK(StDev_Price), 0, DIVIDE(StDev_Price, Avg_Price, 0))
  ```
  
  * **Format**: `0.00%;-0.00%;0.00%`

**Stdev Price**: Unit price standard deviation.

  * **Formula**: `STDEV.P(Fact_PO_Lines[unit_price_bdt])`
  * **Format**: `General`

---

## 📅 Time Intelligence (Vs PY)

**Vs PY (TCO)**: `VAR _Pv = CALCULATE([TCO], SAMEPERIODLASTYEAR('Calendar'[Date])) RETURN DIVIDE([TCO]-_Pv, _Pv)`

**Vs PY (Purchases)**: `VAR _Pv = CALCULATE([Total Purchases], SAMEPERIODLASTYEAR('Calendar'[Date])) RETURN DIVIDE([Total Purchases]-_Pv, _Pv)`

**Vs PY (Spend)**: `VAR _Pv = CALCULATE([Total PO Spend], SAMEPERIODLASTYEAR('Calendar'[Date])) RETURN DIVIDE([Total PO Spend]-_Pv, _Pv)`

**Vs PY (APV)**: `VAR _Pv = CALCULATE([Avg Purchase Value], SAMEPERIODLASTYEAR('Calendar'[Date])) RETURN DIVIDE([Avg Purchase Value]-_Pv, _Pv)`

**Vs PY (Cycle Time)**: `VAR _Pv = CALCULATE([Avg PO Cycle Time], SAMEPERIODLASTYEAR('Calendar'[Date])) RETURN DIVIDE([Avg PO Cycle Time]-_Pv, _Pv)`

**Vs PY (Lead Time)**: `VAR _Pv = CALCULATE([Avg Lead Time], SAMEPERIODLASTYEAR('Calendar'[Date])) RETURN DIVIDE([Avg Lead Time]-_Pv, _Pv)`

**Vs PY (Cost Avoid)**: `VAR _Pv = CALCULATE([Cost Avoidance], SAMEPERIODLASTYEAR('Calendar'[Date])) RETURN DIVIDE([Cost Avoidance]-_Pv, _Pv)`

**Vs PY (Spend/Day)**: `VAR _Pv = CALCULATE([Avg Spend/Day], SAMEPERIODLASTYEAR('Calendar'[Date])) RETURN DIVIDE([Avg Spend/Day]-_Pv, _Pv)`

**Vs PY (Invoice Time)**: `VAR _Pv = CALCULATE([Avg Invoice Processing Time], SAMEPERIODLASTYEAR('Calendar'[Date])) RETURN DIVIDE([Avg Invoice Processing Time]-_Pv, _Pv)`

---

## 🎨 KPI Colors & Formatting

**PY Color (TCO)**: `IF([Vs PY (TCO)]<>0, "#744EC2", "#252423")`

**KPI Color(Cost Savings)**: `IF([Cost Savings]>=0, "#252423", "#D64554")`

**PY Color (Purchases)**: `IF([Vs PY (Purchases)]<>0, "#744EC2", "#252423")`

**PY Color (Spend)**: `IF([Vs PY (Spend)]<>0, "#744EC2", "#252423")`

**KPI Color(PPV%)**: `IF(ABS([PPV Rate])<=0.05, "#252423", "#D64554")`

**PY Color (APV)**: `SWITCH(TRUE(), [Vs PY (APV)]>0, "#48BC66", [Vs PY (APV)]<0, "#D64554", "#252423")`

**KPI Color(Lead Time Var)**: `IF(ABS([Avg Lead Time Variance])<=5, "#252423", "#D64554")`

**KPI Color(Rejection%)**: `IF(ABS([Rejection Rate])<=0.05, "#252423", "#D64554")`

**KPI Color(Maverick%)**: `IF(ABS([Maverick Spend%])<=0.05, "#252423", "#D64554")`

**KPI Color(Rating)**: `IF([Avg Vendor Rating]>=3, "#252423", "#D64554")`

**PY Color (Cost Avoid)**: `SWITCH(TRUE(), [Vs PY (Cost Avoid)]>0, "#48BC66", [Vs PY (Cost Avoid)]<0, "#D64554", "#252423")`

**PY Color (Spend/Day)**: `IF([Vs PY (Spend/Day)]<>0, "#744EC2", "#252423")`

**PY Color (Invoice Time)**: `IF([Vs PY (Invoice Time)]<>0, "#744EC2", "#252423")`

**PY Color (Cycle Time)**: `SWITCH(TRUE(), [Vs PY (Cycle Time)]>0, "#48BC66", [Vs PY (Cycle Time)]<0, "#D64554", "#252423")`

**PY Color (Lead Time)**: `SWITCH(TRUE(), [Vs PY (Lead Time)]>0, "#48BC66", [Vs PY (Lead Time)]<0, "#D64554", "#252423")`

**Vendor Segment Color**:

  ```dax
  VAR Current_PPV = [PPV Rate] VAR Current_Rating = [Avg Vendor Rating] 
  VAR Avg_PPV_Threshold = CALCULATE( [PPV Rate], ALL(Dim_Vendors[vendor_name]) ) 
  VAR Avg_Rating_Threshold = 3 
  RETURN SWITCH( TRUE(), 
      Current_PPV <= Avg_PPV_Threshold && Current_Rating >= Avg_Rating_Threshold, "#744EC2", 
      "#B3A2E8" 
  )
  ```

**Price Segment Color**:

  ```dax
  VAR Current_Spend = [Total PO Spend] VAR Current_Volatility = [Price Volatility %] 
  VAR Global_Stats_Table = CALCULATETABLE( VALUES('Dim_Items'[item_name]), ALLSELECTED('dim_items') ) 
  VAR Spend_Threshold = AVERAGEX( Global_Stats_Table, [Total PO Spend] ) 
  VAR Volatility_Threshold = 0.1 
  RETURN SWITCH( TRUE(), 
      Current_Spend >= Spend_Threshold && Current_Volatility >= Volatility_Threshold, "#DD555F", 
      "#B3A2E8" 
  )
  ```

---

## 🏷️ Visual Helpers & Markers

**SV indicator**: `SWITCH(TRUE(), [Spend Variance]>0, "Over Budget", [Spend Variance]<0, "Under Budget", "")`
**PPV indicator**: `SWITCH(TRUE(), [PPV Rate]>0, "Increase", [PPV Rate]<0, "Decrease", "")`
**Month Label / Year Label / Dept Label / Country Label**: `IF(ISFILTERED(...), "", "Context Name")`
**PO Type**: `MAXX(Fact_PO_Header, IF(Fact_PO_Header[pr_id]=0, "Maverick", "Managed"))`

**Latest Quarter TCO/Spend**:
  
  ```dax
  VAR MaxSalesDate = CALCULATE( MAX(Fact_PO_Header[po_date]), ALL(Fact_PO_Header) ) 
  VAR LatestYearQuarter = CALCULATE( MAX('Calendar'[Year-Quarter]), 'Calendar'[Date] = MaxSalesDate ) 
  VAR CurrentContextQuarter = MAX('Calendar'[Year-Quarter]) 
  RETURN IF( CurrentContextQuarter = LatestYearQuarter, [Measure], BLANK() )
  ```

**Rejection Context**:

  ```dax
  VAR Current_Rate = [PR Rejection Rate] VAR Denominator = IF(Current_Rate > 0, ROUND(1 / Current_Rate, 0), 0) 
  RETURN IF(Current_Rate = 0, "No Rejections Recorded", "Every 1 out of " & Denominator & " are Rejected")
  ```

---

### 🧠 Explanation of Complex Logics

**Procurement Compliance & Maverick Identification**: The `Maverick Spend` and `% Maverick` measures utilize a "Linkage-Gap" logic. In procurement, compliance is defined by the existence of a traceability chain. These measures use `CALCULATE` and `BLANK` filters on the `pr_id` field within the Purchase Order table. By isolating orders that lack a parent Requisition ID, the model identifies spend that bypassed internal controls, allowing management to quantify the financial risk of "rogue" buying habits.

**Operational Accuracy (OTIF)**: The `OTIF%` (On-Time In-Full) is a compound metric that acts as a stringent quality gate. Unlike simple lead-time averages, this logic uses a logical `AND` operation within a `CALCULATE` function. It validates two distinct conditions simultaneously: that the `Quantity Variance` is non-negative (In-Full) and the `Lead Time Variance` is zero or less (On-Time). This provides a more authentic representation of vendor reliability than tracking those metrics in isolation.

**Value-Based Quality Risk (Damage Costing)**: The `Estimated Damage Cost` measure employs `SUMX` for row-level iteration across the Goods Received (GRN) lines. Rather than just counting rejected units, it performs a cross-table lookup to the PO Price for each specific item. This "Contextual Valuation" ensures that a rejected high-value component impacts the TCO (Total Cost of Ownership) more significantly than a low-value consumable, effectively weighting quality issues by their true financial impact.

**Dynamic Benchmark Highlighting**: Measures like `Price Segment Color` and `Vendor Segment Color` use "Statistical Context Shifting." These measures calculate the average performance of the entire dataset (using `ALLSELECTED`) and then compare each individual row's performance against that global benchmark. This logic allows the dashboard to dynamically update its "High Risk" (Red) or "Top Performer" (Purple) color coding based on whatever filters the user has applied, ensuring the visual cues are always relevant to the current view.

**Predictive Cost Avoidance**: The `Cost Avoidance` measure is a "What-If" simulation. It scans the Requisition table for items that were rejected by management and uses `RELATED` to fetch the average market price of those items. It then multiplies that price by the requested quantity to quantify "the money we didn't spend." This transforms a negative action (a rejection) into a positive procurement KPI, proving the value of the gatekeeping process.
