import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omamagoto_barcode_app/providers/product_provider.dart';
import 'package:omamagoto_barcode_app/providers/settings_provider.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isHiraganaOnly = settings.isHiraganaOnly;
    final products = ref.watch(sortedProductsProvider);
    final selectedIds = ref.watch(selectedProductIdsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    final searchController = TextEditingController(text: searchQuery);
    searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: searchController.text.length),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('商品一覧'.toHiragana(isHiraganaOnly)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: '検索'.toHiragana(isHiraganaOnly),
                hintText: '検索ワードを入力'.toHiragana(isHiraganaOnly),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'商品一覧'.toHiragana(isHiraganaOnly)} (${products.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (products.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      if (selectedIds.length == products.length) {
                        ref.read(selectedProductIdsProvider.notifier).clear();
                      } else {
                        ref
                            .read(selectedProductIdsProvider.notifier)
                            .selectAll(products.map((p) => p.id).toList());
                      }
                    },
                    child: Text(
                      selectedIds.length == products.length
                          ? '選択解除'.toHiragana(isHiraganaOnly)
                          : 'すべて選択'.toHiragana(isHiraganaOnly),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Text(
                      searchQuery.isEmpty
                          ? '商品が登録されていません。'.toHiragana(isHiraganaOnly)
                          : '見つかりません'.toHiragana(isHiraganaOnly),
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final isSelected = selectedIds.contains(product.id);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isSelected
                              ? BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 1.5,
                                )
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: isSelected,
                            onChanged: (_) {
                              ref
                                  .read(selectedProductIdsProvider.notifier)
                                  .toggle(product.id);
                            },
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '${product.price} ${'円'.toHiragana(isHiraganaOnly)} | バーコード: ${product.barcode}',
                          ),
trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                tooltip: '編集'.toHiragana(isHiraganaOnly),
                                onPressed: () {
                                  ref.read(editingProductProvider.notifier).state =
                                      product;
                                  context.push('/product-edit');
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                tooltip: '削除'.toHiragana(isHiraganaOnly),
                                onPressed: () => _confirmDelete(
                                  context,
                                  ref,
                                  product.id,
                                  product.name,
                                  isHiraganaOnly,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            ref
                                .read(selectedProductIdsProvider.notifier)
                                .toggle(product.id);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (selectedIds.isNotEmpty) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/print');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '${selectedIds.length}個 ${'印刷へ進む'.toHiragana(isHiraganaOnly)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(editingProductProvider.notifier).state = null;
                      context.push('/product-edit');
                    },
                    icon: const Icon(Icons.add),
                    label: Text(
                      '商品追加'.toHiragana(isHiraganaOnly),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
    bool isHiraganaOnly,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('確認'.toHiragana(isHiraganaOnly)),
          content: Text('$name を${'削除しますか？'.toHiragana(isHiraganaOnly)}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('いいえ'.toHiragana(isHiraganaOnly)),
            ),
            TextButton(
              onPressed: () {
                ref.read(productListProvider.notifier).deleteProduct(id);
                final selected = ref.read(selectedProductIdsProvider);
                if (selected.contains(id)) {
                  ref.read(selectedProductIdsProvider.notifier).toggle(id);
                }
                Navigator.of(context).pop();
              },
              child: Text(
                'はい'.toHiragana(isHiraganaOnly),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}