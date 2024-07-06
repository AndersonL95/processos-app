import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewPage extends StatefulWidget {
  String? pdfPath;

  PdfViewPage({required this.pdfPath});

  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  @override
  void initState() {
    super.initState();
    print("-----PDF-----");
    print(widget.pdfPath);
  }

  final Completer<PDFViewController> controller =
      Completer<PDFViewController>();
  int? currentPage = 0;
  int? page = 0;
  bool isReady = false;
  String erroMsg = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("PDF"),
        ),
        body: Stack(
          children: [
            PDFView(
              filePath: widget.pdfPath,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: true,
              pageSnap: true,
              defaultPage: currentPage!,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
              onRender: (_pages) {
                setState(() {
                  page = _pages;
                  isReady = true;
                });
              },
              onError: (_error) {
                setState(() {
                  erroMsg = _error;
                });
                print("PDFERROR: ${erroMsg.toString()}");
              },
              onPageError: (page, error) {
                setState(() {
                  erroMsg = '$page: ${erroMsg.toString()}';
                });
                print("$page: ${erroMsg.toString()}");
              },
              onViewCreated: (PDFViewController pdfViewController) {
                controller.complete(pdfViewController);
              },
              onPageChanged: (int? page, int? total) {
                setState(() {
                  currentPage = page;
                });
              },
            ),
            erroMsg.isEmpty
                ? !isReady
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container()
                : Center(
                    child: Text(erroMsg),
                  )
          ],
        ));
  }
}
 
 /**localFilePath != null
            ? PDFView(
                filePath: localFilePath,
                onRender: (pages) {
                  setState(() {
                    this.page = pages;
                  });
                },
                onViewCreated: (controller) {
                  setState(() {
                    pdfViewController = controller;
                  });
                },
                onPageChanged: (page, total) {
                  setState(() {
                    currentPage = page;
                  });
                },
                onError: (error) {
                  print("PDFERROR: ${error.toString()}");
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              ) */