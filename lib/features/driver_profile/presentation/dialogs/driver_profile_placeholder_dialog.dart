import 'package:flutter/material.dart';

Future<void> showDriverProfilePlaceholderDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (_) => const AlertDialog(content: Text('Pendiente de implementacion')),
  );
}

