import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'dart:typed_data'; // Import Uint8List

class ChatChunk {
  final String text;

  ChatChunk(this.text);
}

class ChatService {
  final String baseUrl;
  final String apiKey;
  final String userId;
  final Dio _dio;

  ChatService({
    required this.baseUrl,
    required this.apiKey,
    required this.userId,
  }) : _dio = Dio(
         BaseOptions(
           headers: {
             'Authorization': 'Bearer $apiKey',
             'Content-Type': 'application/json',
             'Accept': 'text/event-stream',
           },
           responseType: ResponseType.stream,
         ),
       );

  Stream<ChatChunk> sendMessageStream({
    required String query,
    String? conversationId,
    String? user,
  }) async* {
    user ??= userId;
    try {
      final response = await _dio.post(
        baseUrl,
        data: {
          'query': query,
          'inputs': {},
          'response_mode': 'streaming',
          'user': user,
          'conversation_id': conversationId ?? '',
        },
      );

      // Explicitly cast the stream to Stream<List<int>>
      final stream = response.data.stream
          .cast<List<int>>() // <--- Add this line
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (var line in stream) {
        if (line.startsWith('data: ')) {
          final jsonStr = line.substring(6);
          if (jsonStr.trim().isEmpty) continue;
          final Map<String, dynamic> data = json.decode(jsonStr);

          final event = data['event'];
          if (event == 'agent_message') {
            final chunk = data['answer'] ?? '';
            yield ChatChunk(chunk);
          } else if (event == 'message_end' ||
              event == 'agent_end' ||
              event == 'agent_message_end') {
            break;
          } else if (event == 'error') {
            throw Exception(data['message'] ?? 'Unknown error');
          }
        }
      }
    } catch (e) {
      yield ChatChunk('[Error] ${e.toString()}');
    }
  }
}
