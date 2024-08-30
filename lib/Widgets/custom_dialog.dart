import 'package:flutter/material.dart';
class CustomDialog extends StatefulWidget {
  final Function() onDismiss;
  final Function() onSnooze;

  const CustomDialog({super.key, required this.onDismiss, required this.onSnooze});

  @override
   createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Wake Up Sid'),
      content: const Text('Time to wake up!'),
      actions: [
        TextButton(
          onPressed: widget.onDismiss,
          child: const Text('Dismiss'),
        ),
        TextButton(
          onPressed: widget.onSnooze,
          child: const Text('Snooze'),
        ),
      ],
    );
  }
}