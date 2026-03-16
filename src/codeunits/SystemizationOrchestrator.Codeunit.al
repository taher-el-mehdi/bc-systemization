codeunit 50308 "Systemization Orchestrator"
{
    /// <summary>
    /// Generates an extension package from Systemization setup and field definitions.
    /// </summary>
    procedure systemization_generator(var systemization_extension: Record "Systemization Extension"): Boolean
    var
        systemization_tables: Record "Systemization Table";
        systemization_fields: Record "Systemization Field";
        systemization_pages: Record "Systemization Page";
        systemization_page_fields: Record "Systemization Page Field";
        table_ext_builder: Codeunit "Systemization Table Builder";
        page_ext_builder: Codeunit "Systemization Page Builder";
        app_builder: Codeunit "Systemization Package Builder";
        env_resolver: Codeunit "Systemization Environment";
        table_ext_source: Codeunit "Temp Blob";
        page_ext_source: Codeunit "Temp Blob";
        table_ext_sym_ref: JsonObject;
        page_ext_sym_ref: JsonObject;
        version_major: Integer;
        version_minor: Integer;
        version_build: Integer;
        version_revision: Integer;
        dependency_package_id: Guid;
        empty_guid: Guid;
        has_tables: Boolean;
        has_pages: Boolean;
    begin
        app_builder.reset();
        parse_version(systemization_extension.Version, version_major, version_minor, version_build, version_revision);
        app_builder.set_app_metadata(systemization_extension."App Name", systemization_extension.Publisher,
            version_major, version_minor, version_build, version_revision);
        app_builder.set_extension_id(systemization_extension.Id);

        systemization_tables.Reset();
        systemization_tables.SetRange("Systemization Extension", systemization_extension.Id);
        if systemization_tables.FindSet() then;
        has_tables := systemization_tables.Count() > 0;
        if has_tables then
            repeat
                if (dependency_package_id = empty_guid) and (systemization_tables."Table App Package Id" <> empty_guid) then
                    dependency_package_id := systemization_tables."Table App Package Id";

                table_ext_builder.reset();
                table_ext_builder.set_target(systemization_tables."Table No.", systemization_tables."Table Name", systemization_tables."Table App Package Id");
                table_ext_builder.set_object_id(systemization_tables."Table Ext. Object Id");

                systemization_fields.Reset();
                systemization_fields.SetRange("Systemization Extension", systemization_extension.Id);
                systemization_fields.SetRange("Systemization Table", systemization_tables."Table No.");
                if not systemization_fields.FindSet() then
                    Error('No Systemization Fields defined for table %1.', systemization_tables."Table Name");

                repeat
                    table_ext_builder.add_field(
                        systemization_fields."Field No.",
                        systemization_fields."Field name",
                        systemization_fields."Systemization Type Field",
                        systemization_fields."Field Length",
                        systemization_fields."Option String");
                until systemization_fields.Next() = 0;

                table_ext_builder.generate_source(table_ext_source);
                table_ext_sym_ref := table_ext_builder.generate_symbol_reference();
                app_builder.add_source_file(table_ext_builder.get_source_file_path(), table_ext_source);
                app_builder.add_symbol_reference_fragment('TableExtensions', table_ext_sym_ref);
                app_builder.add_entitlement_entry(
                    table_ext_builder.get_entitlement_type_code(), table_ext_builder.get_object_id());
            until systemization_tables.Next() = 0;

        systemization_pages.Reset();
        systemization_pages.SetRange("Systemization Extension", systemization_extension.Id);
        if systemization_pages.FindSet() then;
        has_pages := systemization_pages.Count() > 0;
        if has_pages then
            repeat
                if (dependency_package_id = empty_guid) and (systemization_pages."Page App Package Id" <> empty_guid) then
                    dependency_package_id := systemization_pages."Page App Package Id";

                page_ext_builder.reset();
                page_ext_builder.set_target(systemization_pages."Page No.", systemization_pages."Page Name", systemization_pages."Page App Package Id");
                page_ext_builder.set_object_id(systemization_pages."Page Ext. Object Id");

                systemization_page_fields.Reset();
                systemization_page_fields.SetRange("Systemization Extension", systemization_extension.Id);
                systemization_page_fields.SetRange("Systemization Page No.", systemization_pages."Page No.");
                if not systemization_page_fields.FindSet() then
                    Error('No Systemization Page Fields defined for page %1.', systemization_pages."Page Name");

                repeat
                    page_ext_builder.add_field(
                        systemization_page_fields."Field name",
                        systemization_page_fields."Source Expression",
                        systemization_page_fields."Type of Place",
                        systemization_page_fields."Anchor Control");
                until systemization_page_fields.Next() = 0;

                page_ext_builder.generate_source(page_ext_source);
                page_ext_sym_ref := page_ext_builder.generate_symbol_reference();
                app_builder.add_source_file(page_ext_builder.get_source_file_path(), page_ext_source);
                app_builder.add_symbol_reference_fragment('PageExtensions', page_ext_sym_ref);
                app_builder.add_entitlement_entry(
                    page_ext_builder.get_entitlement_type_code(), page_ext_builder.get_object_id());
            until systemization_pages.Next() = 0;

        if not has_tables and not has_pages then
            Error('Define at least one Systemization Table or one Systemization Page for extension %1.', systemization_extension."App Name");

        app_builder.set_dependency_xml(
            env_resolver.build_dependency_xml(dependency_package_id));

        Clear(app_package_blob);
        app_builder.build(app_package_blob);
        exit(true);
    end;

    /// <summary>
    /// Downloads the generated extension package for the provided setup record.
    /// </summary>
    procedure download_app(var systemization_extension: Record "Systemization Extension")
    var
        app_publisher: Codeunit "Systemization App Publisher";
    begin
        app_publisher.download_app(app_package_blob, systemization_extension."App Name", systemization_extension.Version);
    end;

    /// <summary>
    /// Publishes the generated extension package for the provided setup record.
    /// </summary>
    procedure publish_app(var systemization_extension: Record "Systemization Extension"): Boolean
    var
        app_publisher: Codeunit "Systemization App Publisher";
    begin
        exit(app_publisher.publish_app(app_package_blob));
    end;

    /// <summary>
    /// Opens the extension deployment status page.
    /// </summary>
    procedure open_deployment_status(var deployment_notification: Notification)
    begin
        Page.Run(Page::"Extension Deployment Status");
    end;

    /// <summary>
    /// Parses a dotted version string into major, minor, build, and revision integers.
    /// </summary>
    local procedure parse_version(version_text: Text; var major: Integer; var minor: Integer; var build: Integer; var revision: Integer)
    var
        work: Text;
        part: Text;
        pos: Integer;
    begin
        // Defensive parsing: missing segments default to zero.
        work := version_text;
        major := 0;
        minor := 0;
        build := 0;
        revision := 0;

        // Segment 1: major
        pos := StrPos(work, '.');
        if pos = 0 then begin
            Evaluate(major, work);
            exit;
        end;
        part := CopyStr(work, 1, pos - 1);
        Evaluate(major, part);
        work := CopyStr(work, pos + 1);

        // Segment 2: minor
        pos := StrPos(work, '.');
        if pos = 0 then begin
            Evaluate(minor, work);
            exit;
        end;
        part := CopyStr(work, 1, pos - 1);
        Evaluate(minor, part);
        work := CopyStr(work, pos + 1);

        // Segment 3: build
        pos := StrPos(work, '.');
        if pos = 0 then begin
            Evaluate(build, work);
            exit;
        end;
        part := CopyStr(work, 1, pos - 1);
        Evaluate(build, part);
        work := CopyStr(work, pos + 1);

        // Segment 4: revision
        Evaluate(revision, work);
    end;

    var
        app_package_blob: Codeunit "Temp Blob";
}
