import 'package:flutter/material.dart';

Future<void> showBusRegistrationPlaceholderDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (_) => const AlertDialog(content: Text('Pendiente de implementacion')),
  );
}

