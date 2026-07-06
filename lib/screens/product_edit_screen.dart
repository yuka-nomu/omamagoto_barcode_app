import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omamagoto_barcode_app/providers/product_provider.dart';
import 'package:omamagoto_barcode_app/providers/settings_provider.dart';

class ProductEditScreen extends ConsumerStatefulWidget {
  const ProductEditScreen({super.key});

  @override
  ConsumerState<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends ConsumerState<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  Product? _editingProduct;

  @override
  void initState() {
    super.initState();
    // Retrieve product to edit (if any) from provider
    _editingProduct = ref.read(editingProductProvider);

    _nameController = TextEditingController(text: _editingProduct?.name ?? '');
    _priceController =
        TextEditingController(text: _editingProduct?.price.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isHiraganaOnly = settings.isHiraganaOnly;
    final isNew = _editingProduct == null;

    final titleText = isNew
        ? '商品登録'.toHiragana(isHiraganaOnly)
        : '商品編集'.toHiragana(isHiraganaOnly);

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '商品名'.toHiragana(isHiraganaOnly),
                  hintText: isHiraganaOnly
                      ? 'あめ（ひらがなのみ）'.toHiragana(isHiraganaOnly)
                      : '例: りんご',
                  border: const OutlineInputBorder(),
                  helperText: isHiraganaOnly
                      ? 'ひらがなのみ入力できます。'.toHiragana(isHiraganaOnly)
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '商品名を入力してください。'.toHiragana(isHiraganaOnly);
                  }
                  if (isHiraganaOnly) {
                    final hiraganaRegex = RegExp(r'^[ぁ-んー\s　]+$');
                    if (!hiraganaRegex.hasMatch(value)) {
                      return 'ひらがなのみ入力してください。'.toHiragana(isHiraganaOnly);
                    }
                  }
                  final name = value.trim();
                  final isDuplicate = ref
                      .read(productListProvider.notifier)
                      .isNameDuplicate(name, excludeId: _editingProduct?.id);
                  if (isDuplicate) {
                    return '同じ商品名が既に登録されています。'.toHiragana(isHiraganaOnly);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Price Field
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: '価格'.toHiragana(isHiraganaOnly),
                  suffixText: '円'.toHiragana(isHiraganaOnly),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '価格を入力してください。'.toHiragana(isHiraganaOnly);
                  }
                  final price = int.tryParse(value);
                  if (price == null || price < 0) {
                    return '正しい価格を入力してください。'.toHiragana(isHiraganaOnly);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 36),

              // Save / Cancel Buttons
              ElevatedButton(
                onPressed: () => _save(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '保存'.toHiragana(isHiraganaOnly),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'キャンセル'.toHiragana(isHiraganaOnly),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final price = int.parse(_priceController.text.trim());

    if (_editingProduct != null) {
      await ref
          .read(productListProvider.notifier)
          .updateProduct(_editingProduct!.id, name, price);
    } else {
      await ref.read(productListProvider.notifier).addProduct(name, price);
    }

    if (context.mounted) {
      context.pop();
    }
  }
}