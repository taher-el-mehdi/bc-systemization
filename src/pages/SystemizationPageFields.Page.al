page 50308 "Systemization Page Fields"
{
    Caption = 'Systemization Page Fields';
    PageType = ListPart;
    SourceTable = "Systemization Page Field";
    CardPageId = "Systemization Page Field";
    InsertAllowed = false;
    ModifyAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Field name"; Rec."Field name")
                {
                    ApplicationArea = all;
                }
                field("Type Place"; Rec."Type of Place")
                {
                    ApplicationArea = all;
                }
                field("Anchor Control"; Rec."Anchor Control")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}
