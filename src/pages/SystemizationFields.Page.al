page 50304 "Systemization Fields"
{
    Caption = 'Systemization Fields';
    PageType = ListPart;
    SourceTable = "Systemization Field";
    CardPageId = "Systemization Field";
    InsertAllowed = false;
    ModifyAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = all;
                }
                field("Field name"; Rec."Field name")
                {
                    ApplicationArea = all;
                }
                field("Systemization Type Field"; Rec."Systemization Type Field")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}
