import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/chat_screen.dart';
import '../screens/chat_history_screen.dart';

class SideMenu extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final int selectedIndex;
  final Function(int) onItemSelected;

  SideMenu({required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? 'Johanna Doe'),
            accountEmail: Text(user?.email ?? 'johanna@company.com'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            decoration: BoxDecoration(
              color: Colors.redAccent,
            ),
          ),
          _buildDrawerOption(
            context: context,
            icon: Icons.chat,
            text: 'Chat',
            index: 0,
            onTap: () => onItemSelected(0),
          ),
          _buildDrawerOption(
            context: context,
            icon: Icons.history,
            text: 'Historial',
            index: 1,
            onTap: () => onItemSelected(1),
          ),
          _buildDrawerOption(
            context: context,
            icon: Icons.report,
            text: 'Reportes',
            index: 2,
            onTap: () => onItemSelected(2),
          ),
          _buildDrawerOption(
            context: context,
            icon: Icons.favorite,
            text: 'Contenidos',
            index: 3,
            onTap: () => onItemSelected(3),
          ),
          _buildDrawerOption(
            context: context,
            icon: Icons.local_hospital,
            text: 'Emergencia',
            index: 4,
            onTap: () => onItemSelected(4),
          ),
          _buildDrawerOption(
            context: context,
            icon: Icons.settings,
            text: 'Ajustes',
            index: 5,
            onTap: () => onItemSelected(5),
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
    );
  }

  Widget _buildDrawerOption({
    required BuildContext context,
    required IconData icon,
    required String text,
    required int index,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      selected: selectedIndex == index,
      selectedTileColor: Colors.redAccent.withOpacity(0.1),
      onTap: onTap,
    );
  }
}
