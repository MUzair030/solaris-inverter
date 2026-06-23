import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

class NetworkMonitor extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _subscription;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  NetworkMonitor() {
    _initialize();
  }

  void _initialize() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });
  }

  // void _updateConnectionStatus(ConnectivityResult result) {
  //   final previouslyConnected = _isConnected;
  //   _isConnected = result != ConnectivityResult.none;
  //   if (_isConnected && !previouslyConnected) {
  //     notifyListeners(); // Notify your app/viewmodels to refresh
  //   }
  // }

  // Updates connection status with extra "ping" check
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    final previouslyConnected = _isConnected;

    // Step 1: No connection at all
    if (result == ConnectivityResult.none) {
      _isConnected = false;
    } else {
      // Step 2: Check real internet with ping
      _isConnected = await _checkInternet();
    }

    // Step 3: Notify only if status actually changed
    if (_isConnected != previouslyConnected) {
      notifyListeners();
    }
  }

  // Simple "ping" check to confirm real internet access
  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup("google.com")
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
