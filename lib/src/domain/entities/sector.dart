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
      "username": name,
    };
  }

  factory Sector.fromJson(Map<String, dynamic> json) {
    return Sector(
      id: json['id'] ?? 0,
      tenantId: json['tenantId'] ?? 0,
      name: json['name'] ?? "",
    );
  }
}
