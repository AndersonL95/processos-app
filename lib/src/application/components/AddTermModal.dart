import 'package:docInHand/src/application/constants/colors.dart';
import 'package:docInHand/src/application/screens/pdfView.dart';
import 'package:docInHand/src/application/utils/pdfRead.dart';
import 'package:docInHand/src/domain/entities/addTerms.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTermModalButton extends StatelessWidget {
  final List<AddTerm> dataTerm;
 
  const AddTermModalButton({
    super.key,
    required this.dataTerm,
    
  });

  void _openModal(BuildContext context) {
    String dateFormatt(String value) {

  if (value.isEmpty) return '';
  if (value.contains('T') && value.contains('Z')) {
    try {
      final date = DateTime.parse(value);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return value;
    }
  }

 
  return value;
}
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(term.nameTerm ?? "Sem nome", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                              Text( "Prazo final: ${dateFormatt(term.newTermDate)}" ?? "Sem nome", style:TextStyle(fontSize: 14, color: customColors['green']) ,),
                            ],
                          )
                        
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
                          if (!context.mounted) return; 

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PdfViewPage(
                                    pdfPath: file.path,
                                    pdfBytes: null,
                                  ),
                                ),
                              );
                        }catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
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
