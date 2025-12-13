// import 'package:beitak_app/features/auth/data/datasources/auth_local_datasource.dart';

// class HomeViewModel {
//   final DateTime Function() _now;

//   HomeViewModel({DateTime Function()? now}) : _now = now ?? DateTime.now;

//   String get greeting {
//     final hour = _now().hour;
//     if (hour < 12) return 'صباح الخير، مرحباً بعودتك!';
//     return 'مساء الخير، مرحباً بعودتك!';
//   }

//   Future<String> greetingWithName() async {
//     try {
//       final session = await AuthLocalDataSourceImpl().getCachedAuthSession();
//       final firstName = session?.user?.firstName.trim();
//       if (firstName != null && firstName.isNotEmpty) {
//         final hour = _now().hour;
//         final base = hour < 12 ? 'صباح الخير' : 'مساء الخير';
//         return '$base يا $firstName 👋';
//       }
//     } catch (_) {}
//     return greeting;
//   }
// }