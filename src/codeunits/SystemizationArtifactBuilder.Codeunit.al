codeunit 50306 "Systemization Artifact Builder"
{
    /// <summary>
    /// Generates NavxManifest.xml content for the output package.
    /// </summary>
    procedure generate_manifest(app_id: Guid; app_name: Text; publisher_name: Text; app_version: Text;
     application_version: Text; runtime_version: Text; target_platform: Text;
     min_object_id: Integer; max_object_id: Integer; dependency_xml: Text;
     var temp_blob: Codeunit "Temp Blob")
    var
        output_stream: OutStream;
        manifest_builder: TextBuilder;
        line_feed: Text[1];
        app_id_text: Text;
        timestamp_text: Text;
    begin
        line_feed := get_line_feed();
        app_id_text := format_guid(app_id);
        timestamp_text := Format(CurrentDateTime, 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>.0000000Z');

        manifest_builder.Append('<Package xmlns="http://schemas.microsoft.com/navx/2015/manifest">');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('  <App Id="');
        manifest_builder.Append(app_id_text);
        manifest_builder.Append('" Name="');
        manifest_builder.Append(app_name);
        manifest_builder.Append('" Publisher="');
        manifest_builder.Append(publisher_name);
        manifest_builder.Append('" Brief="');
        manifest_builder.Append(app_name);
        manifest_builder.Append('" Description="');
        manifest_builder.Append(app_name);
        manifest_builder.Append('" Version="');
        manifest_builder.Append(app_version);
        manifest_builder.Append('" CompatibilityId="0.0.0.0"');
        manifest_builder.Append(' PrivacyStatement="" EULA="" Help="" HelpBaseUrl="" Url="" Logo=""');
        manifest_builder.Append(' Platform="1.0.0.0"');
        manifest_builder.Append(' Application="');
        manifest_builder.Append(application_version);
        manifest_builder.Append('" Runtime="');
        manifest_builder.Append(runtime_version);
        manifest_builder.Append('" Target="');
        manifest_builder.Append(target_platform);
        manifest_builder.Append('" ShowMyCode="True" />');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('  <IdRanges>');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('    <IdRange MinObjectId="');
        manifest_builder.Append(Format(min_object_id));
        manifest_builder.Append('" MaxObjectId="');
        manifest_builder.Append(Format(max_object_id));
        manifest_builder.Append('" />');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('  </IdRanges>');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('  ');
        manifest_builder.Append(dependency_xml);
        manifest_builder.Append(line_feed);
        manifest_builder.Append('  <InternalsVisibleTo />');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('  <ScreenShots />');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('  <SupportedLocales />');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('  <Features>');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('    <Feature>NOIMPLICITWITH</Feature>');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('    <Feature>NOPROMOTEDACTIONPROPERTIES</Feature>');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('  </Features>');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('  <PreprocessorSymbols />');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('  <SuppressWarnings />');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('  <ResourceExposurePolicy AllowDebugging="true" AllowDownloadingSource="true"');
        manifest_builder.Append(' IncludeSourceInSymbolFile="true" ApplyToDevExtension="false" />');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('  <KeyVaultUrls />');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('  <Source />');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('  <Build By="AL Runtime Compiler,1.0.0" Timestamp="');
        manifest_builder.Append(timestamp_text);
        manifest_builder.Append('" CompilerVersion="');
        manifest_builder.Append(runtime_version);
        manifest_builder.Append('.0.0" />');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('  <AlternateIds />');
        manifest_builder.Append(line_feed);
        manifest_builder.Append('</Package>');

        temp_blob.CreateOutStream(output_stream, TextEncoding::UTF8);
        output_stream.WriteText(manifest_builder.ToText());
    end;

    /// <summary>
    /// Generates [Content_Types].xml content for the package.
    /// </summary>
    procedure generate_content_types(var temp_blob: Codeunit "Temp Blob")
    var
        output_stream: OutStream;
        content_types_builder: TextBuilder;
    begin
        content_types_builder.Append('<?xml version="1.0" encoding="utf-8"?>');
        content_types_builder.Append('<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">');
        content_types_builder.Append('<Default Extension="xml" ContentType="" />');
        content_types_builder.Append('<Default Extension="al" ContentType="" />');
        content_types_builder.Append('<Default Extension="json" ContentType="" />');
        content_types_builder.Append('</Types>');

        temp_blob.CreateOutStream(output_stream, TextEncoding::UTF8);
        write_bom(output_stream);
        output_stream.WriteText(content_types_builder.ToText());
    end;

    /// <summary>
    /// Generates SymbolReference.json content from collected fragments.
    /// </summary>
    procedure generate_symbol_reference(app_id: Guid; app_name: Text; publisher_name: Text;
        app_version: Text; runtime_version: Text;
        symbol_fragments: JsonObject;
        var temp_blob: Codeunit "Temp Blob")
    var
        output_stream: OutStream;
        root_json: JsonObject;
        namespaces: JsonArray;
        namespace_object: JsonObject;
    begin
        namespace_object := build_namespace_object(symbol_fragments);
        namespaces.Add(namespace_object);

        root_json.Add('RuntimeVersion', runtime_version);
        root_json.Add('Namespaces', namespaces);
        add_json_array(root_json, 'Codeunits', symbol_fragments);
        add_json_array(root_json, 'Reports', symbol_fragments);
        add_json_array(root_json, 'XmlPorts', symbol_fragments);
        add_json_array(root_json, 'Queries', symbol_fragments);
        add_json_array(root_json, 'ControlAddIns', symbol_fragments);
        add_json_array(root_json, 'EnumTypes', symbol_fragments);
        add_json_array(root_json, 'DotNetPackages', symbol_fragments);
        add_json_array(root_json, 'Interfaces', symbol_fragments);
        add_json_array(root_json, 'PermissionSets', symbol_fragments);
        add_json_array(root_json, 'PermissionSetExtensions', symbol_fragments);
        add_json_array(root_json, 'ReportExtensions', symbol_fragments);
        add_json_array(root_json, 'TableExtensions', symbol_fragments);
        add_json_array(root_json, 'PageExtensions', symbol_fragments);
        add_empty_json_array(root_json, 'InternalsVisibleToModules');
        root_json.Add('AppId', format_guid(app_id));
        root_json.Add('Name', app_name);
        root_json.Add('Publisher', publisher_name);
        root_json.Add('Version', app_version);

        temp_blob.CreateOutStream(output_stream, TextEncoding::UTF8);
        write_bom(output_stream);
        root_json.WriteTo(output_stream);
    end;

    /// <summary>
    /// Generates DocComments.xml content.
    /// </summary>
    procedure generate_doc_comments(app_id: Guid; app_name: Text; publisher_name: Text;
        app_version: Text; var temp_blob: Codeunit "Temp Blob")
    var
        output_stream: OutStream;
        documentation_builder: TextBuilder;
        line_feed: Text[1];
    begin
        line_feed := get_line_feed();

        documentation_builder.Append('<?xml version="1.0"?>');
        documentation_builder.Append(line_feed);
        documentation_builder.Append('<doc>');
        documentation_builder.Append(line_feed);
        documentation_builder.Append('    <application>');
        documentation_builder.Append(line_feed);
        documentation_builder.Append('        <id>');
        documentation_builder.Append(format_guid(app_id));
        documentation_builder.Append('</id>');
        documentation_builder.Append(line_feed);
        documentation_builder.Append('        <name>');
        documentation_builder.Append(app_name);
        documentation_builder.Append('</name>');
        documentation_builder.Append(line_feed);
        documentation_builder.Append('        <publisher>');
        documentation_builder.Append(publisher_name);
        documentation_builder.Append('</publisher>');
        documentation_builder.Append(line_feed);
        documentation_builder.Append('        <version>');
        documentation_builder.Append(app_version);
        documentation_builder.Append('</version>');
        documentation_builder.Append(line_feed);
        documentation_builder.Append('    </application>');
        documentation_builder.Append(line_feed);
        documentation_builder.Append('    <members />');
        documentation_builder.Append(line_feed);
        documentation_builder.Append('</doc>');
        documentation_builder.Append(line_feed);

        temp_blob.CreateOutStream(output_stream, TextEncoding::UTF8);
        output_stream.WriteText(documentation_builder.ToText());
    end;

    /// <summary>
    /// Generates navigation.xml content.
    /// </summary>
    procedure generate_navigation(var temp_blob: Codeunit "Temp Blob")
    var
        output_stream: OutStream;
        navigation_builder: TextBuilder;
    begin
        initialize_crlf();

        navigation_builder.Append('<?xml version="1.0" encoding="utf-8"?>');
        navigation_builder.Append(carriage_return_line_feed);
        navigation_builder.Append('<NavigationDefinition xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"');
        navigation_builder.Append(' xmlns:xsd="http://www.w3.org/2001/XMLSchema"');
        navigation_builder.Append(' xmlns="urn:schemas-microsoft-com:dynamics:NAV:MetaObjects">');
        navigation_builder.Append(carriage_return_line_feed);
        navigation_builder.Append('  <ActionContainers ActionContainerType="Departments" />');
        navigation_builder.Append(carriage_return_line_feed);
        navigation_builder.Append('</NavigationDefinition>');

        temp_blob.CreateOutStream(output_stream, TextEncoding::UTF8);
        write_bom(output_stream);
        output_stream.WriteText(navigation_builder.ToText());
    end;

    /// <summary>
    /// Generates MediaIdListing.xml content.
    /// </summary>
    procedure generate_media_id_listing(var temp_blob: Codeunit "Temp Blob")
    var
        output_stream: OutStream;
        media_listing_builder: TextBuilder;
    begin
        initialize_crlf();

        media_listing_builder.Append('<MediaIdListing xmlns="http://schemas.microsoft.com/navx/2016/mediaidlisting">');
        media_listing_builder.Append(carriage_return_line_feed);
        media_listing_builder.Append('  <MediaSetIds />');
        media_listing_builder.Append(carriage_return_line_feed);
        media_listing_builder.Append('</MediaIdListing>');

        temp_blob.CreateOutStream(output_stream, TextEncoding::UTF8);
        write_bom(output_stream);
        output_stream.WriteText(media_listing_builder.ToText());
    end;

    /// <summary>
    /// Generates entitlement XML content.
    /// </summary>
    procedure generate_entitlement(app_id: Guid;
        type_codes: List of [Integer]; object_ids: List of [Integer];
        var temp_blob: Codeunit "Temp Blob")
    var
        output_stream: OutStream;
        entitlement_builder: TextBuilder;
        entry_index: Integer;
        object_type_code: Integer;
        object_id: Integer;
    begin
        initialize_crlf();

        entitlement_builder.Append('<?xml version="1.0" encoding="utf-8"?>');
        entitlement_builder.Append(carriage_return_line_feed);
        entitlement_builder.Append('<Entitlement MetadataVersion="130000" Name="');
        entitlement_builder.Append(format_guid(app_id));
        entitlement_builder.Append('" Type="Implicit" xmlns="urn:schemas-microsoft-com:dynamics:NAV:MetaObjects">');
        entitlement_builder.Append(carriage_return_line_feed);
        entitlement_builder.Append('  <ObjectEntitlements>');
        entitlement_builder.Append(carriage_return_line_feed);

        for entry_index := 1 to type_codes.Count() do begin
            type_codes.Get(entry_index, object_type_code);
            object_ids.Get(entry_index, object_id);
            entitlement_builder.Append('    <Permission Type="');
            entitlement_builder.Append(Format(object_type_code));
            entitlement_builder.Append('" ID="');
            entitlement_builder.Append(Format(object_id));
            entitlement_builder.Append('" Value="16" />');
            entitlement_builder.Append(carriage_return_line_feed);
        end;

        entitlement_builder.Append('  </ObjectEntitlements>');
        entitlement_builder.Append(carriage_return_line_feed);
        entitlement_builder.Append('</Entitlement>');

        temp_blob.CreateOutStream(output_stream, TextEncoding::UTF8);
        write_bom(output_stream);
        output_stream.WriteText(entitlement_builder.ToText());
    end;

    /// <summary>
    /// Returns entitlement file path for a given app id.
    /// </summary>
    procedure get_entitlement_path(app_id: Guid): Text
    begin
        exit('entitlement/' + format_guid(app_id) + '.xml');
    end;

    /// <summary>
    /// Sanitizes names to alphanumeric-only text.
    /// </summary>
    procedure sanitize_name(input_name: Text): Text
    var
        sanitized_builder: TextBuilder;
        character_index: Integer;
        current_character: Char;
    begin
        for character_index := 1 to StrLen(input_name) do begin
            current_character := input_name[character_index];
            case true of
                (current_character >= 'A') and (current_character <= 'Z'),
                (current_character >= 'a') and (current_character <= 'z'),
                (current_character >= '0') and (current_character <= '9'):
                    sanitized_builder.Append(Format(current_character));
            end;
        end;
        exit(sanitized_builder.ToText());
    end;

    /// <summary>
    /// Formats target object signature for symbol references.
    /// </summary>
    procedure format_target_object(package_key: Guid; object_name: Text): Text
    var
        guid_text: Text;
    begin
        guid_text := LowerCase(DelChr(Format(package_key, 0, 9), '=', '{}-'));
        exit('#' + guid_text + '#' + object_name);
    end;

    /// <summary>
    /// Builds a namespace object from symbol reference fragments.
    /// </summary>
    local procedure build_namespace_object(symbol_fragments: JsonObject): JsonObject
    var
        namespace_object: JsonObject;
    begin
        add_json_array(namespace_object, 'Namespaces', symbol_fragments);
        add_json_array(namespace_object, 'Codeunits', symbol_fragments);
        add_json_array(namespace_object, 'Pages', symbol_fragments);
        add_json_array(namespace_object, 'Reports', symbol_fragments);
        add_json_array(namespace_object, 'XmlPorts', symbol_fragments);
        add_json_array(namespace_object, 'Queries', symbol_fragments);
        add_json_array(namespace_object, 'ControlAddIns', symbol_fragments);
        add_json_array(namespace_object, 'EnumTypes', symbol_fragments);
        add_json_array(namespace_object, 'DotNetPackages', symbol_fragments);
        add_json_array(namespace_object, 'Interfaces', symbol_fragments);
        add_json_array(namespace_object, 'PermissionSets', symbol_fragments);
        add_json_array(namespace_object, 'PermissionSetExtensions', symbol_fragments);
        add_json_array(namespace_object, 'ReportExtensions', symbol_fragments);
        add_json_array(namespace_object, 'TableExtensions', symbol_fragments);
        add_json_array(namespace_object, 'PageExtensions', symbol_fragments);
        namespace_object.Add('Name', '');
        exit(namespace_object);
    end;

    /// <summary>
    /// Adds a named JSON array to target JSON from source fragments.
    /// </summary>
    local procedure add_json_array(var target_json: JsonObject; array_name: Text; symbol_fragments: JsonObject)
    var
        fragment_token: JsonToken;
        fragment_array: JsonArray;
    begin
        if symbol_fragments.Get(array_name, fragment_token) then begin
            fragment_array := fragment_token.AsArray();
            target_json.Add(array_name, fragment_array);
        end else
            add_empty_json_array(target_json, array_name);
    end;

    /// <summary>
    /// Adds an empty JSON array by name to target JSON.
    /// </summary>
    local procedure add_empty_json_array(var target_json: JsonObject; array_name: Text)
    var
        empty_array: JsonArray;
    begin
        target_json.Add(array_name, empty_array);
    end;

    /// <summary>
    /// Writes UTF-8 BOM to an output stream.
    /// </summary>
    local procedure write_bom(var output_stream: OutStream)
    var
        byte_order_mark: Text[1];
    begin
        byte_order_mark := ' ';
        byte_order_mark[1] := 65279;
        output_stream.WriteText(byte_order_mark);
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

    /// <summary>
    /// Initializes carriage return + line feed helper text.
    /// </summary>
    local procedure initialize_crlf()
    begin
        carriage_return_line_feed := '  ';
        carriage_return_line_feed[1] := 13;
        carriage_return_line_feed[2] := 10;
    end;

    /// <summary>
    /// Formats GUID values for artifact output.
    /// </summary>
    local procedure format_guid(source_guid: Guid): Text
    begin
        exit(LowerCase(DelChr(Format(source_guid, 0, 9), '=', '{}')));
    end;

    var
        carriage_return_line_feed: Text[2];
}
