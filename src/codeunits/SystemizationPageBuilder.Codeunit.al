codeunit 50303 "Systemization Page Builder"
{

    /// <summary>
    /// Sets target page metadata for generated page extension output.
    /// </summary>
    procedure set_target(target_page_id: Integer; target_page_name: Text[250]; target_package_id: Guid)
    begin
        TpNm := target_page_name;
        TpPk := target_package_id;
        TgtSet := true;
    end;

    /// <summary>
    /// Sets the object id for the generated page extension.
    /// </summary>
    procedure set_object_id(object_id: Integer)
    begin
        ObjId := object_id;
        ObjSet := true;
    end;

    /// <summary>
    /// Adds a field mapping for generated page controls.
    /// </summary>
    procedure add_field(field_name: Text; source_expression: Text; placement_type: Enum "systemization Type Place"; anchor_control_name: Text[250])
    begin
        FldNms.Add(field_name);
        FldSrc.Add(source_expression);
        FldPlc.Add(placement_type);
        FldAnc.Add(anchor_control_name);
    end;

    /// <summary>
    /// Generates page extension AL source into a temporary blob.
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
    /// Returns the generated page extension AL source as text.
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
    /// Builds and returns the symbol reference fragment for the page extension.
    /// </summary>
    procedure generate_symbol_reference(): JsonObject
    var
        result_json: JsonObject;
        control_changes: JsonArray;
        field_control: JsonObject;
        field_type_definition: JsonObject;
        field_properties: JsonArray;
        control_change: JsonObject;
        controls: JsonArray;
        field_index: Integer;
        control_id: Integer;
    begin
        validate_state();

        control_id := 100000001;

        for field_index := 1 to FldNms.Count() do begin
            Clear(control_change);
            Clear(controls);
            Clear(field_control);
            Clear(field_type_definition);
            Clear(field_properties);

            field_type_definition.Add('Name', 'Text');
            add_json_property(field_properties, 'ApplicationArea', '#All');
            add_json_property(field_properties, 'SourceExpression', FldSrc.Get(field_index));

            field_control.Add('Kind', 8);
            field_control.Add('TypeDefinition', field_type_definition);
            field_control.Add('Properties', field_properties);
            field_control.Add('Id', control_id);
            field_control.Add('Name', sanitize_name(FldNms.Get(field_index)));
            controls.Add(field_control);

            control_change.Add('Anchor', FldAnc.Get(field_index));
            control_change.Add('ChangeKind', get_change_kind(FldPlc.Get(field_index)));
            control_change.Add('Controls', controls);
            control_changes.Add(control_change);

            control_id += 1;
        end;

        result_json.Add('TargetObject', format_target(TpPk, TpNm));
        result_json.Add('ControlChanges', control_changes);
        result_json.Add('ReferenceSourceFileName', get_source_path());
        result_json.Add('Id', ObjId);
        result_json.Add('Name', get_object_name());

        exit(result_json);
    end;

    /// <summary>
    /// Returns the generated source file path for the page extension.
    /// </summary>
    procedure get_source_file_path(): Text
    begin
        exit('src/PageExtension/' + sanitize_name(TpNm) + '.PageExt.al');
    end;

    /// <summary>
    /// Returns entitlement object type code for page extensions.
    /// </summary>
    procedure get_entitlement_type_code(): Integer
    begin
        exit(8);
    end;

    /// <summary>
    /// Returns the configured page extension object id.
    /// </summary>
    procedure get_object_id(): Integer
    begin
        exit(ObjId);
    end;

    /// <summary>
    /// Resets builder state and buffered field mappings.
    /// </summary>
    procedure reset()
    begin
        TpNm := '';
        Clear(TpPk);
        ObjId := 0;
        Clear(FldNms);
        Clear(FldSrc);
        Clear(FldPlc);
        Clear(FldAnc);
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
        if FldNms.Count() = 0 then
            Error(ErrNoFld);
    end;

    /// <summary>
    /// Returns the generated page extension object name.
    /// </summary>
    local procedure get_object_name(): Text
    begin
        exit(TpNm + ' Ext');
    end;

    /// <summary>
    /// Returns generated source path used by symbol references.
    /// </summary>
    local procedure get_source_path(): Text
    begin
        exit('src/PageExtension/' + sanitize_name(TpNm) + '.PageExt.al');
    end;

    /// <summary>
    /// Writes the page extension AL source structure.
    /// </summary>
    local procedure build_source(var page_writer: Codeunit "Systemization Source Writer")
    var
        field_index: Integer;
    begin
        page_writer.begin_object('pageextension', ObjId, get_object_name(), 'extends', TpNm);
        page_writer.begin_block('layout');

        for field_index := 1 to FldNms.Count() do begin
            page_writer.begin_block_with_arg(get_placement_keyword(FldPlc.Get(field_index)), FldAnc.Get(field_index));
            page_writer.begin_page_field(FldNms.Get(field_index), FldSrc.Get(field_index));
            page_writer.add_property('ApplicationArea', 'All');
            page_writer.end_page_field();
            page_writer.end_block();
        end;

        page_writer.end_block();
        page_writer.end_object();
    end;

    /// <summary>
    /// Maps placement enum to AL placement keyword.
    /// </summary>
    local procedure get_placement_keyword(placement_type: Enum "systemization Type Place"): Text
    begin
        case placement_type of
            "systemization Type Place"::addafter:
                exit('addafter');
            "systemization Type Place"::addbefore:
                exit('addbefore');
        end;
    end;

    /// <summary>
    /// Maps placement enum to symbol reference change kind value.
    /// </summary>
    local procedure get_change_kind(placement_type: Enum "systemization Type Place"): Integer
    begin
        case placement_type of
            "systemization Type Place"::addafter:
                exit(1);
            "systemization Type Place"::addbefore:
                exit(2);
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
        TpNm: Text[250];
        TpPk: Guid;
        ObjId: Integer;
        FldNms: List of [Text];
        FldSrc: List of [Text];
        FldPlc: List of [Enum "systemization Type Place"];
        FldAnc: List of [Text];
        TgtSet: Boolean;
        ObjSet: Boolean;
        ErrNoTgt: Label 'Call set_target() before generating output.', Locked = true;
        ErrNoObj: Label 'Call set_object_id() before generating output.', Locked = true;
        ErrNoFld: Label 'Add at least one field with add_field() before generating output.', Locked = true;
}
