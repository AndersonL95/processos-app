class AddTerm {
  final String nameTerm;
  late final String file;

  AddTerm({required this.nameTerm, required this.file});

  factory AddTerm.fromJson(Map<String, dynamic> json) {
    return AddTerm(
      nameTerm: json['nameTerm'].toString(),
      file: json['file'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nameTerm': nameTerm,
      'file': file,
    };
  }
}
