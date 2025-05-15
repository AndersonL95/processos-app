class AddTerm {
  final String nameTerm;
  late final String file;

  AddTerm({required this.nameTerm, required this.file});

  factory AddTerm.fromJson(Map<String, dynamic> json) {
    return AddTerm(
      nameTerm: json['name'].toString(),
      file: json['file'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': nameTerm,
      'file': file,
    };
  }
}
