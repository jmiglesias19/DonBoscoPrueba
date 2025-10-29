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
    tabledata "Cust. Ledger Entry" = r;
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
            column(TotalExclVAT_Header; Amount) { }
            column(TotalInclVAT_Header; "Amount Including VAT") { }
            column(TotalVAT_Header; "Amount Including VAT" - Amount) { }
            column(ExpirationDate; CustLedEnt."Due Date") { }


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

                // --- CORRECCIÓN 4: Cargar el movimiento de cliente ---
                // La factura de venta (ya registrada) tiene un campo 
                // que nos dice exactamente qué movimiento de cliente se creó.
                // Usamos .Get() para cargar ese registro en nuestra variable CustLedEnt.

                CustLedEnt.Reset(); // Limpiamos la variable
                if SalesInvoiceHeader."Cust. Ledger Entry No." <> 0 then
                    CustLedEnt.Get(SalesInvoiceHeader."Cust. Ledger Entry No.");
                // --- FIN CORRECCIÓN 4 ---

            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        VATPPG: Record "VAT Product Posting Group";
        CustLedEnt: Record "Cust. Ledger Entry";
        WorkDescriptionAsText: Text;
        IVAClause: Text;
}