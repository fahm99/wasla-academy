import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/course.dart';
import '../../services/payment_management_service.dart';
import '../../services/payment_service_manager.dart';
import '../../services/payment_simulation_service.dart';

// Events
abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class InitiatePayment extends PaymentEvent {
  final String userId;
  final Course course;
  final String fromAccount;
  final String? description;
  final String paymentMethod;

  const InitiatePayment({
    required this.userId,
    required this.course,
    required this.fromAccount,
    this.description,
    this.paymentMethod = 'simulation', // Default to simulation
  });

  @override
  List<Object?> get props =>
      [userId, course, fromAccount, description, paymentMethod];
}

class ValidateAccount extends PaymentEvent {
  final String accountNumber;

  const ValidateAccount(this.accountNumber);

  @override
  List<Object?> get props => [accountNumber];
}

class CalculateTransferFee extends PaymentEvent {
  final double amount;

  const CalculateTransferFee(this.amount);

  @override
  List<Object?> get props => [amount];
}

class LoadPaymentStatistics extends PaymentEvent {
  final String userId;

  const LoadPaymentStatistics(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ChangePaymentMethod extends PaymentEvent {
  final PaymentServiceType serviceType;

  const ChangePaymentMethod(this.serviceType);

  @override
  List<Object?> get props => [serviceType];
}

class ResetPaymentState extends PaymentEvent {
  const ResetPaymentState();
}

// States
abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentProcessing extends PaymentState {
  final String message;

  const PaymentProcessing({required this.message});

  @override
  List<Object?> get props => [message];
}

class PaymentSuccess extends PaymentState {
  final PaymentResult result;

  const PaymentSuccess({required this.result});

  @override
  List<Object?> get props => [result];
}

class PaymentFailure extends PaymentState {
  final String errorMessage;

  const PaymentFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class AccountValidated extends PaymentState {
  final AccountInfo? accountInfo;
  final String accountNumber;

  const AccountValidated({
    required this.accountInfo,
    required this.accountNumber,
  });

  @override
  List<Object?> get props => [accountInfo, accountNumber];
}

class TransferFeeCalculated extends PaymentState {
  final double fee;
  final double amount;

  const TransferFeeCalculated({
    required this.fee,
    required this.amount,
  });

  @override
  List<Object?> get props => [fee, amount];
}

class PaymentStatisticsLoaded extends PaymentState {
  final PaymentStatistics statistics;

  const PaymentStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

class PaymentMethodChanged extends PaymentState {
  final PaymentServiceType serviceType;

  const PaymentMethodChanged({required this.serviceType});

  @override
  List<Object?> get props => [serviceType];
}

// BLoC
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentManagementService _paymentService;
  final PaymentServiceManager _paymentManager;

  PaymentBloc({
    required PaymentManagementService paymentService,
    required PaymentServiceManager paymentManager,
  })  : _paymentService = paymentService,
        _paymentManager = paymentManager,
        super(const PaymentInitial()) {
    on<InitiatePayment>(_onInitiatePayment);
    on<ValidateAccount>(_onValidateAccount);
    on<CalculateTransferFee>(_onCalculateTransferFee);
    on<LoadPaymentStatistics>(_onLoadPaymentStatistics);
    on<ChangePaymentMethod>(_onChangePaymentMethod);
    on<ResetPaymentState>(_onResetPaymentState);
  }

  Future<void> _onInitiatePayment(
    InitiatePayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    try {
      emit(const PaymentProcessing(message: 'جاري معالجة الدفع...'));

      final result = await _paymentService.processCoursePayment(
        userId: event.userId,
        course: event.course,
        fromAccount: event.fromAccount,
        description: event.description,
        paymentMethod: event.paymentMethod,
      );

      if (result.success) {
        emit(PaymentSuccess(result: result));
      } else {
        emit(PaymentFailure(
            errorMessage: result.errorMessage ?? 'فشل في الدفع'));
      }
    } catch (e) {
      emit(PaymentFailure(errorMessage: 'خطأ في معالجة الدفع: $e'));
    }
  }

  Future<void> _onValidateAccount(
    ValidateAccount event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    try {
      final accountInfo =
          await _paymentService.validateAccount(event.accountNumber);
      emit(AccountValidated(
        accountInfo: accountInfo,
        accountNumber: event.accountNumber,
      ));
    } catch (e) {
      emit(PaymentFailure(errorMessage: 'خطأ في التحقق من الحساب: $e'));
    }
  }

  Future<void> _onCalculateTransferFee(
    CalculateTransferFee event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    try {
      final fee = await _paymentService.calculateTransferFee(event.amount);
      emit(TransferFeeCalculated(fee: fee, amount: event.amount));
    } catch (e) {
      emit(PaymentFailure(errorMessage: 'خطأ في حساب رسوم التحويل: $e'));
    }
  }

  Future<void> _onLoadPaymentStatistics(
    LoadPaymentStatistics event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    try {
      final statistics =
          await _paymentService.getPaymentStatistics(event.userId);
      emit(PaymentStatisticsLoaded(statistics: statistics));
    } catch (e) {
      emit(PaymentFailure(errorMessage: 'خطأ في تحميل إحصائيات الدفع: $e'));
    }
  }

  Future<void> _onChangePaymentMethod(
    ChangePaymentMethod event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      _paymentManager.setServiceType(event.serviceType);
      emit(PaymentMethodChanged(serviceType: event.serviceType));
    } catch (e) {
      emit(PaymentFailure(errorMessage: 'خطأ في تغيير طريقة الدفع: $e'));
    }
  }

  void _onResetPaymentState(
    ResetPaymentState event,
    Emitter<PaymentState> emit,
  ) {
    emit(const PaymentInitial());
  }

  @override
  Future<void> close() {
    _paymentService.dispose();
    return super.close();
  }
}
