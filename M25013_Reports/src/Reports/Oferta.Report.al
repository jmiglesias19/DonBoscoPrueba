report 50101 Oferta
{
    ApplicationArea = All;
    Caption = 'Invoice Report';
    DefaultLayout = RDLC;
    Permissions = tabledata "Company Information" = r,
    tabledata Customer = r,
    tabledata "Sales Header" = r,
    tabledata "Sales Line" = r,
    tabledata "VAT Amount Line" = r,
    tabledata "VAT Product Posting Group" = r,
    tabledata "Cust. Ledger Entry" = r,
    tabledata "Payment Terms" = r,
    tabledata "Payment Method" = r;
    RDLCLayout = 'src/Reports/OfertaReport.rdl';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        //HEADER
        dataitem(SalesHeader; "Sales Header")
        {

            //BODY
            dataitem(SalesLine; "Sales Line")
            {
                DataItemLink = "Document No." = field("No.");

                column(CommercialRegistryText; CompanyInformation.CommercialRegistryText) { }
                column(Image; CompanyInformation.Picture) { }
                column(CompanyAddres; CompanyInformation."Description 2" + ': ' + CompanyInformation.Address + ' | ' + CompanyInformation."Post Code" + ' ' + CompanyInformation.City + ' | ' + CompanyInformation."Phone No.") { }
                column(EmailAndWeb; CompanyInformation."E-Mail" + ' | ' + CompanyInformation."Home Page") { }
                column(DocumentDate; SalesHeader."Document Date") { }
                column(OfferNumber; SalesHeader."No.") { }
                column(WorkDescription_Text; WorkDescriptionAsText) { }
                column(CustomerNumber; "Sell-to Customer No.") { }
                column(CustomerName; "Sell-to Customer Name")
                {
                    IncludeCaption = true;
                }
                column(CustomerAddress; SalesHeader."Sell-to Address") { }
                column(PCAndCity; SalesHeader."Sell-to Post Code" + ' ' + SalesHeader."Sell-to City") { }
                column(CIF; SalesHeader."VAT Registration No.") { }
                column(TotalExclVAT_Header; Amount) { }
                column(TotalInclVAT_Header; "Amount Including VAT") { }
                column(TotalVAT_Header; "Amount Including VAT" - Amount) { }

                column(PaymentTermsDescription; PaymentTermsDescription) { } // Descripción del Término de Pago
                column(PaymentMethodDescription; PaymentMethodDescription) { } // Descripción de la Forma de Pago
                column(CompanyBankName; CompanyInformation."Bank Name") { } // Banco: (de Info. Empresa)
                column(CompanyIBAN; CompanyInformation.IBAN) { }

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
                    if (SalesLine.Description = '') then
                        CurrReport.Skip(); // Si la descripcion esta vacia se la salta y no la imprime

                    IVAClause := '';
                    if VATPPG.Get(SalesLine."VAT Prod. Posting Group") then
                        IVAClause := VATPPG.IVAClause;
                end;
            }

            dataitem(CustLedEnt; "Cust. Ledger Entry")
            {
                DataItemLink = "Document No." = field("No.");
                column(DueDate; "Due Date") { }
                column(DueAmount; "Original Amount")
                {
                    IncludeCaption = true;
                }
                column(BillNo; "Bill No.") { }
                column(EntryNo; "Entry No.") { }
                column(RemainingAmount; "Remaining Amount") { }
                column(Open; "Open") { }
                column(CustomerNo; "Customer No.") { }
                column(DocumentNo; "Document No.") { }
                column(DocumentType; "Document Type") { }
                column(CreditAmount; "Credit Amount") { }

            }



            trigger OnPreDataItem()
            begin
                if CompanyInformation.Get() then
                    CompanyInformation.CalcFields(Picture);
                CompanyInformation.Init();
            end;

            // Se ejecuta DESPUÉS de leer CADA factura
            trigger OnAfterGetRecord()
            var
                BlobInStream: InStream;
            begin
                WorkDescriptionAsText := '';
                if SalesHeader."Work Description".HasValue() then begin
                    SalesHeader.CalcFields("Work Description");
                    SalesHeader."Work Description".CreateInStream(BlobInStream);
                    BlobInStream.ReadText(WorkDescriptionAsText, 65001);

                    // Reemplazar caracteres corruptos comunes utilizando nuestra propia codificación, lo sorprendente es que funciona
                    WorkDescriptionAsText := DelChr(WorkDescriptionAsText, '<>'); // elimina saltos de línea
                    WorkDescriptionAsText := ConvertStr(WorkDescriptionAsText, 'Š', '¿'); // solo caracteres individuales
                    WorkDescriptionAsText := ConvertStr(WorkDescriptionAsText, '‡', 'ú'); // solo caracteres individuales
                    WorkDescriptionAsText := ConvertStr(WorkDescriptionAsText, 'Ž', 'í'); // solo caracteres individuales
                    WorkDescriptionAsText := WorkDescriptionAsText.Replace('í®', 'é');
                    WorkDescriptionAsText := WorkDescriptionAsText.Replace('í„', 'ó');
                    WorkDescriptionAsText := WorkDescriptionAsText.Replace('í‚', 'á');
                    WorkDescriptionAsText := WorkDescriptionAsText.Replace('íú', 'ú');
                    WorkDescriptionAsText := WorkDescriptionAsText.Replace('í¡', 'í');
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
        Factura = 'Factura';
        Cliente = 'Cliente:';
        FechaEmisionFactura = 'Fecha emisión factura:';
        NumFactura = 'Nº Factura:';
        DescTrab = 'Descripción del trabajo:';
        Concepto = 'Concepto';
        CantHoras = 'Cantidad / Horas de servicio';
        PrecUnit = 'Precio Unitario';
        TotalSin = 'Total sin impuesto';
        TipoImpuesto = 'Tipo impuesto';
        Totals = 'Total';
        TotalVATExcl = 'Total EUR VAT excl..';
        ImporteIVARE = 'Importe IVA+RE';
        TotalVATIncl = 'Total EUR VAT incl..';
        EspecImpIVA = 'Especificación importe IVA';
        IdIVA = 'Identificación IVA';
        BaseImponible = 'Base imponible';
        IVAPorcentage = '%IVA';
        CuotaIVA = 'Cuota IVA';
        TotalFactura = 'Total factura';
        ClauIVA = 'Cláusula de IVA';
        ImporteIVA = 'Importe IVA';
        Venc = 'Vencimientos';
        Fecha = 'Fecha';
        Importe = 'Importe';
        TermPago = 'Término de Pago:';
        FormPago = 'Forma de Pago:';
        Banco = 'Banco:';
        NumCuenta = 'Número de Cuenta (C.C.C.):';
    }

    var
        CompanyInformation: Record "Company Information";
        // Customer: Record Customer;
        VATPPG: Record "VAT Product Posting Group";
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        WorkDescriptionAsText: Text;
        IVAClause: Text;

        PaymentTermsDescription: Text;
        PaymentMethodDescription: Text;


}