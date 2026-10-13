import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryBlue =
        isDark ? const Color(0xFF1E5090) : const Color(0xFF0F3A68);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final bgColor = isDark ? const Color(0xFF0F1419) : const Color(0xFFF8F9FA);
    final textColor =
        isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1A1A1A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final dividerColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Appearance Section ──
            Text(
              'Appearance',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: subtitleColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Dark Mode Toggle
                  _buildSettingsTile(
                    context: context,
                    icon: isDark ? Icons.dark_mode : Icons.light_mode,
                    iconColor: isDark
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFF59E0B),
                    title: 'Dark Mode',
                    subtitle: isDark ? 'Dark theme active' : 'Light theme active',
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => themeProvider.toggleTheme(),
                      activeColor: primaryBlue,
                    ),
                  ),
                  Divider(height: 1, color: dividerColor, indent: 56),

                  // Theme Mode Selector
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.palette_outlined,
                    iconColor: primaryBlue,
                    title: 'Theme',
                    subtitle: _themeModeLabel(themeProvider.themeMode),
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    trailing: Icon(
                      Icons.chevron_right,
                      color: subtitleColor,
                    ),
                    onTap: () => _showThemeSelector(context, themeProvider),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── About Section ──
            Text(
              'About',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: subtitleColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.info_outline,
                    iconColor: primaryBlue,
                    title: 'App Version',
                    subtitle: '1.0.3',
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subtitleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: subtitleColor,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.system:
        return 'System default';
    }
  }

  void _showThemeSelector(BuildContext context, ThemeProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue =
        isDark ? const Color(0xFF1E5090) : const Color(0xFF0F3A68);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose Theme',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _themeOption(
                  context: ctx,
                  icon: Icons.light_mode,
                  label: 'Light',
                  isSelected: provider.themeMode == ThemeMode.light,
                  primaryBlue: primaryBlue,
                  onTap: () {
                    provider.setThemeMode(ThemeMode.light);
                    Navigator.pop(ctx);
                  },
                ),
                _themeOption(
                  context: ctx,
                  icon: Icons.dark_mode,
                  label: 'Dark',
                  isSelected: provider.themeMode == ThemeMode.dark,
                  primaryBlue: primaryBlue,
                  onTap: () {
                    provider.setThemeMode(ThemeMode.dark);
                    Navigator.pop(ctx);
                  },
                ),
                _themeOption(
                  context: ctx,
                  icon: Icons.settings_suggest,
                  label: 'System default',
                  isSelected: provider.themeMode == ThemeMode.system,
                  primaryBlue: primaryBlue,
                  onTap: () {
                    provider.setThemeMode(ThemeMode.system);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _themeOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color primaryBlue,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? primaryBlue : Colors.grey,
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? primaryBlue : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: primaryBlue)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: onTap,
    );
  }
}
