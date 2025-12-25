// lib/features/provider/home/presentation/views/profile/account/provider_account_edit_view.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/providers/provider_home_providers.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/viewmodels/account_edit_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/viewmodels/account_profile_providers.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/widgets/account_error_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/widgets/provider_account_password_card.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/widgets/provider_account_profile_card.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/widgets/provider_change_phone_sheet.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/widgets/provider_phone_otp_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ✅ لاستخدام local provider بدل إنشاء Impl جديد
import 'package:beitak_app/features/auth/presentation/providers/auth_providers.dart';

class ProviderAccountEditView extends ConsumerStatefulWidget {
  const ProviderAccountEditView({super.key});

  @override
  ConsumerState<ProviderAccountEditView> createState() =>
      _ProviderAccountEditViewState();
}

class _ProviderAccountEditViewState
    extends ConsumerState<ProviderAccountEditView> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  late final TextEditingController _currentPassCtrl;
  late final TextEditingController _newPassCtrl;
  late final TextEditingController _confirmPassCtrl;

  bool _initFromState = false;

  // ✅ listenables لتحديث كارد واحد بدل الصفحة كلها
  late final Listenable _profileListen;
  late final Listenable _passwordListen;

  @override
  void initState() {
    super.initState();

    _fullNameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();

    _currentPassCtrl = TextEditingController();
    _newPassCtrl = TextEditingController();
    _confirmPassCtrl = TextEditingController();

    _profileListen = Listenable.merge([_fullNameCtrl, _emailCtrl]);
    _passwordListen =
        Listenable.merge([_currentPassCtrl, _newPassCtrl, _confirmPassCtrl]);
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final asyncState = ref.watch(accountEditControllerProvider);

    // ✅ نقل تهيئة الكنترولرز خارج الـ build logic (أسرع وأأمن)
    ref.listen(accountEditControllerProvider, (prev, next) {
      final st = next.asData?.value;
      if (st == null) return;

      if (!_initFromState) {
        _fullNameCtrl.text = st.fullName;
        _emailCtrl.text = st.email;
        _phoneCtrl.text = st.phone;
        _initFromState = true;
      } else {
        // ✅ الهاتف يتغير بعد OTP
        if (_phoneCtrl.text.trim() != st.phone.trim()) {
          _phoneCtrl.text = st.phone;
        }
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: WillPopScope(
        onWillPop: () async => await _confirmLeaveIfDirty(),
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
              ),
              onPressed: () async {
                final ok = await _confirmLeaveIfDirty();
                if (!mounted) return;
                if (ok) context.pop();
              },
            ),
            title: Text(
              'تعديل معلومات الحساب',
              style: AppTextStyles.title18.copyWith(
                fontSize: SizeConfig.ts(18),
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
          ),
          body: asyncState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => AccountErrorView(
              message: err.toString(),
              onRetry: () => ref.invalidate(accountEditControllerProvider),
            ),
            data: (state) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: SizeConfig.padding(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProviderAccountProfileCard(
                        formKey: _profileFormKey,
                        state: state,
                        fullNameCtrl: _fullNameCtrl,
                        emailCtrl: _emailCtrl,
                        phoneCtrl: _phoneCtrl,
                        listenable: _profileListen,
                        onChangePhoneTap: () => _openChangePhoneFlow(state.phone),
                        onSave: _onSaveProfile,
                      ),
                      SizeConfig.v(18),
                      ProviderAccountPasswordCard(
                        formKey: _passwordFormKey,
                        state: state,
                        currentCtrl: _currentPassCtrl,
                        newCtrl: _newPassCtrl,
                        confirmCtrl: _confirmPassCtrl,
                        listenable: _passwordListen,
                        onSave: _onChangePassword,
                      ),
                      SizeConfig.v(24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ===================== Dirty helpers =====================

  String _norm(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ');

  bool _isProfileDirty(AccountEditState state) {
    final name = _norm(_fullNameCtrl.text);
    final email = _norm(_emailCtrl.text);
    return name != _norm(state.fullName) || email != _norm(state.email);
  }

  bool _isPasswordDirty() {
    return _currentPassCtrl.text.trim().isNotEmpty ||
        _newPassCtrl.text.trim().isNotEmpty ||
        _confirmPassCtrl.text.trim().isNotEmpty;
  }

  Future<bool> _confirmLeaveIfDirty() async {
    final asyncState = ref.read(accountEditControllerProvider);
    final st = asyncState.asData?.value;
    if (st == null) return true;

    final dirty = _isProfileDirty(st) || _isPasswordDirty();
    if (!dirty) return true;

    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد'),
        content: const Text('في تغييرات غير محفوظة. بدك تطلع بدون حفظ؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(_, true),
            child: const Text('نعم، اطلع'),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  // ===================== Actions =====================

  Future<void> _onSaveProfile() async {
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;

    final notifier = ref.read(accountEditControllerProvider.notifier);

    final fullName = _fullNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim(); // cache only

    final error = await notifier.saveProfile(
      fullName: fullName,
      email: email,
      phone: phone,
    );

    if (!mounted) return;

    if (error == null) {
      final parts = fullName
          .split(RegExp(r'\s+'))
          .where((s) => s.trim().isNotEmpty)
          .toList();
      final first = parts.isNotEmpty ? parts.first : fullName;
      final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      final local = ref.read(authLocalDataSourceProvider);
      await local.updateCachedUser(
        firstName: first,
        lastName: last,
        email: email,
        phone: phone,
      );

      ref.read(providerHomeViewModelProvider).setProviderName('$first $last');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'تم حفظ بيانات الحساب بنجاح')),
    );
  }

  Future<void> _onChangePassword() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;

    final notifier = ref.read(accountEditControllerProvider.notifier);

    final error = await notifier.changePassword(
      currentPassword: _currentPassCtrl.text.trim(),
      newPassword: _newPassCtrl.text.trim(),
      confirmPassword: _confirmPassCtrl.text.trim(),
    );

    if (!mounted) return;

    if (error == null) {
      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'تم تغيير كلمة المرور بنجاح')),
    );
  }

  // ===================== Phone OTP Flow (Sheets) =====================

  Future<void> _openChangePhoneFlow(String currentPhone) async {
    final normalizedPhone = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeConfig.radius(22)),
        ),
      ),
      builder: (_) {
        return ProviderChangePhoneSheet(
          currentPhone: currentPhone,
          onRequestOtp: (phone) async {
            final notifier = ref.read(accountEditControllerProvider.notifier);
            return await notifier.requestPhoneOtp(phone);
          },
        );
      },
    );

    if (!mounted || normalizedPhone == null) return;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeConfig.radius(22)),
        ),
      ),
      builder: (_) {
        return ProviderPhoneOtpSheet(
          phone: normalizedPhone,
          onResend: () async {
            final notifier = ref.read(accountEditControllerProvider.notifier);
            return await notifier.requestPhoneOtp(normalizedPhone);
          },
          onVerify: (otp) async {
            final notifier = ref.read(accountEditControllerProvider.notifier);
            return await notifier.verifyPhoneOtp(phone: normalizedPhone, otp: otp);
          },
        );
      },
    );

    if (!mounted) return;

    if (ok == true) {
      _phoneCtrl.text = normalizedPhone;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث رقم الهاتف بنجاح')),
      );
    }
  }
}
