import 'package:bloc/bloc.dart';
import 'package:gokid/bloc/user_bloc/user_state.dart';
import '../../models/user_model.dart';
import '../../services/firebase_crud_methods.dart';
import 'user_event.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final FirebaseCrudMethods _firebaseCrudMethods;

  UserBloc(this._firebaseCrudMethods) : super(UserInitial());

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    if (event is LoadUserEvent) {
      yield UserLoading();
      try {
        UserModel? user = await _firebaseCrudMethods.getUserData(event.userId);
        if (user != null) {
          yield UserLoaded(user);
        } else {
          yield UserError('User not found');
        }
      } catch (e) {
        yield UserError('Error loading user: $e');
      }
    }
  }
}
