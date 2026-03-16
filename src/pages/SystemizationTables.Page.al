page 50303 "Systemization Tables"
{
    Caption = 'Systemization Tables';
    PageType = ListPart;
    SourceTable = "Systemization Table";
    CardPageId = "Systemization Table";
    InsertAllowed = false;
    ModifyAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = all;
                }
                field("Table Name"; rec."Table Name")
                {
                    ApplicationArea = all;
                }
                field("Table Ext. Object Id"; Rec."Table Ext. Object Id")
                {
                    ApplicationArea = all;
                }
                field("Systemization fields"; Rec."Systemization fields")
                {
                    applicationArea = all;
                }
            }
        }
    }
}
