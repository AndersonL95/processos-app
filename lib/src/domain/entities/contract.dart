class Contracts {
  late int? id;
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
  String addTerm = "";
  String addQuant = "";
  String companySituation = "";
  String userId = "";
  String file = "";

  Contracts(
      {this.id,
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
      required addTerm,
      required addQuant,
      required companySituation,
      required userId,
      required file}) {
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
    setAddTerm(addTerm);
    setAddQuant(addQuant);
    setCompanySituation(companySituation);
    setUserId(userId);
    setFile(file);
  }
  setNumProcess(numProcess) {
    if (this.numProcess.isEmpty) {
      throw Exception("numProcess está vazio ou é invalido.");
    }
    this.numProcess = numProcess;
  }

  setNumContract(numContract) {
    if (this.numContract.isEmpty) {
      throw Exception("numContract está vazio ou é invalido.");
    }
    this.numContract = numContract;
  }

  setManager(manager) {
    if (this.manager.isEmpty) {
      throw Exception("manager está vazio ou é invalido.");
    }
    this.manager = manager;
  }

  setSupervisor(supervisor) {
    if (this.supervisor.isEmpty) {
      throw Exception("supervisor está vazio ou é invalido.");
    }
    this.supervisor = supervisor;
  }

  setInitDate(initDate) {
    if (this.initDate.isEmpty) {
      throw Exception("initDate está vazio ou é invalido.");
    }
    this.initDate = initDate;
  }

  setFinalDate(finalDate) {
    if (this.finalDate.isEmpty) {
      throw Exception("finalDate está vazio ou é invalido.");
    }
    this.finalDate = finalDate;
  }

  setContractLaw(contractLaw) {
    if (this.contractLaw.isEmpty) {
      throw Exception("contractLaw está vazio ou é invalido.");
    }
    this.contractLaw = contractLaw;
  }

  setContractStatus(contractStatus) {
    if (this.contractStatus.isEmpty) {
      throw Exception("contractStatus está vazio ou é invalido.");
    }
    this.contractStatus = contractStatus;
  }

  setBalance(balance) {
    if (this.balance.isEmpty) {
      throw Exception("balance está vazio ou é invalido.");
    }
    this.balance = balance;
  }

  setTodo(todo) {
    if (this.todo.isEmpty) {
      throw Exception("todo está vazio ou é invalido.");
    }
    this.todo = todo;
  }

  setAddTerm(addTerm) {
    if (this.addTerm.isEmpty) {
      throw Exception("addTerm está vazio ou é invalido.");
    }
    this.addTerm = addTerm;
  }

  setAddQuant(addQuant) {
    if (this.addQuant.isEmpty) {
      throw Exception("addQuant está vazio ou é invalido.");
    }
    this.addQuant = addQuant;
  }

  setCompanySituation(companySituation) {
    if (this.companySituation.isEmpty) {
      throw Exception("companySituation está vazio ou é invalido.");
    }
    this.companySituation = companySituation;
  }

  setUserId(userId) {
    if (this.userId.isEmpty) {
      throw Exception("userId está vazio ou é invalido.");
    }
    this.userId = userId;
  }

  setFile(file) {
    if (this.file.isEmpty) {
      throw Exception("file está vazio ou é invalido.");
    }
    this.file = file;
  }

  Map<String, dynamic> toJson() {
    return {
      numProcess: numProcess,
      numContract: numContract,
      manager: manager,
      supervisor: supervisor,
      initDate: initDate,
      finalDate: finalDate,
      contractLaw: contractLaw,
      contractStatus: contractStatus,
      balance: balance,
      todo: todo,
      addTerm: addTerm,
      addQuant: addQuant,
      companySituation: companySituation,
      userId: userId,
      file: file
    };
  }

  factory Contracts.froJson(Map<String, dynamic> json) {
    return Contracts(
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
        addTerm: json['addTerm'],
        addQuant: json['addQuant'],
        companySituation: json['companySituation'],
        userId: json['userId'],
        file: json['file']);
  }
}
