import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/sensor_data_model.dart';
import '../models/actuator_state_model.dart';
import 'cache_service.dart';
import 'retry_service.dart';
import 'package:flutter/foundation.dart';

class SyncService {
  final FirebaseFirestore _firestore;
  final CacheService _cacheService;
  final String _deviceId;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isOnline = true;

  SyncService(this._firestore, this._cacheService, this._deviceId) {
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      if (_isOnline) {
        _syncPendingChanges();
      }
    });
  }

  Future<void> _syncPendingChanges() async {
    try {
      // Sync sensor data
      final cachedSensorData = await _cacheService.getCachedSensorData(_deviceId);
      if (cachedSensorData != null) {
        await RetryService.withRetry(
          operation: () async {
            await _firestore
                .collection('sensors_data')
                .doc(_deviceId)
                .set(cachedSensorData.toMap());
          },
          shouldRetry: RetryService.isNetworkError,
        );
      }

      // Sync actuator data
      final cachedActuatorData = await _cacheService.getCachedActuatorData(_deviceId);
      if (cachedActuatorData != null) {
        await RetryService.withRetry(
          operation: () async {
            await _firestore
                .collection('actuators')
                .doc(_deviceId)
                .set(cachedActuatorData.toMap());
          },
          shouldRetry: RetryService.isNetworkError,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error syncing data: $e');
      }
    }
  }

  Future<void> syncSensorData(SensorDataModel data) async {
    if (_isOnline) {
      try {
        await RetryService.withRetry(
          operation: () async {
            await _firestore
                .collection('sensors_data')
                .doc(_deviceId)
                .set(data.toMap());
          },
          shouldRetry: RetryService.isNetworkError,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error syncing sensor data: $e');
        }
      }
    }
    await _cacheService.cacheSensorData(_deviceId, data);
  }

  Future<void> syncActuatorData(ActuatorStateModel data) async {
    if (_isOnline) {
      try {
        await RetryService.withRetry(
          operation: () async {
            await _firestore
                .collection('actuators')
                .doc(_deviceId)
                .set(data.toMap());
          },
          shouldRetry: RetryService.isNetworkError,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error syncing actuator data: $e');
        }
      }
    }
    await _cacheService.cacheActuatorData(_deviceId, data);
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
} 