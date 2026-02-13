let
    // Extracted vendor master data from the BanglaBazaar consolidated directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the specific binary content for the vendor dimension.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\",Name="dim_vendors.csv"]}[Content],

    // Imported the CSV document with the correct encoding and 6-column vendor schema.
    Imported_Vendor_Data = Csv.Document(File_Content,[Delimiter=",", Columns=6, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify vendor names, locations, and terms.
    Promote_Headers = Table.PromoteHeaders(Imported_Vendor_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to support regional sourcing and financial analysis.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"vendor_id", Int64.Type}, 
        {"vendor_name", type text}, 
        {"vendor_type", type text}, 
        {"location", type text}, 
        {"currency", type text}, 
        {"payment_terms", type text}
    }),

    // Renamed headers to follow a professional, business-friendly convention for supply chain auditing.
    Renamed_Columns = Table.RenameColumns(Set_Data_Types,{
        {"vendor_id", "Vendor ID"}, 
        {"vendor_name", "Vendor Name"}, 
        {"vendor_type", "Vendor Category"}, 
        {"location", "City/Location"}, 
        {"currency", "Trade Currency"}, 
        {"payment_terms", "Payment Terms"}
    })
in
    Renamed_Columns
