import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omamagoto_barcode_app/providers/product_provider.dart';
import 'package:omamagoto_barcode_app/providers/settings_provider.dart';

enum BarcodePrintSize {
  small(24, '小 (1ページ24枚)'),
  medium(12, '中 (1ページ12枚)'),
  large(6, '大 (1ページ6枚)');

  final int countPerPage;
  final String label;

  const BarcodePrintSize(this.countPerPage, this.label);
}

class BarcodePrintScreen extends ConsumerStatefulWidget {
  const BarcodePrintScreen({super.key});

  @override
  ConsumerState<BarcodePrintScreen> createState() => _BarcodePrintScreenState();
}

class _BarcodePrintScreenState extends ConsumerState<BarcodePrintScreen> {
  BarcodePrintSize _selectedSize = BarcodePrintSize.medium;
  int _copies = 1;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isHiraganaOnly = settings.isHiraganaOnly;
    final selectedIds = ref.watch(selectedProductIdsProvider);
    final allProducts = ref.watch(productListProvider);

    final selectedProducts = allProducts
        .where((product) => selectedIds.contains(product.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('バーコード印刷'.toHiragana(isHiraganaOnly)),
      ),
      body: selectedProducts.isEmpty
          ? Center(
              child: Text(
                'いんさつするしょうひんがありません。'.toHiragana(isHiraganaOnly),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Selected Count Header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'いんさつするしょうひん'.toHiragana(isHiraganaOnly),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: selectedProducts.map((p) {
                              return Chip(
                                label: Text('${p.name} (${p.price}円)'),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Size selection
                  Text(
                    'サイズ選択'.toHiragana(isHiraganaOnly),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...BarcodePrintSize.values.map((size) {
                    final isSelected = _selectedSize == size;
                    return ListTile(
                      title: Text(size.label.toHiragana(isHiraganaOnly)),
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedSize = size;
                        });
                      },
                    );
                  }),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Copies setting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '印刷部数'.toHiragana(isHiraganaOnly),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            iconSize: 32,
                            onPressed: _copies > 1
                                ? () => setState(() => _copies--)
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              '$_copies',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            iconSize: 32,
                            onPressed: () => setState(() => _copies++),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Action Buttons
                  ElevatedButton(
                    onPressed: () => _handlePdfExport(context, isHiraganaOnly),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'PDF出力'.toHiragana(isHiraganaOnly),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _handlePrintShare(context, isHiraganaOnly),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '印刷共有'.toHiragana(isHiraganaOnly),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _handlePdfExport(BuildContext context, bool isHiraganaOnly) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'PDFしゅつりょくちゅう...'.toHiragana(isHiraganaOnly),
        ),
      ),
    );
  }

  void _handlePrintShare(BuildContext context, bool isHiraganaOnly) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'いんさつきょうゆうちゅう...'.toHiragana(isHiraganaOnly),
        ),
      ),
    );
  }
}