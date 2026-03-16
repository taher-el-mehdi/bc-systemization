page 50312 "sytemization Page Field"
{
    PageType = List;
    SourceTable = "Field";
    Editable = false;
    Caption = 'Fields';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Pages)
            {

                field(ID; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.FieldName)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}