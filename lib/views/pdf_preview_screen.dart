import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfPreviewScreen extends StatelessWidget {
  final File file;

  const PdfPreviewScreen({super.key, required this.file});

  /// Request MANAGE_EXTERNAL_STORAGE permission (Android 11+)
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      // For Android 11+, MANAGE_EXTERNAL_STORAGE needed to write to Downloads folder
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      } else {
        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      }
    }
    // iOS and others: no special permission required to write app documents directory
    return true;
  }

  Future<void> _downloadFile(BuildContext context) async {
    final hasPermission = await _requestPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Permission denied. Cannot save file."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      Directory? downloadsDirectory;

      if (Platform.isAndroid) {
        downloadsDirectory = Directory('/storage/emulated/0/Download');
      } else {
        // For iOS or other platforms, save to app documents directory
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      if (!await downloadsDirectory.exists()) {
        await downloadsDirectory.create(recursive: true);
      }

      final newPath =
          "${downloadsDirectory.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf";

      final newFile = await file.copy(newPath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PDF saved to Downloads: ${newFile.path}"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save PDF: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareFile() async {
    await Share.shareXFiles([XFile(file.path)], text: "Here's your invoice!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("PDF Preview"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SfPdfViewer.file(file),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _downloadFile(context),
                  icon: Icon(Icons.download),
                  label: Text("Download"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _shareFile,
                  icon: Icon(Icons.share),
                  label: Text("Share"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
