// import 'package:absence/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class AppSidebar extends StatelessWidget {
  final Function(String route) onMenuTap;

  const AppSidebar({super.key, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0F1923) : const Color(0xFFf8fafc),
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A2A3A), Color(0xFF0F1923)],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFffffff),
                    const Color(0xFFf1f5f9),
                  ],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isDark),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: [
                    _MenuItem(
                      icon: MaterialCommunityIcons.view_dashboard,
                      title: "Dashboard",
                      onTap: () => onMenuTap("dashboard"),
                    ),
                    _MenuItem(
                      icon: MaterialCommunityIcons.cog,
                      title: "Settings",
                      onTap: () => onMenuTap("settings"),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? const Color(0xFF1E3A5F).withOpacity(0.5)
                    : Colors.black.withOpacity(0.08),
                indent: 20,
                endIndent: 20,
              ),
              _MenuItem(
                icon: MaterialCommunityIcons.logout,
                title: "Logout",
                accentColor: const Color(0xFFF87171),
                onTap: () => onMenuTap("logout"),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? const Color(0xFF1E3A5F).withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? const Color(0xFF1E3A5F).withOpacity(0.4)
                  : const Color(0xFFe2e8f0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                "assets/CBI.png",
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "CAIS CBI",
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFF1F5F9)
                      : const Color(0xFF0f1729),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Monitoring System",
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94a3b8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color? accentColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.accentColor,
    required this.onTap,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final isLogout = w.accentColor != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnim.value, child: child);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _isHovered
              ? (isLogout
                  ? (isDark ? const Color(0xFF3A1A1A) : const Color(0xFFfef2f2))
                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFf1f5f9)))
              : Colors.transparent,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: w.onTap,
          onTapDown: (_) => _animController.forward(),
          onTapUp: (_) => _animController.reverse(),
          onTapCancel: () => _animController.reverse(),
          onHover: (value) => setState(() => _isHovered = value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isLogout
                        ? (isDark ? const Color(0xFF3A1A1A) : const Color(0xFFfef2f2))
                        : (isDark
                            ? const Color(0xFF1E3A5F).withOpacity(0.3)
                            : const Color(0xFFe0f2fe)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    w.icon,
                    color: isLogout ? const Color(0xFFF87171) : const Color(0xFF38BDF8),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  w.title,
                  style: TextStyle(
                    color: isLogout
                        ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFdc2626))
                        : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155)),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isLogout
                      ? const Color(0xFFF87171).withOpacity(0.3)
                      : (isDark ? const Color(0xFF475569) : const Color(0xFFcbd5e1)),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
