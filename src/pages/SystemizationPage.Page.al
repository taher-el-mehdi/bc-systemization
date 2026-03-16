page 50307 "Systemization Page"
{
    ApplicationArea = All;
    Caption = 'Systemization Page';
    PageType = Card;
    SourceTable = "Systemization Page";
    layout
    {
        area(Content)
        {
            group(PageInformation)
            {
                Caption = 'Page Information';

                field("systemization Table"; Rec."systemization Table")
                {
                    ApplicationArea = all;
                    Importance = Promoted;
                }
                field("Target Page No."; Rec."Page No.")
                {
                    ApplicationArea = all;
                    Importance = Promoted;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PageMeta: Record "Page Metadata";
                    begin
                        PageMeta.SetRange(SourceTable, Rec."systemization Table");
                        if Page.RunModal(Page::"sytemization Page Metadata", PageMeta) = Action::LookupOK then begin
                            Text := Format(PageMeta.ID);
                            exit(true);
                        end;
                    end;
                }
                field("Page Name"; Rec."Page Name")
                {
                    ApplicationArea = all;
                }
                field("Page Ext. Object Id"; Rec."Page Ext. Object Id")
                {
                    ApplicationArea = all;
                    Importance = Promoted;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        if Rec."Page Ext. Object Id" < 50000 then
                            Error('Page Ext. Object Id must be greater than 50000.');
                    end;
                }
            }
            group(PageFields)
            {
                Caption = 'Systemization Page Fields';

                part(ExtensionPageFields; "Systemization Page Fields")
                {
                    ApplicationArea = All;
                    SubPageLink = "Systemization Extension" = field("Systemization Extension"),
                                    "Systemization Page No." = field("Page No.");
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreatePageField)
            {
                ApplicationArea = All;
                Caption = 'Add page field';
                Image = Add;
                trigger OnAction()
                var
                    new_page_field: Record "Systemization Page Field";
                begin
                    if new_page_field.Get(Rec."Systemization Extension", Rec."Page No.", 0) then
                        Page.Run(Page::"Systemization Page Field", new_page_field)
                    else begin
                        new_page_field.Init();
                        new_page_field."Systemization Extension" := Rec."Systemization Extension";
                        new_page_field."Systemization Page No." := Rec."Page No.";
                        new_page_field."Systemization Table" := Rec."Systemization Table";
                        if new_page_field.Insert() then
                            Page.Run(Page::"Systemization Page Field", new_page_field);
                    end;
                end;
            }
        }
    }
}
