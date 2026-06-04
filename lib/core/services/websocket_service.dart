import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
// import 'package:stomp_dart_client/stomp_config.dart';
// import 'package:stomp_dart_client/stomp_frame.dart';

class WebSocketService {
  StompClient? _stompClient;
  final Map<String, StreamController<dynamic>> _subscriptions = {};
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void connect() {
    if (_isConnected) return;

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: 'http://172.26.25.53:8080/ws',
        onConnect: (StompFrame frame) {
          _isConnected = true;
          debugPrint('WebSocket connected');
        },
        onDisconnect: (StompFrame frame) {
          _isConnected = false;
          debugPrint('WebSocket disconnected');
        },
        onWebSocketError: (dynamic error) {
          debugPrint('WebSocket error: $error');
        },
        onStompError: (StompFrame frame) {
          debugPrint('Stomp error: ${frame.body}');
        },
      ),
    );

    _stompClient!.activate();
  }

  Stream<T> subscribe<T>(
    String destination,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (_subscriptions.containsKey(destination)) {
      return _subscriptions[destination]!.stream as Stream<T>;
    }

    final controller = StreamController<T>.broadcast();
    _subscriptions[destination] = controller;

    _stompClient?.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        try {
          if (frame.body != null) {
            final data = jsonDecode(frame.body!);
            controller.add(fromJson(data as Map<String, dynamic>));
          }
        } catch (e) {
          debugPrint('Error parsing WebSocket message: $e');
        }
      },
    );

    return controller.stream;
  }

  Stream<dynamic> subscribeRaw(String destination) {
    if (_subscriptions.containsKey(destination)) {
      return _subscriptions[destination]!.stream;
    }

    final controller = StreamController<dynamic>.broadcast();
    _subscriptions[destination] = controller;

    _stompClient?.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        try {
          if (frame.body != null) {
            final data = jsonDecode(frame.body!);
            controller.add(data);
          }
        } catch (e) {
          debugPrint('Error parsing WebSocket message: $e');
        }
      },
    );

    return controller.stream;
  }

  void unsubscribe(String destination) {
    if (_subscriptions.containsKey(destination)) {
      _subscriptions[destination]?.close();
      _subscriptions.remove(destination);
    }
  }

  void send(String destination, dynamic body) {
    final jsonBody = jsonEncode(body);
    debugPrint('Sending WebSocket to $destination: $jsonBody');
    _stompClient?.send(
      destination: destination,
      body: jsonBody,
    );
  }

  void disconnect() {
    _subscriptions.forEach((_, controller) => controller.close());
    _subscriptions.clear();
    _stompClient?.deactivate();
    _isConnected = false;
  }
}

class VideoLikeUpdate {
  final String videoId;
  final int likeCount;
  final bool isLiked;

  VideoLikeUpdate({
    required this.videoId,
    required this.likeCount,
    required this.isLiked,
  });

  factory VideoLikeUpdate.fromJson(Map<String, dynamic> json) {
    return VideoLikeUpdate(
      videoId: json['videoId'],
      likeCount: json['likeCount'],
      isLiked: json['isLiked'],
    );
  }
}

class VideoCommentUpdate {
  final String videoId;
  final int commentCount;

  VideoCommentUpdate({
    required this.videoId,
    required this.commentCount,
  });

  factory VideoCommentUpdate.fromJson(Map<String, dynamic> json) {
    return VideoCommentUpdate(
      videoId: json['videoId'],
      commentCount: json['commentCount'],
    );
  }
}
