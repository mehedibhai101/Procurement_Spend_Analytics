let
    // Extracted the Purchase Order (PO) headers from the consolidated directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the binary content for the PO headers.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\",Name="fact_po_header.csv"]}[Content],

    // Imported the CSV document with a 10-column schema.
    Imported_PO_Data = Csv.Document(File_Content,[Delimiter=",", Columns=10, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify vendor links and financial totals.
    Promote_Headers = Table.PromoteHeaders(Imported_PO_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to support currency conversion and emergency spend analysis.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"po_id", Int64.Type}, {"vendor_id", Int64.Type}, {"pr_id", Int64.Type}, 
        {"po_date", type date}, {"currency", type text}, {"exchange_rate", type number}, 
        {"status", type text}, {"total_po_value", type number}, {"department_id", Int64.Type}, 
        {"is_emergency_order", Int64.Type}
    }),

    // Removed technical or redundant columns per requirement.
    // Currency is usually handled via the Vendor dimension or a dedicated Rate table.
    Remove_Technical_Columns = Table.RemoveColumns(Set_Data_Types,{"currency", "status"}),

    // Renamed headers to follow a professional, business-friendly convention.
    Renamed_Final_Columns = Table.RenameColumns(Remove_Technical_Columns,{
        {"po_id", "PO ID"}, {"vendor_id", "Vendor ID"}, {"pr_id", "Source PR ID"}, 
        {"po_date", "Order Date"}, {"exchange_rate", "Exchange Rate"}, 
        {"total_po_value", "Total PO Value (Local)"}, {"department_id", "Department ID"}, 
        {"is_emergency_order", "Is Emergency Order"}
    })
in
    Renamed_Final_Columns
