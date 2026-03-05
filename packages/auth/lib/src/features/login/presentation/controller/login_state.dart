import 'package:common/src/domain/entities/login_type.dart';
import 'package:equatable/equatable.dart';

abstract class LoginState with EquatableMixin {}

class LoginInitialState extends LoginState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class LoginLoadingState extends LoginState with EquatableMixin {
  final String login, password;

  LoginLoadingState(this.login, this.password);

  @override
  List<Object?> get props => [login, password];
}

class LoginDoneState extends LoginState with EquatableMixin {
  final LoginType loginType;

  LoginDoneState(this.loginType);

  @override
  List<Object?> get props => [];
}

class LoginErrorState extends LoginState with EquatableMixin {
  final String login, password;
  final String errorMessage;

  LoginErrorState(this.login, this.password, this.errorMessage);

  @override
  List<Object?> get props => [login, password, errorMessage];
}
