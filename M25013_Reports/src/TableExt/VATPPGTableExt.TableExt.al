tableextension 50102 VATPPGTableExt extends "VAT Product Posting Group"
{
    fields
    {
        field(50101; IVAClause; Text[500])
        {
            AllowInCustomizations = Always;
            Caption = 'IVA Clause';
            DataClassification = ToBeClassified;
            ToolTip = 'Specifies the IVA Clause.';
        }
    }

}