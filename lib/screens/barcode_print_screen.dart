import 'package:flutter/material.dart';

class BarcodePrintScreen extends StatelessWidget {
  const BarcodePrintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Barcode'),
      ),
      body: const Center(
        child: Text('Barcode Print Screen Content'),
      ),
    );
  }
}