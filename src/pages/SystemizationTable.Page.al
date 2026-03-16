page 50302 "Systemization Table"
{
    ApplicationArea = All;
    Caption = 'Systemization Table';
    PageType = Card;
    SourceTable = "Systemization Table";
    layout
    {
        area(Content)
        {
            group(TableInformation)
            {
                Caption = 'Table Information';
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = all;
                    Importance = Promoted;
                    ShowMandatory = true;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = all;
                }
                field("Table Ext. Object Id"; Rec."Table Ext. Object Id")
                {
                    ApplicationArea = all;
                    Importance = Promoted;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        if Rec."Table Ext. Object Id" < 50000 then
                            Error('Table Ext. Object Id must be greater than 50000.');
                    end;
                }
            }

            group(Fields)
            {
                Caption = 'Systemization Fields';

                part(ExtensionFields; "Systemization Fields")
                {
                    ApplicationArea = All;
                    SubPageLink = "Systemization Extension" = field("Systemization Extension"),
                                    "Systemization Table" = field("Table No.");
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateField)
            {
                ApplicationArea = All;
                Caption = 'Add field';
                Image = Add;
                trigger OnAction()
                var
                    new_field: Record "Systemization Field";
                begin
                    if new_field.Get(Rec."Systemization Extension", Rec."Table No.", 0) then
                        Page.Run(Page::"Systemization Field", new_field)
                    else begin
                        new_field.Init();
                        new_field."Systemization Extension" := Rec."Systemization Extension";
                        new_field."Systemization Table" := Rec."Table No.";
                        if new_field.Insert() then
                            Page.Run(Page::"Systemization Field", new_field);
                    end;
                end;
            }
        }
    }
}
