page 50300 "Systemization Extensions"
{
    ApplicationArea = All;
    Caption = 'Systemization Extensions';
    PageType = List;
    UsageCategory = Lists;
    CardPageId = "Systemization Extension";
    SourceTable = "Systemization Extension";
    ModifyAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = all;
                }
                field(Publisher; Rec.Publisher)
                {
                    ApplicationArea = all;
                }
                field("Version"; Rec."Version")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}
