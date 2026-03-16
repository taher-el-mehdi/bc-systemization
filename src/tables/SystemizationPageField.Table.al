table 50303 "Systemization Page Field"
{
    Caption = 'Systemization Page Field';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Systemization Extension"; Guid)
        {
            Caption = 'Systemization Extension';
            TableRelation = "Systemization Extension".Id;
        }
        field(2; "Systemization Table"; Integer)
        {
            Caption = 'Table No.';
            TableRelation = "Systemization Table"."Table No.";
            validatetablerelation = false;
        }
        field(3; "Systemization Page No."; Integer)
        {
            Caption = 'Target Page No.';
            TableRelation = "Systemization Page"."Page No.";
            validatetablerelation = false;
        }
        field(4; "Field No."; integer)
        {
            Caption = 'Field No.';
            TableRelation = Field."No." where(TableNo = field("Systemization Table"));
            trigger OnValidate()
            var
                Field: record field;
            begin
                if Field.Get("Systemization Table", "Field No.") then begin
                    "Field Name" := field.FieldName;
                    exit;
                end;
            end;
        }
        field(5; "Field name"; Text[100])
        {
            Caption = 'Field Name';
            Editable = false;
        }
        field(6; "Type of Place"; Enum "Systemization Type Place")
        {
            Caption = 'Placement';
        }
        field(7; "Anchor Control"; Text[120])
        {
            Caption = 'Anchor Control';
            TableRelation = "Page Control Field".ControlName;
            validatetablerelation = false;
        }
        field(8; "Source Expression"; Text[250])
        {
            Caption = 'Source Expression';
        }
    }

    keys
    {
        key(PK; "Systemization Extension", "Systemization Table", "Systemization Page No.", "Field No.")
        {
            Clustered = true;
        }
    }
}