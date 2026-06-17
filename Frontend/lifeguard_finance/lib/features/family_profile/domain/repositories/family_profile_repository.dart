import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/family_profile_entity.dart';

abstract class FamilyProfileRepository {
  Future<Either<Failure, void>> saveFamilyProfile(FamilyProfileEntity profile);
  Future<Either<Failure, FamilyProfileEntity?>> getFamilyProfile();
}
