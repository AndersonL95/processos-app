import 'package:docInHand/src/domain/entities/addTerms.dart';
import 'package:docInHand/src/infrastucture/addTerm.dart';

class CreateTerms {
  final ApiAddTermService apiAddTermsService;

  CreateTerms(this.apiAddTermsService);

  Future execute(AddTerm addTerm) async {
    var termData = await apiAddTermsService.createTerm(addTerm);
    return termData;
  }
}
