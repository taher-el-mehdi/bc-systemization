table 50300 "Systemization Extension"
{
    Caption = 'Systemization Extension';
    DataClassification = ToBeClassified;
    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id';
            Editable = false;
        }
        field(2; "App Name"; Text[100])
        {
            Caption = 'App Name';
        }
        field(3; Publisher; Text[100])
        {
            Caption = 'Publisher';
        }
        field(4; Version; Code[10])
        {
            Caption = 'Version';
        }
        field(5; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(6; "Object Start Id"; Integer)
        {
            Caption = 'Object Start Id';
            MinValue = 0;
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(AppNameKey; "App Name")
        {
        }
    }

    trigger OnInsert()
    var
        empty_guid: Guid;
    begin
        if Rec.Id = empty_guid then begin
            Rec.Id := CreateGuid();
        end;
    end;

    trigger OnDelete()
    var
        SystemizationTable: Record "Systemization Table";
        SystemizationPage: Record "Systemization Page";
    begin
        SystemizationTable.SetRange("Systemization Extension", Rec.Id);
        if not SystemizationTable.IsEmpty() then
            SystemizationTable.DeleteAll(true);

        SystemizationPage.SetRange("Systemization Extension", Rec.Id);
        if not SystemizationPage.IsEmpty() then
            SystemizationPage.DeleteAll(true);
    end;

}
