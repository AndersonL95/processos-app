import 'dart:convert';
import 'dart:io';

import 'package:docInHand/src/application/constants/colors.dart';
import 'package:docInHand/src/domain/entities/addTerms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class EditTermModal extends StatefulWidget {
  final List<AddTerm> existingTerms;
  final Function(List<AddTerm>) onTermsUpdated;

  const EditTermModal({
    super.key,
    required this.existingTerms,
    required this.onTermsUpdated,
  });

  @override
  State<EditTermModal> createState() => _EditTermModalState();
}

class _EditTermModalState extends State<EditTermModal> {
  final TextEditingController _nameController = TextEditingController();
  String? selectedFilePath;
  late List<AddTerm> localTerms;

  @override
  void initState() {
    super.initState();
    localTerms = List.from(widget.existingTerms);
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFilePath = result.files.single.path!;
      });
    }
  }



void _addTerm() async {
  if (_nameController.text.isNotEmpty && selectedFilePath != null) {
    final fileBytes = await File(selectedFilePath!).readAsBytes();
    final base64File = base64Encode(fileBytes);

    final newTerm = AddTerm(
      nameTerm: _nameController.text,
      file: base64File, // Agora o arquivo é base64
    );

    setState(() {
      localTerms.add(newTerm);
      _nameController.clear();
      selectedFilePath = null;
    });
  }
}


  void _removeTerm(AddTerm term) {
    setState(() {
      localTerms.remove(term);
    });
  }
   String breakLines(String input) {
    List<String> lines = [];
    for (int i = 0; i < input.length; i += 20) {
      int endIndex = i + 20;
      if (endIndex > input.length) {
        endIndex = input.length;
      }
      lines.add(input.substring(i, endIndex));
    }
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Editar Aditivos'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
               iconColor: customColors['green'],
               prefixIconColor: customColors['green'],
               fillColor: customColors['white'],
               hoverColor: customColors['green'],
               filled: true,
               focusColor: customColors['green'],
               labelText: "Nome",
               hintText: "Cadastrar nome",
               prefixIcon: const Icon(Icons.abc_rounded),
               enabledBorder: new OutlineInputBorder(
                 borderSide: BorderSide(
                     color: Color.fromRGBO(1, 76, 45, 1),
                     width: 2),
                 borderRadius: BorderRadius.all(
                   Radius.circular(10),
                 ),
               )),
            ),
            const SizedBox(height: 12),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
                Padding(padding: EdgeInsets.all(1),
                child: Column(
                  children: [
                    ElevatedButton(
                  child: Icon(
                     Icons.picture_as_pdf,
                     size: 25,
                     color:
                         customColors['white'],
                   ),
                  style: ElevatedButton
                   .styleFrom(
                       backgroundColor: selectedFilePath != null ?
                           Colors.green :customColors[
                               "crismon"],
                       shape:
                           RoundedRectangleBorder(
                         borderRadius:
                             BorderRadius
                                 .circular(
                                     10),
                       ),
                       minimumSize:
                           const Size(
                               100, 40)),
                    onPressed: _pickFile,
                ),
                  ],
                ),),
               ElevatedButton(
                style: ElevatedButton
                  .styleFrom(
                      backgroundColor:
                          customColors[
                              "green"],
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    10),
                      ),
                      minimumSize:
                          const Size(
                              100, 40)),
                onPressed: _addTerm,
                child: Icon(
                    Icons.playlist_add,
                    size: 25,
                    color:
                        customColors['white'],
                  ),
                ),
            ],
           ),
            Padding(padding: EdgeInsets.only(top: 20),
              child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(10))),
              clipBehavior: Clip.antiAlias,
              elevation: 2,
              color: Colors.white,
              
              child: SizedBox(
                  width: 290,
                  child: Column(
                    children: [
                       ...localTerms.map((term) {
                          return ListTile(
                            title: Text(breakLines(term.nameTerm) ?? 'Sem nome'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_sweep, color: Colors.red),
                              onPressed: () => _removeTerm(term),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                )
            ),
            ),
           
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton
                .styleFrom(
                    backgroundColor:
                       Colors.red,
                    shape:
                        CircleBorder(),
                    minimumSize:
                        const Size(
                            10, 40)),
              onPressed: (){ Navigator.pop(context);},
              child: Icon(Icons.cancel, size: 20, color: customColors['white'],)
            ),
            
            Padding(padding: EdgeInsets.only(right: 0),
              child: ElevatedButton(
                      child: Icon(Icons.save, size: 25, color: customColors['white'],),
                      style: ElevatedButton
                            .styleFrom(
                                backgroundColor:
                                    Colors.green,
                                shape:
                                  CircleBorder(),
                                minimumSize:
                                    const Size(
                                        10, 40)),
                      onPressed: () {
                        widget.onTermsUpdated(localTerms);
                        Navigator.pop(context);
                      },
                ),
            ),
          ],
        )
      ],
    );
  }
}
