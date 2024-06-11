import 'dart:convert';

class Users {
  int id = 0;
  String username = "";
  String email = "";
  String password = "";
  String name = "";
  String cpf = "";
  String cargo = "";
  String phone = "";

  Users(
      {id,
      required username,
      required email,
      required password,
      required name,
      cpf,
      cargo,
      phone}) {
    setEmail(email);
    setUsername(username);
    setPassword(password);
    setName(name);
  }
  setUsername(username) {
    if (this.username.isEmpty) {
      throw Exception("Username está vazio ou é invalido.");
    }
    this.username = username;
  }

  setEmail(email) {
    if (this.email.isEmpty) {
      throw Exception("E-mail está vazio ou é invalido.");
    }
    this.email = email;
  }

  setPassword(password) {
    if (this.password.isEmpty) {
      throw Exception("Senha está vazio ou é invalido.");
    }
    this.password = password;
  }

  setName(name) {
    if (this.name.isEmpty) {
      throw Exception("Nome está vazio ou é invalido.");
    }
  }

  Map<String, dynamic> toJson() {
    return {
      username: username,
      email: email,
      password: password,
      name: name,
      cpf: cpf,
      cargo: cargo,
      phone: phone
    };
  }

  factory Users.froJson(Map<String, dynamic> json) {
    return Users(
        username: json['username'],
        email: json['email'],
        password: json['password'],
        name: json['name'],
        cpf: json['cpg'],
        cargo: json['cargo']);
  }
}
