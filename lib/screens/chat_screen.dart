import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? loggedInUser;
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
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendMessage(String text) async {
    setState(() {
      messages.add({'sender': 'user', 'text': text});
    });

    try {
      final response = await http.post(
        Uri.parse('http://146.148.78.31:5000/chat'), // URL de tu VM
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final botMessage = jsonResponse['response'];
        setState(() {
          messages.add({'sender': 'bot', 'text': botMessage});
        });
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

    // Auto-scroll al último mensaje
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(loggedInUser?.displayName ?? 'Johanna Doe'),
              accountEmail: Text(loggedInUser?.email ?? 'johanna@company.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/profile.jpg'),
              ),
              decoration: BoxDecoration(
                color: Colors.redAccent,
              ),
            ),
            // Opciones del Drawer
            _buildDrawerOption(
              index: 0,
              icon: Icons.chat,
              text: 'Chat',
              context: context,
            ),
            _buildDrawerOption(
              index: 1,
              icon: Icons.report,
              text: 'Reportes',
              context: context,
            ),
            _buildDrawerOption(
              index: 2,
              icon: Icons.history,
              text: 'Historial',
              context: context,
            ),
            _buildDrawerOption(
              index: 3,
              icon: Icons.favorite,
              text: 'Contenidos',
              context: context,
            ),
            _buildDrawerOption(
              index: 4,
              icon: Icons.local_hospital,
              text: 'Emergencia',
              context: context,
            ),
            _buildDrawerOption(
              index: 5,
              icon: Icons.settings,
              text: 'Ajustes',
              context: context,
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Cerrar Sesión'),
              onTap: () async {
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
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

  Widget _buildDrawerOption({
    required int index,
    required IconData icon,
    required String text,
    required BuildContext context,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      selected: selectedIndex == index,
      selectedTileColor: Colors.redAccent.withOpacity(0.1),
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }
}
