page 50301 "Systemization Extension"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'Systemization Extension';
    SourceTable = "Systemization Extension";
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(Id; Rec.Id)
                {
                    ToolTip = 'Unique identifier used as the technical primary key.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("App Name"; Rec."App Name")
                {
                    ToolTip = 'The name for the generated extension.';
                    ApplicationArea = All;
                }
                field(Publisher; Rec.Publisher)
                {
                    ToolTip = 'The publisher name for the generated extension.';
                    ApplicationArea = All;
                }
                field("Version"; Rec."Version")
                {
                    ToolTip = 'Extension version (e.g. 1.0.0.0).';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'A short description for the generated extension.';
                    ApplicationArea = All;
                }
                field("Object Start Id"; Rec."Object Start Id")
                {
                    ToolTip = 'Optional starting object ID for generated objects.';
                }
            }

            group(Tables)
            {
                Caption = 'Systemization Tables';

                part(ExtensionTables; "Systemization Tables")
                {
                    ApplicationArea = All;
                    SubPageLink = "Systemization Extension" = field(Id);
                }
            }
            group(Pages)
            {
                Caption = 'Systemization Pages';

                part(ExtensionPages; "Systemization Pages")
                {
                    ApplicationArea = All;
                    SubPageLink = "Systemization Extension" = field(Id);
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(CreateFields)
            {
                ApplicationArea = All;
                Caption = 'Add Field in Table';
                Image = Addresses;
                trigger OnAction()
                var
                    SystemizationTable: Record "Systemization Table";
                    SystemizationTableRec: Record "Systemization Table";
                begin
                    if SystemizationTable.Get(Rec.Id, 0) then
                        Page.Run(Page::"Systemization Table", SystemizationTable)
                    else begin

                        SystemizationTable.Init();
                        SystemizationTable."Systemization Extension" := Rec.Id;
                        SystemizationTable."Table Ext. Object Id" := Rec."Object Start Id";

                        SystemizationTableRec.reset();
                        SystemizationTableRec.SetRange("Systemization Extension", Rec.Id);
                        if SystemizationTableRec.Findset() then
                            SystemizationTable."Table Ext. Object Id" += SystemizationTableRec.Count();

                        if SystemizationTable.Insert() then
                            PAGE.Run(PAGE::"Systemization Table", SystemizationTable);
                    end;
                end;
            }
            action(ShowFields)
            {
                ApplicationArea = All;
                Caption = 'Add Field in Page';
                Image = AddContacts;
                trigger OnAction()
                var
                    systemization_page: Record "Systemization Page";
                    SystemizationTableRec: Record "Systemization Table";
                begin
                    if systemization_page.get(Rec.Id, 0) then
                        Page.Run(Page::"Systemization Page", systemization_page)
                    else begin
                        systemization_page.Init();
                        systemization_page."Systemization Extension" := Rec.Id;
                        systemization_page."Page Ext. Object Id" := Rec."Object Start Id";

                        SystemizationTableRec.reset();
                        SystemizationTableRec.SetRange("Systemization Extension", Rec.Id);
                        if SystemizationTableRec.Findset() then
                            systemization_page."Page Ext. Object Id" += SystemizationTableRec.Count();

                        if systemization_page.Insert() then
                            PAGE.Run(PAGE::"Systemization Page", systemization_page);
                    end;
                end;
            }
            action(DownloadApp)
            {
                ApplicationArea = All;
                Caption = 'Download App';
                InFooterBar = true;
                Image = Export;
                trigger OnAction()
                begin
                    if SystemizationOrchestrator.systemization_generator(Rec) then
                        SystemizationOrchestrator.download_app(Rec)
                    else
                        Error('App generation failed: %1', GetLastErrorText());
                end;
            }
            action(PublishApp)
            {
                ApplicationArea = All;
                Caption = 'Publish App';
                InFooterBar = true;
                Image = Apply;
                trigger OnAction()
                var
                    DeploymentNotification: Notification;
                    PublishInitiatedMsg: Label 'Extension upload initiated. check progress the progress here:';
                    PublishFailedErr: Label 'Publish failed: %1', Comment = '%1 = Error message';
                    ViewDeploymentStatusLbl: Label 'Deployment Status';
                begin
                    SystemizationOrchestrator.systemization_generator(Rec);
                    if SystemizationOrchestrator.publish_app(Rec) then begin
                        DeploymentNotification.Message(PublishInitiatedMsg);
                        DeploymentNotification.Scope(NotificationScope::LocalScope);
                        DeploymentNotification.AddAction(ViewDeploymentStatusLbl,
                            Codeunit::"Systemization Orchestrator", 'open_deployment_status');
                        DeploymentNotification.Send();
                    end else
                        Error(PublishFailedErr, GetLastErrorText());
                end;
            }
        }
    }
    var
        SystemizationOrchestrator: Codeunit "Systemization Orchestrator";
}
