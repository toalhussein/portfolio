import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Locale notifier for managing app language
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('ar')); // Default to Arabic (RTL)

  /// Toggle between Arabic and English
  void toggleLocale() {
    state = state.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
  }

  /// Set specific locale
  void setLocale(Locale locale) {
    state = locale;
  }

  /// Check if current locale is RTL
  bool get isRTL => state.languageCode == 'ar';
}

/// Locale provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
