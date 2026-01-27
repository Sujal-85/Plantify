import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/mongo_service.dart';
import '../../../core/services/database_service.dart';
import 'chat_history_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../scan/screens/scan_screen.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatModel> _messages = [];
  final List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;
  
  // Voice & TTS
  late stt.SpeechToText _speech;
  bool _isListening = false;
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _loadChatHistory();
    
    // Welcome message if no history
    if (_messages.isEmpty) {
      _addBotMessage('Namaste! I am your Plantify Assistant, here to help you achieve a healthy and bountiful harvest. How can I assist you with your crops today?');
    }

    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
  }

  Future<void> _loadChatHistory() async {
    final db = context.read<DatabaseService>();
    final history = await db.getChatMessages();
    if (history.isNotEmpty) {
      setState(() {
        _messages.clear();
        for (var msg in history) {
          _messages.add(ChatModel(
            text: msg['message'],
            isUser: msg['isUser'] == 1,
            timestamp: DateTime.parse(msg['timestamp']),
          ));
          if (msg['isUser'] == 1) {
            _history.add({'role': 'user', 'parts': [{'text': msg['message']}]});
          } else {
            _history.add({'role': 'model', 'parts': [{'text': msg['message']}]});
          }
        }
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _addBotMessage(String text) async {
    final msg = ChatModel(text: text, isUser: false);
    setState(() {
      _messages.add(msg);
    });
    _scrollToBottom();
    await context.read<DatabaseService>().saveChatMessage(text, false);
  }

  Future<void> _sendMessage([String? customText]) async {
    final text = customText ?? _controller.text.trim();
    if (text.isEmpty) return;

    final userMsg = ChatModel(text: text, isUser: true);
    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();
    await context.read<DatabaseService>().saveChatMessage(text, true);

    final mongoService = context.read<MongoService>();
    try {
      final response = await mongoService.getChatResponse(text, _history);
      
      setState(() {
        _messages.add(ChatModel(text: response, isUser: false));
        _history.add({'role': 'user', 'parts': [{'text': text}]});
        _history.add({'role': 'model', 'parts': [{'text': response}]});
        _isLoading = false;
      });
      await context.read<DatabaseService>().saveChatMessage(response, false);
    } catch (e) {
      _addBotMessage('Error: $e');
      setState(() => _isLoading = false);
    }
    _scrollToBottom();
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => debugPrint('onStatus: $val'),
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
            });
            if (val.finalResult) {
               setState(() => _isListening = false);
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await _flutterTts.setLanguage("en-IN");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Plantify digital assistant', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 16),
                _buildDisclaimerCard(),
                const SizedBox(height: 24),
                ..._messages.map((m) => _buildMessageBubble(m)),
                if (_messages.length == 1) _buildHistoryCard(),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          _buildSuggestedActions(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8C4), // Light orange/yellow from image
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.brown, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This is the beginning of a conversation with the Plantify digital assistant. This is a very new service and prone to errors. Take a critical look at answers given.',
                  style: TextStyle(color: Colors.brown[900], fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0056D2),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Open disclaimer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatModel message) {
    final bool isUser = message.isUser;
    final bool showSpeaker = !isUser && message.text.length > 20;

    return Column(
      children: [
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFFD9F2ED) : const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                      bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.4, fontWeight: FontWeight.w400),
                      ),
                      if (!isUser && message.text.contains('Health Check')) ...[
                        const SizedBox(height: 12),
                        _buildHealthCheckInnerCard(),
                      ],
                    ],
                  ),
                ).animate().fade().slideY(begin: 0.1, end: 0),
              ),
              if (!isUser) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: () => _speak(message.text),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthCheckInnerCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0056D2).withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen()));
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0056D2).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.health_and_safety_outlined, color: Color(0xFF0056D2), size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Health Check', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0056D2))),
                  Text('Take a picture and get a diagnosis', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.call_made_rounded, color: Color(0xFF0056D2), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFECF0FF), // Light blue from image
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chat history', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Refer back to your previous\nconversations', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomRight,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatHistoryScreen()));
              },
              icon: const Icon(Icons.history, size: 18),
              label: const Text('Open history'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedActions() {
    final List<String> suggestions = [
      'Identify a pest or disease',
      'Wheat crop care',
      'Tomato plant tips',
      'Fertilizer help'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Click to send an answer suggested by Plantify', 
            style: TextStyle(color: Colors.grey, fontSize: 11)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ActionChip(
                  label: Text(suggestions[index]),
                  onPressed: () => _sendMessage(suggestions[index]),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ask a question',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isListening ? _listen : _listen,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF0056D2),
              child: Icon(
                _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatModel {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatModel({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
