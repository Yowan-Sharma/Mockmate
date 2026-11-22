import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/loading_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/custom_interview_screen.dart';
import '../../features/interview/presentation/screens/interview_setup_screen.dart';
import '../../features/interview/presentation/screens/live_interview_screen.dart';
import '../../features/interview/presentation/screens/evaluation_screen.dart';
import '../../features/past_interviews/presentation/screens/past_interviews_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const LoadingScreen(mode: LoadingMode.appInitialization),
      ),
      GoRoute(
        path: '/post-auth',
        builder: (context, state) => const LoadingScreen(mode: LoadingMode.postAuthentication),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/custom',
        builder: (context, state) => const CustomInterviewScreen(),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => InterviewSetupScreen(
          extraData: state.extra as Map<String, dynamic>? ?? {},
        ),
      ),
      GoRoute(
        path: '/live',
        builder: (context, state) => const LiveInterviewScreen(),
      ),
      GoRoute(
        path: '/evaluation',
        builder: (context, state) => const EvaluationScreen(),
      ),
      GoRoute(
        path: '/past-interviews',
        builder: (context, state) => PastInterviewsScreen(
          selectedContext: state.extra as String?,
        ),
      ),
    ],
    redirect: (context, state) {
      final isAuth = authState.status == AuthStatus.authenticated;
      final isInitializing = authState.status == AuthStatus.initializing;
      final isAuthenticating = authState.status == AuthStatus.authenticating;
      
      final isSplash = state.matchedLocation == '/splash';
      final isLogin = state.matchedLocation == '/login';
      final isSignup = state.matchedLocation == '/signup';

      if (isInitializing) {
        return isSplash ? null : '/splash';
      }

      if (isAuth) {
        if (isLogin || isSignup || isSplash) {
          // If we came from login/signup or splash, go through post-auth loading
          return '/post-auth';
        }
        return null; // allow /home or /post-auth
      }

      if (!isAuth && !isInitializing && !isAuthenticating) {
        if (!isLogin && !isSignup) {
          return '/login';
        }
      }

      return null;
    },
  );
});
