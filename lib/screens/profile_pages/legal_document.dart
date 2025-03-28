import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class LegalDocument extends StatefulWidget {
  const LegalDocument({super.key});

  @override
  State<LegalDocument> createState() => _LegalDocumentState();
}

class _LegalDocumentState extends State<LegalDocument> {
  String localPath = "";

  @override
  void initState() {
    super.initState();
    loadPDF();
  }

  Future<void> loadPDF() async {
    final ByteData data = await rootBundle.load("assets/ab.pdf");
    final Uint8List bytes = data.buffer.asUint8List();
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/Introduction.pdf");
    await file.writeAsBytes(bytes, flush: true);

    setState(() {
      localPath = file.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Documento Legal",
        style: TextStyle(fontSize: 15),
      )),
      body: localPath.isEmpty
          ? Center(child: CircularProgressIndicator())
          : PDFView(
              filePath: localPath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageSnap: true,
              fitPolicy: FitPolicy.BOTH,
            ),
    );
  }
}
