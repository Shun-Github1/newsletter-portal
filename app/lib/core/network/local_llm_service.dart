import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/widgets.dart';

enum LlmServerStatus {
  offline,
  starting,
  online,
  error,
}

final llmServerStatusProvider = StateProvider<LlmServerStatus>((ref) => LlmServerStatus.offline);
final llmServerErrorProvider = StateProvider<String?>((ref) => null);

class LocalLlmService with WidgetsBindingObserver {
  final Ref _ref;
  final _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8089',
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Process? _serverProcess;
  IOSink? _logSink;
  LlmServerStatus _status = LlmServerStatus.offline;
  String? _statusError;
  bool _disposed = false;
  
  final _statusController = StreamController<LlmServerStatus>.broadcast();
  Stream<LlmServerStatus> get statusStream => _statusController.stream;
  LlmServerStatus get status => _status;
  String? get statusError => _statusError;

  LocalLlmService(this._ref) {
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () {
      if (!_disposed) {
        _ref.read(llmServerStatusProvider.notifier).state = _status;
        _ref.read(llmServerErrorProvider.notifier).state = _statusError;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached || state == AppLifecycleState.hidden) {
      killServer();
    }
  }

  void _updateStatus(LlmServerStatus status, [String? error]) {
    _status = status;
    _statusError = error;
    _statusController.add(status);
    
    if (!_disposed) {
      _ref.read(llmServerStatusProvider.notifier).state = status;
      _ref.read(llmServerErrorProvider.notifier).state = error;
    }
    
    debugPrint('LocalLlmService status: $status ${error != null ? "- $error" : ""}');
  }

  /// Locates the GGUF model and llama-server binary in the local assets.
  /// Returns a map with 'exe' and 'model' paths, or throws if not found.
  Map<String, String> _resolveLlmPaths() {
    final exeName = Platform.isWindows ? 'llama-server.exe' : 'llama-server';
    final dllName = 'llama.dll';

    final runningExeDir = File(Platform.resolvedExecutable).parent.path;
    
    // Candidates for lookup
    final possibleDirs = [
      '$runningExeDir/data/flutter_assets/assets/llm',
      'assets/llm',
      'app/assets/llm',
    ];

    Directory? llmDir;
    for (final path in possibleDirs) {
      final dir = Directory(path);
      if (dir.existsSync() && File('${dir.path}/$exeName').existsSync()) {
        llmDir = dir;
        break;
      }
    }

    if (llmDir == null) {
      llmDir = Directory('assets/llm'); // fallback
    }

    final exeFile = File('${llmDir.path}/$exeName');
    final dllFile = File('${llmDir.path}/$dllName');
    final modelFile = File('${llmDir.path}/qwen2.5-0.5b-instruct-q4_k_m.gguf');

    if (!exeFile.existsSync()) {
      throw Exception(
        'Missing llama-server executable. Expected at ${exeFile.absolute.path}\n'
        'Please run the download script to fetch the model and binaries.'
      );
    }
    if (!dllFile.existsSync()) {
      throw Exception(
        'Missing llama.dll. Expected at ${dllFile.absolute.path}\n'
        'Please run the download script to fetch the binaries.'
      );
    }
    if (!modelFile.existsSync()) {
      throw Exception(
        'Missing Qwen 2.5 GGUF model file. Expected at ${modelFile.absolute.path}\n'
        'Please run the download script to fetch the model.'
      );
    }

    return {
      'exe': exeFile.absolute.path,
      'model': modelFile.absolute.path,
      'workingDir': llmDir.absolute.path,
    };
  }

  /// Starts the llama-server.exe process as a background service.
  Future<void> startServer() async {
    if (_status == LlmServerStatus.starting || _status == LlmServerStatus.online) {
      return;
    }

    _updateStatus(LlmServerStatus.starting);

    try {
      // First, check if there's already a server running on port 8089 (e.g. from previous run)
      final isHealthy = await checkHealth();
      if (isHealthy) {
        _updateStatus(LlmServerStatus.online);
        return;
      }

      final paths = _resolveLlmPaths();
      final exePath = paths['exe']!;
      final modelPath = paths['model']!;
      final workingDir = paths['workingDir']!;

      debugPrint('Starting local LLM server:\nExe: $exePath\nModel: $modelPath');

      // Inject the working directory into the environment PATH so Windows resolves local DLLs
      final env = Map<String, String>.from(Platform.environment);
      final pathKey = env.keys.firstWhere(
        (k) => k.toUpperCase() == 'PATH',
        orElse: () => 'PATH',
      );
      final currentPath = env[pathKey] ?? '';
      env[pathKey] = '$workingDir;$currentPath';

      _serverProcess = await Process.start(
        exePath,
        [
          '--model', modelPath,
          '--port', '8089',
          '--ctx-size', '2048',
          '--threads', '4',
          '--no-mmap',
        ],
        workingDirectory: workingDir,
        runInShell: false,
        environment: env,
      );

      // Set up log file
      final appDocDir = await getApplicationDocumentsDirectory();
      final logFile = File('${appDocDir.path}/llama_server.log');
      if (logFile.existsSync()) {
        try {
          logFile.deleteSync();
        } catch (_) {}
      }
      _logSink = logFile.openWrite(mode: FileMode.write);

      // Listen to stdout and stderr for debugging and file logging
      _serverProcess!.stdout.transform(utf8.decoder).listen((data) {
        _logSink?.write(data);
        debugPrint('[LLM Server Output]: $data');
      });
      _serverProcess!.stderr.transform(utf8.decoder).listen((data) {
        _logSink?.write(data);
        debugPrint('[LLM Server Error]: $data');
      });

      // Monitor exit code
      _serverProcess!.exitCode.then((code) {
        _logSink?.write('\n[Process Exited with Code: $code]\n');
        _logSink?.close();
        _logSink = null;
        debugPrint('Local LLM server process exited with code: $code');
        if (!_disposed && (_status == LlmServerStatus.online || _status == LlmServerStatus.starting)) {
          _updateStatus(LlmServerStatus.error, 'Server exited unexpectedly with code $code. Check llama_server.log for details.');
        }
      });

      // Poll the health endpoint until it is ready
      bool ready = false;
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        ready = await checkHealth();
        if (ready) break;
      }

      if (ready) {
        _updateStatus(LlmServerStatus.online);
      } else {
        _updateStatus(LlmServerStatus.error, 'Server started but did not respond to health checks.');
        killServer();
      }
    } catch (e) {
      _updateStatus(LlmServerStatus.error, e.toString());
    }
  }

  /// Checks if the server is up and responsive.
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'ok') {
          return true;
        }
        // Sometimes llama-server returns simple JSON or just 200 OK
        return true;
      }
      return false;
    } catch (_) {
      try {
        // Fallback check: check v1/models endpoint
        final response = await _dio.get('/v1/models');
        return response.statusCode == 200;
      } catch (_) {
        return false;
      }
    }
  }

  /// Terminates the server process.
  void killServer() {
    WidgetsBinding.instance.removeObserver(this);
    if (_serverProcess != null) {
      _serverProcess!.kill();
      _serverProcess = null;
      debugPrint('Local LLM server process terminated.');
    }
    _logSink?.close();
    _logSink = null;
    _updateStatus(LlmServerStatus.offline);
  }

  /// Sends a chat prompt and returns a stream of text chunks.
  Stream<String> chatStream(List<Map<String, String>> messages) async* {
    if (_status != LlmServerStatus.online) {
      // Try to auto-start if offline
      await startServer();
      if (_status != LlmServerStatus.online) {
        throw Exception('Local LLM server is not online (Current status: $_status).');
      }
    }

    final response = await _dio.post(
      '/v1/chat/completions',
      data: {
        'model': 'qwen2.5-0.5b-instruct',
        'messages': messages,
        'stream': true,
        'temperature': 0.7,
        'max_tokens': 1024,
      },
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data.stream as Stream<Uint8List>;
    
    // Parse Server-Sent Events (SSE)
    await for (final chunk in stream.cast<List<int>>().transform(utf8.decoder)) {
      final lines = chunk.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        if (trimmed == 'data: [DONE]') continue;
        
        if (trimmed.startsWith('data: ')) {
          final jsonStr = trimmed.substring(6);
          try {
            final data = jsonDecode(jsonStr);
            final choices = data['choices'] as List;
            if (choices.isNotEmpty) {
              final delta = choices[0]['delta'];
              final content = delta['content'] as String?;
              if (content != null && content.isNotEmpty) {
                yield content;
              }
            }
          } catch (_) {
            // Ignore parse errors on malformed chunks
          }
        }
      }
    }
  }
}

final localLlmServiceProvider = Provider<LocalLlmService>((ref) {
  final service = LocalLlmService(ref);
  ref.onDispose(() {
    service.killServer();
  });
  return service;
});
