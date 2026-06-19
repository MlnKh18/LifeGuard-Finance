import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/presentation/bloc/fvs_bloc.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/presentation/bloc/fvs_event.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/presentation/bloc/fvs_state.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/data/datasources/fvs_calculator.dart';
import 'package:lifeguard_finance/features/family_profile/domain/repositories/family_profile_repository.dart';
import 'package:lifeguard_finance/features/family_profile/domain/entities/family_profile_entity.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/domain/entities/fvs_score_entity.dart';
import 'package:lifeguard_finance/core/data/local/hive_service.dart';

class MockFamilyProfileRepository extends Mock implements FamilyProfileRepository {}
class MockFvsCalculator extends Mock implements FvsCalculator {}
class MockHiveService extends Mock implements HiveService {}

void main() {
  late MockFamilyProfileRepository mockProfileRepo;
  late MockFvsCalculator mockCalculator;
  late MockHiveService mockHiveService;
  late FvsBloc fvsBloc;

  setUp(() {
    mockProfileRepo = MockFamilyProfileRepository();
    mockCalculator = MockFvsCalculator();
    mockHiveService = MockHiveService();
    
    when(() => mockHiveService.watchKey(any())).thenAnswer((_) => const Stream.empty());
    when(() => mockHiveService.getData(any())).thenReturn(null);
    when(() => mockHiveService.saveData(any(), any())).thenAnswer((_) async {});
    
    fvsBloc = FvsBloc(
      familyProfileRepository: mockProfileRepo,
      fvsCalculator: mockCalculator,
      hiveService: mockHiveService,
    );
  });

  tearDown(() {
    fvsBloc.close();
  });

  group('FvsBloc Tests', () {
    final tProfile = FamilyFinanceProfile(
      fixedIncome: 10000000,
      variableIncome: 0,
      routineExpenses: 5000000,
      debtPayments: 0,
      liquidSavings: 50000000,
      totalDependents: 1,
      hasBpjs: true,
      hasAdditionalInsurance: true,
    );

    final tScore = FvsScore(
      score: 95.0,
      s1: 100, s2: 100, s3: 100, s4: 100, s5: 100, s6: 100, s7: 100,
      category: 'Aman',
      description: 'Desc',
    );

    blocTest<FvsBloc, FvsState>(
      'emits [FvsLoading, FvsLoaded] when LoadFvs is successful',
      build: () {
        when(() => mockProfileRepo.getFamilyProfile()).thenAnswer((_) async => Right(tProfile));
        when(() => mockCalculator.calculate(tProfile)).thenReturn(tScore);
        return fvsBloc;
      },
      act: (bloc) => bloc.add(LoadFvs()),
      expect: () => [
        isA<FvsLoading>(),
        isA<FvsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockProfileRepo.getFamilyProfile()).called(1);
        verify(() => mockCalculator.calculate(tProfile)).called(1);
      },
    );

    blocTest<FvsBloc, FvsState>(
      'emits [FvsLoading, FvsNoProfile] when no profile exists',
      build: () {
        when(() => mockProfileRepo.getFamilyProfile()).thenAnswer((_) async => const Right(null));
        return fvsBloc;
      },
      act: (bloc) => bloc.add(LoadFvs()),
      expect: () => [
        isA<FvsLoading>(),
        isA<FvsNoProfile>(),
      ],
    );
  });
}
