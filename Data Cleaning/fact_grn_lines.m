let
    // Extracted the granular item-level receipt details from the consolidated directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the specific binary content for the Goods Received Note (GRN) line items.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\",Name="fact_grn_lines.csv"]}[Content],

    // Imported the CSV document with the correct encoding and 6-column receipt schema.
    Imported_GRN_Lines = Csv.Document(File_Content,[Delimiter=",", Columns=6, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify quantities and quality status.
    Promote_Headers = Table.PromoteHeaders(Imported_PR_Lines, [PromoteAllScalars=true]),

    // Assigned standardized data types to support fulfillment and quality control analysis.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"grn_line_id", Int64.Type}, 
        {"grn_id", Int64.Type}, 
        {"po_line_id", Int64.Type}, 
        {"item_id", Int64.Type}, 
        {"qty_received", Int64.Type}, 
        {"quality_status", type text}
    }),

    // Renamed headers to follow professional logistics and supply chain terminology.
    Renamed_Columns = Table.RenameColumns(Set_Data_Types,{
        {"grn_line_id", "GRN Line ID"}, 
        {"grn_id", "GRN ID"}, 
        {"po_line_id", "PO Line ID"}, 
        {"item_id", "Item ID"}, 
        {"qty_received", "Quantity Received"}, 
        {"quality_status", "Quality Status"}
    })
in
    Renamed_Columns
