import 'package:bloc/bloc.dart';
import 'package:camar_ais/data/datasources/auth_local_datasources.dart';
import 'package:camar_ais/data/datasources/auth_remote_datasources.dart';
import 'package:meta/meta.dart';


part 'logout_event.dart';
part 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final AuthRemoteDataSource remote;
  LogoutBloc(
    this.remote,
  ) : super(LogoutInitial()) {
    on<LogoutButtonPressed>((event, emit) async {
      emit(LogoutLoading());
      final response = await remote.logout();
      response.fold(
        (l) => emit(LogoutFailed(message: l)),
        (r) {
          AuthLocalDatasource().removeAuthData();
          emit(LogoutSuccess());
        },
      );
    });
  }
}