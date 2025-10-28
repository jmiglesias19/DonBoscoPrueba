tableextension 50100 CompanyInfoExt extends "Company Information"
{
    fields
    {
        field(50100; "Description 2"; Text[500])
        {
            Caption = 'Description 2';
            DataClassification = ToBeClassified;
            ToolTip = 'Specifies the name of the company.';
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

}