# Project Background: Procurement Spend Analytics at BanglaBazaar

BanglaBazaar.com is a leading e-commerce enterprise in Bangladesh, operating at the forefront of the nation's digital retail revolution. Since its inception, the company has scaled to manage a massive logistical footprint, serving millions of customers. As the organization prepares for a potential IPO, the **Procurement & Supply Chain** function has transitioned from a support role into a high-stakes capital allocation engine.

This project focuses on **Source-to-Pay (S2P) Intelligence**—moving beyond simple invoice tracking to diagnose "Process Paralysis" and "Value Leakage" across the supply chain. With an annual Total Cost of Ownership (TCO) of **39.3 Billion BDT**, any inefficiency in the purchasing cycle directly impacts the company's bottom line. This analysis serves as a strategic roadmap for the Executive Leadership Team to transition from a reactive, high-cost model to a **Strategic Sourcing** powerhouse.

Insights and recommendations are provided on the following key areas:

* **Category 1: Process Paralysis & Maverick Spend** (Diagnosing the 8-Month Cycle)
* **Category 2: The Payment Paradox** (Leveraging Terms against Performance)
* **Category 3: The "Unreliability Tax"** (Inventory Hoarding & Working Capital)
* **Category 4: Price Variance & Commercial Leakage** (Managed vs. Unmanaged Spend)

**SQL & DAX queries regarding procurement KPIs can be found here [[Link to Script]](https://www.google.com/search?q=%23).**

**An interactive Spend Analytics dashboard used to report and explore procurement trends can be found here [[Link to Dashboard]](https://www.google.com/search?q=%23).**

---

# Data Structure & Initial Checks

The procurement analytics data warehouse is structured as a Star Schema, integrating the entire lifecycle of a purchase—from the initial request to the final bank settlement.

* **`fact_pr_lines` / `fact_po_lines`:** Tracks the requisition-to-order flow, identifying bottlenecks in the approval chain.
* **`fact_grn_lines`:** Records goods receipt quality and timelines, used to calculate **On-Time-In-Full (OTIF)** delivery.
* **`fact_invoices`:** Financial records categorized by spend type (Inventory, Capex, Opex) to monitor cash outflows.
* **`dim_vendors` & `dim_contracts`:** Profiles 150+ partners and their negotiated rates vs. actual invoiced amounts.

### Procurement Data Warehouse Schema

---

# Executive Summary

### Overview of Findings

BanglaBazaar is currently **"Funding Inefficiency."** While TCO has surged by **86.6%**, procurement volume only grew by **63.3%**, indicating significant price leakage. The root cause is an alarming **246.5-day PO Cycle Time**, which has broken the formal procurement process and forced departments into **18.73% Maverick Spend** (unauthorized buying). Strategically, we have surrendered our leverage by paying invoices in **~3 days** (financing the vendor) while accepting a dangerous **57.93% OTIF** reliability rate. This unreliability has forced the company to hoard **62% of its spend in Inventory** as a defensive "Safety Stock" measure.

[**Visualization: Executive KPI Overview - TCO vs. Volume & OTIF Performance**]

---

# Insights Deep Dive

### Category 1: Process Paralysis & Maverick Spend

* **The Approval Bottleneck.** The 246.5-day cycle from request to order is the primary driver of non-compliance. Departments simply cannot wait 8 months for essential items, leading to "emergency" off-contract buying.
* **IT & Tech "Going Rogue."** **44% of Maverick Spend** is concentrated in the IT & Technology department. This lack of centralized control is a major contributor to our overall **18.73% maverick rate**.
* **Approval Friction.** Data suggests that 70% of the delay occurs between "Request Approved" and "PO Released," signaling a breakdown in the purchasing department’s execution speed.

[**Visualization: Maverick Spend % vs. PO Cycle Time by Department**]

### Category 2: The Payment Paradox & Leverage Gap

* **Financing Underperformance.** We process invoices in an average of **2.98 days**, yet our vendors only deliver on time **57.93% of the time**. We are rewarding poor service with immediate liquidity.
* **Vendor Risk Profile.** High-monetary risk vendors like **Galvan-Jackson Ltd** (Rating: 1.82) are being paid as quickly as top-tier partners, removing any incentive for them to improve their delivery reliability.
* **Lost Cash Flow.** By paying in 3 days instead of a standard Net-30, the company is sacrificing significant interest-earning potential on its cash reserves.

[**Visualization: Vendor 2x2 Matrix - Payment Speed vs. Delivery Reliability (OTIF)**]

### Category 3: The "Unreliability Tax" (Inventory Hoarding)

* **Defensive Overstocking.** **62.2% of total spend** is locked in Inventory. This high concentration is not a strategic buffer but a reaction to the low 57% OTIF rate.
* **Capital Opportunity.** Improving vendor reliability to 85% OTIF would allow the organization to reduce inventory levels by 15%, potentially freeing up **5.9 Billion BDT** in working capital.
* **Storage Costs.** The excess "Safety Stock" is driving up warehousing and facilities costs, which have increased by 21% YoY.

[**Visualization: Inventory Spend vs. Vendor OTIF Correlation**]

### Category 4: Price Variance & Commercial Leakage

* **The "Urgency Premium."** Off-contract buying has resulted in a **+8.43% Price Variance**. For common items like IT peripherals, we are paying 15-18% more than our negotiated rates.
* **Managed vs. Unmanaged Spend.** Only **81% of spend** is formally "Managed." The remaining 19% "Unmanaged" spend is where the majority of margin erosion occurs.
* **Tail Spend Management.** 70% of our vendors represent only 5% of our spend but consume 40% of the procurement team's administrative bandwidth.

[**Visualization: Price Variance Heatmap by Category & Vendor**]

---

# Recommendations:

Based on the analysis, the following strategic pillars are recommended for the upcoming fiscal year:

* **Red Tape Compression:** Immediately audit the approval chain to reduce the PO Cycle Time from 246 days to **under 30 days**. Speed is the only cure for Maverick Spend.
* **Strategic Payment Terms:** Move all non-critical vendors to **Net-30 or Net-45 terms**. Reserve "Fast Payment" (3-day) only as a reward for partners achieving **>95% OTIF**.
* **Digital IT Catalogs:** Implement pre-approved digital catalogs for high-volatility IT hardware. Lock in annual fixed rates to eliminate the **18% price variance** and rogue buying.
* **Vendor Rationalization:** Phase out "Risky Vendors" (Rating <3.0) and consolidate volume with high-performers like **Hull-Smith Traders** (Rating 4.05) to increase volume-based discounts.
* **Transition to JIT:** Once OTIF reliability improves, transition Inventory management toward **Just-In-Time (JIT)** principles to liquefy tied-up capital for IPO expansion.

---

# Assumptions and Caveats:

* **Assumption 1:** Maverick Spend was identified by transactions with no linked `contract_id` or a price variance of >5% from the master contract.
* **Assumption 2:** PO Cycle Time includes all approval steps from the initial PR `request_date` to the final PO `Released` status.
* **Assumption 3:** Currency risk for global importers was calculated using the BDT/USD volatility during the 2023 fiscal year.
