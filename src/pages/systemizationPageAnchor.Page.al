
page 50310 "systemization Page Anchor"
{
    PageType = List;
    SourceTable = "Page Control Field";
    Editable = false;
    Caption = 'Select Anchor Control';
    ApplicationArea = All;
    SourceTableView = sorting(Sequence);

    layout
    {
        area(Content)
        {
            repeater(Controls)
            {
                field(Sequence; Rec.Sequence)
                {
                    ToolTip = 'Specifies the value of the Sequence field.', Comment = '%';
                }
                field(ControlName; Rec.ControlName)
                {
                    ApplicationArea = All;
                    ToolTip = 'The control name.';
                }
            }
        }
    }
}