codeunit 50302 "Systemization Table Builder"
{

    /// <summary>
    /// Sets target table metadata for generated table extension output.
    /// </summary>
    procedure set_target(target_table_id: Integer; target_table_name: Text[250]; target_package_id: Guid)
    begin
        TtId := target_table_id;
        TtNm := target_table_name;
        TtPk := target_package_id;
        TgtSet := true;
    end;

    /// <summary>
    /// Sets the object id for the generated table extension.
    /// </summary>
    procedure set_object_id(object_id: Integer)
    begin
        ObjId := object_id;
        ObjSet := true;
    end;

    /// <summary>
    /// Adds a configured field definition to the table extension buffer.
    /// </summary>
    procedure add_field(field_id: Integer; field_name: Text[100]; field_data_type: Enum "Systemization Type Field"; field_length: Integer; option_string: Text[250])
    begin
        FIds.Add(field_id);
        FNms.Add(field_name);
        FDts.Add(field_data_type.AsInteger());
        FLns.Add(field_length);
        FOpts.Add(option_string);
    end;

    /// <summary>
    /// Generates table extension AL source into a temporary blob.
    /// </summary>
    procedure generate_source(var source_blob: Codeunit "Temp Blob")
    var
        page_writer: Codeunit "Systemization Source Writer";
    begin
        validate_state();
        build_source(page_writer);
        page_writer.write_to_blob(source_blob);
    end;

    /// <summary>
    /// Returns the generated table extension AL source as text.
    /// </summary>
    procedure preview_source(): Text
    var
        page_writer: Codeunit "Systemization Source Writer";
    begin
        validate_state();
        build_source(page_writer);
        exit(page_writer.to_text());
    end;

    /// <summary>
    /// Builds and returns the symbol reference fragment for the table extension.
    /// </summary>
    procedure generate_symbol_reference(): JsonObject
    var
        result_json: JsonObject;
        fields_array: JsonArray;
        field_object: JsonObject;
        field_type_definition: JsonObject;
        field_properties: JsonArray;
        field_data_type: Enum "Systemization Type Field";
        type_name: Text;
        type_subtype: Text;
        field_index: Integer;
        caption_name: Text;
    begin
        validate_state();

        for field_index := 1 to FIds.Count() do begin
            Clear(field_object);
            Clear(field_type_definition);
            Clear(field_properties);

            field_data_type := "Systemization Type Field".FromInteger(FDts.Get(field_index));
            get_type_info(field_data_type, FLns.Get(field_index), FOpts.Get(field_index), type_name, type_subtype);

            field_type_definition.Add('Name', type_name);
            if type_subtype <> '' then
                field_type_definition.Add('Subtype', type_subtype);

            caption_name := FNms.Get(field_index);
            add_json_property(field_properties, 'Caption', caption_name);
            add_json_property(field_properties, 'DataClassification', 'CustomerContent');

            field_object.Add('TypeDefinition', field_type_definition);
            field_object.Add('Properties', field_properties);
            field_object.Add('Id', FIds.Get(field_index));
            field_object.Add('Name', caption_name);
            fields_array.Add(field_object);
        end;

        result_json.Add('TargetObject', format_target(TtPk, TtNm));
        result_json.Add('Fields', fields_array);
        result_json.Add('ReferenceSourceFileName', get_source_file_path());
        result_json.Add('Id', ObjId);
        result_json.Add('Name', get_object_name());

        exit(result_json);
    end;

    /// <summary>
    /// Returns the generated source file path for the table extension.
    /// </summary>
    procedure get_source_file_path(): Text
    begin
        exit('src/TableExtension/' + sanitize_name(TtNm) + '.TableExt.al');
    end;

    /// <summary>
    /// Returns entitlement object type code for table extensions.
    /// </summary>
    procedure get_entitlement_type_code(): Integer
    begin
        exit(9);
    end;

    /// <summary>
    /// Returns the configured table extension object id.
    /// </summary>
    procedure get_object_id(): Integer
    begin
        exit(ObjId);
    end;

    /// <summary>
    /// Resets builder state and buffered field definitions.
    /// </summary>
    procedure reset()
    begin
        TtId := 0;
        TtNm := '';
        Clear(TtPk);
        ObjId := 0;
        Clear(FIds);
        Clear(FNms);
        Clear(FDts);
        Clear(FLns);
        Clear(FOpts);
        TgtSet := false;
        ObjSet := false;
    end;

    /// <summary>
    /// Validates required target/object/field state before generation.
    /// </summary>
    local procedure validate_state()
    begin
        if not TgtSet then
            Error(ErrNoTgt);
        if not ObjSet then
            Error(ErrNoObj);
        if FIds.Count() = 0 then
            Error(ErrNoFld);
    end;

    /// <summary>
    /// Returns the generated table extension object name.
    /// </summary>
    local procedure get_object_name(): Text
    begin
        exit(TtNm + ' Ext');
    end;

    /// <summary>
    /// Writes the table extension AL source structure.
    /// </summary>
    local procedure build_source(var page_writer: Codeunit "Systemization Source Writer")
    var
        field_data_type: Enum "Systemization Type Field";
        field_type_text: Text;
        field_index: Integer;
    begin
        page_writer.begin_object('tableextension', ObjId, get_object_name(), 'extends', TtNm);
        page_writer.begin_block('fields');

        for field_index := 1 to FIds.Count() do begin
            field_data_type := "Systemization Type Field".FromInteger(FDts.Get(field_index));
            field_type_text := get_field_type_string(field_data_type, FLns.Get(field_index));

            page_writer.begin_field(FIds.Get(field_index), FNms.Get(field_index), field_type_text);
            page_writer.add_property('DataClassification', 'CustomerContent');
            page_writer.add_string_property('Caption', FNms.Get(field_index));

            if field_data_type = "Systemization Type Field"::Option then
                if FOpts.Get(field_index) <> '' then begin
                    page_writer.add_property('OptionMembers', FOpts.Get(field_index));
                    page_writer.add_string_property('OptionCaption', FOpts.Get(field_index));
                end;

            page_writer.end_field();
        end;

        page_writer.end_block();
        page_writer.end_object();
    end;

    /// <summary>
    /// Resolves AL field type syntax from configured field type and length.
    /// </summary>
    local procedure get_field_type_string(field_data_type: Enum "Systemization Type Field"; field_length: Integer): Text
    var
        effective_length: Integer;
    begin
        case field_data_type of
            "Systemization Type Field"::Text:
                begin
                    effective_length := field_length;
                    if effective_length <= 0 then
                        effective_length := 100;
                    exit('Text[' + Format(effective_length) + ']');
                end;
            "Systemization Type Field"::Code:
                begin
                    effective_length := field_length;
                    if effective_length <= 0 then
                        effective_length := 20;
                    exit('Code[' + Format(effective_length) + ']');
                end;
            "Systemization Type Field"::Integer:
                exit('Integer');
            "Systemization Type Field"::Decimal:
                exit('Decimal');
            "Systemization Type Field"::Boolean:
                exit('Boolean');
            "Systemization Type Field"::Date:
                exit('Date');
            "Systemization Type Field"::DateTime:
                exit('DateTime');
            "Systemization Type Field"::Option:
                exit('Option');
            else
                exit('Text[100]');
        end;
    end;

    /// <summary>
    /// Resolves symbol reference type name and subtype values.
    /// </summary>
    local procedure get_type_info(field_data_type: Enum "Systemization Type Field"; field_length: Integer; option_string: Text; var type_name: Text; var type_subtype: Text)
    var
        effective_length: Integer;
    begin
        type_subtype := '';
        case field_data_type of
            "Systemization Type Field"::Text:
                begin
                    type_name := 'Text';
                    effective_length := field_length;
                    if effective_length <= 0 then
                        effective_length := 100;
                    type_subtype := Format(effective_length);
                end;
            "Systemization Type Field"::Code:
                begin
                    type_name := 'Code';
                    effective_length := field_length;
                    if effective_length <= 0 then
                        effective_length := 20;
                    type_subtype := Format(effective_length);
                end;
            "Systemization Type Field"::Integer:
                type_name := 'Integer';
            "Systemization Type Field"::Decimal:
                type_name := 'Decimal';
            "Systemization Type Field"::Boolean:
                type_name := 'Boolean';
            "Systemization Type Field"::Date:
                type_name := 'Date';
            "Systemization Type Field"::DateTime:
                type_name := 'DateTime';
            "Systemization Type Field"::Option:
                begin
                    type_name := 'Option';
                    if option_string <> '' then
                        type_subtype := option_string;
                end;
            else
                type_name := 'Text';
        end;
    end;

    /// <summary>
    /// Formats target object signature for symbol references.
    /// </summary>
    local procedure format_target(package_key: Guid; object_name: Text): Text
    var
        guid_text: Text;
    begin
        guid_text := LowerCase(DelChr(Format(package_key, 0, 9), '=', '{}-'));
        exit('#' + guid_text + '#' + object_name);
    end;

    /// <summary>
    /// Sanitizes names to alphanumeric-only text.
    /// </summary>
    local procedure sanitize_name(input_name: Text): Text
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
    /// Adds a name/value JSON property object to an array.
    /// </summary>
    local procedure add_json_property(var properties_array: JsonArray; property_name: Text; property_value: Text)
    var
        property_object: JsonObject;
    begin
        property_object.Add('Name', property_name);
        property_object.Add('Value', property_value);
        properties_array.Add(property_object);
    end;

    var
        TtId: Integer;
        TtNm: Text[250];
        TtPk: Guid;
        ObjId: Integer;
        FIds: List of [Integer];
        FNms: List of [Text];
        FDts: List of [Integer];
        FLns: List of [Integer];
        FOpts: List of [Text];
        TgtSet: Boolean;
        ObjSet: Boolean;
        ErrNoTgt: Label 'Call set_target() before generating output.', Locked = true;
        ErrNoObj: Label 'Call set_object_id() before generating output.', Locked = true;
        ErrNoFld: Label 'Add at least one field with add_field() before generating output.', Locked = true;
}
