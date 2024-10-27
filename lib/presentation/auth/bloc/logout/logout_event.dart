part of 'logout_bloc.dart';

@immutable
sealed class LogoutEvent {}

class LogoutButtonPressed extends LogoutEvent {}