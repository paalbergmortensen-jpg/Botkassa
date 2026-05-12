import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/add_fine_screen.dart';
import 'screens/active_appeals_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

import 'package:flutter/foundation.dart';
import 'services/payment_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'services/firestore_service.dart';
import 'screens/team_onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }
  }

  // Initialize RevenueCat
  final paymentService = PaymentService();
  await paymentService.init();

  runApp(
    const ProviderScope(
      child: BotkassaApp(),
    ),
  );
}

class BotkassaApp extends ConsumerWidget {
  const BotkassaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) {
      return MaterialApp(
        title: 'Botkassa (Web Preview)',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainNavigationScreen(),
      );
    }

    final authState = ref.watch(authStateProvider);
    final profileState = ref.watch(userProfileProvider);

    return MaterialApp(
      title: 'Botkassa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authState.when(
        data: (user) {
          if (user == null) return const LoginScreen();
          
          return profileState.when(
            data: (profile) {
              if (profile == null || profile.teamId == null) {
                return const TeamOnboardingScreen();
              }
              return const MainNavigationScreen();
            },
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (e, s) => Scaffold(body: Center(child: Text('Profilfeil: $e'))),
          );
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, s) => Scaffold(body: Center(child: Text('Authfeil: $e'))),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const LeaderboardScreen(),
    const AddFineScreen(),
    const ActiveAppealsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Oversikt',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Toppliste',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline_rounded),
              label: 'Legg til',
            ),
            NavigationDestination(
              icon: Icon(Icons.gavel_rounded),
              label: 'Anker',
            ),
          ],
        ),
      ),
    );
  }
}
