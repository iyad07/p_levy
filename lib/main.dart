import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/payment_success_screen.dart';
import 'screens/wallet_screen.dart';

void main() {
  runApp(const PLevyApp());
}

class PLevyApp extends StatelessWidget {
  const PLevyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppStateProvider()..initializeApp(),
      child: Consumer<AppStateProvider>(builder: (context, appState, child) {
        return MaterialApp.router(
          title: 'P-Levy',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1E3A8A),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            fontFamily: 'System',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black87),
              titleTextStyle: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            cardTheme: CardTheme(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
            ),
          ),
          routerConfig: _createRouter(appState),
        );
      }),
    );
  }

  GoRouter _createRouter(AppStateProvider appState) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isOnboarded = appState.isOnboarded;
        final isLoading = appState.isLoading;
        
        // Don't redirect while loading
        if (isLoading) {
          return null;
        }
        
        // If user is not onboarded and trying to access protected routes
        if (!isOnboarded && 
            state.matchedLocation != '/' && 
            state.matchedLocation != '/onboarding') {
          return '/';
        }
        
        // If user is onboarded and trying to access welcome/onboarding
        if (isOnboarded && 
            (state.matchedLocation == '/' || state.matchedLocation == '/onboarding')) {
          return '/dashboard';
        }
        
        return null;
      },
      routes: [
        // Welcome Screen
        GoRoute(
          path: '/',
          builder: (context, state) => const WelcomeScreen(),
        ),
        
        // Onboarding Screen
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        
        // Dashboard Screen
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        
        // Payment Screen
        GoRoute(
          path: '/payment',
          builder: (context, state) => const PaymentScreen(),
        ),
        
        // Payment Success Screen
        GoRoute(
          path: '/payment-success',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return PaymentSuccessScreen(paymentData: extra);
          },
        ),
        
        // Wallet Screen
        GoRoute(
          path: '/wallet',
          builder: (context, state) => const WalletScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Page Not Found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The page "${state.matchedLocation}" could not be found.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Loading Screen Widget
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.savings,
                size: 50,
                color: Color(0xFF1E3A8A),
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'P-Levy',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 40),
            
            const CircularProgressIndicator(
              color: Colors.white,
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
