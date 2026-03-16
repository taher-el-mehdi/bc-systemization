codeunit 50301 "Systemization Source Writer"
{

    /// <summary>
    /// Starts an AL object declaration block.
    /// </summary>
    procedure begin_object(object_type: Text; object_id: Integer; object_name: Text; extends_keyword: Text; extends_name: Text)
    begin
        initialize();
        source_builder.Append(object_type);
        source_builder.Append(' ');
        source_builder.Append(Format(object_id));
        source_builder.Append(' "');
        source_builder.Append(object_name);
        source_builder.Append('"');
        if extends_keyword <> '' then begin
            source_builder.Append(' ');
            source_builder.Append(extends_keyword);
            source_builder.Append(' "');
            source_builder.Append(extends_name);
            source_builder.Append('"');
        end;
        source_builder.Append(get_line_feed());
        source_builder.Append('{');
        source_builder.Append(get_line_feed());
        indentation_level += 1;
    end;

    /// <summary>
    /// Ends the current AL object declaration block.
    /// </summary>
    procedure end_object()
    begin
        indentation_level -= 1;
        write_padding();
        source_builder.Append('}');
        source_builder.Append(get_line_feed());
    end;

    /// <summary>
    /// Starts a named AL block.
    /// </summary>
    procedure begin_block(block_keyword: Text)
    begin
        initialize();
        write_padding();
        source_builder.Append(block_keyword);
        source_builder.Append(get_line_feed());
        write_padding();
        source_builder.Append('{');
        source_builder.Append(get_line_feed());
        indentation_level += 1;
    end;

    /// <summary>
    /// Starts a named AL block with an argument.
    /// </summary>
    procedure begin_block_with_arg(block_keyword: Text; block_argument: Text)
    begin
        initialize();
        write_padding();
        source_builder.Append(block_keyword);
        source_builder.Append('("');
        source_builder.Append(block_argument);
        source_builder.Append('")');
        source_builder.Append(get_line_feed());
        write_padding();
        source_builder.Append('{');
        source_builder.Append(get_line_feed());
        indentation_level += 1;
    end;

    /// <summary>
    /// Ends the current AL block.
    /// </summary>
    procedure end_block()
    begin
        indentation_level -= 1;
        write_padding();
        source_builder.Append('}');
        source_builder.Append(get_line_feed());
    end;

    /// <summary>
    /// Starts a table field declaration block.
    /// </summary>
    procedure begin_field(field_id: Integer; field_name: Text; field_type: Text)
    begin
        initialize();
        write_padding();
        source_builder.Append('field(');
        source_builder.Append(Format(field_id));
        source_builder.Append('; "');
        source_builder.Append(field_name);
        source_builder.Append('"; ');
        source_builder.Append(field_type);
        source_builder.Append(')');
        source_builder.Append(get_line_feed());
        write_padding();
        source_builder.Append('{');
        source_builder.Append(get_line_feed());
        indentation_level += 1;
    end;

    /// <summary>
    /// Ends the current table field declaration block.
    /// </summary>
    procedure end_field()
    begin
        indentation_level -= 1;
        write_padding();
        source_builder.Append('}');
        source_builder.Append(get_line_feed());
    end;

    /// <summary>
    /// Starts a page field declaration block.
    /// </summary>
    procedure begin_page_field(field_name: Text; source_expression: Text)
    begin
        initialize();
        write_padding();
        source_builder.Append('field("');
        source_builder.Append(field_name);
        source_builder.Append('"; ');
        source_builder.Append('Rec."' + field_name + '"');
        source_builder.Append(')');
        source_builder.Append(get_line_feed());
        write_padding();
        source_builder.Append('{');
        source_builder.Append(get_line_feed());
        indentation_level += 1;
    end;

    /// <summary>
    /// Ends the current page field declaration block.
    /// </summary>
    procedure end_page_field()
    begin
        indentation_level -= 1;
        write_padding();
        source_builder.Append('}');
        source_builder.Append(get_line_feed());
    end;

    /// <summary>
    /// Adds a non-string AL property assignment.
    /// </summary>
    procedure add_property(property_name: Text; property_value: Text)
    begin
        initialize();
        write_padding();
        source_builder.Append(property_name);
        source_builder.Append(' = ');
        source_builder.Append(property_value);
        source_builder.Append(';');
        source_builder.Append(get_line_feed());
    end;

    /// <summary>
    /// Adds a string AL property assignment.
    /// </summary>
    procedure add_string_property(property_name: Text; property_value: Text)
    begin
        initialize();
        write_padding();
        source_builder.Append(property_name);
        source_builder.Append(' = ''');
        source_builder.Append(property_value);
        source_builder.Append(''';');
        source_builder.Append(get_line_feed());
    end;

    /// <summary>
    /// Writes a raw line at the current indentation level.
    /// </summary>
    procedure write_line(line_text: Text)
    begin
        initialize();
        write_padding();
        source_builder.Append(line_text);
        source_builder.Append(get_line_feed());
    end;

    /// <summary>
    /// Writes a blank line to the generated source.
    /// </summary>
    procedure write_blank_line()
    begin
        initialize();
        source_builder.Append(get_line_feed());
    end;

    /// <summary>
    /// Returns the generated source as text.
    /// </summary>
    procedure to_text(): Text
    begin
        initialize();
        exit(source_builder.ToText());
    end;

    /// <summary>
    /// Writes generated source to a UTF-8 temporary blob.
    /// </summary>
    procedure write_to_blob(var temp_blob: Codeunit "Temp Blob")
    var
        output_stream: OutStream;
    begin
        initialize();
        temp_blob.CreateOutStream(output_stream, TextEncoding::UTF8);
        output_stream.WriteText(source_builder.ToText());
    end;

    /// <summary>
    /// Resets the writer state and clears generated source.
    /// </summary>
    procedure reset()
    begin
        Clear(source_builder);
        indentation_level := 0;
        is_initialized := false;
    end;

    /// <summary>
    /// Lazily initializes internal writer buffers.
    /// </summary>
    local procedure initialize()
    begin
        if is_initialized then
            exit;
        Clear(source_builder);
        indentation_level := 0;
        is_initialized := true;
    end;

    /// <summary>
    /// Writes indentation spaces for the current indentation level.
    /// </summary>
    local procedure write_padding()
    var
        indentation_index: Integer;
    begin
        for indentation_index := 1 to indentation_level do
            source_builder.Append('    ');
    end;

    /// <summary>
    /// Returns a line feed character for generated text.
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
        source_builder: TextBuilder;
        indentation_level: Integer;
        is_initialized: Boolean;
}
