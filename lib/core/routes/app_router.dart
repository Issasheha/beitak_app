// lib/core/routes/app_router.dart

import 'package:beitak_app/features/auth/presentation/views/login/login_view.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/provider_application_view.dart';
import 'package:beitak_app/features/auth/presentation/views/register/register_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/add_package_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/add_service_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/browse/browse_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/provider_my_service.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/profile_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/provider_home_view.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/browse_service_view.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/widgets/change_password_view.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/support_widgets/help_center_view.dart';
import 'package:beitak_app/features/user/home/presentation/home_view.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/my_service_view.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/profile_view.dart';
import 'package:beitak_app/features/user/home/presentation/views/request_service/request_service_view.dart';
import 'package:beitak_app/features/user/notifications/presentation/views/notifications_view.dart';
import 'package:beitak_app/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:beitak_app/features/splash/presentation/views/splash_view.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();

      final bool seenSplash = prefs.getBool('seen_splash') ?? false;
      final bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
      final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final bool isGuest = prefs.getBool('is_guest') ?? false;

      final String location = state.matchedLocation;

      // 🔒 المسارات التي تتطلب "مستخدم حقيقي" وليس ضيف
      // ✅ شلنا منها browseServices عشان الضيف يقدر يتصفح الخدمات
      const authOnlyRoutes = <String>{
        // AppRoutes.requestService,
        AppRoutes.myServices,
        AppRoutes.profile,
        AppRoutes.changePassword,
        AppRoutes.notifications,
      };

      // 1) أول تشغيل: روح على Splash
      if (!seenSplash) {
        await prefs.setBool('seen_splash', true);
        if (location != AppRoutes.splash) return AppRoutes.splash;
        return null;
      }

      // 2) لم يرَ الـ Onboarding بعد → يجب أن يمر عليها
      if (!seenOnboarding) {
        if (location != AppRoutes.onboarding && location != AppRoutes.splash) {
          return AppRoutes.onboarding;
        }
        return null;
      }

      // 3) ليس "داخل التطبيق" بعد (لا ضيف ولا مستخدم مسجَّل)
      if (!isLoggedIn) {
        // يُسمح له فقط:
        // - splash
        // - onboarding
        // - login
        // - register
        // - providerApplication
        // - providerHome (مؤقتاً للتجربة)
        if (location != AppRoutes.login &&
            location != AppRoutes.register &&
            location != AppRoutes.providerApplication &&
            location != AppRoutes.onboarding &&
            location != AppRoutes.splash &&
            location != AppRoutes.providerHome &&
            location != AppRoutes.providerProfile &&
            location != AppRoutes.providerBrowse &&
            location != AppRoutes.providerMyService &&
            location != AppRoutes.providerAddPackage &&
            location != AppRoutes.providerAddService) {
          return AppRoutes.login;
        }
        return null;
      }

      // 4) ضيف يحاول الوصول إلى مسار يحتاج حساب حقيقي → نوديه على login مع from
      if (isLoggedIn && isGuest && authOnlyRoutes.contains(location)) {
        // نضيف from كـ query param عشان نرجعه لنفس الصفحة بعد الـ login
        return '${AppRoutes.login}?from=$location';
      }

      // 5) مستخدم مسجّل (حقيقي) لا يرجع إلى login / register / onboarding
      // 👈 انتبه: هذا الشرط لا ينطبق على الضيف (isGuest == false فقط)
      if (isLoggedIn &&
          !isGuest &&
          (location == AppRoutes.login ||
              location == AppRoutes.register ||
              location == AppRoutes.onboarding)) {
        return AppRoutes.home;
      }

      // 6) باقي الحالات: اسمح له يكمل
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboarding,
        builder: (context, state) {
          // بعد ما يخلّص Onboarding نحفظ إنو شافها (احتياطًا)
          Future.microtask(() async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('seen_onboarding', true);
          });
          return const OnboardingView();
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.home,
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.register,
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: AppRoutes.providerApplication,
        name: AppRoutes.providerApplication,
        builder: (context, state) => const ProviderApplicationView(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profile,
        builder: (context, state) => const ProfileView(),
      ),
      GoRoute(
        path: AppRoutes.browseServices,
        name: AppRoutes.browseServices,
        builder: (context, state) => const BrowseServiceView(),
      ),
      GoRoute(
        path: AppRoutes.requestService,
        name: AppRoutes.requestService,
        builder: (context, state) => const RequestServiceView(),
      ),
      GoRoute(
        path: AppRoutes.myServices,
        name: AppRoutes.myServices,
        builder: (context, state) => const MyServicesView(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: AppRoutes.notifications,
        builder: (context, state) => const NotificationsView(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        name: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordView(),
      ),
      GoRoute(
        path: AppRoutes.helpCenter,
        name: AppRoutes.helpCenter,
        builder: (context, state) => const HelpCenterView(),
      ),
      GoRoute(
        path: AppRoutes.providerHome,
        name: AppRoutes.providerHome,
        builder: (context, state) => const ProviderHomeView(),
      ),
      GoRoute(
        path: AppRoutes.providerProfile,
        name: AppRoutes.providerProfile,
        builder: (context, state) => const ProviderProfileView(),
      ),
      GoRoute(
        path: AppRoutes.providerBrowse,
        name: AppRoutes.providerBrowse,
        builder: (context, state) => const ProviderBrowseView(),
      ),
      GoRoute(
        path: AppRoutes.providerMyService,
        name: AppRoutes.providerMyService,
        builder: (context, state) => const ProviderMyServiceView(),
      ),
      GoRoute(
        path: AppRoutes.providerAddService,
        name: AppRoutes.providerAddService,
        builder: (context, state) => const AddServiceView(),
      ),
      GoRoute(
        path: AppRoutes.providerAddPackage,
        name: AppRoutes.providerAddPackage,
        builder: (context, state) => const AddPackageView(),
      ),
    ],
  );
}
