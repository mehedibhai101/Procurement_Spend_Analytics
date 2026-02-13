let
    // Extracted the granular item-level purchase records from the consolidated directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the specific binary content for the PO line items.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\",Name="fact_po_lines.csv"]}[Content],

    // Imported the CSV document with the correct encoding and 6-column detail schema.
    Imported_PO_Lines = Csv.Document(File_Content,[Delimiter=",", Columns=6, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify items, volumes, and costs.
    Promote_Headers = Table.PromoteHeaders(Imported_PO_Lines, [PromoteAllScalars=true]),

    // Assigned standardized data types to support spend analysis and price variance calculations.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"po_line_id", Int64.Type}, 
        {"po_id", Int64.Type}, 
        {"item_id", Int64.Type}, 
        {"quantity", Int64.Type}, 
        {"unit_price", type number}, 
        {"line_amount", type number}
    }),

    // Renamed headers to follow professional supply chain and financial standards.
    Renamed_Columns = Table.RenameColumns(Set_Data_Types,{
        {"po_line_id", "PO Line ID"}, 
        {"po_id", "PO ID"}, 
        {"item_id", "Item ID"}, 
        {"quantity", "Order Quantity"}, 
        {"unit_price", "Unit Price (BDT)"}, 
        {"line_amount", "Line Total (BDT)"}
    })
in
    Renamed_Columns
