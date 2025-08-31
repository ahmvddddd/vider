import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants/sizes.dart';
import 'widgets/notifications_header.dart';

class NotificationViewScreen extends StatelessWidget {
  final String title;
  final String message;
  final DateTime date;
  const NotificationViewScreen({super.key,
    required this.title,
    required this.message,
    required this.date
    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NotificationsHeader(
        title: Text('Notification',
        style: Theme.of(context).textTheme.headlineSmall,),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.spaceBtwItems),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
              style: Theme.of(context).textTheme.labelMedium,),

              const SizedBox(height: Sizes.sm),
              Text(message,
              style: Theme.of(context).textTheme.bodyMedium,
              softWrap: true,),
              
              const SizedBox(height: Sizes.spaceBtwSections,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                DateFormat('dd/MM/yy HH:mm:ss').format(date),
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
        ],
      ),
            ],
          ),
        ),
      ),
    );
  }
}