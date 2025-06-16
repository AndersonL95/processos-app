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

  void _addTerm() {
    if (_nameController.text.isNotEmpty && selectedFilePath != null) {
      final newTerm = AddTerm(
        nameTerm: _nameController.text,
        file: selectedFilePath!,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
            ElevatedButton(
               child: Icon(
                  Icons.picture_as_pdf,
                  size: 25,
                  color:
                      customColors['white'],
                ),
               style: ElevatedButton
                .styleFrom(
                    backgroundColor:
                        customColors[
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
                            160, 40)),
              onPressed: _pickFile,
            ),
            if (selectedFilePath != null)
              Text('Selecionado: ${selectedFilePath!.split('/').last}'),
            const SizedBox(height: 12),
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
                            160, 40)),
              onPressed: _addTerm,
              child: Icon(
                  Icons.playlist_add,
                  size: 25,
                  color:
                      customColors['white'],
                ),
            ),
            const SizedBox(height: 20),
            const Text("Aditivos atuais:",
            
            style: TextStyle(fontSize: 20),),
            ...localTerms.map((term) {
              return ListTile(
                title: Text(term.nameTerm ?? 'Sem nome'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.red),
                  onPressed: () => _removeTerm(term),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              style: ElevatedButton
                .styleFrom(
                    backgroundColor:
                        customColors[
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
              onPressed: (){ Navigator.pop(context);},
              child: Text("Cancelar", style: TextStyle(color: customColors['white']),)
            ),
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
                            90, 40)),
          onPressed: () {
            widget.onTermsUpdated(localTerms);
            Navigator.pop(context);
          },
          child: Text('Salvar', style: TextStyle(color: customColors['white']),),
        ),
          ],
        )
      ],
    );
  }
}
