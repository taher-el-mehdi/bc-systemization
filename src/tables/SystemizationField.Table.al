table 50302 "Systemization Field"
{
    Caption = 'Systemization Field';
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
        field(5; "Field No."; Integer)
        {
            Caption = 'Field No.';
        }
        field(6; "Field name"; Text[100])
        {
            Caption = 'Field Name';
        }
        field(7; "Field caption"; Text[50])
        {
            Caption = 'Field Caption';
        }
        field(10; "Systemization Type Field"; Enum "Systemization Type Field")
        {
            Caption = 'Field Type';
        }
        field(8; "Field Length"; Integer)
        {
            Caption = 'Field Length';
            MinValue = 0;
        }
        field(9; "Option String"; Text[2048])
        {
            Caption = 'Option String';
        }
    }
    keys
    {
        key(PK; "Systemization Extension", "Systemization Table", "Field No.")
        {
            Clustered = true;
        }
    }
}
