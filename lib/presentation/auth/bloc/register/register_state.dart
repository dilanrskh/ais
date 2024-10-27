part of 'register_bloc.dart';

@immutable
sealed class RegisterState {}

final class RegisterInitial extends RegisterState {}

final class RegisterLoading extends RegisterState {}

final class RegisterSuccess extends RegisterState {
  final AuthResponseModel data;

  RegisterSuccess({
     required this.data,
  });
}

final class RegisterFailed extends RegisterState {
  final String message;

  RegisterFailed({
    required this.message,
  });
}
