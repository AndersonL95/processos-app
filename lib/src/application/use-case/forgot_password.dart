import 'package:docInHand/src/domain/entities/users.dart';
import 'package:docInHand/src/infrastucture/users.dart';

class ForgotPassword {
  final ApiService apiService;

  ForgotPassword(this.apiService);

  Future execute(String email) async {
    var userData = await apiService.sendForgotPasswordEmail(email);
    return userData;
  }
}
