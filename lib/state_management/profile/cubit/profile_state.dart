import 'package:equatable/equatable.dart';
import 'package:ebidan/data/models/bidan_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Bidan bidan;

  const ProfileLoaded(this.bidan);

  @override
  List<Object?> get props => [bidan];
}

class ProfileFailure extends ProfileState {
  final String message;

  const ProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}
