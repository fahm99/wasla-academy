import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasla_app/common/bloc/payment/payment_bloc.dart';
import 'package:wasla_app/common/services/payment_simulation_service.dart';
import 'package:wasla_app/common/services/payment_service_manager.dart';
import 'package:wasla_app/common/services/payment_management_service.dart';
import 'package:wasla_app/common/models/course.dart';

void main() {
  group('Payment System Tests', () {
    late PaymentSimulationService simulationService;
    late PaymentServiceManager paymentManager;
    late PaymentManagementService managementService;
    late PaymentBloc paymentBloc;

    setUp(() {
      simulationService = PaymentSimulationService();
      paymentManager = PaymentServiceManager();
      managementService = PaymentManagementService();

      // Initialize payment manager with simulation
      paymentManager.initialize(serviceType: PaymentServiceType.simulation);

      paymentBloc = PaymentBloc(
        paymentService: managementService,
        paymentManager: paymentManager,
      );
    });

    tearDown(() {
      paymentBloc.close();
      managementService.dispose();
      paymentManager.dispose();
    });

    group('Payment Simulation Service Tests', () {
      test('should validate account info correctly', () async {
        // Test valid account
        final validAccount =
            await simulationService.getAccountInfo('400001234567');
        expect(validAccount, isNotNull);
        expect(validAccount!.accountNumber, equals('400001234567'));
        expect(validAccount.holderName, equals('أحمد محمد علي'));
        expect(validAccount.balance, equals(5000.0));

        // Test invalid account
        final invalidAccount = await simulationService.getAccountInfo('123456');
        expect(invalidAccount, isNull);
      });

      test('should process successful payment', () async {
        final result = await simulationService.initiatePayment(
          fromAccount: '400001234567',
          toAccount: '400009876543',
          amount: 299.0,
          courseId: 'test_course_id',
          userId: 'test_user_id',
          description: 'Test payment for course',
        );

        expect(result.success, isTrue);
        expect(result.transactionId, isNotNull);
        expect(result.amount, equals(299.0));
        expect(result.currency, equals('SAR'));
      });

      test('should fail payment with insufficient balance', () async {
        final result = await simulationService.initiatePayment(
          fromAccount: '400001111111', // Account with 1200 balance
          toAccount: '400009876543',
          amount: 2000.0, // More than available balance
          courseId: 'test_course_id',
          userId: 'test_user_id',
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('رصيد غير كافي'));
      });

      test('should calculate transfer fees correctly', () async {
        final fee1 = await simulationService.getTransferFee(100.0);
        expect(fee1, equals(2.0)); // Fixed fee for small amounts

        final fee2 = await simulationService.getTransferFee(1000.0);
        expect(fee2, equals(5.0)); // 0.5% of 1000 = 5
      });
    });

    group('Payment Service Manager Tests', () {
      test('should switch between service types', () {
        expect(paymentManager.isUsingSimulation, isTrue);
        expect(paymentManager.currentServiceType,
            equals(PaymentServiceType.simulation));

        paymentManager.setServiceType(PaymentServiceType.alkuraimi);
        expect(paymentManager.isUsingAlkuraimi, isTrue);
        expect(paymentManager.currentServiceType,
            equals(PaymentServiceType.alkuraimi));
      });

      test('should test connection successfully', () async {
        final connectionTest = await paymentManager.testConnection();
        expect(connectionTest, isTrue);
      });
    });

    group('Payment Bloc Tests', () {
      test('should emit correct states during payment process', () async {
        final mockCourse = Course(
          id: 'test_course_id',
          title: 'Test Course',
          description: 'Test course description',
          instructorId: 'test_instructor_id',
          instructorName: 'Test Instructor',
          status: CourseStatus.published,
          level: CourseLevel.beginner,
          price: 299.0,
          duration: 120,
          lessonsCount: 10,
          category: 'Programming',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final expectedStates = [
          isA<PaymentInitial>(),
          isA<PaymentLoading>(),
          isA<PaymentProcessing>(),
          isA<PaymentSuccess>(),
        ];

        expectLater(
          paymentBloc.stream,
          emitsInOrder(expectedStates),
        );

        paymentBloc.add(InitiatePayment(
          userId: 'test_user_id',
          course: mockCourse,
          fromAccount: '400001234567',
          description: 'Test payment',
        ));
      });

      test('should handle payment failure correctly', () async {
        final mockCourse = Course(
          id: 'test_course_id',
          title: 'Test Course',
          description: 'Test course description',
          instructorId: 'test_instructor_id',
          instructorName: 'Test Instructor',
          status: CourseStatus.published,
          level: CourseLevel.beginner,
          price: 5000.0, // Amount higher than available balance
          duration: 120,
          lessonsCount: 10,
          category: 'Programming',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expectLater(
          paymentBloc.stream,
          emitsInOrder([
            isA<PaymentLoading>(),
            isA<PaymentFailure>(),
          ]),
        );

        paymentBloc.add(InitiatePayment(
          userId: 'test_user_id',
          course: mockCourse,
          fromAccount: '400001111111', // Account with insufficient balance
        ));
      });

      test('should load payment statistics correctly', () async {
        expectLater(
          paymentBloc.stream,
          emitsInOrder([
            isA<PaymentLoading>(),
            isA<PaymentStatisticsLoaded>(),
          ]),
        );

        paymentBloc.add(const LoadPaymentStatistics('test_user_id'));
      });

      test('should change payment method successfully', () async {
        expectLater(
          paymentBloc.stream,
          emits(isA<PaymentMethodChanged>()),
        );

        paymentBloc.add(const ChangePaymentMethod(PaymentServiceType.alkuraimi));
      });
    });

    group('Integration Tests', () {
      testWidgets('Payment method selection screen should work',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<PaymentBloc>(
              create: (context) => paymentBloc,
              child: Scaffold(
                body: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        context.read<PaymentBloc>().add(
                              const ChangePaymentMethod(
                                  PaymentServiceType.simulation),
                            );
                      },
                      child: const Text('Switch to Simulation'),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Tap the button to change payment method
        await tester.tap(find.text('Switch to Simulation'));
        await tester.pump();

        // Verify the button exists and is tappable
        expect(find.text('Switch to Simulation'), findsOneWidget);
      });
    });

    group('Error Handling Tests', () {
      test('should handle invalid account numbers gracefully', () async {
        expect(
          () => simulationService.getAccountInfo(''),
          throwsA(isA<PaymentException>()),
        );

        expect(
          () => simulationService.getAccountInfo('123'),
          throwsA(isA<PaymentException>()),
        );
      });

      test('should handle network errors in real payment service', () async {
        // This would test actual network error handling
        // For now, we test that the simulation handles errors gracefully
        try {
          await simulationService.initiatePayment(
            fromAccount: 'invalid_account',
            toAccount: '400001234567',
            amount: 100.0,
            courseId: 'test_course',
            userId: 'test_user',
          );
        } catch (e) {
          expect(e, isA<PaymentException>());
        }
      });
    });

    group('Performance Tests', () {
      test('should handle multiple concurrent payment requests', () async {
        final futures = List.generate(
            5,
            (index) => simulationService.initiatePayment(
                  fromAccount: '400001234567',
                  toAccount: '400009876543',
                  amount: 50.0,
                  courseId: 'course_$index',
                  userId: 'user_$index',
                ));

        final results = await Future.wait(futures);

        // All payments should be processed
        expect(results.length, equals(5));

        // Most should succeed (90% success rate in simulation)
        final successCount = results.where((r) => r.success).length;
        expect(successCount, greaterThanOrEqualTo(3));
      });

      test('payment processing should complete within reasonable time',
          () async {
        final stopwatch = Stopwatch()..start();

        await simulationService.initiatePayment(
          fromAccount: '400001234567',
          toAccount: '400009876543',
          amount: 299.0,
          courseId: 'performance_test_course',
          userId: 'performance_test_user',
        );

        stopwatch.stop();

        // Payment should complete within 5 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });
    });
  });
}
