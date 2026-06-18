import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lifeguard_finance/core/data/local/hive_service.dart';
import 'package:lifeguard_finance/core/data/local/local_keys.dart';
import 'package:lifeguard_finance/core/errors/failures.dart';
import 'package:lifeguard_finance/features/family_profile/domain/entities/family_profile_entity.dart';
import 'package:lifeguard_finance/features/family_profile/domain/repositories/family_profile_repository.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/data/datasources/fvs_calculator.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/presentation/bloc/fvs_bloc.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/presentation/bloc/fvs_event.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/presentation/bloc/fvs_state.dart';

class MockFamilyProfileRepository extends Mock implements FamilyProfileRepository {}

class MockHiveService extends Mock implements HiveService {}

void main() {
  late MockFamilyProfileRepository repository;
  late MockHiveService hiveService;

  final profile = const FamilyFinanceProfile(
    fixedIncome: 8000000,
    variableIncome: 0,
    routineExpenses: 4000000,
    debtPayments: 800000,
    liquidSavings: 12000000,
    totalDependents: 2,
    hasBpjs: true,
    hasAdditionalInsurance: true,
  );

  setUp(() {
    repository = MockFamilyProfileRepository();
    hiveService = MockHiveService();
    // saveData<T> is generic; mocktail matches on type arguments, so the two
    // distinct T's actually used by FvsBloc (dynamic for the raw previous-score
    // passthrough, Map<String, dynamic> for FvsScore.toJson()) need separate stubs.
    when(() => hiveService.saveData<dynamic>(any(), any())).thenAnswer((_) async {});
    when(() => hiveService.saveData<Map<String, dynamic>>(any(), any())).thenAnswer((_) async {});
  });

  FvsBloc buildBloc() => FvsBloc(
        familyProfileRepository: repository,
        fvsCalculator: const FvsCalculator(),
        hiveService: hiveService,
      );

  group('CalculateFvs', () {
    blocTest<FvsBloc, FvsState>(
      'emits [FvsLoading, FvsLoaded] and persists the new score when a profile exists',
      build: () {
        when(() => repository.getFamilyProfile()).thenAnswer((_) async => Right(profile));
        when(() => hiveService.getData(LocalKeys.fvsScore)).thenReturn(null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CalculateFvs()),
      expect: () => [isA<FvsLoading>(), isA<FvsLoaded>()],
      verify: (_) {
        verify(() => hiveService.saveData<Map<String, dynamic>>(LocalKeys.fvsScore, any())).called(1);
      },
    );

    blocTest<FvsBloc, FvsState>(
      'snapshots the previous score before overwriting it',
      build: () {
        when(() => repository.getFamilyProfile()).thenAnswer((_) async => Right(profile));
        when(() => hiveService.getData(LocalKeys.fvsScore)).thenReturn({'score': 50.0});
        return buildBloc();
      },
      act: (bloc) => bloc.add(CalculateFvs()),
      expect: () => [isA<FvsLoading>(), isA<FvsLoaded>()],
      verify: (_) {
        verify(() => hiveService.saveData<dynamic>(LocalKeys.previousFvsScore, {'score': 50.0})).called(1);
      },
    );

    blocTest<FvsBloc, FvsState>(
      'emits [FvsLoading, FvsNoProfile] when no family profile has been saved',
      build: () {
        when(() => repository.getFamilyProfile()).thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CalculateFvs()),
      expect: () => [isA<FvsLoading>(), isA<FvsNoProfile>()],
    );

    blocTest<FvsBloc, FvsState>(
      'emits [FvsLoading, FvsError] when the repository fails',
      build: () {
        when(() => repository.getFamilyProfile())
            .thenAnswer((_) async => const Left(CacheFailure('Gagal memuat profil')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CalculateFvs()),
      expect: () => [isA<FvsLoading>(), isA<FvsError>()],
    );
  });

  group('LoadFvs', () {
    blocTest<FvsBloc, FvsState>(
      'falls back to CalculateFvs when there is no cached score',
      build: () {
        when(() => hiveService.getData(LocalKeys.fvsScore)).thenReturn(null);
        when(() => repository.getFamilyProfile()).thenAnswer((_) async => Right(profile));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadFvs()),
      // Bloc skips re-emitting a state that equals the current one, so the
      // second FvsLoading() (emitted by the chained CalculateFvs handler) is
      // suppressed since FvsLoading is Equatable with empty props.
      expect: () => [isA<FvsLoading>(), isA<FvsLoaded>()],
    );

    blocTest<FvsBloc, FvsState>(
      'emits the cached score directly without recalculating when one exists',
      build: () {
        when(() => repository.getFamilyProfile()).thenAnswer((_) async => Right(profile));
        when(() => hiveService.getData(LocalKeys.fvsScore)).thenReturn(
          const FvsCalculator().calculate(profile).toJson(),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadFvs()),
      expect: () => [isA<FvsLoading>(), isA<FvsLoaded>()],
      verify: (_) {
        verifyNever(() => hiveService.saveData<Map<String, dynamic>>(LocalKeys.fvsScore, any()));
      },
    );
  });
}
