// lib/src/features/dashboard/presentation/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:aic_woippy_app/src/features/distributions/presentation/distributions_screen.dart';
import 'package:aic_woippy_app/src/features/announcements/presentation/announcements_screen.dart';
import 'package:aic_woippy_app/src/features/profile/presentation/profile_screen.dart';
import 'package:aic_woippy_app/src/features/dashboard/presentation/announcement_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // L'index de la page sélectionnée, commence maintenant à 0 pour Distributions
  int _selectedIndex = 0;

  // NOUVELLE FONCTION pour changer d'onglet
  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // NOUVEL ORDRE DES PAGES
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      // La page de distribution a maintenant besoin de la fonction pour changer d'onglet
      DistributionsScreen(navigateToProfileTab: () => _changeTab(2)),
      AnnouncementsScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AnnouncementBanner(),
            Expanded(
              // Utilisation d'un IndexedStack pour préserver l'état de chaque page
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: GNav(
            rippleColor: colors.primaryColor.withOpacity(0.1),
            hoverColor: colors.primaryColor.withOpacity(0.1),
            gap: 8,
            activeColor: colors.primaryColor,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            color: Colors.grey[600],
            tabs: const [
              GButton(
                icon: Icons.shopping_basket_outlined,
                text: 'Distributions',
              ),
              GButton(
                icon: Icons.campaign_outlined,
                text: 'Annonces',
              ),
              GButton(
                icon: Icons.person_outline,
                text: 'Profil',
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              _changeTab(index);
            },
          ),
        ),
      ),
    );
  }
}