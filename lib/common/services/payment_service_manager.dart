import 'alkuraimi_payment_service.dart';
import 'payment_simulation_service.dart';

/// Payment Service Manager
/// Manages switching between Al-Kuraimi API and simulation services
class PaymentServiceManager {
  static final PaymentServiceManager _instance =
      PaymentServiceManager._internal();
  factory PaymentServiceManager() => _instance;
  PaymentServiceManager._internal();

  // Service instances
  late AlkuraimiPaymentService _alkuraimiService;
  late PaymentSimulationService _simulationService;

  // Current service type
  PaymentServiceType _currentServiceType = PaymentServiceType.simulation;

  // Initialization flag
  bool _isInitialized = false;

  /// Initialize the payment manager
  void initialize(
      {PaymentServiceType serviceType = PaymentServiceType.simulation}) {
    if (_isInitialized) return;

    _alkuraimiService = AlkuraimiPaymentService();
    _simulationService = PaymentSimulationService();

    setServiceType(serviceType);
    _isInitialized = true;
  }

  /// Set the current service type
  void setServiceType(PaymentServiceType serviceType) {
    _currentServiceType = serviceType;
    print('💳 Payment service switched to: ${serviceType.displayName}');
  }

  /// Get current service type
  PaymentServiceType get currentServiceType => _currentServiceType;

  /// Check if using simulation
  bool get isUsingSimulation =>
      _currentServiceType == PaymentServiceType.simulation;

  /// Check if using Al-Kuraimi API
  bool get isUsingAlkuraimi =>
      _currentServiceType == PaymentServiceType.alkuraimi;

  /// Get account information
  Future<AccountInfo?> getAccountInfo(String accountNumber) async {
    _ensureInitialized();

    switch (_currentServiceType) {
      case PaymentServiceType.simulation:
        return await _simulationService.getAccountInfo(accountNumber);
      case PaymentServiceType.alkuraimi:
        return await _alkuraimiService.getAccountInfo(accountNumber);
    }
  }

  /// Calculate transfer fees
  Future<double> getTransferFee(double amount) async {
    _ensureInitialized();

    switch (_currentServiceType) {
      case PaymentServiceType.simulation:
        return await _simulationService.getTransferFee(amount);
      case PaymentServiceType.alkuraimi:
        return await _alkuraimiService.getTransferFee(amount);
    }
  }

  /// Initiate payment
  Future<PaymentResult> initiatePayment({
    required String fromAccount,
    required String toAccount,
    required double amount,
    required String courseId,
    required String userId,
    String? description,
  }) async {
    _ensureInitialized();

    switch (_currentServiceType) {
      case PaymentServiceType.simulation:
        return await _simulationService.initiatePayment(
          fromAccount: fromAccount,
          toAccount: toAccount,
          amount: amount,
          courseId: courseId,
          userId: userId,
          description: description,
        );
      case PaymentServiceType.alkuraimi:
        return await _alkuraimiService.initiatePayment(
          fromAccount: fromAccount,
          toAccount: toAccount,
          amount: amount,
          courseId: courseId,
          userId: userId,
          description: description,
        );
    }
  }

  /// Test connection to current service
  Future<bool> testConnection() async {
    _ensureInitialized();

    try {
      switch (_currentServiceType) {
        case PaymentServiceType.simulation:
          // Simulation always works
          return true;
        case PaymentServiceType.alkuraimi:
          return await _alkuraimiService.testConnection();
      }
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  /// Get service configuration
  Map<String, dynamic> getServiceConfiguration() {
    return {
      'serviceType': _currentServiceType.name,
      'displayName': _currentServiceType.displayName,
      'isSimulation': isUsingSimulation,
      'isInitialized': _isInitialized,
    };
  }

  /// Ensure manager is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw const PaymentException(
          'Payment manager not initialized. Call initialize() first.');
    }
  }

  /// Dispose resources
  void dispose() {
    if (_isInitialized) {
      _alkuraimiService.dispose();
      _isInitialized = false;
    }
  }
}

/// Payment service types
enum PaymentServiceType {
  simulation('محاكاة بنك الكريمي'),
  alkuraimi('بنك الكريمي - API');

  const PaymentServiceType(this.displayName);
  final String displayName;
}
