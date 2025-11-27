import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nodhapp/utils/app_constant.dart';
import 'package:nodhapp/providers/cart_manager.dart' as providers;
import 'package:nodhapp/services/supabase_service.dart' as services;
import 'package:nodhapp/screens/login/userProfile.dart'; 
import 'package:nodhapp/screens/home/home_page.dart';
import 'package:nodhapp/screens/cart/cart_page.dart';
import 'package:nodhapp/screens/cart/OrderHistoryPage.dart'; // <--- NEW IMPORT
import 'package:nodhapp/screens/login/login_page.dart';
import 'package:flutter_animate/flutter_animate.dart';



class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Index changed from 0-2 (3 tabs) to 0-3 (4 tabs)
  int _selectedIndex = 0; 

  final providers.CartManager _cartManager = providers.CartManager();
  final services.SupabaseService _supabaseService = services.SupabaseService();

  // State to hold the fetched UserProfile data
  UserProfile? _userProfile;
  bool _isLoadingProfile = false;


  @override
  void initState() {
    super.initState();
    _cartManager.onAuthRequired = _promptLogin;
    // We don't fetch here. We fetch when the profile tab is tapped.
  }

  void _promptLogin() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please log in to use the cart.'),
        action: SnackBarAction(
          label: 'LOGIN',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
      ),
    );
  }

  // New function to fetch the user profile from Supabase
  Future<void> _fetchUserProfile() async {
    if (_supabaseService.currentUser == null) return;

    if (_isLoadingProfile) return;

    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final profile = await _supabaseService.getUserProfile();
      setState(() {
        _userProfile = profile;
      });
    } catch (e) {
      debugPrint('Error fetching user profile in MainLayout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data.')),
        );
      }
    } finally {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Trigger profile fetch when the Profile tab (now index 3) is tapped
    if (index == 3) {
      _fetchUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pages list updated: Home (0), Cart (1), Orders (2), Profile (3)
    final List<Widget> pages = [
      HomePage(cartManager: _cartManager),
      CartPage(cartManager: _cartManager),
      const OrderHistoryPage(), // <--- NEW ORDERS PAGE (Index 2)
      _buildProfilePage(), // <--- PROFILE PAGE (Index 3)
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.SURFACE_COLOR,
        elevation: 0,
        title: Text(
          _getAppBarTitle(_selectedIndex),
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: AppConstant.FONT_HEADLINE,
            color: AppConstant.TEXT_PRIMARY,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppConstant.TEXT_PRIMARY),
            onPressed: () {},
          ),
          _buildCartIcon(),
          const SizedBox(width: AppConstant.PADDING_SMALL),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Cart',
          ),
          // --- NEW ORDER TRACKING TAB (Index 2) ---
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          // ----------------------------------------
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: AppConstant.SURFACE_COLOR,
        selectedItemColor: AppConstant.PRIMARY_COLOR,
        unselectedItemColor: AppConstant.TEXT_SECONDARY,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        showSelectedLabels: false,
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return AppConstant.APP_NAME;
      case 1:
        return 'My Cart';
      case 2: // <--- UPDATED INDEX
        return 'My Orders';
      case 3: // <--- UPDATED INDEX
        return 'Profile';
      default:
        return AppConstant.APP_NAME;
    }
  }

  Widget _buildCartIcon() {
    return AnimatedBuilder(
      animation: _cartManager,
      builder: (context, child) {
        return Badge(
          label: Text('${_cartManager.totalItems}',
              style: const TextStyle(color: Colors.white)),
          isLabelVisible: _cartManager.totalItems > 0,
          backgroundColor: AppConstant.PRIMARY_COLOR,
          child: IconButton(
            icon: const Icon(Icons.shopping_bag_outlined,
                color: AppConstant.TEXT_PRIMARY),
            onPressed: () => _onItemTapped(1),
          ),
        ).animate(
          target: _cartManager.totalItems > 0 ? 1 : 0,
        ).shake(
          hz: 4,
          duration: 200.ms,
        );
      },
    );
  }

  Widget _buildProfilePage() {
    final user = _supabaseService.currentUser;

    if (user == null) {
      return _buildLoggedOutProfile();
    }

    if (_isLoadingProfile) {
      return const Center(
        child: CircularProgressIndicator(color: AppConstant.PRIMARY_COLOR),
      );
    }
    
    // Use RefreshIndicator for pull-to-refresh functionality
    return RefreshIndicator(
      onRefresh: _fetchUserProfile, 
      color: AppConstant.PRIMARY_COLOR,
      backgroundColor: AppConstant.SURFACE_COLOR,
      child: _buildLoggedInProfile(user, _userProfile),
    );
  }

  Widget _buildLoggedInProfile(User user, UserProfile? profile) {
    return ListView(
      padding: const EdgeInsets.all(AppConstant.PADDING_LARGE),
      children: [
        // Avatar and Email/Username
        Center(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppConstant.PRIMARY_COLOR,
                child: Icon(Icons.person, size: 50, color: AppConstant.BACKGROUND_COLOR),
              ),
              const SizedBox(height: AppConstant.PADDING_MEDIUM),
              Text(
                profile?.username ?? user.email ?? 'User',
                style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: AppConstant.TEXT_PRIMARY),
              ),
              Text(
                user.email ?? 'No email provided',
                style: GoogleFonts.lato(fontSize: 16, color: AppConstant.TEXT_SECONDARY),
              ),
              const SizedBox(height: AppConstant.PADDING_LARGE * 2),
            ],
          ),
        ),

        // SHIPPING ADDRESS SECTION (Only shown if data is fetched)
        if (profile != null) ...[
          Text(
            'Shipping Address',
            style: GoogleFonts.playfairDisplay(fontSize: AppConstant.FONT_TITLE, color: AppConstant.PRIMARY_COLOR),
          ),
          const Divider(color: AppConstant.TEXT_SECONDARY),
          _buildProfileDetailRow('Full Name', profile.fullName),
          _buildProfileDetailRow('Address Line 1', profile.addressLine1),
          _buildProfileDetailRow('City', profile.city),
          _buildProfileDetailRow('Postal Code', profile.postalCode),
          
          const SizedBox(height: AppConstant.PADDING_LARGE),
        ],

        // LOGOUT BUTTON
        ElevatedButton(
          onPressed: () async {
            await _supabaseService.signOut();
            // Clear state and force refresh
            setState(() {
              _selectedIndex = 0;
              _userProfile = null; 
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstant.ERROR_COLOR,
            foregroundColor: AppConstant.BACKGROUND_COLOR, // Changed foreground to be visible on red
          ),
          child: const Text('Log Out'),
        ),
      ],
    );
  }

  Widget _buildProfileDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstant.PADDING_SMALL / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: GoogleFonts.lato(color: AppConstant.TEXT_SECONDARY, fontWeight: FontWeight.w500),
          ),
          Text(
            value != null && value.isNotEmpty ? value : 'Not Set',
            style: GoogleFonts.lato(color: AppConstant.TEXT_PRIMARY),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedOutProfile() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.person_off_outlined,
            size: 80, color: AppConstant.TEXT_SECONDARY),
        const SizedBox(height: AppConstant.PADDING_MEDIUM),
        Text(
          'You are browsing as a guest',
          style: GoogleFonts.playfairDisplay(
            fontSize: AppConstant.FONT_TITLE,
            color: AppConstant.TEXT_PRIMARY,
          ),
        ),
        const SizedBox(height: AppConstant.PADDING_SMALL),
        Text(
          'Log in to save your cart and more.',
          style: GoogleFonts.lato(color: AppConstant.TEXT_SECONDARY),
        ),
        const SizedBox(height: AppConstant.PADDING_LARGE),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstant.PRIMARY_COLOR,
            foregroundColor: AppConstant.BACKGROUND_COLOR,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: const Text('Login / Sign Up'),
        ),
      ],
    );
  }
}

