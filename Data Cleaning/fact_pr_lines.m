let
    // Extracted the granular item-level demand from the consolidated directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the binary content for the PR line items.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\",Name="fact_pr_lines.csv"]}[Content],

    // Imported the CSV document with the correct encoding and 4-column detail schema.
    Imported_PR_Lines = Csv.Document(File_Content,[Delimiter=",", Columns=4, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify items and requested quantities.
    Promote_Headers = Table.PromoteHeaders(Imported_PR_Lines, [PromoteAllScalars=true]),

    // Assigned standardized data types to facilitate volume analysis and inventory demand planning.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"pr_line_id", Int64.Type}, 
        {"pr_id", Int64.Type}, 
        {"item_id", Int64.Type}, 
        {"qty_requested", Int64.Type}
    }),

    // Renamed headers to follow professional supply chain standards for reporting.
    Renamed_Columns = Table.RenameColumns(Set_Data_Types,{
        {"pr_line_id", "PR Line ID"}, 
        {"pr_id", "PR ID"}, 
        {"item_id", "Item ID"}, 
        {"qty_requested", "Quantity Requested"}
    })
in
    Renamed_Columns
