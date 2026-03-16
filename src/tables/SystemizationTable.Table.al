table 50301 "Systemization Table"
{
    Caption = 'Systemization Table';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Systemization Extension"; Guid)
        {
            Caption = 'Systemization Extension';
            tableRelation = "Systemization Extension".Id;
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            validatetablerelation = false;
            trigger OnValidate()
            var
                AllObj: Record AllObjWithCaption;
            begin
                if "Table No." = 0 then begin
                    "Table Name" := '';
                    Clear("Table App Package Id");
                    exit;
                end;
                AllObj.SetLoadFields("Object Name", "App Package ID");
                AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
                AllObj.SetRange("Object ID", "Table No.");
                AllObj.FindFirst();
                "Table Name" := AllObj."Object Name";
                "Table App Package Id" := AllObj."App Package ID";
            end;
        }
        field(3; "Table Name"; Text[30])
        {
            Caption = 'Table Name';
            editable = false;
        }
        field(4; "Table Ext. Object Id"; Integer)
        {
            Caption = 'Table Extension Object ID';
            MinValue = 50000;
        }
        field(5; "Table App Package Id"; Guid)
        {
            Caption = 'Table App Package Id';
            Editable = false;
        }
        field(6; "Systemization fields"; integer)
        {
            Caption = 'Fields';
            FieldClass = flowfield;
            CalcFormula = Count("Systemization Field" where("Systemization Extension" = field("Systemization Extension"), "Systemization Table" = field("Table No.")));
        }
    }
    keys
    {
        key(PK; "Systemization Extension", "Table No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        SystemizationField: Record "Systemization Field";
    begin
        SystemizationField.SetRange("Systemization Extension", Rec."Systemization Extension");
        SystemizationField.SetRange("Systemization Table", Rec."Table No.");
        if not SystemizationField.IsEmpty() then
            SystemizationField.DeleteAll(true);
    end;
}
