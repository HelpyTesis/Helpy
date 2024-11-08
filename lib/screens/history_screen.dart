import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({Key? key}) : super(key: key);

  @override
  _ChatHistoryScreenState createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService chatService = ChatService();
  User? loggedInUser;
  List<Map<String, dynamic>> chatHistory = [];

  @override
  void initState() {
    super.initState();
    loggedInUser = _auth.currentUser;
    loadChatHistory();
  }

  Future<void> loadChatHistory() async {
    if (loggedInUser == null) return;
    final history = await chatService.getUserChats(loggedInUser!.uid);
    setState(() {
      chatHistory = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Chats')),
      body: chatHistory.isEmpty
          ? const Center(child: Text('No hay chats anteriores.'))
          : ListView.builder(
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                final chat = chatHistory[index];
                return ListTile(
                  title: Text("Chat del ${chat['fecha_inicio_chat'].toDate()}"),
                  subtitle: Text(chat['riesgo_detectado']
                      ? 'Riesgo detectado'
                      : 'Sin riesgo detectado'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatScreen(chatId: chat['chatId']),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
