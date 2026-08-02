import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:newsletter_portal/domain/entities/chat_message.dart';

class ChatLocalDatasource {
  static const String _boxName = 'chat_history';

  Future<Box<String>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<String>(_boxName);
    }
    return await Hive.openBox<String>(_boxName);
  }

  Future<List<ChatMessage>> loadHistory(String projectId) async {
    final box = await _getBox();
    final raw = box.get(projectId);
    if (raw == null) return [];

    try {
      final jsonList = jsonDecode(raw) as List;
      return jsonList
          .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistory(String projectId, List<ChatMessage> history) async {
    final box = await _getBox();
    final jsonList = history.map((m) => m.toJson()).toList();
    await box.put(projectId, jsonEncode(jsonList));
  }

  Future<void> deleteHistory(String projectId) async {
    final box = await _getBox();
    await box.delete(projectId);
  }
}
