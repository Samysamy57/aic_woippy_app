// lib/src/features/dashboard/presentation/home_screen.dart
import 'package:flutter/material.dart';
import 'package:aic_woippy_app/src/features/distributions/presentation/distributions_screen.dart';
import 'package:aic_woippy_app/src/features/announcements/presentation/announcements_screen.dart';
import 'package:aic_woippy_app/src/features/profile/presentation/profile_screen.dart';
import 'package:aic_woippy_app/src/features/dashboard/presentation/announcement_banner.dart';
import 'package:aic_woippy_app/src/shared/widgets/background_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      DistributionsScreen(navigateToProfileTab: () => _onItemTapped(2)),
      AnnouncementsScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context);
    // MODIFICATION ICI : On spécifie le chemin de la NOUVELLE image
    return BackgroundContainer(
      imagePath: 'assets/images/background_main.png', // <-- AJOUTEZ CETTE LIGNE
      child: Scaffold(
        backgroundColor: Colors.transparent, // Important pour voir l'image derrière
        body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            const AnnouncementBanner(),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      ),
      // --- DÉBUT DE LA CORRECTION ---
      bottomNavigationBar: Container(
        // On décore le conteneur avec une bordure en haut
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300, // Une couleur de ligne discrète
              width: 0.5, // Très fin
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_basket_outlined),
                label: 'Distributions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.campaign_outlined),
                label: 'Annonces',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profil',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: colors.primaryColor,
            unselectedItemColor: Colors.grey[600],
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
      // --- FIN DE LA CORRECTION ---
      ),
    );
  }
}