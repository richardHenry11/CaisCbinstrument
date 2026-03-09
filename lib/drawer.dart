import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class AppSidebar extends StatelessWidget {
  final Function(String route) onMenuTap;

  const AppSidebar({super.key, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Drawer(
        backgroundColor: const Color.fromARGB(255, 63, 63, 63),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 1,
                  child: DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 60, 122, 228),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset("assets/CBI.png", width: 50, height: 50),
                        const SizedBox(height: 12),
                        const Text(
                          "Cais CBI",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Monitoring System",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                _menuItem(
                  icon: MaterialCommunityIcons.view_dashboard,
                  title: "Dashboard",
                  onTap: () => onMenuTap("dashboard"),
                ),

                _menuItem(
                  icon: MaterialCommunityIcons.cog,
                  title: "Settings",
                  onTap: () => onMenuTap("settings"),
                ),

                const Divider(color: Colors.white24),

                _menuItem(
                  icon: MaterialCommunityIcons.logout,
                  title: "Logout",
                  color: Colors.redAccent,
                  onTap: () => onMenuTap("logout"),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}
