import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/family_profile_entity.dart';
import '../repositories/family_profile_repository.dart';

class GetFamilyProfile {
  final FamilyProfileRepository repository;

  GetFamilyProfile(this.repository);

  Future<Either<Failure, FamilyFinanceProfile?>> call() {
    return repository.getFamilyProfile();
  }
}
