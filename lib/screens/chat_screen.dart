import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    getCurrentUser();

    // Inicializar la animación de escala
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

  void signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
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
              onTap: signOut,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: Tween(begin: 0.4, end: 0.4).animate(_controller),
              child: ScaleTransition(
                scale:
                    _scaleAnimation, // Animación de respiración (crecimiento y encogimiento)
                child: Image.asset(
                  'assets/logo.png',
                  height: 150,
                  opacity: const AlwaysStoppedAnimation(0.4), // Opacidad fija
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Hola, cuéntame sobre ti?',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
