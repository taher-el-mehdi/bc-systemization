codeunit 50300 "Systemization Package Builder"
{

    /// <summary>
    /// Sets app metadata values used during package generation.
    /// </summary>
    procedure set_app_metadata(app_name: Text[100]; publisher_name: Text[100];
        major_version: Integer; minor_version: Integer; build_version: Integer; revision_version: Integer)
    begin
        ANm := app_name;
        APub := publisher_name;
        VMaj := major_version;
        VMin := minor_version;
        VBld := build_version;
        VRev := revision_version;
        MetaSet := true;
    end;

    /// <summary>
    /// Adds a generated source file to the package source collection.
    /// </summary>
    procedure add_source_file(zip_entry_path: Text; var source_blob: Codeunit "Temp Blob")
    var
        source_input_stream: InStream;
        source_builder: TextBuilder;
        source_line_text: Text;
        line_feed: Text[1];
        line_count: Integer;
    begin
        line_feed := get_line_feed();
        source_blob.CreateInStream(source_input_stream, TextEncoding::UTF8);
        line_count := 0;
        while not source_input_stream.EOS() do begin
            source_input_stream.ReadText(source_line_text);
            if line_count > 0 then
                source_builder.Append(line_feed);
            source_builder.Append(source_line_text);
            line_count += 1;
        end;

        SrcPaths.Add(zip_entry_path);
        SrcContents.Add(source_builder.ToText());
    end;

    /// <summary>
    /// Adds a symbol reference fragment to a named symbol section.
    /// </summary>
    procedure add_symbol_reference_fragment(array_name: Text; fragment_object: JsonObject)
    var
        existing_token: JsonToken;
        existing_array: JsonArray;
    begin
        if SRF.Get(array_name, existing_token) then begin
            existing_array := existing_token.AsArray();
            existing_array.Add(fragment_object);
            SRF.Replace(array_name, existing_array);
        end else begin
            Clear(existing_array);
            existing_array.Add(fragment_object);
            SRF.Add(array_name, existing_array);
        end;
    end;

    /// <summary>
    /// Adds an entitlement entry defined by object type code and object id.
    /// </summary>
    procedure add_entitlement_entry(type_code: Integer; object_id: Integer)
    begin
        ETCodes.Add(type_code);
        EObjIds.Add(object_id);
    end;

    /// <summary>
    /// Sets dependency XML override for manifest generation.
    /// </summary>
    procedure set_dependency_xml(dependency_xml: Text)
    begin
        DepXmlOvr := dependency_xml;
    end;

    /// <summary>
    /// Sets application version override.
    /// </summary>
    procedure set_application_version(application_version: Text)
    begin
        AppVerOvr := application_version;
    end;

    /// <summary>
    /// Sets runtime version override.
    /// </summary>
    procedure set_runtime_version(runtime_version: Text)
    begin
        RtVerOvr := runtime_version;
    end;

    /// <summary>
    /// Sets target platform override.
    /// </summary>
    procedure set_target_platform(target_platform: Text)
    begin
        TgtOvr := target_platform;
    end;

    /// <summary>
    /// Sets extension id used for app and package GUID values.
    /// </summary>
    procedure set_extension_id(extension_id: Guid)
    begin
        ExtId := extension_id;
    end;

    /// <summary>
    /// Builds the final app package blob from configured metadata and source fragments.
    /// </summary>
    procedure build(var result_blob: Codeunit "Temp Blob")
    var
        data_compression: Codeunit "Data Compression";
        zip_blob: Codeunit "Temp Blob";
        entry_blob: Codeunit "Temp Blob";
        app_output_stream: OutStream;
        zip_output_stream: OutStream;
        zip_input_stream: InStream;
        app_id: Guid;
        package_id: Guid;
        app_version: Text;
        application_version: Text;
        runtime_version: Text;
        target_platform: Text;
        dependency_xml: Text;
        min_object_id: Integer;
        max_object_id: Integer;
        zip_size: Integer;
        event_context: JsonObject;
        is_handled: Boolean;
        file_index: Integer;
        file_path: Text;
        file_contents: Text;
    begin
        if not MetaSet then
            Error(ErrNoMeta);
        if SrcPaths.Count() = 0 then
            Error(ErrNoSrc);

        // Reuse extension id when provided; otherwise fallback to generated identifiers.
        app_id := resolve_extension_id();
        package_id := app_id;
        app_version := format_version();

        application_version := resolve_application_version();
        runtime_version := resolve_runtime_version();
        target_platform := resolve_target_platform();
        dependency_xml := resolve_dependency_xml();

        calculate_id_range(min_object_id, max_object_id);

        event_context := make_context(app_id, app_version, application_version, runtime_version, target_platform);
        on_before_build_app(event_context, is_handled);
        if is_handled then
            exit;

        // Build all package entries into a ZIP payload first.
        data_compression.CreateZipArchive();

        Clear(entry_blob);
        CGen.generate_manifest(app_id, ANm, APub, app_version, application_version, runtime_version, target_platform, min_object_id, max_object_id, dependency_xml, entry_blob);
        add_to_zip(data_compression, 'NavxManifest.xml', entry_blob);

        Clear(entry_blob);
        CGen.generate_content_types(entry_blob);
        add_to_zip(data_compression, '[Content_Types].xml', entry_blob);

        Clear(entry_blob);
        CGen.generate_doc_comments(app_id, ANm, APub, app_version, entry_blob);
        add_to_zip(data_compression, 'DocComments.xml', entry_blob);

        Clear(entry_blob);
        CGen.generate_navigation(entry_blob);
        add_to_zip(data_compression, 'navigation.xml', entry_blob);

        Clear(entry_blob);
        CGen.generate_media_id_listing(entry_blob);
        add_to_zip(data_compression, 'MediaIdListing.xml', entry_blob);

        // Add generated AL source files collected from builders.
        for file_index := 1 to SrcPaths.Count() do begin
            SrcPaths.Get(file_index, file_path);
            SrcContents.Get(file_index, file_contents);
            Clear(entry_blob);
            text_to_blob(file_contents, entry_blob);
            add_to_zip(data_compression, file_path, entry_blob);
        end;

        // Extension point: subscribers can add extra generated files.
        on_collect_additional_files(data_compression, SRF, event_context);

        Clear(entry_blob);
        CGen.generate_symbol_reference(app_id, ANm, APub, app_version, runtime_version, SRF, entry_blob);
        add_to_zip(data_compression, 'SymbolReference.json', entry_blob);

        Clear(entry_blob);
        CGen.generate_entitlement(app_id, ETCodes, EObjIds, entry_blob);
        add_to_zip(data_compression, CGen.get_entitlement_path(app_id), entry_blob);

        // Final packaging step:
        // 1) Save ZIP to temporary blob
        // 2) Write NAVX header
        // 3) Append ZIP stream after header
        zip_blob.CreateOutStream(zip_output_stream);
        data_compression.SaveZipArchive(zip_output_stream);
        data_compression.CloseZipArchive();
        zip_size := zip_blob.Length();

        result_blob.CreateOutStream(app_output_stream);
        BW.write_navx_header(app_output_stream, package_id, zip_size);
        zip_blob.CreateInStream(zip_input_stream);
        CopyStream(app_output_stream, zip_input_stream);

        on_after_build_app(result_blob, event_context);
    end;

    /// <summary>
    /// Resets internal builder state.
    /// </summary>
    procedure reset()
    begin
        Clear(SrcPaths);
        Clear(SrcContents);
        Clear(SRF);
        Clear(ETCodes);
        Clear(EObjIds);
        Clear(ANm);
        Clear(APub);
        Clear(VMaj);
        Clear(VMin);
        Clear(VBld);
        Clear(VRev);
        Clear(AppVerOvr);
        Clear(RtVerOvr);
        Clear(TgtOvr);
        Clear(DepXmlOvr);
        Clear(ExtId);
        MetaSet := false;
    end;

    /// <summary>
    /// Event fired before build starts.
    /// </summary>
    [IntegrationEvent(false, false)]
    local procedure on_before_build_app(context_json: JsonObject; var is_handled: Boolean)
    begin
    end;

    /// <summary>
    /// Event fired to collect additional files to include in the package.
    /// </summary>
    [IntegrationEvent(false, false)]
    local procedure on_collect_additional_files(
        var data_compression: Codeunit "Data Compression";
        var symbol_reference_fragments: JsonObject;
        context_json: JsonObject)
    begin
    end;

    /// <summary>
    /// Event fired after build completes.
    /// </summary>
    [IntegrationEvent(false, false)]
    local procedure on_after_build_app(var app_blob: Codeunit "Temp Blob"; context_json: JsonObject)
    begin
    end;

    /// <summary>
    /// Formats stored version parts into dotted version text.
    /// </summary>
    local procedure format_version(): Text
    begin
        exit(StrSubstNo('%1.%2.%3.%4', VMaj, VMin, VBld, VRev));
    end;

    /// <summary>
    /// Resolves application version using override or environment value.
    /// </summary>
    local procedure resolve_application_version(): Text
    begin
        if AppVerOvr <> '' then
            exit(AppVerOvr);
        exit(ER.get_application_version());
    end;

    /// <summary>
    /// Resolves runtime version using override or environment value.
    /// </summary>
    local procedure resolve_runtime_version(): Text
    begin
        if RtVerOvr <> '' then
            exit(RtVerOvr);
        exit(ER.get_runtime_version());
    end;

    /// <summary>
    /// Resolves target platform using override or environment value.
    /// </summary>
    local procedure resolve_target_platform(): Text
    begin
        if TgtOvr <> '' then
            exit(TgtOvr);
        exit(ER.get_target_platform());
    end;

    /// <summary>
    /// Resolves dependency XML using override or default empty dependencies.
    /// </summary>
    local procedure resolve_dependency_xml(): Text
    begin
        if DepXmlOvr <> '' then
            exit(DepXmlOvr);
        exit('<Dependencies />');
    end;

    /// <summary>
    /// Resolves extension id for packaging identifiers.
    /// </summary>
    local procedure resolve_extension_id(): Guid
    var
        empty_guid: Guid;
    begin
        if ExtId <> empty_guid then
            exit(ExtId);
        exit(CreateGuid());
    end;

    /// <summary>
    /// Calculates min and max object ids from entitlement entries.
    /// </summary>
    local procedure calculate_id_range(var min_object_id: Integer; var max_object_id: Integer)
    var
        current_object_id: Integer;
        entry_index: Integer;
    begin
        if EObjIds.Count() = 0 then begin
            min_object_id := 50100;
            max_object_id := 50199;
            exit;
        end;

        EObjIds.Get(1, min_object_id);
        max_object_id := min_object_id;

        for entry_index := 2 to EObjIds.Count() do begin
            EObjIds.Get(entry_index, current_object_id);
            if current_object_id < min_object_id then
                min_object_id := current_object_id;
            if current_object_id > max_object_id then
                max_object_id := current_object_id;
        end;
    end;

    /// <summary>
    /// Builds context JSON used for build events and telemetry-style payloads.
    /// </summary>
    local procedure make_context(app_id: Guid; app_version: Text;
        application_version: Text; runtime_version: Text; target_platform: Text): JsonObject
    var
        context_json: JsonObject;
    begin
        context_json.Add('AppId', Format(app_id, 0, 9));
        context_json.Add('AppName', ANm);
        context_json.Add('Publisher', APub);
        context_json.Add('AppVersion', app_version);
        context_json.Add('ApplicationVersion', application_version);
        context_json.Add('RuntimeVersion', runtime_version);
        context_json.Add('TargetPlatform', target_platform);
        context_json.Add('SourceFileCount', SrcPaths.Count());
        context_json.Add('EntitlementCount', ETCodes.Count());
        exit(context_json);
    end;

    /// <summary>
    /// Adds a blob as a file entry to the ZIP package stream.
    /// </summary>
    local procedure add_to_zip(var data_compression: Codeunit "Data Compression"; entry_path: Text; var temp_blob: Codeunit "Temp Blob")
    var
        entry_input_stream: InStream;
    begin
        temp_blob.CreateInStream(entry_input_stream);
        data_compression.AddEntry(entry_input_stream, entry_path);
    end;

    /// <summary>
    /// Writes text content to a UTF-8 temporary blob.
    /// </summary>
    local procedure text_to_blob(content_text: Text; var temp_blob: Codeunit "Temp Blob")
    var
        output_stream: OutStream;
    begin
        temp_blob.CreateOutStream(output_stream, TextEncoding::UTF8);
        output_stream.WriteText(content_text);
    end;

    /// <summary>
    /// Returns a line feed character used by text builders.
    /// </summary>
    local procedure get_line_feed(): Text[1]
    var
        line_feed: Text[1];
    begin
        line_feed := ' ';
        line_feed[1] := 10;
        exit(line_feed);
    end;

    var
        CGen: Codeunit "Systemization Artifact Builder";
        BW: Codeunit "Systemization Navx Writer";
        ER: Codeunit "Systemization Environment";
        SrcPaths: List of [Text];
        SrcContents: List of [Text];
        SRF: JsonObject;
        ETCodes: List of [Integer];
        EObjIds: List of [Integer];
        ANm: Text[100];
        APub: Text[100];
        VMaj: Integer;
        VMin: Integer;
        VBld: Integer;
        VRev: Integer;
        AppVerOvr: Text;
        RtVerOvr: Text;
        TgtOvr: Text;
        DepXmlOvr: Text;
        ExtId: Guid;
        MetaSet: Boolean;
        ErrNoMeta: Label 'Call set_app_metadata() before build().', Locked = true;
        ErrNoSrc: Label 'Add at least one source file before calling build().', Locked = true;

}
