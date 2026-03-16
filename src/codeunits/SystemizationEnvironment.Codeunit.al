codeunit 50304 "Systemization Environment"
{
    /// <summary>
    /// Returns the application version derived from the installed Base Application.
    /// </summary>
    procedure get_application_version(): Text
    var
        module_info: ModuleInfo;
    begin
        NavApp.GetModuleInfo(get_base_app_id(), module_info);
        exit(Format(module_info.AppVersion().Major()) + '.0.0.0');
    end;

    /// <summary>
    /// Returns the runtime version mapped from the installed Base Application major version.
    /// </summary>
    procedure get_runtime_version(): Text
    var
        module_info: ModuleInfo;
        major_version: Integer;
    begin
        NavApp.GetModuleInfo(get_base_app_id(), module_info);
        major_version := module_info.AppVersion().Major();
        exit(map_major_to_runtime(major_version));
    end;

    /// <summary>
    /// Returns the target platform name for the current environment.
    /// </summary>
    procedure get_target_platform(): Text
    var
        environment_information: Codeunit "Environment Information";
    begin
        if environment_information.IsSaaS() then
            exit('Cloud');
        exit('OnPremises');
    end;

    /// <summary>
    /// Builds dependency XML for a package when a non-Microsoft dependency is detected.
    /// </summary>
    procedure build_dependency_xml(package_id: Guid): Text
    var
        dependency_app_id: Guid;
        dependency_name: Text;
        dependency_publisher: Text;
        dependency_version: Text;
        dependency_xml_builder: TextBuilder;
    begin
        // If no dependency is found, generated app remains dependency-free.
        if not resolve_dependency(package_id, dependency_app_id, dependency_name, dependency_publisher, dependency_version) then
            exit('<Dependencies />');

        // Skip explicit dependency on Microsoft apps to keep output lean.
        if dependency_publisher = 'Microsoft' then
            exit('<Dependencies />');

        dependency_xml_builder.Append('<Dependencies>');
        dependency_xml_builder.Append(get_line_feed());
        dependency_xml_builder.Append('    <Dependency Id="');
        dependency_xml_builder.Append(LowerCase(DelChr(Format(dependency_app_id, 0, 9), '=', '{}')));
        dependency_xml_builder.Append('" Name="');
        dependency_xml_builder.Append(dependency_name);
        dependency_xml_builder.Append('" Publisher="');
        dependency_xml_builder.Append(dependency_publisher);
        dependency_xml_builder.Append('" MinVersion="');
        dependency_xml_builder.Append(dependency_version);
        dependency_xml_builder.Append('" />');
        dependency_xml_builder.Append(get_line_feed());
        dependency_xml_builder.Append('  </Dependencies>');
        exit(dependency_xml_builder.ToText());
    end;

    /// <summary>
    /// Resolves dependency metadata from the installed app list by package id.
    /// </summary>
    procedure resolve_dependency(package_id: Guid;
        var dependency_app_id: Guid; var dependency_name: Text;
        var dependency_publisher: Text; var dependency_version: Text): Boolean
    var
        installed_app: Record "NAV App Installed App";
        empty_guid: Guid;
    begin
        if package_id = empty_guid then
            exit(false);

        installed_app.SetLoadFields("App ID", Name, Publisher, "Version Major", "Version Minor", "Version Build", "Version Revision");
        installed_app.SetRange("Package ID", package_id);
        if not installed_app.FindFirst() then
            exit(false);

        dependency_app_id := installed_app."App ID";
        dependency_name := installed_app.Name;
        dependency_publisher := installed_app.Publisher;
        dependency_version := Format(installed_app."Version Major") + '.0.0.0';

        exit(true);
    end;

    /// <summary>
    /// Gets the app id of the installed Base Application.
    /// </summary>
    local procedure get_base_app_id(): Guid
    var
        installed_app: Record "NAV App Installed App";
    begin
        installed_app.SetLoadFields("App ID");
        installed_app.SetRange(Name, 'Base Application');
        installed_app.SetRange(Publisher, 'Microsoft');
        installed_app.FindFirst();
        exit(installed_app."App ID");
    end;

    /// <summary>
    /// Maps an application major version to the runtime major version.
    /// </summary>
    local procedure map_major_to_runtime(major_version: Integer): Text
    begin
        // Current solution assumes runtime major = base app major - 11.
        // If BC runtime mapping changes in future versions, adjust this rule.
        exit(Format(major_version - 11) + '.0');
    end;

    /// <summary>
    /// Returns a line feed character used by generated text builders.
    /// </summary>
    local procedure get_line_feed(): Text[1]
    var
        line_feed: Text[1];
    begin
        line_feed := ' ';
        line_feed[1] := 10;
        exit(line_feed);
    end;
}
