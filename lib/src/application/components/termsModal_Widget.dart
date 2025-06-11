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
              decoration: const InputDecoration(labelText: 'Nome:'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text(
                'Selecionar Arquivo PDF',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: customColors['green']!,
              ),
            ),
            if (selectedFilePath != null)
              Text(
                'Arquivo selecionado: ${selectedFilePath!.split('/').last}',
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTerm,
              child: const Text(
                'Adicionar à Lista',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: customColors['green']!,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Aditivos adicionados:'),
            ...localTerms.map((term) => ListTile(
                  title: Text(term.nameTerm ?? 'Sem nome'),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
