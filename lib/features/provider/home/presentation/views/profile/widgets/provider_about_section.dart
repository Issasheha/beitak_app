// lib/features/provider/home/presentation/views/profile/widgets/provider_about_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_controller.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_profile_section_card.dart';

class ProviderAboutSection extends ConsumerWidget {
  final ProviderProfileState state;
  final ProviderProfileController controller;

  const ProviderAboutSection({
    super.key,
    required this.state,
    required this.controller,
  });

  static const int _maxAboutLength = 300;

  String _sanitize(String input) {
    final noHtml = input.replaceAll(RegExp(r'<[^>]*>'), '');
    return noHtml.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);

    final bioText = state.bio.trim().isEmpty ? '—' : state.bio.trim();

    return ProviderProfileSectionCard(
      title: 'النبذة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            bioText,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13.6),
              color: AppColors.textPrimary,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizeConfig.v(10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _openEditSheet(context),
              child: Text(
                'تعديل النبذة',
                style: AppTextStyles.body14.copyWith(
                  fontSize: SizeConfig.ts(13),
                  color: AppColors.lightGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditSheet(BuildContext context) {
    final initialText = state.bio == '—' ? '' : state.bio;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: _EditBioSheet(
            initialText: initialText,
            maxLen: _maxAboutLength,
            sanitize: _sanitize,
            onSave: (sanitized) => controller.updateBio(sanitized),
          ),
        );
      },
    );
  }
}

// ===================== Edit Sheet (BEST UX) =====================

class _EditBioSheet extends StatefulWidget {
  final String initialText;
  final int maxLen;
  final String Function(String) sanitize;
  final Future<void> Function(String) onSave;

  const _EditBioSheet({
    required this.initialText,
    required this.maxLen,
    required this.sanitize,
    required this.onSave,
  });

  @override
  State<_EditBioSheet> createState() => _EditBioSheetState();
}

class _EditBioSheetState extends State<_EditBioSheet> {
  late final TextEditingController _ctrl;
  final FocusNode _focus = FocusNode();

  final ValueNotifier<String?> _error = ValueNotifier<String?>(null);
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);
  final ValueNotifier<bool> _changed = ValueNotifier<bool>(false);

  late final String _initialSanitized;
  bool _saving = false;

  // footer heights (تقريبية ثابتة عشان نترك مساحة)
  double get _footerHeight => SizeConfig.h(66);

  @override
  void initState() {
    super.initState();

    _ctrl = TextEditingController(text: widget.initialText);
    _initialSanitized = widget.sanitize(widget.initialText);

    _ctrl.addListener(_validateNow);
    _validateNow();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.removeListener(_validateNow);
    _ctrl.dispose();
    _focus.dispose();
    _error.dispose();
    _counter.dispose();
    _changed.dispose();
    super.dispose();
  }

  void _validateNow() {
    if (!mounted) return;

    final sanitized = widget.sanitize(_ctrl.text);

    _counter.value = sanitized.length;
    _error.value = sanitized.length > widget.maxLen ? 'النص طويل جداً.' : null;

    final didChange = sanitized != _initialSanitized;
    _changed.value = didChange;
  }

  Future<void> _handleSave() async {
    if (_saving) return;

    final sanitized = widget.sanitize(_ctrl.text);
    if (sanitized.length > widget.maxLen) return;

    // ✅ إذا ما تغير شيء: سكّر بدون رسالة نجاح وبدون طلب
    if (!_changed.value) {
      FocusScope.of(context).unfocus();
      Navigator.of(context).pop();
      return;
    }

    setState(() => _saving = true);

    try {
      await widget.onSave(sanitized);

      if (!mounted) return;
      FocusScope.of(context).unfocus();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث النبذة بنجاح')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تحديث النبذة، حاول مرة أخرى')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.68,
      minChildSize: 0.50,
      maxChildSize: 0.92,
      builder: (context, scrollCtrl) {
        // ✅ مهم: نخلي الـ footer ثابت + فوق الكيبورد
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return Container(
          margin: EdgeInsets.only(top: SizeConfig.h(18)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(SizeConfig.radius(22)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Stack(
              children: [
                // ===================== CONTENT (scrollable) =====================
                ListView(
                  controller: scrollCtrl,
                  padding: EdgeInsets.fromLTRB(
                    SizeConfig.w(16),
                    SizeConfig.h(10),
                    SizeConfig.w(16),
                    // ✅ اترك مساحة للـ footer + مساحة للكيبود
                    _footerHeight + SizeConfig.h(16) + bottomInset,
                  ),
                  children: [
                    // drag handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        margin: EdgeInsets.only(bottom: SizeConfig.h(10)),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),

                    // header row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'تعديل النبذة',
                            style: AppTextStyles.body16.copyWith(
                              fontSize: SizeConfig.ts(16),
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    Divider(
                      height: 18,
                      color: Colors.grey.withValues(alpha: 0.14),
                    ),

                    // helper text (UX أفضل)
                    Text(
                      'اكتب نبذة قصيرة عن خدماتك (حتى ${widget.maxLen} حرف).',
                      style: AppTextStyles.caption11.copyWith(
                        fontSize: SizeConfig.ts(12),
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizeConfig.v(10),

                    // TextField
                    ValueListenableBuilder<String?>(
                      valueListenable: _error,
                      builder: (context, err, _) {
                        return TextField(
                          focusNode: _focus,
                          controller: _ctrl,
                          enabled: !_saving,
                          maxLines: 7,
                          minLines: 5,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            hintText: 'مثال: خبرة 5 سنوات في تنظيف المنازل…',
                            errorText: err,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(SizeConfig.radius(14)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(SizeConfig.radius(14)),
                              borderSide: BorderSide(
                                color: AppColors.borderLight.withValues(alpha: 0.9),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(SizeConfig.radius(14)),
                              borderSide: BorderSide(
                                color: AppColors.lightGreen.withValues(alpha: 0.95),
                                width: 1.6,
                              ),
                            ),
                            contentPadding: SizeConfig.padding(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        );
                      },
                    ),
                    SizeConfig.v(8),

                    // counter + error
                    Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<String?>(
                            valueListenable: _error,
                            builder: (_, err, __) {
                              if (err == null) return const SizedBox.shrink();
                              return Text(
                                err,
                                style: AppTextStyles.caption11.copyWith(
                                  fontSize: SizeConfig.ts(12),
                                  color: Colors.red,
                                  fontWeight: FontWeight.w700,
                                ),
                              );
                            },
                          ),
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: _counter,
                          builder: (_, n, __) {
                            final over = n > widget.maxLen;
                            return Text(
                              '$n/${widget.maxLen}',
                              style: AppTextStyles.caption11.copyWith(
                                fontSize: SizeConfig.ts(12),
                                color: over ? Colors.red : AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                // ===================== STICKY FOOTER (always visible) =====================
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.only(bottom: bottomInset),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        SizeConfig.w(16),
                        SizeConfig.h(10),
                        SizeConfig.w(16),
                        SizeConfig.h(10),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.14),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _saving
                                  ? null
                                  : () {
                                      FocusScope.of(context).unfocus();
                                      Navigator.of(context).pop();
                                    },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.borderLight.withValues(alpha: 0.9),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(SizeConfig.radius(14)),
                                ),
                                padding: SizeConfig.padding(vertical: 12),
                              ),
                              child: Text(
                                'إلغاء',
                                style: AppTextStyles.body14.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          SizeConfig.hSpace(10),
                          Expanded(
                            child: ValueListenableBuilder<String?>(
                              valueListenable: _error,
                              builder: (_, err, __) {
                                return ValueListenableBuilder<bool>(
                                  valueListenable: _changed,
                                  builder: (_, changed, __) {
                                    final disabled = err != null || _saving || !changed;

                                    return ElevatedButton(
                                      onPressed: disabled ? null : _handleSave,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.lightGreen,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: AppColors.lightGreen
                                            .withValues(alpha: 0.28),
                                        disabledForegroundColor:
                                            Colors.white.withValues(alpha: 0.9),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            SizeConfig.radius(14),
                                          ),
                                        ),
                                        padding: SizeConfig.padding(vertical: 12),
                                      ),
                                      child: _saving
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.check_rounded, size: 18),
                                                SizeConfig.hSpace(6),
                                                Text(
                                                  changed ? 'حفظ' : 'لا يوجد تغيير',
                                                  style: AppTextStyles.body14.copyWith(
                                                    fontSize: SizeConfig.ts(14),
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
