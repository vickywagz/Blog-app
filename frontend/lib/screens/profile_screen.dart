import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/widgets/profilepictureupdate_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // State management for inputs
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _emailController;

  // Tracks if any values have actually changed to activate top buttons
  bool _hasChanges = false;

  // 🟢 State variables to store initial values dynamically from the Provider
  late String _initialName;
  late String _initialUsername;
  late String _initialBio;
  late String _initialEmail;

  @override
  void initState() {
    super.initState();

    // 🟢 Extract the current user state immediately on initialization
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    // 🟢 Fallback to your old defaults if the user object properties happen to be blank
    _initialName = user?.name ?? 'Julian Vane';
    _initialUsername = user?.username ?? 'julianvane';
    _initialBio =
        user?.bio ??
        'Editor-in-Chief. Obsessed with minimal computing and the intersection of technology and human';
    _initialEmail = user?.email ?? 'julian.vane@curator.io';

    // Assign text values straight down to controllers
    _nameController = TextEditingController(text: _initialName);
    _usernameController = TextEditingController(text: _initialUsername);
    _bioController = TextEditingController(text: _initialBio);
    _emailController = TextEditingController(text: _initialEmail);

    // Listeners to watch and activate the top "Save Changes" header block dynamically
    _nameController.addListener(_checkForChanges);
    _usernameController.addListener(_checkForChanges);
    _bioController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final changed =
        _nameController.text != _initialName ||
        _usernameController.text != _initialUsername ||
        _bioController.text != _initialBio;

    if (changed != _hasChanges) {
      setState(() {
        _hasChanges = changed;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _resetFields() {
    _nameController.text = _initialName;
    _usernameController.text = _initialUsername;
    _bioController.text = _initialBio;
    FocusScope.of(context).unfocus();
  }

  // Inside your Profile Screen State class where you handle the save event:
  // Inside your Profile Screen State class where you handle the save event:
  Future<void> _handleProfileSave() async {
    final authProvider = context.read<AuthProvider>();

    // Get values straight from your text controllers
    final newName = _nameController.text.trim();
    final newBio = _bioController.text.trim();
    final newUsername = _usernameController.text
        .trim(); // 🟢 Read username field

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name field cannot be empty')),
      );
      return;
    }

    // Fire the updates straight to the database via provider
    bool success = await authProvider.updateProfileDetails(
      name: newName,
      bio: newBio,
      username: newUsername, 
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Profile updated successfully!'
                : 'Failed to update profile.',
          ),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );

      // 🟢 FIXED: Removed the undefined _isEditing line since you track state via _hasChanges instead!
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF002244),
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of The Curator?',
          ),
          actions: [
            TextButton(
              // 🟢 The button already has an onPressed handler dismissing the dialog box here!
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF7A8087),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // 1. Dismiss modal first
                Navigator.pop(dialogContext);

                // 2. Clear out the User state data inside your provider layer 🟢
                await context.read<AuthProvider>().logout();

                // 3. Purge history and redirect safely
                if (context.mounted) {
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 Optional: If your avatar or other parts of the layout need to react
    // immediately to profile data changes elsewhere, you can watch the state here:
    final currentUser = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: Color(0xFF00365C),
          ),
          label: const Text(
            'Studio',
            style: TextStyle(
              color: Color(0xFF00365C),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        actions: [
          if (_hasChanges) ...[
            TextButton(
              onPressed: _resetFields,
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF7A8087),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton(
                onPressed: _hasChanges
                    ? () async {
                        // 🟢 1. Dismiss keyboard
                        FocusScope.of(context).unfocus();

                        // 🟢 2. Call the actual save logic we defined
                        await _handleProfileSave();

                        // 🟢 3. Update the initial values so the "Save" button hides again
                        setState(() {
                          _initialName = _nameController.text;
                          _initialBio = _bioController.text;
                          _initialUsername = _usernameController.text;
                          _hasChanges = false;
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF00365C,
                  ), // 🟢 Use brand blue when active
                  disabledBackgroundColor: const Color(0xFFECEFF3),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white, // 🟢 White text for better contrast
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ] else ...[
            TextButton(
              onPressed: null,
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFFC4C8CE), fontSize: 15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Color(0xFFC4C8CE),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟢 INSERT THIS INSTEAD:
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: ProfilePictureUploadWidget(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'DISPLAY NAME',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00365C),
                  letterSpacing: 0.8,
                ),
              ),
              TextField(
                controller: _nameController,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2328),
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 6),
                ),
              ),
              TextField(
                controller: _usernameController,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7A8087),
                ),
                decoration: const InputDecoration(
                  prefixText: '@ ',
                  prefixStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7A8087),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'WRITER BIO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00365C),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _bioController,
                        maxLines: null,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Color(0xFF1F2328),
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFF9096A0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Divider(color: Color(0xFFEAEAEA), thickness: 1),
              const SizedBox(height: 24),
              const Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2328),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EMAIL ADDRESS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7A8087),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _initialEmail, // 🟢 Render dynamically populated state parameter
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2328),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  context.push("/password-security-screen");
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.security_rounded,
                        size: 20,
                        color: Color(0xFF00365C),
                      ),
                      SizedBox(width: 14),
                      Text(
                        'Password & Security',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2328),
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Color(0xFF7A8087),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 44),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    _showLogoutConfirmationDialog(context);
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 16,
                    color: Colors.redAccent,
                  ),
                  label: const Text('Log Out'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
