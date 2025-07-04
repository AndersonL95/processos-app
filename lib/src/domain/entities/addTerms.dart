class AddTerm {
  int? id;
  final String nameTerm;
  late final String file;
  final String newTermDate;
  int? contractId;

  AddTerm({required this.nameTerm, required this.newTermDate, required this.file, this.contractId, this.id});

  factory AddTerm.fromJson(Map<String, dynamic> json) {
    return AddTerm(
      nameTerm: json['nameTerm'].toString(),
      file: json['file'].toString(),
      newTermDate: json['newTermDate'],
      contractId: json['contractId'],
      id: json['id']
    );
  }

 Map<String, dynamic> toJson() {
  DateTime? parsedDate;

  // Tenta converter "03/07/2025" para um DateTime
  try {
    final parts = newTermDate.split('/');
    if (parts.length == 3) {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      parsedDate = DateTime(year, month, day);
    }
  } catch (_) {
    parsedDate = null;
  }

  return {
    'nameTerm': nameTerm,
    'file': file,
    'newTermDate': parsedDate?.toIso8601String() ?? newTermDate,
    if (contractId != null) 'contractId': contractId,
    if (id != null) 'id': id
  };
}

}
