import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadUserEvent extends UserEvent {
  final String userId;

  LoadUserEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
