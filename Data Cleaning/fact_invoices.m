let
    // Extracted the financial invoice records from the consolidated directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the specific binary content for the vendor invoices.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\",Name="fact_invoices.csv"]}[Content],

    // Imported the CSV document with the correct encoding and 8-column financial schema.
    Imported_Invoice_Data = Csv.Document(File_Content,[Delimiter=",", Columns=8, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify invoice dates and spend totals.
    Promote_Headers = Table.PromoteHeaders(Imported_Invoice_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to support accounts payable and spend categorization.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"invoice_id", Int64.Type}, {"po_id", Int64.Type}, {"grn_id", Int64.Type}, 
        {"invoice_date", type date}, {"vendor_invoice_no", type text}, 
        {"invoice_amount", type number}, {"currency", type text}, {"spend_category", type text}
    }),

    // Cleaned the Spend Category to keep high-level groups (e.g., "Capex", "Opex") 
    // by removing sub-category suffixes for better aggregation.
    Clean_Spend_Category = Table.TransformColumns(Set_Data_Types, {
        {"spend_category", each Text.BeforeDelimiter(_, "-"), type text}
    }),

    // Removed technical or document-specific columns that are not needed for quantitative analysis.
    Remove_Non_Analytical_Columns = Table.RemoveColumns(Clean_Spend_Category,{"vendor_invoice_no", "currency"}),

    // Renamed headers to follow professional financial reporting standards.
    Renamed_Columns = Table.RenameColumns(Remove_Non_Analytical_Columns,{
        {"invoice_id", "Invoice ID"}, {"po_id", "PO ID"}, {"grn_id", "GRN ID"}, 
        {"invoice_date", "Invoice Date"}, {"invoice_amount", "Invoice Total (BDT)"}, 
        {"spend_category", "Spend Type"}
    })
in
    Renamed_Columns
