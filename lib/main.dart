import 'package:co_rider/screens/active_ride_dashboard_screen.dart';
import 'package:co_rider/screens/create_ride_screen.dart';
import 'package:co_rider/screens/ride_details_screen.dart';
import 'package:co_rider/screens/ride_results_screen.dart';
import 'package:co_rider/screens/search_rides_screen.dart';
import 'package:co_rider/screens/role_selection_screen.dart';
import 'package:co_rider/screens/splash_screen.dart';
import 'package:co_rider/theme/dark_theme.dart';
import 'package:co_rider/theme/light_theme.dart';
import 'package:co_rider/theme/theme_controller.dart'; // Added this import
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:co_rider/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '', 
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController(),
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'CoRider',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/role_selection': (context) => const RoleSelectionScreen(),
            '/create_ride': (context) => const CreateRideScreen(),
            '/active_ride_dashboard': (context) => const ActiveRideDashboardScreen(),
            '/search_rides': (context) => const SearchRidesScreen(),
            '/ride_results': (context) => const RideResultsScreen(),
            '/ride_details': (context) => const RideDetailsScreen(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
