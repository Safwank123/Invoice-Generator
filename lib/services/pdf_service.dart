import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/product_model.dart';

class PDFService {
  Future<File> generateInvoicePDF({
    required String userName,
    required String userEmail,
    required List<Product> selectedProducts,
  }) async {
    final pdf = pw.Document();
    final total = selectedProducts.fold(0.0, (sum, p) => sum + p.price);

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Invoice", style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 10),
            pw.Text("Name: $userName"),
            pw.Text("Email: $userEmail"),
            pw.SizedBox(height: 20),
            pw.Text("Products:", style: pw.TextStyle(fontSize: 18)),
            pw.ListView.builder(
              itemCount: selectedProducts.length,
              itemBuilder: (context, index) {
                final product = selectedProducts[index];
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(product.name),
                    pw.Text("₹${product.price.toStringAsFixed(2)}"),
                  ],
                );
              },
            ),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text("Total: ₹${total.toStringAsFixed(2)}",
                  style: pw.TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/invoice.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
