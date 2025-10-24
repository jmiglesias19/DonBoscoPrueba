report 50100 Invoice
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Permissions = tabledata "Company Information" = r;
    // DefaultRenderingLayout = LayoutName;
    DefaultLayout = RDLC;
    RDLCLayout = 'src/Reports/InvoiceReport.rdl';

    dataset
    {
        dataitem(DataItemName;
        "Company Information")
        {
            column(Image; Picture)
            {

            }
        }
    }

    requestpage
    {
        AboutTitle = 'Teaching tip title';
        AboutText = 'Teaching tip content';
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    Caption = 'GroupName';
                    // field(Name; SourceExpression)
                    // {

                    // }
                }
            }
        }


    }
}