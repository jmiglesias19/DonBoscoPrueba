report 50100 Invoice
{
    ApplicationArea = All;
    Caption = 'Invoice Report';
    DefaultLayout = RDLC;
    Permissions = tabledata "Company Information" = r,
    tabledata Customer = r,
    tabledata "Sales Invoice Header" = r,
    tabledata "Sales Invoice Line" = r;
    RDLCLayout = 'src/Reports/InvoiceReport.rdl';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        //HEADER
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
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
            // Total IVA excl. (EUR) -> Suma de "Line Amount"
            column(TotalExclVAT_Header; Amount) { }

            // Total IVA incl. (Eur) -> Suma de "Amount Including VAT"
            column(TotalInclVAT_Header; "Amount Including VAT") { }

            // IVA TOTAL (EUR) -> Suma de "VAT Amount"
            // (Es mejor restarlos para evitar problemas de redondeo)
            column(TotalVAT_Header; "Amount Including VAT" - Amount) { }


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

                trigger OnAfterGetRecord()
                begin
                    if (SalesInvoiceLine.Description = '') then
                        CurrReport.Skip(); // Si la descripcion esta vacia se la salta y no la imprime

                end;

            }

            // Se ejecuta ANTES de empezar a leer las facturas
            trigger OnPreDataItem()
            begin
                // Cargamos la info de la compañía UNA SOLA VEZ
                if CompanyInformation.Get() then
                    // --- OPTIMIZACIÓN ---
                    // Se carga la imagen aquí, una sola vez.
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

                // --- LÓGICA BLOB A TEXTO ---
                WorkDescriptionAsText := '';
                if SalesInvoiceHeader."Work Description".HasValue() then begin
                    SalesInvoiceHeader.CalcFields("Work Description");
                    SalesInvoiceHeader."Work Description".CreateInStream(BlobInStream);
                    BlobInStream.Read(WorkDescriptionAsText);
                end;
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        WorkDescriptionAsText: Text;

}