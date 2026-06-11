import 'package:blog_app/screens/add_update_screen.dart'; 
import 'package:blog_app/providers/post_provider.dart'; // Added for Provider access
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // Added for Provider access

class MainDashboardLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainDashboardLayout({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainDashboardLayout> createState() => _MainDashboardLayoutState();
}

class _MainDashboardLayoutState extends State<MainDashboardLayout> {

  @override
  void initState() {
    super.initState();
    // Kicks off the initial data sync thread smoothly as the interface mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().getAllPost();
    });
  }

  void _onTabSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: widget.navigationShell,
      
      /// Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF005A8D),
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddUpdateScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.only(left: 45, right: 45, bottom: 16),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF2C3036),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 25,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  filledIcon: Icons.home_rounded,
                  label: 'Feed',
                ),
                _buildTabItem(
                  index: 1,
                  icon: Icons.bookmark_border_rounded,
                  filledIcon: Icons.bookmark_rounded,
                  label: 'Saved',
                ),
                _buildTabItem(
                  index: 2,
                  icon: Icons.grid_view_outlined,
                  filledIcon: Icons.grid_view_rounded,
                  label: 'Studio',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required IconData filledIcon,
    required String label,
  }) {
    final bool isActive = widget.navigationShell.currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? filledIcon : icon,
              color: isActive ? const Color(0xFF1F2328) : const Color(0xFF9096A0),
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1F2328),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: -0.2,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}