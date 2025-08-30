import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/connectivity_service.dart';

// أحداث الاتصال
abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object?> get props => [];
}

// حدث تغيير حالة الاتصال
class ConnectivityChanged extends ConnectivityEvent {
  final bool isConnected;

  const ConnectivityChanged(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}

// حالات الاتصال
abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object?> get props => [];
}

// حالة الاتصال الأولية
class ConnectivityInitial extends ConnectivityState {}

// حالة الاتصال متصل
class ConnectivityConnected extends ConnectivityState {}

// حالة الاتصال غير متصل
class ConnectivityDisconnected extends ConnectivityState {}

/// Bloc لإدارة حالة الاتصال بالإنترنت
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityService _connectivityService;
  StreamSubscription? _connectivitySubscription;

  ConnectivityBloc({required ConnectivityService connectivityService})
      : _connectivityService = connectivityService,
        super(ConnectivityInitial()) {
    on<ConnectivityChanged>(_onConnectivityChanged);

    // الاستماع لتغييرات حالة الاتصال
    _connectivitySubscription = _connectivityService.connectionStatus.listen(
      (isConnected) => add(ConnectivityChanged(isConnected)),
    );

    // التحقق من حالة الاتصال الأولية
    add(ConnectivityChanged(_connectivityService.isConnected));
  }

  void _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    if (event.isConnected) {
      emit(ConnectivityConnected());
    } else {
      emit(ConnectivityDisconnected());
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}

