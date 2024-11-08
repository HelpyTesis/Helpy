import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../widgets/side_menu.dart';
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
  int selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    loadChatHistory();
  }

  void getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  Future<void> loadChatHistory() async {
    if (loggedInUser == null) return;
    
    // Intento de obtener el historial del usuario actual
    try {
      final history = await chatService.getUserChats(loggedInUser!.uid);
      print("Historial de chats cargado en pantalla: $history");  // Muestra en la consola para ver si obtiene los datos

      // Revisa si el historial está vacío y muestra un mensaje adecuado
      if (history.isEmpty) {
        print("No hay chats anteriores en Firestore para el usuario actual.");
      } else {
        setState(() {
          chatHistory = history;
        });
        print("Chats cargados en pantalla correctamente.");
      }
    } catch (e) {
      print("Error al cargar el historial de chats: $e");
    }
  }

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Hoy ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  void handleSideMenuItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ChatScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Chats'),
      ),
      drawer: SideMenu(
        selectedIndex: selectedIndex,
        onItemSelected: handleSideMenuItemSelected,
      ),
      body: chatHistory.isEmpty
          ? const Center(child: Text('No hay chats anteriores.'))
          : ListView.builder(
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                final chat = chatHistory[index];
                final Timestamp fechaInicio = chat['fecha_inicio_chat'];
                final formattedDate = formatDate(fechaInicio);

                return ListTile(
                  title: Text('Chat del $formattedDate'),
                  subtitle: Text(chat['riesgo_detectado']
                      ? 'Riesgo detectado'
                      : 'Sin riesgo detectado'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(chatId: chat['chatId']),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
