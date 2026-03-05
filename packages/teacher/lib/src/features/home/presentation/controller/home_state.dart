import 'package:common/common.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState with EquatableMixin {}

class HomeInitialState extends HomeState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class HomeLoadingState extends HomeState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class HomeLoadedState extends HomeState with EquatableMixin {
  final List<Lesson> lessons;
  final bool isSyncing;

  HomeLoadedState(this.lessons, {this.isSyncing = false});

  @override
  List<Object?> get props => [lessons, isSyncing];
}

class HomeErrorState extends HomeState with EquatableMixin {
  final String errorMessage;

  HomeErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class HomeLoggedOutState extends HomeState with EquatableMixin {
  @override
  List<Object?> get props => [];
}
