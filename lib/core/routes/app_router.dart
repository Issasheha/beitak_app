// lib/core/routes/app_router.dart

import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/routes/router_refresh_notifier.dart';
import 'package:beitak_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:beitak_app/features/auth/presentation/providers/auth_state.dart';

import 'package:beitak_app/features/auth/presentation/views/login/login_view.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/provider_application_view.dart';
import 'package:beitak_app/features/auth/presentation/views/register/register_view.dart';

import 'package:beitak_app/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/about_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/provider_edit_account_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account_settings_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/documents/provider_documents_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/help_center_provider_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/history/provider_history_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/reviews/provider_reviews_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/terms_and_conditions_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/provider_earnings_view.dart';
import 'package:beitak_app/features/splash/presentation/views/splash_view.dart';

import 'package:beitak_app/features/provider/home/presentation/views/add_package_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/add_service_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/bookings/browse_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/marketplace/marketplace_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/provider_my_service.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/profile_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/provider_home_view.dart';

import 'package:beitak_app/features/user/home/presentation/home_view.dart';
import 'package:beitak_app/features/user/home/presentation/search_view.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/browse_service_view.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/provider_ratings_view.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/models/booking_list_item.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/service_details_view.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/my_service_view.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/help_center_user_view.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/profile_view.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/widgets/change_password_view.dart';
import 'package:beitak_app/features/user/home/presentation/views/request_service/request_service_view.dart';
import 'package:beitak_app/features/user/notifications/presentation/views/notifications_view.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = RouterRefreshNotifier();

  final sub = ref.listen<AuthState>(
    authControllerProvider,
    (_, __) => refresh.ping(),
  );

  ref.onDispose(() {
    sub.close();
    refresh.dispose();
  });

  // ========= Route groups =========

  const publicRoutes = <String>{
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.providerApplication,
  };

  // صفحات تتطلب حساب حقيقي (مش ضيف)
  const authOnlyRoutes = <String>{
    AppRoutes.myServices,
    AppRoutes.profile,
    AppRoutes.changePassword,
    AppRoutes.notifications,
  };

  // صفحات Provider فقط
  const providerOnlyRoutes = <String>{
    AppRoutes.providerHome,
    AppRoutes.providerProfile,
    AppRoutes.providerBrowse,
    AppRoutes.providerMyService,
    AppRoutes.providerAddService,
    AppRoutes.providerAddPackage,
    AppRoutes.providerMarketplace,
  };

  // صفحات User فقط (نترك HelpCenter متاح للجميع لو حبيت، بس خلّيه هنا إذا بدك ينعزل)
  const userOnlyRoutes = <String>{
    AppRoutes.home,
    AppRoutes.profile,
    AppRoutes.browseServices,
    AppRoutes.requestService,
    AppRoutes.myServices,
    AppRoutes.notifications,
    AppRoutes.changePassword,
    AppRoutes.helpCenter,
    AppRoutes.search,
    AppRoutes.serviceDetail,
  };

  String _encodeFrom(GoRouterState state) {
    final full = state.uri.toString(); // يشمل query
    return Uri.encodeComponent(full);
  }

  bool _isSafeFromRaw(String fromRaw) {
    if (!fromRaw.startsWith('/')) return false;

    const blocked = <String>{
      AppRoutes.login,
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.register,
    };

    // ممنوع يرجع لصفحات بتعمل loops
    if (blocked.contains(fromRaw)) return false;

    return true;
  }

  /// يرجّع from مناسب حسب الدور (وإلا null)
  String? _safeFromForRole({
    required String decodedFrom,
    required bool isProvider,
  }) {
    if (!_isSafeFromRaw(decodedFrom)) return null;

    // نقرأ path فقط (بدون query)
    final path = Uri.parse(decodedFrom).path;

    // ✅ لو Provider وجاي يروح لمسار User → امنعه
    if (isProvider && userOnlyRoutes.contains(path)) return null;

    // ✅ لو User وجاي يروح لمسار Provider → امنعه
    if (!isProvider && providerOnlyRoutes.contains(path)) return null;

    return decodedFrom;
  }

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: refresh,
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();

      final seenSplash = prefs.getBool('seen_splash') ?? false;
      final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

      // الأفضل نستخدم path للمقارنات
      final path = state.uri.path;

      // 1) Splash أول مرة
      if (!seenSplash) {
        return path == AppRoutes.splash ? null : AppRoutes.splash;
      }

      // 2) Onboarding أول مرة
      if (!seenOnboarding) {
        if (path == AppRoutes.onboarding || path == AppRoutes.splash)
          return null;
        return AppRoutes.onboarding;
      }

      // 3) AuthState مصدر الحقيقة
      final auth = ref.read(authControllerProvider);

      // أثناء التحميل الأولي للجلسة
      if (auth.status == AuthStatus.loading) return null;

      // 4) غير مسجل
      if (auth.status == AuthStatus.unauthenticated) {
        if (publicRoutes.contains(path)) return null;
        return '${AppRoutes.login}?from=${_encodeFrom(state)}';
      }

      // 5) ضيف
      if (auth.status == AuthStatus.guest) {
        // ممنوع على صفحات الحساب الحقيقي
        if (authOnlyRoutes.contains(path)) {
          return '${AppRoutes.login}?from=${_encodeFrom(state)}';
        }

        // ممنوع يفتح صفحات Provider
        if (providerOnlyRoutes.contains(path)) {
          return AppRoutes.home;
        }

        // لو ضيف وواقف على login → وديه Home
        if (path == AppRoutes.login) return AppRoutes.home;

        return null;
      }

      // 6) مسجّل دخول
      if (auth.status == AuthStatus.authenticated) {
        // ✅ Role Guards: امنع الدخول لصفحات الطرف الآخر
        if (auth.isProvider && userOnlyRoutes.contains(path)) {
          return AppRoutes.providerHome;
        }
        if (!auth.isProvider && providerOnlyRoutes.contains(path)) {
          return AppRoutes.home;
        }

        // لو جاي من login ومعه from → رجّعه بشرط يكون مناسب للدور
        if (path == AppRoutes.login) {
          final from = state.uri.queryParameters['from'];
          if (from != null && from.isNotEmpty) {
            final decoded = Uri.decodeComponent(from);
            final safe = _safeFromForRole(
              decodedFrom: decoded,
              isProvider: auth.isProvider,
            );
            if (safe != null) return safe;
          }

          // لو ما في from صالح → وجهة افتراضية حسب الدور
          return auth.isProvider ? AppRoutes.providerHome : AppRoutes.home;
        }

        // لا يرجع للـ public routes
        if (publicRoutes.contains(path)) {
          return auth.isProvider ? AppRoutes.providerHome : AppRoutes.home;
        }
      }

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
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.register,
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.home,
        builder: (context, state) => const HomeView(),
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
        builder: (context, state) {
          final q = state.uri.queryParameters['q'];
          final cityId =
              int.tryParse(state.uri.queryParameters['city_id'] ?? '');
          return BrowseServiceView(initialSearch: q, initialCityId: cityId);
        },
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
      // GoRoute(
      //   path: AppRoutes.helpCenter,
      //   name: AppRoutes.helpCenter,
      //   builder: (context, state) => const HelpCenterView(),
      // ),
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
        builder: (context, state) {
          final tab = state.uri.queryParameters['tab'];
          return ProviderBrowseView(initialTab: tab);
        },
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
      GoRoute(
        path: AppRoutes.search,
        name: AppRoutes.search,
        builder: (context, state) => const SearchView(),
      ),
      GoRoute(
        path: AppRoutes.serviceDetail,
        name: AppRoutes.serviceDetail,
        builder: (context, state) {
          final item = state.extra as BookingListItem;
          return ServiceDetailsView(initialItem: item);
        },
      ),
      GoRoute(
        path: AppRoutes.providerMarketplace,
        name: AppRoutes.providerMarketplace,
        builder: (context, state) => const MarketplaceView(),
      ),
      GoRoute(
        path: AppRoutes.providerTerms,
        name: AppRoutes.providerTerms,
        builder: (context, state) => const TermsAndConditionsView(),
      ),
      GoRoute(
        path: AppRoutes.providerHelpCenter,
        name: AppRoutes.providerHelpCenter,
        builder: (context, state) => const HelpCenterProviderView(),
      ),
      GoRoute(
        path: AppRoutes.provideraccountSettings,
        name: AppRoutes.provideraccountSettings,
        builder: (context, state) => const ProviderAccountSettingsView(),
      ),
      GoRoute(
        path: AppRoutes.provideraccountEdit,
        name: AppRoutes.provideraccountEdit,
        builder: (context, state) => const ProviderAccountEditView(),
      ),
      GoRoute(
        path: AppRoutes.providerdocumentsView,
        name: AppRoutes.providerdocumentsView,
        builder: (context, state) => const ProviderDocumentsView(),
      ),
      GoRoute(
        path: AppRoutes.providerHistory,
        name: AppRoutes.providerHistory,
        builder: (context, state) => const ProviderHistoryView(),
      ),
      GoRoute(
        path: AppRoutes.providerReviews,
        name: AppRoutes.providerReviews,
        builder: (context, state) => const ProviderReviewsView(),
      ),
      GoRoute(
        path: AppRoutes.providerAboutView,
        name: AppRoutes.providerAboutView,
        builder: (context, state) => const AboutView(),
      ),
      GoRoute(
        path: AppRoutes.providerEarningsView,
        name: AppRoutes.providerEarningsView,
        builder: (context, state) => const ProviderEarningsView(),
      ),
      GoRoute(
        path: AppRoutes.providerRatings,
        name: AppRoutes.providerRatings,
        builder: (context, state) {
          final providerId =
              int.tryParse(state.uri.queryParameters['provider_id'] ?? '') ?? 0;
          final providerName = state.uri.queryParameters['name'];

          return ProviderRatingsView(
            providerId: providerId,
            providerName: providerName,
          );
        },
      ),
      GoRoute(
  path: AppRoutes.userTerms,
  builder: (context, state) => const TermsAndConditionsView(),
),
GoRoute(
  path: AppRoutes.userHelpCenter,
  builder: (context, state) => const HelpCenterUserView(),
),
GoRoute(
  path: AppRoutes.userAbout,
  builder: (context, state) => const AboutView(),
),

    ],
  );
});
