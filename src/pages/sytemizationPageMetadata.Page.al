page 50311 "sytemization Page Metadata"
{
    PageType = List;
    SourceTable = "Page Metadata";
    Editable = false;
    Caption = 'Page';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Pages)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Caption; Rec.Caption)
                {
                    ToolTip = 'Specifies the value of the Caption field.', Comment = '%';
                }
            }
        }
    }
}