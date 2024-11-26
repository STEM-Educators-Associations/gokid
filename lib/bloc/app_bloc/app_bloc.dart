import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppInitial());

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    if (event is FetchData) {
      yield AppLoading();
      try {
        final data = await fetchDataFromInternet();
        yield AppLoaded(data: data);
      } catch (e) {
        yield AppError(message: e.toString());
      }
    }
  }

  Future<dynamic> fetchDataFromInternet() async {

    await Future.delayed(Duration(seconds: 2));
    return "Fetched Data";
  }
}
