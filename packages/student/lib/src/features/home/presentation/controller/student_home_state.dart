import 'package:common/common.dart';
import 'package:equatable/equatable.dart';

abstract class StudentHomeState with EquatableMixin {}

class StudentHomeInitialState extends StudentHomeState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class StudentHomeLoadingState extends StudentHomeState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class StudentHomeLoadedState extends StudentHomeState with EquatableMixin {
  final List<Lesson> lessons;
  final bool isSyncing;

  StudentHomeLoadedState(this.lessons, {this.isSyncing = false});

  @override
  List<Object?> get props => [lessons, isSyncing];
}

class StudentHomeErrorState extends StudentHomeState with EquatableMixin {
  final String errorMessage;

  StudentHomeErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class StudentHomeLoggedOutState extends StudentHomeState with EquatableMixin {
  @override
  List<Object?> get props => [];
}
