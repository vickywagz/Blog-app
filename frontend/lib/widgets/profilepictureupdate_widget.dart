import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:blog_app/providers/auth_provider.dart';

class ProfilePictureUploadWidget extends StatefulWidget {
  const ProfilePictureUploadWidget({super.key});

  @override
  State<ProfilePictureUploadWidget> createState() => _ProfilePictureUploadWidgetState();
}

class _ProfilePictureUploadWidgetState extends State<ProfilePictureUploadWidget> {
  bool _isUploadingLocal = false;

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    
    // 1. Fire up native operating system image browser modal overlay
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Compresses image to 80% quality to save network bandwidth
    );

    if (pickedFile == null) return; // User canceled picking selection

    setState(() => _isUploadingLocal = true);

    // 2. Dispatch file binary payload straight to backend provider pipe
    File imageFile = File(pickedFile.path);
    bool success = await context.read<AuthProvider>().uploadProfileImage(imageFile);

    setState(() => _isUploadingLocal = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
              ? 'Profile picture updated successfully!' 
              : 'Upload failed. Please try again.'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Stack(
      children: [
        // The Profile Avatar Core Frame Circle Representation Shape
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xFFEAEAEA),
          backgroundImage: user?.profileImage != null && user!.profileImage!.isNotEmpty
              ? NetworkImage(user.profileImage!)
              : const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=256'),
        ),
        
        // Transparent Overlay Spinner shown during file stream upload transitions
        if (_isUploadingLocal)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              ),
            ),
          ),

        // Floating Camera Icon Trigger Action button
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: _isUploadingLocal ? null : _pickAndUploadImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF00365C),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}