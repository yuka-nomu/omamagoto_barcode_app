import 'package:flutter/material.dart';

class ProductEditScreen extends StatelessWidget {
  const ProductEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: const Center(
        child: Text('Product Edit Screen Content'),
      ),
    );
  }
}