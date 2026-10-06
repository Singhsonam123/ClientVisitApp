import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/gallery/data/gallery_repository.dart';
import 'features/gallery/presentation/bloc/gallery_bloc.dart';
import 'features/voting/data/voting_repository.dart';
import 'features/voting/presentation/bloc/voting_bloc.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/splash/presentation/pages/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final prefs = await SharedPreferences.getInstance();
  final authRepo    = AuthRepository(prefs);
  final galleryRepo = GalleryRepository(prefs);
  runApp(ShutterflyApp(authRepo: authRepo, galleryRepo: galleryRepo));
}

class ShutterflyApp extends StatelessWidget {
  final AuthRepository  authRepo;
  final GalleryRepository galleryRepo;
  const ShutterflyApp({super.key, required this.authRepo, required this.galleryRepo});

  @override
  Widget build(BuildContext context) {
    final votingRepo = VotingRepository();
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepo)..add(const AuthCheckRequested()),
        ),
        BlocProvider<GalleryBloc>(
          create: (_) => GalleryBloc(galleryRepo),
        ),
        BlocProvider<VotingBloc>(
          create: (_) => VotingBloc(votingRepo),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AppRouter(),
      ),
    );
  }
}

class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  /// Tracks whether the welcome screen has been fully shown.
  bool _welcomeShown = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Show splash while auth state is being determined
        if (state is AuthInitial || state is AuthLoading) {
          return const SplashPage();
        }

        // Show welcome screen once after splash resolves
        if (!_welcomeShown) {
          return WelcomePage(
            onComplete: () => setState(() => _welcomeShown = true),
          );
        }

        // Unauthenticated users (and post-signup) see the login page.
        if (state is AuthUnauthenticated ||
            state is AuthFailure ||
            state is AuthSignupSuccess) {
          return const LoginPage();
        }

        // Authenticated users go to the home screen.
        return const HomePage();
      },
    );
  }
}
