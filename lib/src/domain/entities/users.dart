class Users {
  int id;
  int? tenantId;
  String username;
  String email;
  String password;
  String name;
  String cpf;
  String cargo;
  String phone;
  String photo;
  String role;

  Users(
      {required this.id,
      this.tenantId,
      required this.username,
      required this.email,
      required this.password,
      required this.name,
      this.cpf = "",
      this.cargo = "",
      this.phone = "",
      this.photo = "",
      this.role = ""});

  void setUsername(String username) {
    if (username.isEmpty) {
      throw Exception("Username está vazio ou é invalido.");
    }
    this.username = username;
  }

  void setEmail(String email) {
    if (email.isEmpty) {
      throw Exception("E-mail está vazio ou é invalido.");
    }
    this.email = email;
  }

  void setPassword(String password) {
    if (password.isEmpty) {
      throw Exception("Senha está vazia ou é inválida.");
    }
    this.password = password;
  }

  void setName(String name) {
    if (name.isEmpty) {
      throw Exception("Nome está vazio ou é invalido.");
    }
    this.name = name;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "tenantId": tenantId,
      "username": username,
      "email": email,
      "password": password,
      "name": name,
      "cpf": cpf,
      "cargo": cargo,
      "phone": phone,
      "photo": photo,
      "role": role
    };
  }

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
        id: json['id'] ?? 0,
        username: json['username'] ?? "",
        email: json['email'] ?? "",
        password: json['password'] ?? "",
        name: json['name'] ?? "",
        cpf: json['cpf'] ?? "",
        cargo: json['cargo'] ?? "",
        phone: json['phone'] ?? "",
        photo: json['photo'] ?? "",
        role: json['role'] ?? "");
  }
}
