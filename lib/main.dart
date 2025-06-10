import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/report_provider.dart';
import 'services/auth_provider.dart';

void main() {
  runApp(const EcoGuardianApp());
}

class EcoGuardianApp extends StatelessWidget {
  const EcoGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ReportProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'EcoGuardian',
        debugShowCheckedModeBanner: false,
                 theme: ThemeData(
           primarySwatch: Colors.purple,
           primaryColor: const Color(0xFF6A1B9A),
           colorScheme: ColorScheme.fromSwatch(
             primarySwatch: Colors.purple,
           ).copyWith(
             secondary: const Color(0xFF9C27B0),
             surface: Colors.white,
           ),
           scaffoldBackgroundColor: const Color(0xFFF3E5F5),
                     appBarTheme: const AppBarTheme(
             backgroundColor: Color(0xFF6A1B9A),
             foregroundColor: Colors.white,
             elevation: 0,
             centerTitle: true,
           ),
           elevatedButtonTheme: ElevatedButtonThemeData(
             style: ElevatedButton.styleFrom(
               backgroundColor: const Color(0xFF9C27B0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
          ),
                     floatingActionButtonTheme: const FloatingActionButtonThemeData(
             backgroundColor: Color(0xFF9C27B0),
             foregroundColor: Colors.white,
           ),
           textTheme: const TextTheme(
             headlineSmall: TextStyle(
               color: Color(0xFF6A1B9A),
               fontWeight: FontWeight.bold,
             ),
             titleLarge: TextStyle(
               color: Color(0xFF6A1B9A),
               fontWeight: FontWeight.w600,
             ),
             titleMedium: TextStyle(
               color: Color(0xFF6A1B9A),
               fontWeight: FontWeight.w500,
             ),
            bodyLarge: TextStyle(
              color: Color(0xFF424242),
            ),
            bodyMedium: TextStyle(
              color: Color(0xFF616161),
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initializeAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.eco,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'EcoGuardian',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (authProvider.isLoggedIn) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
