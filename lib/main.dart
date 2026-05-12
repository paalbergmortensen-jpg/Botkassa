import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/add_fine_screen.dart';
import 'screens/active_appeals_screen.dart';
import 'screens/login_screen.dart';
import 'models/fine_type.dart';
import 'models/user.dart';
import 'services/auth_service.dart';

import 'package:flutter/foundation.dart';
import 'services/payment_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'services/firestore_service.dart';
import 'screens/team_onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
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

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;
    final isAdmin = profile?.role == UserRole.admin || kIsWeb;

    final List<Widget> screens = [
      const DashboardScreen(),
      const LeaderboardScreen(),
      const ActiveAppealsScreen(),
      if (isAdmin) const AddFineScreen(),
    ];

    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.grid_view_rounded),
        label: 'Oversikt',
      ),
      const NavigationDestination(
        icon: Icon(Icons.bar_chart_rounded),
        label: 'Toppliste',
      ),
      const NavigationDestination(
        icon: Icon(Icons.gavel_rounded),
        label: 'Anker',
      ),
      if (isAdmin)
        const NavigationDestination(
          icon: Icon(Icons.add_circle_outline_rounded),
          label: 'Gi bot',
        ),
    ];

    // Safety check for index out of bounds
    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
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
          destinations: destinations,
        ),
      ),
    );
  }
}
