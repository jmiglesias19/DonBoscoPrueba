report 50100 Invoice
{
    ApplicationArea = All;
    Caption = 'Invoice Report';
    DefaultLayout = RDLC;
    Permissions = tabledata "Company Information" = r,
    tabledata Customer = r,
    tabledata "Sales Invoice Header" = r,
    tabledata "Sales Invoice Line" = r,
    tabledata "VAT Amount Line" = r,
    tabledata "VAT Product Posting Group" = r,
    tabledata "Cust. Ledger Entry" = r,
    tabledata "Payment Terms" = r,
    tabledata "Payment Method" = r;
    RDLCLayout = 'src/Reports/InvoiceReport.rdl';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        //HEADER
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            column(CommercialRegistryText; CompanyInformation.CommercialRegistryText) { }
            column(Image; CompanyInformation.Picture) { }
            column(CompanyAddres; CompanyInformation."Description 2" + ': ' + CompanyInformation.Address + ' | ' + CompanyInformation."Post Code" + ' ' + CompanyInformation.City + ' | ' + CompanyInformation."Phone No.") { }
            column(EmailAndWeb; CompanyInformation."E-Mail" + ' | ' + CompanyInformation."Home Page") { }
            column(DocumentDate; "Document Date") { }
            column(InvoiceNumber; "No.") { }
            column(WorkDescription_Text; WorkDescriptionAsText) { }
            column(CustomerNumber; Customer."No.") { }
            column(CustomerName; "Sell-to Customer Name") { }
            column(CustomerAddress; "Sell-to Address") { }
            column(PCAndCity; "Sell-to Post Code" + ' ' + "Sell-to City") { }
            column(CIF; "VAT Registration No.") { }
            column(TotalExclVAT_Header; Amount) { }
            column(TotalInclVAT_Header; "Amount Including VAT") { }
            column(TotalVAT_Header; "Amount Including VAT" - Amount) { }

            column(PaymentTermsDescription; PaymentTermsDescription) { } // Descripción del Término de Pago
            column(PaymentMethodDescription; PaymentMethodDescription) { } // Descripción de la Forma de Pago
            column(CompanyBankName; CompanyInformation."Bank Name") { } // Banco: (de Info. Empresa)
            column(CompanyIBAN; CompanyInformation.IBAN) { }




            //BODY
            dataitem(SalesInvoiceLine; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = field("No.");
                column(Concept; "Description") { }
                column(Quantity; Quantity) { }
                column(UnitPrice; "Unit Price") { }
                column(LineAmount; "Line Amount") { }
                column(InvoiceType; "VAT Prod. Posting Group") { }
                column(Total; "Amount Including VAT") { }
                column(IVAPercentage; "VAT %") { }
                column(IVAClause; IVAClause) { }



                trigger OnAfterGetRecord()
                begin
                    if (SalesInvoiceLine.Description = '') then
                        CurrReport.Skip(); // Si la descripcion esta vacia se la salta y no la imprime

                    IVAClause := '';
                    if VATPPG.Get(SalesInvoiceLine."VAT Prod. Posting Group") then
                        IVAClause := VATPPG.IVAClause;
                end;
            }

            dataitem(CustLedEnt; "Cust. Ledger Entry")
            {
                DataItemLink = "Document No." = field("No.");
                column(DueDate; "Due Date") { }
                column(DueAmount; "Original Amount") { }
                column(BillNo; "Bill No.") { }

            }



            trigger OnPreDataItem()
            begin
                // ... (tu código de CompanyInformation)
                if CompanyInformation.Get() then
                    CompanyInformation.CalcFields(Picture)
                else
                    CompanyInformation.Init();
            end;

            // Se ejecuta DESPUÉS de leer CADA factura
            trigger OnAfterGetRecord()
            var
                BlobInStream: InStream;
            begin
                if not Customer.Get("Bill-to Customer No.") then
                    Customer.Init();

                // ... (tu código de LÓGICA BLOB A TEXTO)
                WorkDescriptionAsText := '';
                if SalesInvoiceHeader."Work Description".HasValue() then begin
                    SalesInvoiceHeader.CalcFields("Work Description");
                    SalesInvoiceHeader."Work Description".CreateInStream(BlobInStream);
                    BlobInStream.Read(WorkDescriptionAsText);
                end;

                // Cargar Término de Pago
                PaymentTermsDescription := '';
                if PaymentTerms.Get("Payment Terms Code") then
                    PaymentTermsDescription := PaymentTerms.Description;

                // Cargar Forma de Pago
                PaymentMethodDescription := '';
                if PaymentMethod.Get("Payment Method Code") then
                    PaymentMethodDescription := PaymentMethod.Description;

                // if (CustLedEnt."Bill No." = '') then
                //     CurrReport.Skip();

            end;
        }
    }

    labels
    {

    }

    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        VATPPG: Record "VAT Product Posting Group";
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        // CustLedEdge: Record "Cust. Ledger Entry";
        WorkDescriptionAsText: Text;
        IVAClause: Text;

        PaymentTermsDescription: Text;
        PaymentMethodDescription: Text;
}