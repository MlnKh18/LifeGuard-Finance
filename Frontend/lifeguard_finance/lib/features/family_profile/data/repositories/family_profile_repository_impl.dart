import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/data/local/hive_service.dart';
import '../../../../core/data/local/local_keys.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/family_profile_entity.dart';
import '../../domain/repositories/family_profile_repository.dart';
import '../models/family_profile_model.dart';

import '../../../../core/network/api_client.dart';

class FamilyProfileRepositoryImpl implements FamilyProfileRepository {
  final HiveService hiveService;
  final ApiClient apiClient;

  FamilyProfileRepositoryImpl({
    required this.hiveService,
    required this.apiClient,
  });

  @override
  Future<Either<Failure, void>> saveFamilyProfile(FamilyFinanceProfile profile) async {
    try {
      // Invalidate dependent caches first to avoid race conditions with watchers
      await hiveService.deleteData(LocalKeys.recommendations);
      await hiveService.deleteData(LocalKeys.emergencySimulation);
      await hiveService.deleteData('${LocalKeys.emergencySimulation}_input');
      await hiveService.deleteData(LocalKeys.fvsScore);

      final model = FamilyFinanceProfileModel.fromEntity(profile);
      await hiveService.saveData(LocalKeys.familyProfile, model.toJson());
      
      // Sync to API
      try {
        await apiClient.dio.post('/profiles', data: model.toJson());
      } catch (e) {
        // debugPrint('Profile API Sync Error: $e');
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Gagal menyimpan profil keuangan keluarga: $e'));
    }
  }

  @override
  Future<Either<Failure, FamilyFinanceProfile?>> getFamilyProfile() async {
    try {
      // Sync with API in background
      apiClient.dio.get('/profiles').catchError((e) => debugPrint('Sync error'));

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
