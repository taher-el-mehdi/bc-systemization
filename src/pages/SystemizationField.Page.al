page 50305 "Systemization Field"
{
    ApplicationArea = All;
    Caption = 'Systemization Field';
    PageType = Card;
    SourceTable = "Systemization Field";
    layout
    {
        area(Content)
        {
            group(FieldInformation)
            {
                Caption = 'Field Information';

                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = all;
                    Importance = Promoted;
                    ShowMandatory = true;
                }
                field("Field name"; Rec."Field name")
                {
                    ApplicationArea = all;
                    Importance = Promoted;
                    ShowMandatory = true;
                }
                field("Field caption"; Rec."Field caption")
                {
                    ApplicationArea = all;
                }
                field("Systemization Type Field"; Rec."Systemization Type Field")
                {
                    ApplicationArea = all;
                    Importance = Promoted;
                    ShowMandatory = true;
                }
                field("Field Length"; Rec."Field Length")
                {
                    ApplicationArea = all;
                }
                field("Option String"; Rec."Option String")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}
