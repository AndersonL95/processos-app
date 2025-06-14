import 'package:docInHand/src/application/screens/pdfView.dart';
import 'package:docInHand/src/application/utils/pdfRead.dart';
import 'package:docInHand/src/domain/entities/addTerms.dart';
import 'package:flutter/material.dart';

class AddTermModalButton extends StatelessWidget {
  final List<AddTerm> dataTerm;
 
  const AddTermModalButton({
    super.key,
    required this.dataTerm,
    
  });

  void _openModal(BuildContext context) {
     String pathPDF = "";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Aditivos",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (dataTerm.isEmpty)
                const Text("Nenhum aditivo disponível."),
              if (dataTerm.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: dataTerm.length,
                  itemBuilder: (context, index) {
                    final term = dataTerm[index];
                    return ListTile(
                      title: Row(
                        children: [
                          Padding(padding: EdgeInsets.all(10),
                            child: Image.asset('Assets/images/pdf.png',scale: 10.0,)
                          ),
                          Text(term.nameTerm ?? "Sem nome"),
                        
                        ],
                      ),
                      onTap: () async {
                        final currentContext = context;
                      
                        Navigator.of(currentContext).pop();
                      
                        try {
                          final file = await pathFile(
                            fileBase64: term.file,
                            fileName: 'aditivo_${term.id}',
                          );
                          Navigator.push(
                            currentContext,
                            MaterialPageRoute(
                              builder: (_) => PdfViewPage(
                                pdfPath: file.path,
                                pdfBytes: null,
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(currentContext).showSnackBar(
                            SnackBar(content: Text("Erro ao abrir PDF: $e")),
                          );
                        }
                      }

                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          if(dataTerm.isNotEmpty)
          Padding(padding: EdgeInsets.all(0),
          child: InkWell(
            onTap: () => _openModal(context),
            child: Image.asset(
              'Assets/images/aditivos.png',
              scale: 9.0,
            ),
      ),),
      if(dataTerm.isEmpty)
        Image.asset(
              'Assets/images/empty.png',
              scale: 9.0,
            ),
        ],
      )
    );
  }
}
