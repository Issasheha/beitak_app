import 'package:flutter/foundation.dart';

class RecentSearchStore {
  RecentSearchStore._();
  static final instance = RecentSearchStore._();

  final ValueNotifier<List<String>> listenable = ValueNotifier<List<String>>(<String>[]);

  void add(String term) {
    final t = term.trim();
    if (t.isEmpty) return;

    final list = List<String>.from(listenable.value);
    list.removeWhere((e) => e.toLowerCase() == t.toLowerCase());
    list.insert(0, t);

    if (list.length > 6) list.removeRange(6, list.length);
    listenable.value = list;
  }

  void remove(String term) {
    final list = List<String>.from(listenable.value);
    list.removeWhere((e) => e.toLowerCase() == term.toLowerCase());
    listenable.value = list;
  }
}
