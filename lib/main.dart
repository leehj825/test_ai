import 'package:flutter/material.dart';
import 'package:ai_edge_sdk/ai_edge_sdk.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini Nano Chat',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatProvider extends ChangeNotifier {
  final AiEdgeSdk _model = AiEdgeSdk();
  bool _isModelReady = false;
  String _statusMessage = 'Initializing... / 초기화 중...';
  final List<ChatMessage> _messages = [];
  bool _isGenerating = false;

  bool get isModelReady => _isModelReady;
  String get statusMessage => _statusMessage;
  List<ChatMessage> get messages => _messages;
  bool get isGenerating => _isGenerating;

  ChatProvider() {
    _initModel();
  }

  Future<void> _initModel() async {
    try {
      final isSupported = await _model.isSupported();
      if (!isSupported) {
        _isModelReady = false;
        _statusMessage = 'Model not supported on this device. / 이 기기에서는 모델이 지원되지 않습니다.';
        notifyListeners();
        return;
      }

      _isModelReady = await _model.initialize(
        modelName: 'gemini-nano',
      );
      if (_isModelReady) {
        _statusMessage = 'Ready / 준비됨';
      } else {
        _statusMessage = 'Failed to initialize model. / 모델을 초기화하지 못했습니다.';
      }
    } catch (e) {
      _isModelReady = false;
      _statusMessage = 'Model not available or supported. / 모델을 사용할 수 없거나 지원되지 않습니다.';
    }
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || !_isModelReady) return;

    _messages.add(ChatMessage(text: text, isUser: true));
    _isGenerating = true;
    notifyListeners();

    _messages.add(ChatMessage(text: '', isUser: false)); // Placeholder for streaming response
    int nanoMessageIndex = _messages.length - 1;

    try {
      String fullPrompt = "System Instruction: You are a helpful AI assistant. You must detect if the user speaks English or Korean, and seamlessly respond in the matching language. Ensure your responses are natural and polite.\n\nUser: $text\n\nAI Assistant:";
      await _model.generateContentStream(
        fullPrompt,
        onChunk: (chunk) {
          _messages[nanoMessageIndex] = ChatMessage(
            text: _messages[nanoMessageIndex].text + chunk,
            isUser: false,
          );
          notifyListeners();
        },
      );
    } catch (e) {
      _messages[nanoMessageIndex] = ChatMessage(
        text: 'Error generating response. / 응답을 생성하는 중 오류가 발생했습니다.',
        isUser: false,
      );
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Nano Local'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => context.read<ChatProvider>().clearChat(),
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          // Scroll to bottom whenever messages update and are not at bottom
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                color: provider.isModelReady ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                width: double.infinity,
                child: Center(
                  child: Text(
                    provider.statusMessage,
                    style: TextStyle(
                      color: provider.isModelReady ? Colors.green[200] : Colors.red[200],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: provider.messages.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8.0),
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    return Align(
                      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: message.isUser ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16.0).copyWith(
                            bottomRight: message.isUser ? const Radius.circular(0) : null,
                            bottomLeft: !message.isUser ? const Radius.circular(0) : null,
                          ),
                        ),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                        child: Text(
                          message.text.isEmpty ? '...' : message.text,
                          style: TextStyle(
                            color: message.isUser ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type a message / 메시지를 입력하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        ),
                        onSubmitted: (value) {
                          if (!provider.isGenerating && provider.isModelReady) {
                            provider.sendMessage(value);
                            _controller.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: provider.isGenerating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.0),
                            )
                          : const Icon(Icons.send),
                      onPressed: provider.isGenerating || !provider.isModelReady
                          ? null
                          : () {
                              provider.sendMessage(_controller.text);
                              _controller.clear();
                            },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
