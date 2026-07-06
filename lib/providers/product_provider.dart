import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Product {
  final String id;
  final String name;
  final int price;
  final String barcode;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.barcode,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'barcode': barcode,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      barcode: json['barcode'] as String,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    int? price,
    String? barcode,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      barcode: barcode ?? this.barcode,
    );
  }
}

class ProductListNotifier extends StateNotifier<List<Product>> {
  ProductListNotifier() : super([]) {
    _loadProducts();
  }

  static const _storageKey = 'omamagoto_products';

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        state = jsonList.map((e) => Product.fromJson(e)).toList();
      } catch (e) {
        state = _getInitialProducts();
      }
    } else {
      state = _getInitialProducts();
      await _saveProducts();
    }
  }

  List<Product> _getInitialProducts() {
    return [
      Product(id: '1', name: 'あめ', price: 100, barcode: '10000001'),
      Product(id: '2', name: 'いちご', price: 300, barcode: '10000002'),
      Product(id: '3', name: 'うどん', price: 250, barcode: '10000003'),
      Product(id: '4', name: 'えびせん', price: 120, barcode: '10000004'),
      Product(id: '5', name: 'おにぎり', price: 150, barcode: '10000005'),
    ];
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  Future<void> addProduct(String name, int price) async {
    final String barcode = DateTime.now().millisecondsSinceEpoch.toString();
    final newProduct = Product(
      id: DateTime.now().toIso8601String(),
      name: name,
      price: price,
      barcode: barcode,
    );
    state = [...state, newProduct];
    await _saveProducts();
  }

  Future<void> updateProduct(String id, String name, int price) async {
    state = [
      for (final product in state)
        if (product.id == id)
          product.copyWith(name: name, price: price)
        else
          product
    ];
    await _saveProducts();
  }

  bool isNameDuplicate(String name, {String? excludeId}) {
    final trimmedName = name.trim().toLowerCase();
    return state.any((product) {
      if (excludeId != null && product.id == excludeId) {
        return false;
      }
      return product.name.toLowerCase() == trimmedName;
    });
  }

  Future<void> deleteProduct(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _saveProducts();
  }

  Future<void> deleteMultipleProducts(List<String> ids) async {
    state = state.where((p) => !ids.contains(p.id)).toList();
    await _saveProducts();
  }

  Future<void> resetToDefault() async {
    state = _getInitialProducts();
    await _saveProducts();
  }
}

final productListProvider =
    StateNotifierProvider<ProductListNotifier, List<Product>>((ref) {
  return ProductListNotifier();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final sortedProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productListProvider);
  final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();

  final filtered = products.where((product) {
    return product.name.toLowerCase().contains(searchQuery) ||
        product.barcode.contains(searchQuery);
  }).toList();

  filtered.sort((a, b) => a.name.compareTo(b.name));
  return filtered;
});

class SelectedProductIdsNotifier extends StateNotifier<Set<String>> {
  SelectedProductIdsNotifier() : super({});

  void toggle(String id) {
    if (state.contains(id)) {
      state = state.where((item) => item != id).toSet();
    } else {
      state = {...state, id};
    }
  }

  void selectAll(List<String> ids) {
    state = ids.toSet();
  }

  void clear() {
    state = {};
  }
}

final selectedProductIdsProvider =
    StateNotifierProvider<SelectedProductIdsNotifier, Set<String>>((ref) {
  return SelectedProductIdsNotifier();
});

final editingProductProvider = StateProvider<Product?>((ref) => null);
