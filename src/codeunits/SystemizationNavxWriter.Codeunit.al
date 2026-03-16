codeunit 50305 "Systemization Navx Writer"
{
    /// <summary>
    /// Writes the NAVX header to the output stream before the ZIP payload.
    /// </summary>
    procedure write_navx_header(var output_stream: OutStream; package_guid: Guid; zip_size: Integer)
    var
        magic_number: Integer;
        guid_segments: array[4] of Integer;
    begin
        // NAVX package magic number expected by BC runtime when reading package stream.
        magic_number := 1482047822;
        guid_to_le_integers(package_guid, guid_segments);

        output_stream.Write(magic_number);
        output_stream.Write(40);
        output_stream.Write(2);
        output_stream.Write(guid_segments[1]);
        output_stream.Write(guid_segments[2]);
        output_stream.Write(guid_segments[3]);
        output_stream.Write(guid_segments[4]);
        output_stream.Write(zip_size);
        output_stream.Write(0);
        output_stream.Write(magic_number);
    end;

    /// <summary>
    /// Converts a GUID into little-endian integer segments used in NAVX headers.
    /// </summary>
    procedure guid_to_le_integers(source_guid: Guid; var little_endian_segments: array[4] of Integer)
    var
        guid_text: Text;
        guid_part_1: Text;
        guid_part_2: Text;
        guid_part_3: Text;
        guid_part_4: Text;
        guid_part_5: Text;
    begin
        // GUID is serialized in mixed endianness.
        // We normalize into 4 int32 values as expected by NAVX header layout.
        guid_text := UpperCase(DelChr(Format(source_guid, 0, 9), '=', '{}'));

        guid_part_1 := CopyStr(guid_text, 1, 8);
        guid_part_2 := CopyStr(guid_text, 10, 4);
        guid_part_3 := CopyStr(guid_text, 15, 4);
        guid_part_4 := CopyStr(guid_text, 20, 4);
        guid_part_5 := CopyStr(guid_text, 25, 12);

        little_endian_segments[1] := hex_to_signed_int32(guid_part_1);
        little_endian_segments[2] := hex_to_signed_int32(guid_part_3 + guid_part_2);
        little_endian_segments[3] := hex_to_signed_int32(reverse_hex_bytes(guid_part_4 + CopyStr(guid_part_5, 1, 4)));
        little_endian_segments[4] := hex_to_signed_int32(reverse_hex_bytes(CopyStr(guid_part_5, 5, 8)));
    end;

    /// <summary>
    /// Converts an 8-character hexadecimal string into a signed 32-bit integer.
    /// </summary>
    procedure hex_to_signed_int32(hexadecimal_text: Text): Integer
    var
        numeric_value: BigInteger;
        character_index: Integer;
    begin
        // Parse exactly 8 hex chars into a signed 32-bit integer.
        numeric_value := 0;
        for character_index := 1 to 8 do
            numeric_value := numeric_value * 16 + hex_char_to_int(hexadecimal_text[character_index]);

        // Convert from unsigned range to signed int32 representation.
        if numeric_value > 2147483647 then begin
            numeric_value := numeric_value - 2147483647;
            numeric_value := numeric_value - 2147483647;
            numeric_value := numeric_value - 2;
        end;

        exit(numeric_value);
    end;

    /// <summary>
    /// Reverses byte order in hexadecimal text by two-character byte groups.
    /// </summary>
    local procedure reverse_hex_bytes(hexadecimal_text: Text): Text
    begin
        exit(CopyStr(hexadecimal_text, 7, 2) + CopyStr(hexadecimal_text, 5, 2) +
             CopyStr(hexadecimal_text, 3, 2) + CopyStr(hexadecimal_text, 1, 2));
    end;

    /// <summary>
    /// Converts a single hexadecimal character to its integer value.
    /// </summary>
    local procedure hex_char_to_int(hexadecimal_character: Char): Integer
    begin
        case true of
            (hexadecimal_character >= '0') and (hexadecimal_character <= '9'):
                exit(hexadecimal_character - 48);
            (hexadecimal_character >= 'A') and (hexadecimal_character <= 'F'):
                exit(hexadecimal_character - 55);
            (hexadecimal_character >= 'a') and (hexadecimal_character <= 'f'):
                exit(hexadecimal_character - 87);
            else
                Error('Invalid hex character: %1', hexadecimal_character);
        end;
    end;
}
