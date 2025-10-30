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

        field(50101; "CommercialRegistryText"; Text[500])
        {
            AllowInCustomizations = Always;
            Caption = 'Commercial Registry Text';
            ToolTip = 'Specifies the commercial registry text.';
        }
    }



}