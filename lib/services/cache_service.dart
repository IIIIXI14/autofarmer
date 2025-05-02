import 'dart:convert';
import 'package:shared_preferences.dart';
import '../models/sensor_data_model.dart';
import '../models/actuator_state_model.dart';

class CacheService {
  static const String _sensorDataKey = 'sensor_data';
  static const String _actuatorDataKey = 'actuator_data';
  static const String _historyDataKey = 'history_data';
  static const Duration _cacheDuration = Duration(minutes: 5);

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  Future<void> cacheSensorData(String deviceId, SensorDataModel data) async {
    final cache = {
      'data': data.toMap(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _prefs.setString('$_sensorDataKey:$deviceId', jsonEncode(cache));
  }

  Future<SensorDataModel?> getCachedSensorData(String deviceId) async {
    final cached = _prefs.getString('$_sensorDataKey:$deviceId');
    if (cached == null) return null;

    try {
      final cache = jsonDecode(cached) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cache['timestamp'] as String);
      
      if (DateTime.now().difference(timestamp) > _cacheDuration) {
        await _prefs.remove('$_sensorDataKey:$deviceId');
        return null;
      }

      return SensorDataModel.fromMap(cache['data'] as Map<String, dynamic>);
    } catch (e) {
      await _prefs.remove('$_sensorDataKey:$deviceId');
      return null;
    }
  }

  Future<void> cacheActuatorData(String deviceId, ActuatorStateModel data) async {
    final cache = {
      'data': data.toMap(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _prefs.setString('$_actuatorDataKey:$deviceId', jsonEncode(cache));
  }

  Future<ActuatorStateModel?> getCachedActuatorData(String deviceId) async {
    final cached = _prefs.getString('$_actuatorDataKey:$deviceId');
    if (cached == null) return null;

    try {
      final cache = jsonDecode(cached) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cache['timestamp'] as String);
      
      if (DateTime.now().difference(timestamp) > _cacheDuration) {
        await _prefs.remove('$_actuatorDataKey:$deviceId');
        return null;
      }

      return ActuatorStateModel.fromMap(cache['data'] as Map<String, dynamic>);
    } catch (e) {
      await _prefs.remove('$_actuatorDataKey:$deviceId');
      return null;
    }
  }

  Future<void> cacheHistoryData(String deviceId, List<Map<String, dynamic>> data) async {
    final cache = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _prefs.setString('$_historyDataKey:$deviceId', jsonEncode(cache));
  }

  Future<List<Map<String, dynamic>>?> getCachedHistoryData(String deviceId) async {
    final cached = _prefs.getString('$_historyDataKey:$deviceId');
    if (cached == null) return null;

    try {
      final cache = jsonDecode(cached) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cache['timestamp'] as String);
      
      if (DateTime.now().difference(timestamp) > _cacheDuration) {
        await _prefs.remove('$_historyDataKey:$deviceId');
        return null;
      }

      return (cache['data'] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      await _prefs.remove('$_historyDataKey:$deviceId');
      return null;
    }
  }

  Future<void> clearCache(String deviceId) async {
    await _prefs.remove('$_sensorDataKey:$deviceId');
    await _prefs.remove('$_actuatorDataKey:$deviceId');
    await _prefs.remove('$_historyDataKey:$deviceId');
  }
} 