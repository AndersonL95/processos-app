class Sector {
  late int? id;
  int? tenantId;
  String name;

  Sector({
    this.id,
    this.tenantId,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "tenantId": tenantId,
      "name": name,
    };
  }

  factory Sector.fromJson(Map<String, dynamic> json) {
 return Sector(
      name: json['name'].toString(),
      id: json['id']
    );
}
}