import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import 'package:camar_ais/data/datasources/auth_remote_datasources.dart';
import 'package:camar_ais/data/models/auth_response_model.dart';
import 'package:camar_ais/data/models/register_request.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRemoteDataSource remote;
  RegisterBloc(
    this.remote,
  ) : super(RegisterInitial()) {
    on<RegisterButtonPressed>((event, emit) async {
      emit(RegisterLoading());
      final response  = await remote.register(event.data);
      response.fold(
        (error) => emit(RegisterFailed(message: error)),
        (data) => emit(RegisterSuccess(data: data)),
      );
    });
  }
}