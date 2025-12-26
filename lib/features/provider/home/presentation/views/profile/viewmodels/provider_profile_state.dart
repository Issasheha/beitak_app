import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum DocStatus { verified, inReview, required, recommended }

extension DocStatusX on DocStatus {
  String get labelAr {
    switch (this) {
      case DocStatus.verified:
        return 'موثق';
      case DocStatus.inReview:
        return 'قيد المراجعة';
      case DocStatus.required:
        return 'مطلوب';
      case DocStatus.recommended:
        return 'مستحسن';
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
      case DocStatus.recommended:
        return const Color(0xFFE7F1FF);
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
      case DocStatus.recommended:
        return const Color(0xFF1E5AA8);
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

  final int totalBookings;
  final double rating;
  final int ratingCount;
  final int completedBookings;

  final int experienceYears;

  final String displayName;
  final String categoryLabel;
  final String memberSinceLabel;

  final String bio;
  final bool isAvailable;

  /// قد يحتوي city فقط أو city + تفاصيل (لو تغيرت الداتا لاحقًا)
  final String locationLabel;

  /// ✅ NEW: City only (محسوبة مرة وحدة في الـ controller)
  final String cityLabel;

  final List<ProviderDocumentItem> documents;

  final bool isFullyVerified;
  final List<String> missingRequiredDocs;

  final bool isUpdatingAvailability;

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
    required this.cityLabel,
    required this.documents,
    required this.isFullyVerified,
    required this.missingRequiredDocs,
    required this.isUpdatingAvailability,
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
      memberSinceLabel: 'عضو منذ —',
      bio: '—',
      isAvailable: false,
      locationLabel: '',
      cityLabel: '',
      documents: <ProviderDocumentItem>[],
      isFullyVerified: false,
      missingRequiredDocs: <String>[],
      isUpdatingAvailability: false,
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
    String? cityLabel,
    List<ProviderDocumentItem>? documents,
    bool? isFullyVerified,
    List<String>? missingRequiredDocs,
    bool? isUpdatingAvailability,
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
      cityLabel: cityLabel ?? this.cityLabel,
      documents: documents ?? this.documents,
      isFullyVerified: isFullyVerified ?? this.isFullyVerified,
      missingRequiredDocs: missingRequiredDocs ?? this.missingRequiredDocs,
      isUpdatingAvailability: isUpdatingAvailability ?? this.isUpdatingAvailability,
    );
  }

  // ✅ PERFORMANCE NOTE:
  // لا تعمل deep compare على provider map (مكلف جدًا).
  // اعمل compare بالـidentity فقط.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ProviderProfileState &&
            identical(other.provider, provider) &&
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
            other.cityLabel == cityLabel &&
            listEquals(other.documents, documents) &&
            other.isFullyVerified == isFullyVerified &&
            listEquals(other.missingRequiredDocs, missingRequiredDocs) &&
            other.isUpdatingAvailability == isUpdatingAvailability);
  }

  @override
  int get hashCode => Object.hash(
        identityHashCode(provider),
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
        cityLabel,
        Object.hashAll(documents),
        isFullyVerified,
        Object.hashAll(missingRequiredDocs),
        isUpdatingAvailability,
      );
}
