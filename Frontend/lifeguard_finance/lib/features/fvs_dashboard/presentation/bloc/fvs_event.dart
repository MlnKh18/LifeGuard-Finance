import 'package:equatable/equatable.dart';

abstract class FvsEvent extends Equatable {
  const FvsEvent();

  @override
  List<Object?> get props => [];
}

class LoadFvs extends FvsEvent {}

class CalculateFvs extends FvsEvent {}
