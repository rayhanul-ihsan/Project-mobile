import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project_fullstack/controllers/auth_controller.dart';
import 'package:project_fullstack/config/app_config.dart';
import 'package:project_fullstack/routes/app_routes.dart';
import 'package:project_fullstack/widgets/app_bar/components/app_bar_avatar_menu.dart';
import 'package:project_fullstack/widgets/app_bar/components/app_bar_greeting.dart';
import 'package:project_fullstack/widgets/app_bar/components/app_bar_search_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String name;
  final String subtitle;
  final String image;
  final VoidCallback? onAvatarTap;

  const CustomAppBar({
    super.key,
    required this.name,
    this.subtitle = 'Jelajah produk terkait dari kami',
    required this.image,
    this.onAvatarTap,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(140.0);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _loggedIn = false;
  Map<String, dynamic>? _user;
  String? _displayName;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _displayName = widget.name;
    _photoPath = widget.image;
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic>? parsed;
    if (prefs.containsKey('user')) {
      try {
        final raw = prefs.getString('user');
        if (raw != null && raw.isNotEmpty) {
          parsed = jsonDecode(raw) as Map<String, dynamic>;
        }
      } catch (_) {}
    }
    if (parsed == null && prefs.containsKey('auth')) {
      try {
        final raw = prefs.getString('auth');
        if (raw != null && raw.isNotEmpty) {
          final m = jsonDecode(raw);
          if (m is Map && m.containsKey('data')) {
            parsed = Map<String, dynamic>.from(m['data']);
          }
        }
      } catch (_) {}
    }
    if (parsed != null) {
      setState(() {
        _user = parsed;
        _loggedIn = true;
        _displayName = parsed?['username'] ?? parsed?['name'] ?? widget.name;
        _photoPath =
            parsed?['image'] ?? parsed?['photo'] ?? widget.image;
      });
    }
  }

  String _resolveimage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    final apiBase = AppConfig.apiBase.replaceAll(RegExp(r'/$'), '');
    String hostBase = apiBase;
    final apiIndex = apiBase.indexOf('/api');
    if (apiIndex != -1) hostBase = apiBase.substring(0, apiIndex);
    final normalizedPath = imagePath.replaceAll(RegExp(r'^/'), '');
    final useHost = imagePath.startsWith('/uploads');
    return useHost ? '$hostBase/$normalizedPath' : '$apiBase/$normalizedPath';
  }

  Future<void> _onMenuSelected(String value) async {
    if (value == 'login') {
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }
    if (value == 'management') {
      Navigator.pushNamed(context, AppRoutes.productList);
      return;
    }
    if (value == 'logout') {
      await AuthController().logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('auth');
      await prefs.remove('access_token');
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _displayName ?? widget.name;
    final subtitle = widget.subtitle;
    final resolvedImage = _photoPath != null && _photoPath!.isNotEmpty
        ? _resolveimage(_photoPath)
        : null;

    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AppBarGreeting(name: displayName, subtitle: subtitle),
                const SizedBox(width: 12),
                AppBarAvatarMenu(
                  displayName: displayName,
                  resolvedImage: resolvedImage,
                  loggedIn: _loggedIn,
                  role: _user?['role'],
                  onSelected: (v) async {
                    await _onMenuSelected(v);
                    if (widget.onAvatarTap != null) widget.onAvatarTap!();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppBarSearchField(),
          ],
        ),
      ),
    );
  }
}
