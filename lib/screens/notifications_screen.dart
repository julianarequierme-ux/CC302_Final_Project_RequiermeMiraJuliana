import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../widgets/common_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, String>> _items = [
    {
      't': 'Booking confirmed',
      'm': 'Your Manila → Cebu flight is confirmed.',
      'w': '2h ago'
    },
    {
      't': 'Special deal',
      'm': 'Up to 50% OFF on selected sea boat trips.',
      'w': 'Yesterday'
    },
    {
      't': 'Check-in reminder',
      'm': 'Online check-in opens 24 hours before departure.',
      'w': '2 days ago'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _items.isEmpty
          ? const StateMessage(
              icon: Icons.notifications_off_outlined,
              title: 'All caught up',
              message: 'You have no notifications.')
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final n = _items[i];
                return Dismissible(
                  key: ValueKey(n['t']! + n['w']!),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: AppColors.danger,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) => confirmDialog(context,
                      title: 'Delete notification?',
                      message: 'This cannot be undone.'),
                  onDismissed: (_) => setState(() => _items.removeAt(i)),
                  child: Card(
                    color: Colors.white,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE6EEFB),
                          child: Icon(Icons.notifications,
                              color: AppColors.primary)),
                      title: Text(n['t']!,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${n['m']}\n${n['w']}'),
                      isThreeLine: true,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
