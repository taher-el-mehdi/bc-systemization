table 50304 "Systemization Page"
{
    Caption = 'Systemization Page';
    DataClassification = ToBeClassified;

    fields
    {

        field(1; "Systemization Extension"; Guid)
        {
            Caption = 'Systemization Extension';
            tableRelation = "Systemization Extension".Id;
        }
        field(2; "Systemization Table"; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            validatetablerelation = false;
        }
        field(3; "Page No."; Integer)
        {
            Caption = 'Page No.';
            TableRelation = "Page Metadata".Id where(SourceTable = field("Systemization Table"));
            validatetablerelation = false;

            trigger OnValidate()
            var
                AllObj: Record AllObjWithCaption;
                PageMeta: Record "Page Metadata";
            begin
                if "Page No." = 0 then begin
                    "Page Name" := '';
                    Clear("Page App Package Id");
                    exit;
                end;
                PageMeta.SetLoadFields(Name, SourceTable);
                PageMeta.Get("Page No.");
                "Page Name" := PageMeta.Name;

                AllObj.SetLoadFields("App Package ID");
                AllObj.SetRange("Object Type", AllObj."Object Type"::Page);
                AllObj.SetRange("Object ID", "Page No.");
                AllObj.FindFirst();
                "Page App Package Id" := AllObj."App Package ID";
            end;
        }
        field(4; "Page Name"; Text[250])
        {
            Caption = 'Target Page Name';
            Editable = false;
        }
        field(5; "Page App Package Id"; Guid)
        {
            Caption = 'Target Page App Package Id';
            Editable = false;
        }
        field(6; "Page Ext. Object Id"; Integer)
        {
            Caption = 'Page Extension Object ID';
            MinValue = 50000;
        }
    }
    keys
    {
        key(PK; "Systemization Extension", "Page No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        SystemizationPageField: Record "Systemization Page Field";
    begin
        SystemizationPageField.SetRange("Systemization Extension", Rec."Systemization Extension");
        SystemizationPageField.SetRange("Systemization Page No.", Rec."Page No.");
        if not SystemizationPageField.IsEmpty() then
            SystemizationPageField.DeleteAll(true);
    end;
}
