import 'package:bloc/bloc.dart';
import 'package:camar_ais/data/datasources/auth_remote_datasources.dart';
import 'package:camar_ais/data/models/auth_response_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_event.dart';
part 'login_state.dart';
part 'login_bloc.freezed.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRemoteDataSource authRemoteDatasource;
  LoginBloc(
    this.authRemoteDatasource,
  ) : super(const _Initial()) {
    on<_Login>((event, emit) async {
      emit(const _Loading());
      final response = await authRemoteDatasource.login(
        event.email,
        event.password,
      );
      response.fold(
        (l) => emit(_Error(l)),
        (r) {
          if (r != null) {
            emit(_Success(r));
          } else {
            emit(const _Error('Authentication failed'));
          }
        },
      );
    });
  }
}