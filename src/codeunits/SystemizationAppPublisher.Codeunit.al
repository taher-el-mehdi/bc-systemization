codeunit 50307 "Systemization App Publisher"
{

    /// <summary>
    /// Downloads the generated app package blob to the client.
    /// </summary>
    procedure download_app(var app_package_blob: Codeunit "Temp Blob"; app_name: Text; app_version: Text)
    var
        app_package_stream: InStream;
        download_file_name: Text;
    begin
        if not app_package_blob.HasValue() then
            Error(AppBlobEmptyErr);

        app_package_blob.CreateInStream(app_package_stream);
        download_file_name := build_file_name(app_name, app_version);
        DownloadFromStream(app_package_stream, DownloadDialogTitleLbl, '', AppFileFilterLbl, download_file_name);
    end;

    /// <summary>
    /// Publishes the generated app package blob using Extension Management.
    /// </summary>
    procedure publish_app(var app_package_blob: Codeunit "Temp Blob"): Boolean
    var
        app_package_stream: InStream;
    begin
        if not app_package_blob.HasValue() then
            Error(AppBlobEmptyErr);

        app_package_blob.CreateInStream(app_package_stream);
        if not try_upload_extension(app_package_stream) then
            exit(false);

        exit(true);
    end;

    /// <summary>
    /// Gets the most recent extension deployment status and related error message.
    /// </summary>
    procedure get_deployment_status(var deployment_status_value: Integer; var deployment_error_message: Text)
    var
        extension_management: Codeunit "Extension Management";
        temporary_deployment_status: Record "Extension Deployment Status" temporary;
    begin
        extension_management.GetAllExtensionDeploymentStatusEntries(temporary_deployment_status);
        temporary_deployment_status.SetCurrentKey("Started On");
        temporary_deployment_status.Ascending(false);
        if not temporary_deployment_status.FindFirst() then begin
            deployment_status_value := 0;
            exit;
        end;

        deployment_status_value := temporary_deployment_status.Status;
        if temporary_deployment_status.Status in [temporary_deployment_status.Status::Failed, temporary_deployment_status.Status::NotFound] then
            deployment_error_message := temporary_deployment_status.Description;
    end;

    /// <summary>
    /// Attempts to upload an extension package stream.
    /// </summary>
    [TryFunction]
    local procedure try_upload_extension(app_package_stream: InStream)
    var
        extension_management: Codeunit "Extension Management";
    begin
        extension_management.UploadExtension(app_package_stream, GlobalLanguage());
    end;

    /// <summary>
    /// Builds a safe app file name for download.
    /// </summary>
    local procedure build_file_name(app_name: Text; app_version: Text): Text
    var
        safe_name: Text;
    begin
        safe_name := DelChr(app_name, '=', '/\:*?"<>|');
        if safe_name = '' then
            safe_name := 'Extension';
        exit(safe_name + '_' + app_version + '.app');
    end;

    var
        AppBlobEmptyErr: Label 'The app blob is empty. Generate an app before downloading or publishing.';
        DownloadDialogTitleLbl: Label 'Download Extension';
        AppFileFilterLbl: Label 'App Files (*.app)|*.app';
}
