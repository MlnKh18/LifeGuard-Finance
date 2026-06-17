import 'package:dartz/dartz.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/family_profile_entity.dart';
import '../../domain/repositories/family_profile_repository.dart';
import '../models/family_profile_model.dart';

class FamilyProfileRepositoryImpl implements FamilyProfileRepository {
  final HiveService hiveService;

  FamilyProfileRepositoryImpl(this.hiveService);

  @override
  Future<Either<Failure, void>> saveFamilyProfile(FamilyFinanceProfile profile) async {
    try {
      final model = FamilyFinanceProfileModel.fromEntity(profile);
      await hiveService.saveData(LocalKeys.familyProfile, model.toJson());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Gagal menyimpan profil keuangan keluarga: $e'));
    }
  }

  @override
  Future<Either<Failure, FamilyFinanceProfile?>> getFamilyProfile() async {
    try {
      final rawData = hiveService.getData(LocalKeys.familyProfile);
      if (rawData == null) {
        return const Right(null);
      }
      
      final jsonMap = Map<String, dynamic>.from(rawData as Map);
      final model = FamilyFinanceProfileModel.fromJson(jsonMap);
      return Right(model);
    } catch (e) {
      return Left(CacheFailure('Gagal memuat profil keuangan keluarga: $e'));
    }
  }
}
