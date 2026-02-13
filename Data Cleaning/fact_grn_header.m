let
    // Extracted the Goods Received Note (GRN) headers from the consolidated directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the specific binary content for the receipt headers.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\",Name="fact_grn_header.csv"]}[Content],

    // Imported the CSV document with the correct encoding and 4-column schema.
    Imported_GRN_Data = Csv.Document(File_Content,[Delimiter=",", Columns=4, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify receipt IDs and linked Purchase Orders.
    Promote_Headers = Table.PromoteHeaders(Imported_GRN_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to support lead time and delivery performance analysis.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"grn_id", Int64.Type}, 
        {"po_id", Int64.Type}, 
        {"received_date", type date}, 
        {"delivery_challan", type text}
    }),

    // Removed the 'delivery_challan' column as it is a physical document reference 
    // and typically not required for primary quantitative analysis.
    Remove_Document_Refs = Table.RemoveColumns(Set_Data_Types,{"delivery_challan"}),

    // Renamed headers to follow professional logistics and supply chain standards.
    Renamed_Columns = Table.RenameColumns(Remove_Document_Refs,{
        {"grn_id", "GRN ID"}, 
        {"po_id", "PO ID"}, 
        {"received_date", "Received Date"}
    })
in
    Renamed_Columns
