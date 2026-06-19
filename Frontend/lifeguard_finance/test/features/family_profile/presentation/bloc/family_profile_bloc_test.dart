import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:lifeguard_finance/features/family_profile/presentation/bloc/family_profile_bloc.dart';
import 'package:lifeguard_finance/features/family_profile/presentation/bloc/family_profile_event.dart';
import 'package:lifeguard_finance/features/family_profile/presentation/bloc/family_profile_state.dart';
import 'package:lifeguard_finance/features/family_profile/domain/usecases/get_family_profile.dart';
import 'package:lifeguard_finance/features/family_profile/domain/usecases/save_family_profile.dart';
import 'package:lifeguard_finance/features/family_profile/domain/entities/family_profile_entity.dart';

class MockGetFamilyProfile extends Mock implements GetFamilyProfile {}
class MockSaveFamilyProfile extends Mock implements SaveFamilyProfile {}

void main() {
  late MockGetFamilyProfile mockGet;
  late MockSaveFamilyProfile mockSave;
  late FamilyProfileBloc bloc;

  setUp(() {
    mockGet = MockGetFamilyProfile();
    mockSave = MockSaveFamilyProfile();
    bloc = FamilyProfileBloc(
      getFamilyProfile: mockGet,
      saveFamilyProfile: mockSave,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('FamilyProfileBloc Tests', () {
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

    blocTest<FamilyProfileBloc, FamilyProfileState>(
      'emits [Loading, Loaded] when profile exists',
      build: () {
        when(() => mockGet()).thenAnswer((_) async => Right(tProfile));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadFamilyProfile()),
      expect: () => [
        isA<FamilyProfileLoading>(),
        isA<FamilyProfileLoaded>(),
      ],
    );

    blocTest<FamilyProfileBloc, FamilyProfileState>(
      'emits [Loading, Saved] when SaveFamilyProfile is successful',
      build: () {
        when(() => mockSave(tProfile)).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(SaveFamilyProfileEvent(tProfile)),
      expect: () => [
        isA<FamilyProfileLoading>(),
        isA<FamilyProfileSaved>(),
      ],
    );
  });
}
