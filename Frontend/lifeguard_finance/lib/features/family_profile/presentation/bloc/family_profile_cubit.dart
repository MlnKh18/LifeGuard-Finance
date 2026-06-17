import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/family_profile_repository.dart';

class FamilyProfileCubit extends Cubit<int> {
  final FamilyProfileRepository repository;

  FamilyProfileCubit(this.repository) : super(0);
}
