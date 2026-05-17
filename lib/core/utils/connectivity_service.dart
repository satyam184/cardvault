import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ValueNotifier<bool> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityService() : super(true) {
    _init();
  }

  void _init() async {
    await checkConnection();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  Future<void> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results);
    } catch (e) {
      debugPrint('Failed to check connectivity: $e');
    }
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final hasConnection = results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);
    if (value != hasConnection) {
      value = hasConnection;
    }
  }

  void disposeService() {
    _subscription?.cancel();
    super.dispose();
  }
}
