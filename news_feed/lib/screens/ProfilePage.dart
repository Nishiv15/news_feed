import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supabase_auth_service.dart';
import '../models/news_model.dart';
import '../widgets/NewsFeedNavbar.dart';
import '../widgets/NewsFeedFooter.dart';
import '../screens/HomePage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedCountry = globalCountry;
  bool _isProfileUpdating = false;
  bool _isPasswordUpdating = false;
  bool _isAccountDeleting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String _displayName = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    _displayName = user?.userMetadata?['display_name'] ?? 'User';
    _email = user?.email ?? '';
    _usernameController = TextEditingController(text: _displayName);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _initials {
    final parts = _displayName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (_displayName.isNotEmpty) return _displayName[0].toUpperCase();
    return 'U';
  }

  Future<void> _updateProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;
    setState(() => _isProfileUpdating = true);
    try {
      await SupabaseAuthService.updateUserProfile(
        newUsername: _usernameController.text.trim(),
        newCountry: _selectedCountry,
      );
      globalCountry = _selectedCountry;
      setState(() => _displayName = _usernameController.text.trim());
      if (mounted) {
        _showSnackbar('Profile updated successfully!', Colors.green);
      }
    } catch (e) {
      if (mounted) _showSnackbar('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isProfileUpdating = false);
    }
  }

  Future<void> _updatePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() => _isPasswordUpdating = true);
    try {
      await SupabaseAuthService.updateUserPassword(newPassword: _passwordController.text);
      if (mounted) {
        _passwordController.clear();
        _confirmPasswordController.clear();
        Navigator.pop(context); // Close the bottom sheet
        _showSnackbar('Password changed successfully!', Colors.green);
      }
    } catch (e) {
      if (mounted) _showSnackbar('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isPasswordUpdating = false);
    }
  }

  Future<void> _deleteAccount() async {
    setState(() => _isAccountDeleting = true);
    try {
      await SupabaseAuthService.deleteAccount();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (_) => false,
        );
        _showSnackbar('Account deactivated.', Colors.orange);
      }
    } catch (e) {
      if (mounted) _showSnackbar('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isAccountDeleting = false);
    }
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Form(
            key: _passwordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Change Password',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Text('Enter a new password for your account.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                  ),
                  validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isPasswordUpdating ? null : _updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A2E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isPasswordUpdating
                        ? const SizedBox(height: 22, width: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Update Password',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
          const SizedBox(width: 10),
          const Text('Delete Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
        content: const Text(
          'Are you sure? This will permanently deactivate your account and erase all saved articles. This action cannot be undone.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); _deleteAccount(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes, Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final countryName = countryMap.entries
        .firstWhere((e) => e.value == _selectedCountry, orElse: () => const MapEntry('Unknown', ''))
        .key;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A2E),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar circle with initials
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(color: Colors.white.withOpacity(0.6), width: 2.5),
                        ),
                        child: Center(
                          child: Text(
                            _initials,
                            style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _displayName,
                        style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _email,
                        style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _SectionHeader(title: 'Account Information'),
                      const SizedBox(height: 8),
                      _SettingsCard(
                        children: [
                          Form(
                            key: _profileFormKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    labelText: 'Display Name',
                                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF0F3460)),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: const Color(0xFFF8F9FA),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? 'Name cannot be empty' : null,
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _selectedCountry,
                                  decoration: InputDecoration(
                                    labelText: 'Preferred Country',
                                    prefixIcon: const Icon(Icons.public, color: Color(0xFF0F3460)),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: const Color(0xFFF8F9FA),
                                  ),
                                  items: countryMap.entries.map((e) =>
                                    DropdownMenuItem(value: e.value, child: Text(e.key))
                                  ).toList(),
                                  onChanged: (v) { if (v != null) setState(() => _selectedCountry = v); },
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isProfileUpdating ? null : _updateProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1A1A2E),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: _isProfileUpdating
                                        ? const SizedBox(height: 22, width: 22,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : const Text('Save Changes',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // QUICK INFO TILES
                      _SectionHeader(title: 'Details'),
                      const SizedBox(height: 8),
                      _SettingsCard(children: [
                        _InfoTile(icon: Icons.email_outlined, label: 'Email', value: _email),
                        const Divider(height: 1, indent: 56),
                        _InfoTile(icon: Icons.flag_outlined, label: 'Country', value: countryName),
                      ]),

                      const SizedBox(height: 28),

                      // SECTION: SECURITY 
                      _SectionHeader(title: 'Security'),
                      const SizedBox(height: 8),
                      _SettingsCard(children: [
                        _ActionTile(
                          icon: Icons.lock_outline,
                          iconColor: const Color(0xFF0F3460),
                          label: 'Change Password',
                          subtitle: 'Update your account password',
                          onTap: _showChangePasswordSheet,
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        ),
                      ]),

                      const SizedBox(height: 28),

                      // SECTION: DANGER ZONE
                      _SectionHeader(title: 'Danger Zone'),
                      const SizedBox(height: 8),
                      _SettingsCard(children: [
                        _ActionTile(
                          icon: Icons.delete_outline,
                          iconColor: Colors.red,
                          label: 'Delete Account',
                          subtitle: 'Permanently deactivate your account',
                          onTap: _isAccountDeleting ? null : _showDeleteConfirmation,
                          trailing: _isAccountDeleting
                              ? const SizedBox(height: 20, width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                              : const Icon(Icons.chevron_right, color: Colors.red),
                          labelColor: Colors.red,
                        ),
                      ]),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FooterWidget(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Colors.grey[500],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF0F3460)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget trailing;
  final Color labelColor;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
    required this.trailing,
    this.labelColor = const Color(0xFF1A1A2E),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: labelColor)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
