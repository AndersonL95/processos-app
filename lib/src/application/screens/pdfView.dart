import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:toastification/toastification.dart';

class PdfViewPage extends StatefulWidget {
  String? pdfPath;
  final pdfBytes;

  PdfViewPage({required this.pdfPath, required this.pdfBytes});

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

  Future<File> savePdf() async {
    Completer<File> completer = Completer();
    try {
      var url = widget.pdfBytes['id'];
      var bytes =
          base64Decode(widget.pdfBytes['file'].toString().replaceAll('\n', ''));
      final dir = await getDownloadsDirectory();
      File file = File("${dir?.path}/${url.toString()}.pdf");
      await file.writeAsBytes(bytes.buffer.asUint8List());

      completer.complete(file);

      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        context: context,
        title: const Text("PDF salvo."),
        autoCloseDuration: const Duration(seconds: 3),
      );
    } catch (e) {
      print("Erro: $e");
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        context: context,
        title: const Text("Erro ao salvar PDF."),
        autoCloseDuration: const Duration(seconds: 5),
      );
    }
    return completer.future;
  }

  Future<void> printPdf() async {
    var bytes =
        base64Decode(widget.pdfBytes['file'].toString().replaceAll('\n', ''));

    try {
      await Printing.layoutPdf(onLayout: (format) async => bytes);
    } catch (e) {
      print("ERRO: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text(
                  "DocInHand",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              )),
          toolbarHeight: 120,
          centerTitle: false,
          backgroundColor: customColors['green'],
          elevation: 0,
          automaticallyImplyLeading: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: PopupMenuButton(
                iconSize: 45,
                onSelected: (value) {
                  setState(() {});
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                        child: InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.download,
                            color: customColors['green'],
                          ),
                          Text(
                            "Download",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      onTap: () => {savePdf()},
                    )),
                    PopupMenuItem(
                        child: InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.print,
                            color: customColors['green'],
                          ),
                          Text(
                            "Imprimir",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      onTap: () => {printPdf()},
                    )),
                  ];
                },
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            PDFView(
              filePath: widget.pdfPath,
              enableSwipe: true,
              swipeHorizontal: false,
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