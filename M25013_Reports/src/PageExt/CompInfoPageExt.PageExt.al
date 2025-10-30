pageextension 50101 CompInfoPageExt extends "Company Information"
{
    layout
    {
        addafter(Name)
        {
            field(CompanyName; Rec."Description 2")
            {
                Caption = 'Company Name';
                ApplicationArea = All;
            }
        }

        addbefore(Picture)
        {
            field(CommercialRegistryText; Rec.CommercialRegistryText)
            {
                Caption = 'Commercial Registry Text';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

}