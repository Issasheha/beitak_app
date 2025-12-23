// lib/features/provider/home/presentation/views/profile/viewmodels/provider_profile_state.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum DocStatus { verified, inReview, required }

extension DocStatusX on DocStatus {
  String get labelAr {
    switch (this) {
      case DocStatus.verified:
        return 'موثق';
      case DocStatus.inReview:
        return 'قيد المراجعة';
      case DocStatus.required:
        return 'مطلوب';
    }
  }

  Color get chipBg {
    switch (this) {
      case DocStatus.verified:
        return const Color(0xFFE8F5E9);
      case DocStatus.inReview:
        return const Color(0xFFFFF8E1);
      case DocStatus.required:
        return const Color(0xFFFFEBEE);
    }
  }

  Color get chipFg {
    switch (this) {
      case DocStatus.verified:
        return const Color(0xFF2E7D32);
      case DocStatus.inReview:
        return const Color(0xFFF57F17);
      case DocStatus.required:
        return const Color(0xFFC62828);
    }
  }
}

@immutable
class ProviderDocumentItem {
  final String title;
  final DocStatus status;

  const ProviderDocumentItem({
    required this.title,
    required this.status,
  });

  ProviderDocumentItem copyWith({
    String? title,
    DocStatus? status,
  }) {
    return ProviderDocumentItem(
      title: title ?? this.title,
      status: status ?? this.status,
    );
  }
}

@immutable
class ProviderProfileState {
  final Map<String, dynamic> provider;

  // header stats
  final int totalBookings;
  final double rating;
  final int ratingCount;
  final int completedBookings;

  // ✅ NEW
  final int experienceYears;

  // header identity
  final String displayName;
  final String categoryLabel;
  final String memberSinceLabel;

  // sections
  final String bio;
  final bool isAvailable;
  final String locationLabel;

  final List<ProviderDocumentItem> documents;

  const ProviderProfileState({
    required this.provider,
    required this.totalBookings,
    required this.rating,
    required this.ratingCount,
    required this.completedBookings,
    required this.experienceYears,
    required this.displayName,
    required this.categoryLabel,
    required this.memberSinceLabel,
    required this.bio,
    required this.isAvailable,
    required this.locationLabel,
    required this.documents,
  });

  factory ProviderProfileState.empty() {
    return const ProviderProfileState(
      provider: <String, dynamic>{},
      totalBookings: 0,
      rating: 0.0,
      ratingCount: 0,
      completedBookings: 0,
      experienceYears: 0,
      displayName: 'مزود خدمة',
      categoryLabel: 'خدمات',
      memberSinceLabel: 'Member since —',
      bio: '—',
      isAvailable: false,
      locationLabel: 'عمان، الأردن',
      documents: <ProviderDocumentItem>[],
    );
  }

  ProviderProfileState copyWith({
    Map<String, dynamic>? provider,
    int? totalBookings,
    double? rating,
    int? ratingCount,
    int? completedBookings,
    int? experienceYears,
    String? displayName,
    String? categoryLabel,
    String? memberSinceLabel,
    String? bio,
    bool? isAvailable,
    String? locationLabel,
    List<ProviderDocumentItem>? documents,
  }) {
    return ProviderProfileState(
      provider: provider ?? this.provider,
      totalBookings: totalBookings ?? this.totalBookings,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      completedBookings: completedBookings ?? this.completedBookings,
      experienceYears: experienceYears ?? this.experienceYears,
      displayName: displayName ?? this.displayName,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      memberSinceLabel: memberSinceLabel ?? this.memberSinceLabel,
      bio: bio ?? this.bio,
      isAvailable: isAvailable ?? this.isAvailable,
      locationLabel: locationLabel ?? this.locationLabel,
      documents: documents ?? this.documents,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ProviderProfileState &&
            mapEquals(other.provider, provider) &&
            other.totalBookings == totalBookings &&
            other.rating == rating &&
            other.ratingCount == ratingCount &&
            other.completedBookings == completedBookings &&
            other.experienceYears == experienceYears &&
            other.displayName == displayName &&
            other.categoryLabel == categoryLabel &&
            other.memberSinceLabel == memberSinceLabel &&
            other.bio == bio &&
            other.isAvailable == isAvailable &&
            other.locationLabel == locationLabel &&
            listEquals(other.documents, documents));
  }

  @override
  int get hashCode => Object.hash(
        _mapHash(provider),
        totalBookings,
        rating,
        ratingCount,
        completedBookings,
        experienceYears,
        displayName,
        categoryLabel,
        memberSinceLabel,
        bio,
        isAvailable,
        locationLabel,
        Object.hashAll(documents),
      );

  static int _mapHash(Map<String, dynamic> m) {
    return Object.hashAll(m.entries.map((e) => Object.hash(e.key, e.value)));
  }
}
