import 'package:equatable/equatable.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

class AppInitial extends AppState {}

class AppLoading extends AppState {}

class AppLoaded extends AppState {
  final dynamic data;

  const AppLoaded({required this.data});

  @override
  List<Object> get props => [data];
}

class AppError extends AppState {
  final String message;

  const AppError({required this.message});

  @override
  List<Object> get props => [message];
}
