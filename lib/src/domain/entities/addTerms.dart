class AddTerm {
  int? id;
  String name;
  String? file;

  AddTerm({this.id, required this.name, this.file});

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'file': file,
      };

  factory AddTerm.fromJson(Map<String, dynamic> json) => AddTerm(
        id: json['id'],
        name: json['name'],
        file: json['file'],
      );
}
