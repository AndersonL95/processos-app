class AddTerm {
  int? id;
  final String nameTerm;
  late final String file;
  int? contractId;

  AddTerm({required this.nameTerm, required this.file, this.contractId, this.id});

  factory AddTerm.fromJson(Map<String, dynamic> json) {
    return AddTerm(
      nameTerm: json['nameTerm'].toString(),
      file: json['file'].toString(),
      contractId: json['contractId'],
      id: json['id']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nameTerm': nameTerm,
      'file': file,
      if(contractId != null) 'contractId': contractId,
      if(id != null) 'id': id
    };
  }
}
