import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/family_profile_entity.dart';
import '../repositories/family_profile_repository.dart';

class SaveFamilyProfile {
  final FamilyProfileRepository repository;

  SaveFamilyProfile(this.repository);

  Future<Either<Failure, void>> call(FamilyFinanceProfile profile) {
    return repository.saveFamilyProfile(profile);
  }
}
