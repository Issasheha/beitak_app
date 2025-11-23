// lib/features/user/notifications/presentation/views/notifications_view.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/user/notifications/presentation/viewmodels/notifications_viewmodel.dart';
import 'package:flutter/material.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late final NotificationsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = NotificationsViewModel();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final notifications = _viewModel.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'الإشعارات',
          style: TextStyle(
            fontSize: SizeConfig.ts(22),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: AppColors.textSecondary
                        .withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد إشعارات حاليًا',
                    style: TextStyle(
                      fontSize: SizeConfig.ts(18),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: SizeConfig.padding(all: 16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final noti = notifications[index];

                return Dismissible(
                  key: ValueKey(noti.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: SizeConfig.padding(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: SizeConfig.padding(horizontal: 24),
                    child: const Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      _viewModel.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف الإشعار')),
                    );
                  },
                  child: Container(
                    margin: SizeConfig.padding(vertical: 8),
                    padding: SizeConfig.padding(all: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: noti.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            noti.icon,
                            color: noti.color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                noti.title,
                                style: TextStyle(
                                  fontSize: SizeConfig.ts(16),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                noti.body,
                                style: TextStyle(
                                  fontSize: SizeConfig.ts(14),
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              noti.timeLabel,
                              style: TextStyle(
                                fontSize: SizeConfig.ts(11),
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Icon(
                              Icons.circle,
                              size: 10,
                              color: noti.isRead
                                  ? AppColors.textSecondary
                                      .withValues(alpha: 0.4)
                                  : noti.color,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
