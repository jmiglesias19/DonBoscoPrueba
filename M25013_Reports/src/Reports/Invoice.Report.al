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

            // --- INICIO DEL CAMBIO (BLOB) ---
            // 1. Comentamos o eliminamos la columna BLOB que da error
            // column(WorkDescription; "Work Description") { }

            // 2. Añadimos la nueva columna que apunta a nuestra variable de texto
            column(WorkDescription_Text; WorkDescriptionAsText) { }
            // --- FIN DEL CAMBIO ---

            column(CustomerNumber; Customer."No.") { }
            column(CustomerName; "Sell-to Customer Name") { }
            column(CustomerAddress; "Sell-to Address") { }
            column(PCAndCity; "Sell-to Post Code" + ' ' + "Sell-to City") { }
            column(CIF; "VAT Registration No.") { }

            // Se ejecuta ANTES de empezar a leer las facturas
            trigger OnPreDataItem()
            begin
                // Cargamos la info de la compañía UNA SOLA VEZ
                if not CompanyInformation.Get() then
                    CompanyInformation.Init();
            end;

            // Se ejecuta DESPUÉS de leer CADA factura
            trigger OnAfterGetRecord()
            var
                // Variable local para el stream
                BlobInStream: InStream;
            begin
                // Lógica que ya tenías
                CompanyInformation.CalcFields(Picture);
                if not Customer.Get("Bill-to Customer No.") then
                    Customer.Init();

                // --- INICIO LÓGICA BLOB A TEXTO ---

                // 3. Limpiamos la variable para este registro
                WorkDescriptionAsText := '';

                // 4. Comprobamos si el campo BLOB tiene contenido
                if SalesInvoiceHeader."Work Description".HasValue() then begin

                    // 5. Cargamos el campo BLOB (necesario como con las imágenes)
                    SalesInvoiceHeader.CalcFields("Work Description");

                    // 6. Creamos un InStream (tubería de lectura)
                    SalesInvoiceHeader."Work Description".CreateInStream(BlobInStream);

                    // 7. Leemos todo el contenido del BLOB y lo metemos en la variable BigText
                    BlobInStream.Read(WorkDescriptionAsText);
                end;
                // --- FIN LÓGICA BLOB A TEXTO ---
            end;
        }

        // ... (resto de tu dataitem de líneas si lo tuvieras) ...
    }

    // ... (labels) ...

    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;

        // --- 8. VARIABLE GLOBAL AÑADIDA ---
        // Aquí guardaremos el texto del BLOB
        WorkDescriptionAsText: Text;
}