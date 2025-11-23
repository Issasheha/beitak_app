import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_viewmodel.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_business_info_section.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_contact_info_section.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_notification_prefs_section.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_profile_header_card.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_profile_section_card.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_support_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProviderProfileView extends StatefulWidget {
  const ProviderProfileView({super.key});

  @override
  State<ProviderProfileView> createState() => _ProviderProfileViewState();
}

class _ProviderProfileViewState extends State<ProviderProfileView> {
  late final ProviderProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProviderProfileViewModel();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Directionality(
      textDirection: TextDirection.rtl,
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
            onPressed: () => context.go(AppRoutes.providerHome),
          ),
          title: Text(
            'الملف التجاري',
            style: TextStyle(
              fontSize: SizeConfig.ts(20),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.help_outline,
                color: AppColors.textPrimary,
              ),
              onPressed: () => context.push(AppRoutes.helpCenter),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: SizeConfig.padding(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProviderProfileHeaderCard(viewModel: _viewModel),
                SizeConfig.v(20),
                ProviderBusinessInfoSection(viewModel: _viewModel),
                SizeConfig.v(16),
                ProviderContactInfoSection(viewModel: _viewModel),
                SizeConfig.v(16),
                ProviderNotificationPrefsSection(
                  notifyNewBookings: _viewModel.notifyNewBookings,
                  notifyBookingUpdates: _viewModel.notifyBookingUpdates,
                  notifyMessages: _viewModel.notifyMessages,
                  notifyReviews: _viewModel.notifyReviews,
                  onNewBookingsChanged: (v) {
                    setState(() {
                      _viewModel.updateNotifications(notifyNewBookings: v);
                    });
                  },
                  onBookingUpdatesChanged: (v) {
                    setState(() {
                      _viewModel.updateNotifications(
                        notifyBookingUpdates: v,
                      );
                    });
                  },
                  onMessagesChanged: (v) {
                    setState(() {
                      _viewModel.updateNotifications(notifyMessages: v);
                    });
                  },
                  onReviewsChanged: (v) {
                    setState(() {
                      _viewModel.updateNotifications(notifyReviews: v);
                    });
                  },
                ),
                SizeConfig.v(16),
                const ProviderProfileSectionCard(
                  title: 'الدعم والمساعدة',
                  child: ProviderSupportSection(),
                ),
                SizeConfig.v(40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
