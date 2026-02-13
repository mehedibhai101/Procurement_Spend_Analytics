let
    // Extracted the master item list from the BanglaBazaar consolidated directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the specific binary content for the item dimension.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\",Name="dim_items.csv"]}[Content],

    // Imported the CSV document with the correct encoding and 6-column schema.
    Imported_Item_Data = Csv.Document(File_Content,[Delimiter=",", Columns=6, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify item names and financial groupings.
    Promote_Headers = Table.PromoteHeaders(Imported_Item_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to support inventory reconciliation and GL mapping.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"item_id", Int64.Type}, 
        {"item_name", type text}, 
        {"category", type text}, 
        {"item_type", type text}, 
        {"uom", type text}, 
        {"accounting_group", type text}
    }),

    // Renamed headers to follow a professional, business-friendly convention for audit and stock reporting.
    Renamed_Columns = Table.RenameColumns(Set_Data_Types,{
        {"item_id", "Item ID"}, 
        {"item_name", "Item Description"}, 
        {"category", "Category"}, 
        {"item_type", "Item Type"}, 
        {"uom", "Unit of Measure (UOM)"}, 
        {"accounting_group", "Accounting Group"}
    })
in
    Renamed_Columns
