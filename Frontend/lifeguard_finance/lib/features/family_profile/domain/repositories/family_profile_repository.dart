import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/family_profile_entity.dart';

abstract class FamilyProfileRepository {
  Future<Either<Failure, void>> saveFamilyProfile(FamilyFinanceProfile profile);
  Future<Either<Failure, FamilyFinanceProfile?>> getFamilyProfile();
}
