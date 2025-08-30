import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// خدمة مراقبة حالة الاتصال بالإنترنت
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  /// تدفق حالة الاتصال (متصل/غير متصل)
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  /// حالة الاتصال الحالية
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  ConnectivityService() {
    // الاستماع لتغييرات حالة الاتصال
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    // التحقق من حالة الاتصال الأولية
    _checkInitialConnection();
  }

  /// التحقق من حالة الاتصال الأولية
  Future<void> _checkInitialConnection() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    // Handle both old and new API - checkConnectivity now returns List<ConnectivityResult>
    _updateConnectionStatus(connectivityResults);
    }

  /// تحديث حالة الاتصال بناءً على نتيجة الاتصال
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // المستخدم متصل إذا كان لديه أي اتصال غير "none"
    _isConnected = results.any((result) => result != ConnectivityResult.none);
    _connectionStatusController.add(_isConnected);
  }

  /// إغلاق الموارد عند الانتهاء
  void dispose() {
    _connectionStatusController.close();
  }
}
