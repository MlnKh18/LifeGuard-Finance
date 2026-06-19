import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/presentation/bloc/fvs_bloc.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/presentation/bloc/fvs_event.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/presentation/bloc/fvs_state.dart';
import 'package:lifeguard_finance/features/fvs_dashboard/presentation/pages/dashboard_page.dart';

class MockFvsBloc extends MockBloc<FvsEvent, FvsState> implements FvsBloc {}

void main() {
  late MockFvsBloc fvsBloc;

  setUp(() {
    fvsBloc = MockFvsBloc();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<FvsBloc>.value(
        value: fvsBloc,
        child: const DashboardView(),
      ),
    );
  }

  testWidgets('shows a loading indicator while the FVS score is loading', (tester) async {
    when(() => fvsBloc.state).thenReturn(FvsLoading());

    await tester.pumpWidget(buildSubject());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('prompts the user to complete their profile when none exists', (tester) async {
    when(() => fvsBloc.state).thenReturn(FvsNoProfile());

    await tester.pumpWidget(buildSubject());

    expect(find.text('Profil Keuangan Belum Lengkap'), findsOneWidget);
    expect(find.text('Lengkapi Profil Sekarang'), findsOneWidget);
  });

  testWidgets('shows an error view with a retry button when loading fails', (tester) async {
    when(() => fvsBloc.state).thenReturn(const FvsError('Gagal memuat skor FVS'));

    await tester.pumpWidget(buildSubject());

    expect(find.text('Terjadi Kesalahan'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });
}
