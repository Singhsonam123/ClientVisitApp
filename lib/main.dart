import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/toast_utils.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_screen.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Client Visit App',
      theme: AppTheme.lightTheme,
      home: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final prefs = snapshot.data!;
          final authRepository = AuthRepository(prefs);
          final authBloc = AuthBloc(authRepository);

          // Set the session expired callback in ApiClient
          // This will be called when token refresh fails
          ApiClient.setOnSessionExpired(() {
            print('[MAIN] Session expired callback triggered');
            authBloc.add(const SessionExpiredEvent());
          });

          return BlocProvider(
            create: (context) => authBloc
              ..add(const AuthCheckRequested()),
            child: const AppRouter(),
          );
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppRouter extends StatefulWidget {
   const AppRouter({super.key});

   @override
   State<AppRouter> createState() => _AppRouterState();
 }

 class _AppRouterState extends State<AppRouter> {
   @override
   Widget build(BuildContext context) {
     return BlocListener<AuthBloc, AuthState>(
       listener: (context, state) {
         // Handle session expired state
         if (state is AuthSessionExpired) {
           // Show session expired toast
           ToastUtils.showErrorToast(
             context,
             'Session expired, please login again',
             duration: const Duration(seconds: 4),
           );
         }
       },
       child: BlocBuilder<AuthBloc, AuthState>(
         buildWhen: (previous, current) {
           // Only rebuild for state changes that matter for navigation
           // Don't rebuild for AuthLoading (let login page handle its own loading state)
           if (current is AuthLoading) {
             return false;
           }
           return true;
         },
         builder: (context, state) {
           // Show splash screen initially
           if (state is AuthInitial) {
             return const SplashScreen();
           }

           // If authenticated, show home
           if (state is AuthAuthenticated) {
             return const HomePage();
           }

           // If session expired, show login
           if (state is AuthSessionExpired) {
             return const LoginPage();
           }

           // If unauthenticated, show login
           if (state is AuthUnauthenticated) {
             return const LoginPage();
           }

           // Default to login
           return const LoginPage();
         },
       ),
     );
   }
 }
