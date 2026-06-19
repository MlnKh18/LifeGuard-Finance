import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/presentation/pages/dashboard_page.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/presentation/bloc/fvs_bloc.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/presentation/bloc/fvs_state.dart';
import 'package:lifeguard_finance/core/di/injection.dart';

class MockFvsBloc extends Mock implements FvsBloc {}

void main() {
  late MockFvsBloc mockFvsBloc;

  setUpAll(() {
    // Setup minimal GetIt dependencies needed for widget
    getIt.registerLazySingleton<FvsBloc>(() => MockFvsBloc());
  });

  setUp(() {
    mockFvsBloc = getIt<FvsBloc>() as MockFvsBloc;
  });

  tearDownAll(() {
    getIt.reset();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<FvsBloc>.value(
        value: mockFvsBloc,
        child: const DashboardView(),
      ),
    );
  }

  testWidgets('Should display loading indicator when FvsLoading', (WidgetTester tester) async {
    when(() => mockFvsBloc.state).thenReturn(FvsLoading());
    when(() => mockFvsBloc.stream).thenAnswer((_) => Stream.value(FvsLoading()));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Should display No Profile view when FvsNoProfile', (WidgetTester tester) async {
    when(() => mockFvsBloc.state).thenReturn(FvsNoProfile());
    when(() => mockFvsBloc.stream).thenAnswer((_) => Stream.value(FvsNoProfile()));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Profil Keuangan Belum Lengkap'), findsOneWidget);
  });
}
