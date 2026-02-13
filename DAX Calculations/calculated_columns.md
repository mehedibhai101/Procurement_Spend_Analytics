# 🏗️ Calculated Tables & Columns: Procurement Spend Analysis

This documentation details the foundational calculated tables and columns required to transform raw procurement data into actionable intelligence. These structures enable complex variance analysis, vendor performance scoring, and financial tracking across multiple currencies.

---

## 📊 Calculated Tables

Calculated tables in this model are used to facilitate advanced data visualizations, such as waterfall charts and financial reconciliation flows.

**Cost Flow**: A specialized table designed to drive "Spend Bridge" visualizations, tracking the journey from budgeted baseline to net investment.

  * **Formula**:

  ```dax
  Cost Flow = {
      ("Budgeted Baseline", 'Calculations'[Total Contracted Amount], 0),
      ("Negotiated Savings", 'Calculations'[Total PPV], 1),
      ("Committed Capital", 'Calculations'[Total PO Spend], 2),
      ("True-Up Amount", 'Calculations'[Spend Variance], 3),
      ("Invoiced Amount", 'Calculations'[Total Acquisition Cost], 4),
      ("Damage Cost", 'Calculations'[Estimated Damage Cost], 5),
      ("Net Effective Investment", 'Calculations'[TCO], 6)
  }
  ```

---

## 📑 Calculated Columns

These columns enrich the fact tables by calculating variances, processing times, and currency-adjusted values at the row level.

| Table Name | Column Name | DAX Formula |
| --- | --- | --- |
| **Dim_Vendors** | **vendor_rating** | See Multi-line Snippet Below |
| **Dim_Items** | **avg_price** | `CALCULATE(AVERAGE(Fact_PO_Lines[unit_price_bdt]))` |
| **Fact_PR_Lines** | **is_rejected** | `IF(RELATED(Fact_PR_Header[status])="Rejected", 1, 0)` |
| **Fact_PO_Header** | **po_value_bdt** | `Fact_PO_Header[exchange_rate] * Fact_PO_Header[total_po_value]` |
| **Fact_PO_Header** | **PO Cycle Time** | See Multi-line Snippet Below |
| **Fact_PO_Lines** | **line_amount_bdt** | `Fact_PO_Lines[line_amount] * RELATED(Fact_PO_Header[exchange_rate])` |
| **Fact_PO_Lines** | **Contracted_Amount** | See Multi-line Snippet Below |
| **Fact_PO_Lines** | **Purchase Price Variance** | `IF(Fact_PO_Lines[Contracted_Amount] <> BLANK(), Fact_PO_Lines[line_amount_bdt] - Fact_PO_Lines[Contracted_Amount], Fact_PO_Lines[line_amount_bdt])` |
| **Fact_PO_Lines** | **unit_price_bdt** | `Fact_PO_Lines[unit_price] * RELATED(Fact_PO_Header[exchange_rate])` |
| **Fact_GRN_Header** | **dept_id** | `LOOKUPVALUE(Fact_PO_Header[department_id], Fact_PO_Header[po_id], Fact_GRN_Header[po_id])` |
| **Fact_GRN_Lines** | **Quantity Variance** | See Multi-line Snippet Below |
| **Fact_GRN_Lines** | **PO Unit Price** | See Multi-line Snippet Below |
| **Fact_GRN_Lines** | **Lead Time** | See Multi-line Snippet Below |
| **Fact_GRN_Lines** | **Lead Time Variance** | See Multi-line Snippet Below |
| **Fact_GRN_Lines** | **vendor_id** | `LOOKUPVALUE('fact_po_header'[vendor_id], Fact_PO_Header[po_id], RELATED(Fact_GRN_Header[po_id]))` |
| **Fact_Invoices** | **invoice_amount_bdt** | `Fact_Invoices[invoice_amount] * LOOKUPVALUE(Fact_PO_Header[exchange_rate], Fact_PO_Header[po_id], Fact_Invoices[po_id])` |
| **Fact_Invoices** | **Invoice Processing Time** | `DATEDIFF(LOOKUPVALUE(Fact_GRN_Header[received_date], Fact_GRN_Header[grn_id], Fact_Invoices[grn_id]), Fact_Invoices[invoice_date], DAY)` |
| **Fact_Invoices** | **pr_id** | `LOOKUPVALUE(Fact_PO_Header[pr_id], Fact_PO_Header[po_id], Fact_Invoices[po_id])` |
| **Fact_Invoices** | **dept_id** | `LOOKUPVALUE(Fact_PO_Header[department_id], Fact_PO_Header[po_id], Fact_Invoices[po_id])` |
| **Calendar** | **Year-Quarter** | `'Calendar'[Year] & "-" & 'Calendar'[Quarter]` |

---

## 🧠 Complex Column Logic Explained

**vendor_rating (Dim_Vendors)**:
Generates a 5-star score by weighting reliability (OTIF), quality (Pass Rate), and schedule consistency.

  ```dax
  VAR _consistency = 1 - ABS([Avg Lead Time Variance])/15 
  VAR _cons = IF(_consistency < 0, 0, _consistency) 
  VAR Weighted_Score = 
      ([OTIF%] * 0.5) +      -- 50% Weight on On-Time-In-Full delivery
      ([Quality Pass Rate] * 0.3) + -- 30% Weight on Good Condition items
      (_cons * 0.2)          -- 20% Weight on Schedule Consistency
  RETURN 
      ROUND(Weighted_Score * 5, 2)
  ```

**Contracted_Amount (Fact_PO_Lines)**:
A critical "Shadow Value" column that calculates what the spend *should* have been based on pre-negotiated contracts, allowing for variance detection.

  ```dax
  VAR Current_Item = 'fact_po_lines'[item_id]
  VAR Current_Vendor = RELATED('fact_po_header'[vendor_id])   
  VAR Contracted_Price = 
      LOOKUPVALUE(
          'dim_contracts'[contract_price],
          'dim_contracts'[vendor_id], Current_Vendor,
          'dim_contracts'[item_id], Current_Item
      ) 
  RETURN 
      Contracted_Price * Fact_PO_Lines[quantity] * RELATED(Fact_PO_Header[exchange_rate])
  ```

**Lead Time & Variance (Fact_GRN_Lines)**:
Calculates the actual time from PO issuance to receipt and measures the deviation from contracted SLA days.
  
  ```dax
  -- Lead Time Calculation
  VAR _PoDate = 
      LOOKUPVALUE(Fact_PO_Header[po_date], Fact_PO_Header[po_id], RELATED(Fact_GRN_Header[po_id])) 
  RETURN 
      DATEDIFF(_PoDate, RELATED(Fact_GRN_Header[received_date]), DAY)
  
  -- Lead Time Variance Calculation
  VAR _contracted = 
      LOOKUPVALUE(
          'dim_contracts'[lead_time_days],
          'dim_contracts'[vendor_id], Fact_GRN_Lines[vendor_id],
          'dim_contracts'[item_id], Fact_GRN_Lines[item_id]
      ) 
  RETURN 
      Fact_GRN_Lines[Lead Time] - _contracted
  ```

**PO Cycle Time (Fact_PO_Header)**:
Measures the operational efficiency of the procurement department by tracking the gap between a user's request and the formal purchase order.

  ```dax
  VAR PRDate = 
      LOOKUPVALUE(Fact_PR_Header[request_date], Fact_PR_Header[pr_id], Fact_PO_Header[pr_id]) 
  RETURN 
      DATEDIFF(PRDate, Fact_PO_Header[po_date], DAY)
  ```

---

**🧠 Explanation of Complex Logics**

**Shadow Value Benchmarking**: The `Contracted_Amount` and `Purchase Price Variance` columns are the core of the cost-saving engine. By calculating a "theoretical" price at the line-item level (using contract rates) and comparing it to the actual PO price, the model can isolate exactly where negotiations failed or where prices fluctuated due to market volatility, even across different currencies.

**Multi-Fact Reconciliation**: Many columns, such as `Quantity Variance` and `Invoice Processing Time`, rely on `LOOKUPVALUE` across different fact tables (PR, PO, GRN, and Invoices). This ensures that the model can track a single item from its requisition stage through to payment, identifying bottlenecks (like slow invoice processing) or discrepancies (like short shipments) at every touchpoint.

**Consistency Normalization**: In the `vendor_rating` column, lead time variance is normalized. Because a 15-day delay is considered a total failure in this model, the consistency variable is capped at 0. This prevents extreme outliers from skewing the weighted score into negative values, keeping the 0-5 star rating mathematically sound.

**Currency Synchronization**: Since procurement often happens in multiple currencies, all financial columns (PO Value, Line Amount, Invoiced Amount) are normalized to BDT using the `exchange_rate` found in the `Fact_PO_Header`. This allows the department to see a consolidated global spend figure without the noise of fluctuating exchange rates affecting the totals.
