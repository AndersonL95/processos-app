import 'package:docInHand/src/domain/entities/addTerms.dart';

class Contracts {
  late int? id;
  late int? tenantId;
  String name = "";
  String numProcess = "";
  String numContract = "";
  String manager = "";
  String supervisor = "";
  String initDate = "";
  String finalDate = "";
  String contractLaw = "";
  String contractStatus = "";
  String balance = "";
  String todo = "";
  String addQuant = "";
  String companySituation = "";
  String sector = "";
  String active = "";
  late int userId;
  String file = "";
  List<AddTerm>? addTerm;

  Contracts(
      {this.id,
      this.tenantId,
      required name,
      required numProcess,
      required numContract,
      required manager,
      required supervisor,
      required initDate,
      required finalDate,
      required contractLaw,
      required contractStatus,
      required balance,
      required todo,
      this.addTerm,
      required addQuant,
      required companySituation,
      required userId,
      required sector,
      required active,
      required this.file}) {
    setName(name);
    setNumProcess(numProcess);
    setNumContract(numContract);
    setManager(manager);
    setSupervisor(supervisor);
    setInitDate(initDate);
    setFinalDate(finalDate);
    setContractLaw(contractLaw);
    setContractStatus(contractStatus);
    setBalance(balance);
    setTodo(todo);
    setAddQuant(addQuant);
    setCompanySituation(companySituation);
    setSector(sector);
    setUserId(userId);
    setFile(file);
  }
  void setName(name) {
    if (name == "") {
      throw Exception("Nome está vazio ou é invalido.");
    }
    this.name = name;
  }

  void setSector(sector) {
    if (sector == "") {
      throw Exception("Setor está vazio ou é invalido.");
    }
    this.sector = sector;
  }

  void setNumProcess(numProcess) {
    if (numProcess == "") {
      throw Exception("numProcess está vazio ou é invalido.");
    }
    this.numProcess = numProcess;
  }

  void setNumContract(numContract) {
    if (numContract == "") {
      throw Exception("numContract está vazio ou é invalido.");
    }
    this.numContract = numContract;
  }

  void setManager(manager) {
    if (manager == "") {
      throw Exception("manager está vazio ou é invalido.");
    }
    this.manager = manager;
  }

  void setSupervisor(supervisor) {
    if (supervisor == "") {
      throw Exception("supervisor está vazio ou é invalido.");
    }
    this.supervisor = supervisor;
  }

  void setInitDate(initDate) {
    if (initDate == "") {
      throw Exception("initDate está vazio ou é invalido.");
    }
    this.initDate = initDate;
  }

  void setFinalDate(finalDate) {
    if (finalDate == "") {
      throw Exception("finalDate está vazio ou é invalido.");
    }
    this.finalDate = finalDate;
  }

  void setContractLaw(contractLaw) {
    if (contractLaw == "") {
      throw Exception("contractLaw está vazio ou é invalido.");
    }
    this.contractLaw = contractLaw;
  }

  void setContractStatus(contractStatus) {
    if (contractStatus == "") {
      throw Exception("contractStatus está vazio ou é invalido.");
    }
    this.contractStatus = contractStatus;
  }

  void setBalance(balance) {
    if (balance == "") {
      throw Exception("balance está vazio ou é invalido.");
    }
    this.balance = balance;
  }

  void setTodo(todo) {
    if (todo == "") {
      throw Exception("todo está vazio ou é invalido.");
    }
    this.todo = todo;
  }

  void setAddQuant(addQuant) {
    if (addQuant == "") {
      throw Exception("addQuant está vazio ou é invalido.");
    }
    this.addQuant = addQuant;
  }

  void setCompanySituation(companySituation) {
    if (companySituation == "") {
      throw Exception("companySituation está vazio ou é invalido.");
    }
    this.companySituation = companySituation;
  }

  void setUserId(userId) {
    if (userId == null) {
      throw Exception("userId está vazio ou é invalido.");
    }
    this.userId = userId;
  }

  void setFile(file) {
    if (file == "") {
      throw Exception("file está vazio ou é invalido.");
    }
    this.file = file;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'name': name,
      'numProcess': numProcess,
      'numContract': numContract,
      'manager': manager,
      'supervisor': supervisor,
      'initDate': initDate,
      'finalDate': finalDate,
      'contractLaw': contractLaw,
      'contractStatus': contractStatus,
      'balance': balance,
      'todo': todo,
      'add_term': addTerm?.map((e) => e.toJson()).toList() ?? [],
      'addQuant': addQuant,
      'companySituation': companySituation,
      'userId': userId,
      'sector': sector,
      'active': active,
      'file': file
    };
  }

  factory Contracts.fromJson(Map<String, dynamic> json) {
    return Contracts(
        id: json['id'],
        name: json['name'],
        numProcess: json['numProcess'],
        numContract: json['numContract'],
        manager: json['manager'],
        supervisor: json['supervisor'],
        initDate: json['initDate'],
        finalDate: json['finalDate'],
        contractLaw: json['contractLaw'],
        contractStatus: json['contractStatus'],
        balance: json['balance'],
        todo: json['todo'],
        addTerm: json['add_term'] != null
            ? (json['add_term'] as List).map((e) => AddTerm.fromJson(e)).toList()
            : [],
        addQuant: json['addQuant'],
        companySituation: json['companySituation'],
        sector: json['sector'],
        active: json['active'],
        userId: json['userId'],
        file: json['file']);
  }
}
