import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cargoo_flutter/models/chat_message.dart';

class PtitMadouChatScreen extends StatefulWidget {
  const PtitMadouChatScreen({Key? key}) : super(key: key);

  @override
  State<PtitMadouChatScreen> createState() => _PtitMadouChatScreenState();
}

class _PtitMadouChatScreenState extends State<PtitMadouChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  bool _loading = false;
  String? _conversationId;
  String? _userId;

  final List<String> _quickSuggestions = [
    "Quand faire la vidange ?",
    "Ma voiture chauffe",
    "Bruit au freinage",
    "Préparer un voyage",
    "Ma batterie est faible",
    "Voyant moteur allumé",
  ];

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  void _initChat() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _userId = user.id;
    }

    _messages = [
      ChatMessage(
        id: 'welcome',
        text:
            "Salut ! Je suis Ptit Madou, ton assistant mécanique made in CI.\n\nJe connais bien nos réalités ivoiriennes : chaleur, poussière, embouteillages, nids de poule...\n\nPose-moi tes questions sur :\n- L'entretien de ton véhicule\n- Les pannes et diagnostics\n- Les pièces compatibles\n- Les conseils de conduite\n\nTu peux aussi m'envoyer une photo pour un diagnostic visuel !",
        sender: 'bot',
        timestamp: DateTime.now(),
      ),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _createConversation() async {
    if (_conversationId != null || _userId == null) return;

    try {
      final response = await Supabase.instance.client
          .from('ai_conversations')
          .insert({
            'user_id': _userId,
            'title': 'Conversation Ptit Madou',
          })
          .select()
          .maybeSingle();

      if (response != null) {
        setState(() {
          _conversationId = response['id'] as String;
        });
      }
    } catch (e) {
      print('Erreur création conversation: $e');
    }
  }

  Future<void> _saveMessage(String role, String content) async {
    if (_conversationId == null) {
      await _createConversation();
    }

    if (_conversationId != null) {
      try {
        await Supabase.instance.client.from('ai_messages').insert({
          'conversation_id': _conversationId,
          'role': role,
          'content': content,
        });
      } catch (e) {
        print('Erreur sauvegarde message: $e');
      }
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _loading) return;

    final userMessage = ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      sender: 'user',
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _loading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    await _saveMessage('user', text);

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'ptit-madou-chat',
        body: {
          'message': text,
          'history': _messages
              .sublist(1)
              .map((m) => {
                    'role': m.sender == 'user' ? 'user' : 'assistant',
                    'content': m.text,
                  })
              .toList(),
          'conversationId': _conversationId,
        },
      );

      if (response.data != null && response.data is Map) {
        final botResponse = (response.data as Map)['response'] as String?;
        final botText = botResponse ??
            "Désolé, je n'ai pas pu traiter ta demande.";

        final botMessage = ChatMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          text: botText,
          sender: 'bot',
          timestamp: DateTime.now(),
        );

        setState(() {
          _messages.add(botMessage);
          _loading = false;
        });

        await _saveMessage('assistant', botText);
      } else {
        _showError(
            "Désolé, une erreur est survenue. Vérifie ta connexion et réessaie.");
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print('Erreur appel API: $e');
      _showError(
          "Désolé, une erreur est survenue. Vérifie ta connexion et réessaie.");
      setState(() {
        _loading = false;
      });
    }

    _scrollToBottom();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _clearConversation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer la conversation'),
        content:
            const Text('Veux-tu vraiment supprimer tout l\'historique ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _conversationId = null;
                _initChat();
              });
              Navigator.pop(context);
            },
            child: const Text('Effacer',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2B44),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: const Color(0xFFFF6B00),
              ),
              child: const Icon(Icons.build, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ptit Madou',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green[400],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'En ligne',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color.fromARGB(179, 255, 255, 255),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _clearConversation,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return _buildMessageBubble(_messages[index]);
                } else {
                  return _buildTypingBubble();
                }
              },
            ),
          ),

          if (_messages.length <= 1)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _quickSuggestions.map((suggestion) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _sendMessage(suggestion),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          suggestion,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 16),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFFFFF5EF),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFFFF6B00),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Écris ton message...",
                        hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: null,
                      onSubmitted: (text) => _sendMessage(text),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (_messageController.text.trim().isNotEmpty &&
                        !_loading) {
                      _sendMessage(_messageController.text.trim());
                    }
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(21),
                      color: (_messageController.text.trim().isEmpty ||
                              _loading)
                          ? Colors.grey[400]
                          : const Color(0xFFFF6B00),
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.sender == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFFF6B00),
              ),
              child: const Icon(Icons.build, color: Colors.white, size: 11),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFFFF6B00) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                boxShadow: isUser
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isUser ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.timestamp
                        .toLocal()
                        .toString()
                        .substring(11, 16),
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFFF6B00),
            ),
            child: const Icon(Icons.build, color: Colors.white, size: 11),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: const Radius.circular(4),
                bottomRight: const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(0.4),
                const SizedBox(width: 4),
                _buildTypingDot(0.8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(double delayFactor) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: const Color(0xFFFF6B00).withOpacity(0.6),
      ),
    );
  }
}
