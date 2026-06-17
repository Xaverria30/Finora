import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../viewmodels/notification_viewmodel.dart';
import '../../utils/formatters.dart';
import '../../l10n/app_localizations.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<NotificationViewModel>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('notifications'),
          style: TextStyle(
            color: Theme.of(context).textTheme.headlineSmall?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Consumer<NotificationViewModel>(
            builder: (context, notificationVM, _) {
              if (notificationVM.notifications.isEmpty) return const SizedBox();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.done_all_rounded,
                      color: notificationVM.unreadCount > 0
                          ? AppColors.primary
                          : Colors.grey.shade400,
                    ),
                    tooltip: AppLocalizations.of(context).translate('mark_all_read'),
                    onPressed: notificationVM.unreadCount > 0
                        ? () => _showMarkAllReadDialog(context, notificationVM)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.error),
                    tooltip: AppLocalizations.of(context).translate('clear_all'),
                    onPressed: () => _showDeleteAllDialog(context, notificationVM),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, notificationVM, _) {
          final notifications = notificationVM.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.notifications_off_outlined,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context).translate('no_notifications'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).translate('no_notifications_subtitle'),
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(
                context,
                notification,
                notificationVM,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    Map<String, dynamic> notification,
    NotificationViewModel notificationVM,
  ) {
    final bool isRead = notification['isRead'] as bool? ?? false;
    final String type = notification['type'] as String? ?? 'info';

    IconData iconData = Icons.notifications_outlined;
    Color iconColor = AppColors.primary;
    Color bgColor = const Color(0xFFFCE4EC);

    switch (type) {
      case 'success':
      case 'transaction_update':
        iconData = Icons.check_circle_outline_rounded;
        iconColor = const Color(0xFF4DB6AC);
        bgColor = Theme.of(context).brightness == Brightness.light
            ? const Color(0xFFE0F2F1)
            : const Color(0xFF4DB6AC).withOpacity(0.2);
        break;
      case 'warning':
      case 'budget_alert':
        iconData = Icons.warning_amber_rounded;
        iconColor = const Color(0xFFFFB74D);
        bgColor = Theme.of(context).brightness == Brightness.light
            ? const Color(0xFFFFF3E0)
            : const Color(0xFFFFB74D).withOpacity(0.2);
        break;
      case 'error':
        iconData = Icons.error_outline_rounded;
        iconColor = const Color(0xFFE53935);
        bgColor = Theme.of(context).brightness == Brightness.light
            ? const Color(0xFFFFEBEE)
            : const Color(0xFFE53935).withOpacity(0.2);
        break;
    }

    return Dismissible(
      key: Key(notification['id'] as String),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(Icons.delete_outline, color: Colors.red.shade400),
      ),
      onDismissed: (_) =>
          notificationVM.removeNotification(notification['id'] as String),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
          border: isRead
              ? null
              : Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (!isRead) {
                notificationVM.markAsRead(notification['id'] as String);
              }
            },
            borderRadius: BorderRadius.circular(25),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notification['title'] as String? ??
                                    AppLocalizations.of(
                                      context,
                                    ).translate('notifications'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isRead
                                      ? FontWeight.w600
                                      : FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification['message'] as String? ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isRead
                                ? Colors.grey.shade600
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDate(notification['createdAt'] as DateTime?),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return AppLocalizations.of(context).translate(
        'minutes_ago',
        params: {'count': difference.inMinutes.toString()},
      );
    } else if (difference.inHours < 24) {
      return AppLocalizations.of(context).translate(
        'hours_ago',
        params: {'count': difference.inHours.toString()},
      );
    } else if (difference.inDays < 7) {
      return AppLocalizations.of(
        context,
      ).translate('days_ago', params: {'count': difference.inDays.toString()});
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showMarkAllReadDialog(BuildContext context, NotificationViewModel notificationVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('mark_all_read_confirm_title')),
        content: Text(AppLocalizations.of(context).translate('mark_all_read_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              notificationVM.markAllAsRead();
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context).translate('save'),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, NotificationViewModel notificationVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('delete_all_confirm_title')),
        content: Text(AppLocalizations.of(context).translate('delete_all_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              notificationVM.clearAll();
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context).translate('delete'),
              style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
