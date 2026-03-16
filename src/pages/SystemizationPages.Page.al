page 50306 "Systemization Pages"
{
    Caption = 'Systemization Pages';
    PageType = ListPart;
    SourceTable = "Systemization Page";
    CardPageId = "Systemization Page";
    InsertAllowed = false;
    ModifyAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Target Page No."; Rec."Page No.")
                {
                    ApplicationArea = all;
                }
                field("Page Name"; Rec."Page Name")
                {
                    ApplicationArea = all;
                }
                field("Page Ext. Object Id"; Rec."Page Ext. Object Id")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}