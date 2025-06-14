import 'package:docInHand/src/domain/entities/addTerms.dart';
import 'package:flutter/material.dart';

class AddTermModalButton extends StatelessWidget {
  final List<AddTerm> dataTerm;

  const AddTermModalButton({
    super.key,
    required this.dataTerm,
  });

  void _openModal(BuildContext context) {
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
                      title: Text(term.nameTerm ?? "Sem nome"),
                      subtitle: Text("ID: ${term.id}, Contrato: ${term.contractId}"),
                      onTap: () {
                       
                        Navigator.pop(context); // Fecha o modal
                      
                        print("Selecionado: ${term.nameTerm}");
                      },
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
      child: InkWell(
        onTap: () => _openModal(context),
        child: Image.asset(
          'Assets/images/aditivos.png',
          scale: 9.0,
        ),
      ),
    );
  }
}
