import 'dart:convert';
import 'package:archive/archive.dart';

class CompressionService {
  static String compressData(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final compressed = GZipEncoder().encode(bytes);
    return base64Encode(compressed!);
  }

  static Map<String, dynamic> decompressData(String compressedData) {
    final bytes = base64Decode(compressedData);
    final decompressed = GZipDecoder().decodeBytes(bytes);
    final jsonString = utf8.decode(decompressed);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  static String compressList(List<Map<String, dynamic>> data) {
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final compressed = GZipEncoder().encode(bytes);
    return base64Encode(compressed!);
  }

  static List<Map<String, dynamic>> decompressList(String compressedData) {
    final bytes = base64Decode(compressedData);
    final decompressed = GZipDecoder().decodeBytes(bytes);
    final jsonString = utf8.decode(decompressed);
    return (jsonDecode(jsonString) as List).cast<Map<String, dynamic>>();
  }
} 