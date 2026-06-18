import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lifeguard_finance/core/errors/failures.dart';
import 'package:lifeguard_finance/features/family_profile/domain/entities/family_profile_entity.dart';
import 'package:lifeguard_finance/features/family_profile/domain/repositories/family_profile_repository.dart';
import 'package:lifeguard_finance/features/family_profile/domain/usecases/get_family_profile.dart';
import 'package:lifeguard_finance/features/family_profile/domain/usecases/save_family_profile.dart';
import 'package:lifeguard_finance/features/family_profile/presentation/bloc/family_profile_bloc.dart';
import 'package:lifeguard_finance/features/family_profile/presentation/bloc/family_profile_event.dart';
import 'package:lifeguard_finance/features/family_profile/presentation/bloc/family_profile_state.dart';

class MockFamilyProfileRepository extends Mock implements FamilyProfileRepository {}

void main() {
  late MockFamilyProfileRepository repository;
  late GetFamilyProfile getFamilyProfile;
  late SaveFamilyProfile saveFamilyProfile;

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
    getFamilyProfile = GetFamilyProfile(repository);
    saveFamilyProfile = SaveFamilyProfile(repository);
  });

  FamilyProfileBloc buildBloc() => FamilyProfileBloc(
        getFamilyProfile: getFamilyProfile,
        saveFamilyProfile: saveFamilyProfile,
      );

  group('LoadFamilyProfile', () {
    blocTest<FamilyProfileBloc, FamilyProfileState>(
      'emits [Loading, Loaded] when a profile is found',
      build: () {
        when(() => repository.getFamilyProfile()).thenAnswer((_) async => Right(profile));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadFamilyProfile()),
      expect: () => [isA<FamilyProfileLoading>(), FamilyProfileLoaded(profile)],
    );

    blocTest<FamilyProfileBloc, FamilyProfileState>(
      'emits [Loading, Loaded(null)] when no profile has been saved yet',
      build: () {
        when(() => repository.getFamilyProfile()).thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadFamilyProfile()),
      expect: () => [isA<FamilyProfileLoading>(), const FamilyProfileLoaded(null)],
    );

    blocTest<FamilyProfileBloc, FamilyProfileState>(
      'emits [Loading, Error] when the repository fails',
      build: () {
        when(() => repository.getFamilyProfile())
            .thenAnswer((_) async => const Left(CacheFailure('Gagal memuat profil')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadFamilyProfile()),
      expect: () => [isA<FamilyProfileLoading>(), isA<FamilyProfileError>()],
    );
  });

  group('SaveFamilyProfileEvent', () {
    blocTest<FamilyProfileBloc, FamilyProfileState>(
      'emits [Loading, Saved] when the save succeeds',
      build: () {
        when(() => repository.saveFamilyProfile(profile)).thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(SaveFamilyProfileEvent(profile)),
      expect: () => [isA<FamilyProfileLoading>(), isA<FamilyProfileSaved>()],
      verify: (_) {
        verify(() => repository.saveFamilyProfile(profile)).called(1);
      },
    );

    blocTest<FamilyProfileBloc, FamilyProfileState>(
      'emits [Loading, Error] when the save fails',
      build: () {
        when(() => repository.saveFamilyProfile(profile))
            .thenAnswer((_) async => const Left(CacheFailure('Gagal menyimpan profil')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(SaveFamilyProfileEvent(profile)),
      expect: () => [isA<FamilyProfileLoading>(), isA<FamilyProfileError>()],
    );
  });
}
