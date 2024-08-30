import 'package:flutter/material.dart';
class SnoozeOption extends StatelessWidget {
  final Duration snoozeDuration;
  final VoidCallback onSelected;

  const SnoozeOption({super.key, required this.snoozeDuration, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white, // Changed to white
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Snooze for ${snoozeDuration.inMinutes} minutes',
              style: const TextStyle(color: Colors.black), // Add this to make the text visible
            ),
            const Icon(Icons.alarm, color: Colors.black), // Add this to make the icon visible
          ],
        ),
      ),
    );
  }
}