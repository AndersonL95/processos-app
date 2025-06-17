import 'package:docInHand/src/application/constants/colors.dart';
import 'package:docInHand/src/domain/entities/addTerms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AddTermModal extends StatefulWidget {
  final Function(AddTerm) onAddTerm;

  const AddTermModal({super.key, required this.onAddTerm});

  @override
  State<AddTermModal> createState() => _AddTermModalState();
}

class _AddTermModalState extends State<AddTermModal> {
  final TextEditingController _nameController = TextEditingController();
  String? selectedFilePath;
  List<AddTerm> localTerms = [];

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

  void _addTerm() {
    if (_nameController.text.isNotEmpty && selectedFilePath != null) {
      final newTerm = AddTerm(
        nameTerm: _nameController.text,
        file: selectedFilePath!,
      );

      widget.onAddTerm(newTerm);

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
      title: const Text('Adicionar Aditivo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           TextField(
              controller: _nameController,
              decoration: InputDecoration(
               iconColor: customColors['green'],
               prefixIconColor: customColors['green'],
               fillColor: Colors.white60,
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
               ElevatedButton(
              onPressed: _pickFile,
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
             
            ),
            ElevatedButton(
              onPressed: _addTerm,
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
                        const Text('Aditivos adicionados:'),
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
           
       Padding(padding: EdgeInsets.only(top: 20),
          child: ElevatedButton(
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
        ),
           
          ],
        ),
      ),
      
    );
  }
}
