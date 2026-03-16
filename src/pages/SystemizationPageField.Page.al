page 50309 "Systemization Page Field"
{
    ApplicationArea = All;
    Caption = 'Systemization Page Field';
    PageType = Card;
    SourceTable = "Systemization Page Field";
    layout
    {
        area(Content)
        {
            group(FieldInformation)
            {
                Caption = 'Field Information';

                field("Field no."; Rec."Field no.")
                {
                    ApplicationArea = all;
                    Importance = Promoted;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        fieldRec: Record "field";
                    begin
                        fieldRec.SetRange(TableNo, Rec."systemization Table");
                        if Page.RunModal(Page::"sytemization Page Field", fieldRec) = Action::LookupOK then begin
                            Text := Format(fieldRec."No.");
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    var
                        Field: record field;
                    begin
                        if Field.Get(rec."Systemization Table", rec."Field No.") then begin
                            rec."Field Name" := field.FieldName;
                        end;
                    end;
                }
                field("Field name"; Rec."Field name")
                {
                    ApplicationArea = all;
                    Importance = Promoted;
                    ShowMandatory = true;
                }
                field("Type Place"; Rec."Type of Place")
                {
                    ApplicationArea = all;
                    Importance = Promoted;
                    ShowMandatory = true;
                }
                field("Anchor Control"; Rec."Anchor Control")
                {
                    ApplicationArea = all;
                    Importance = Promoted;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PageCtrlField: Record "Page Control Field";
                    begin
                        PageCtrlField.SetRange(PageNo, Rec."Systemization Page No.");
                        if Page.RunModal(Page::"systemization Page Anchor", PageCtrlField) = Action::LookupOK then begin
                            Text := PageCtrlField.ControlName;
                            exit(true);
                        end;
                    end;
                }
            }
        }
    }
}
