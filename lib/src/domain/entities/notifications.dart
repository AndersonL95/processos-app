class Notification {
  late int? id;
  late int? contractId;
  int? tenantId;
  String message;
  bool read = false;
  DateTime createdAt;

  Notification(
      {this.id,
      this.contractId,
      this.tenantId,
      required this.message,
      required this.read,
      required this.createdAt});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "tenantId": tenantId,
      "contractId": contractId,
      "message": message,
      "read": read,
      "createdAt": createdAt
    };
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
        id: json['id'] ?? 0,
        tenantId: json['tenantId'] ?? 0,
        contractId: json['contractId'] ?? 0,
        message: json['message'] ?? "",
        read: json['read'] ?? false,
        createdAt: json['createAt'] ?? "");
  }
}
