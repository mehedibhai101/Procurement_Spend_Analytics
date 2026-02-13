let
    // Extracted the internal Purchase Requisition headers from the consolidated directory.
    Source_Folder = Folder.Files("your_folder_path"),

    // Accessed the binary content for the PR headers.
    File_Content = Source_Folder{[#"Folder Path"="your_folder_path\",Name="fact_pr_header.csv"]}[Content],

    // Imported the CSV document with the correct encoding and 5-column schema.
    Imported_PR_Data = Csv.Document(File_Content,[Delimiter=",", Columns=5, Encoding=1252, QuoteStyle=QuoteStyle.None]),

    // Promoted the first row to headers to identify request dates and statuses.
    Promote_Headers = Table.PromoteHeaders(Imported_PR_Data, [PromoteAllScalars=true]),

    // Assigned standardized data types to support procurement cycle-time analysis.
    Set_Data_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"pr_id", Int64.Type}, 
        {"request_date", type date}, 
        {"dept_id", Int64.Type}, 
        {"status", type text}, 
        {"requester", type text}
    }),

    // Renamed headers to professional, business-friendly labels for internal audit reporting.
    Renamed_Columns = Table.RenameColumns(Set_Data_Types,{
        {"pr_id", "PR ID"}, 
        {"request_date", "Request Date"}, 
        {"dept_id", "Department ID"}, 
        {"status", "Approval Status"}, 
        {"requester", "Requested By"}
    })
in
    Renamed_Columns
