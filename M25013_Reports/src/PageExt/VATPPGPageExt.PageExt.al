pageextension 50102 VATPPGPageExt extends "VAT Product Posting Groups"
{
    layout
    {
        addafter(Code)
        {
            field(IVAClause; Rec.IVAClause)
            {
                ApplicationArea = all;
                Caption = 'IVA Clause';
            }
        }
    }


}