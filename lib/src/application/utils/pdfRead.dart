import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<File> pathFile({required String fileBase64, required String fileName}) async {
  try {
    final bytes = base64Decode(fileBase64.replaceAll('\n', ''));
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.pdf');
    await file.writeAsBytes(bytes.buffer.asUint8List());
    return file;
  } catch (e) {
    throw Exception("Erro ao salvar PDF: $e");
  }
}
