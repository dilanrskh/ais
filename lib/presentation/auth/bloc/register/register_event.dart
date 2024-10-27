part of 'register_bloc.dart';

@immutable
sealed class RegisterEvent {}

class RegisterButtonPressed extends RegisterEvent {
  final RegisterRequestModel data;
  
  RegisterButtonPressed({
    required this.data,
  });
}
