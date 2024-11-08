// lib/screens/chat_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:helpy/screens/chat_history_screen.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../widgets/side_menu.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;

  const ChatScreen({Key? key, this.chatId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService chatService = ChatService();
  User? loggedInUser;
  String? chatId;
  int selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final List<Map<String, String>> messages = [];
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    loadLastOrNewChat();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
    }
  }

  Future<void> loadLastOrNewChat() async {
    if (loggedInUser == null) return;
    chatId = widget.chatId ??
        await chatService.getLastChatId(loggedInUser!.uid) ??
        await chatService.createChat(loggedInUser!.uid);
    loadMessages();
  }

  Future<void> loadMessages() async {
    if (chatId == null) return;
    final chatMessages = await chatService.getMessages(chatId!);
    setState(() {
      messages.clear();
      messages.addAll(chatMessages
          .map((msg) => {'sender': msg['tipo'], 'text': msg['texto']}));
    });
  }

  Future<void> createNewChat() async {
    if (loggedInUser == null) return;
    chatId = await chatService.createChat(loggedInUser!.uid);
    setState(() {
      messages.clear();
    });
  }

  Future<void> sendMessage(String text) async {
    setState(() {
      messages.add({'sender': 'user', 'text': text});
    });

    if (chatId != null) {
      await chatService.saveMessage(chatId!, text, 'user');
    }

    try {
      final response = await http.post(
        Uri.parse('http://146.148.78.31:5000/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final botMessage = jsonResponse['response'];

        setState(() {
          messages.add({'sender': 'bot', 'text': botMessage});
        });

        if (chatId != null) {
          await chatService.saveMessage(chatId!, botMessage, 'bot');
        }
      } else {
        setState(() {
          messages.add({
            'sender': 'bot',
            'text': 'Error: No se pudo obtener una respuesta.'
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          'sender': 'bot',
          'text': 'Error: No se pudo conectar al servidor.'
        });
      });
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void handleSideMenuItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChatHistoryScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: createNewChat,
          ),
        ],
      ),
      drawer: SideMenu(
        selectedIndex: selectedIndex,
        onItemSelected: handleSideMenuItemSelected,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: FadeTransition(
                    opacity: Tween(begin: 0.4, end: 0.4).animate(_controller),
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.asset(
                        'assets/logo.png',
                        height: 150,
                        opacity: const AlwaysStoppedAnimation(0.4),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 180.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return Align(
                        alignment: message['sender'] == 'user'
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: message['sender'] == 'user'
                                ? Colors.blueAccent
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message['text'] ?? '',
                            style: TextStyle(
                                color: message['sender'] == 'user'
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Hola, cuéntame sobre ti?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onSubmitted: (text) {
                      if (text.isNotEmpty) {
                        sendMessage(text);
                        messageController.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final text = messageController.text;
                    if (text.isNotEmpty) {
                      sendMessage(text);
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
