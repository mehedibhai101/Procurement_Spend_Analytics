let
    // Extracted vendor contract and procurement terms from the BanglaBazaar consolidated directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the specific binary content for the contract dimension.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\",Name="dim_contracts.csv"]}[Content],

    // Imported the CSV document with the correct encoding and 5-column contract schema.
    Imported_Contract_Data = Csv.Document(File_Content,[Delimiter=",", Columns=5, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify contract pricing and lead times.
    Promote_Headers = Table.PromoteHeaders(Imported_Contract_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to support procurement cost analysis and logistics planning.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"contract_id", Int64.Type}, 
        {"vendor_id", Int64.Type}, 
        {"item_id", Int64.Type}, 
        {"contract_price", type number}, 
        {"lead_time_days", Int64.Type}
    }),

    // Renamed technical headers to professional labels for supply chain and procurement reporting.
    Renamed_Columns = Table.RenameColumns(Set_Data_Types,{
        {"contract_id", "Contract ID"}, 
        {"vendor_id", "Vendor ID"}, 
        {"item_id", "Item ID"}, 
        {"contract_price", "Negotiated Price (BDT)"}, 
        {"lead_time_days", "Lead Time (Days)"}
    })
in
    Renamed_Columns
