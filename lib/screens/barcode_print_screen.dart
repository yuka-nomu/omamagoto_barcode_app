import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omamagoto_barcode_app/providers/product_provider.dart';
import 'package:omamagoto_barcode_app/providers/settings_provider.dart';
import 'package:omamagoto_barcode_app/services/pdf_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

enum BarcodePrintSize {
  small(36, '小 (36枚)'),
  medium(24, '中 (24枚)'),
  large(12, '大 (12枚)');

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
  final Map<String, int> _qty = {};

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isHiraganaOnly = settings.isHiraganaOnly;
    final selectedIds = ref.watch(selectedProductIdsProvider);
    final allProducts = ref.watch(productListProvider);

    final selectedProducts = allProducts
        .where((product) => selectedIds.contains(product.id))
        .toList();

    for (final p in selectedProducts) {
      _qty.putIfAbsent(p.id, () => 1);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('バーコード印刷'.toHiragana(isHiraganaOnly)),
      ),
      body: selectedProducts.isEmpty
          ? Center(
              child: Text(
                '印刷する商品がありません。'.toHiragana(isHiraganaOnly),
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
                          /*Text(
                            '印刷する商品'.toHiragana(isHiraganaOnly),
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
                          const SizedBox(height: 16),*/
                          Text(
                            '各商品の印刷枚数'.toHiragana(isHiraganaOnly),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...selectedProducts.map((p) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(child: Text('${p.name} (${p.price}円)')),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      if ((_qty[p.id] ?? 1) > 1) {
                                        setState(() {
                                          _qty[p.id] = (_qty[p.id] ?? 1) - 1;
                                        });
                                      }
                                    },
                                  ),
                                  Container(
                                    width: 48,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${_qty[p.id] ?? 1}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        _qty[p.id] = (_qty[p.id] ?? 1) + 1;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList()
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

  void _handlePdfExport(BuildContext context, bool isHiraganaOnly) async {
    final selectedIds = ref.read(selectedProductIdsProvider);
    final allProducts = ref.read(productListProvider);
    final selectedProducts = allProducts
        .where((product) => selectedIds.contains(product.id))
        .toList();

    if (selectedProducts.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF出力中...')),
    );

    try {
      final pdfDoc = await _buildPdf(selectedProducts);
      final bytes = await pdfDoc.save().timeout(const Duration(seconds: 60));
      final savedPath = await savePdfToDownloads(bytes, 'バーコード印刷.pdf').timeout(const Duration(seconds: 60));

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (savedPath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDFを保存しました: $savedPath')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDFの保存先が取得できませんでした。')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF出力に失敗しました: $e')),
        );
        debugPrint('$e');
      }
    }
  }

  void _handlePrintShare(BuildContext context, bool isHiraganaOnly) async {
    final selectedIds = ref.read(selectedProductIdsProvider);
    final allProducts = ref.read(productListProvider);
    final selectedProducts = allProducts
        .where((product) => selectedIds.contains(product.id))
        .toList();

    if (selectedProducts.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('共有中...')),
    );

    try {
      final pdfDoc = await _buildPdf(selectedProducts);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfDoc.save(),
        name: 'バーコード印刷',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('共有に失敗しました: $e')),
        );
      }
    }
  }

  Future<pw.Document> _buildPdf(List<Product> selectedProducts) async {
    final pdfDoc = pw.Document();

    final fontData = await rootBundle.load('assets/fonts/NotoSansJP-Regular.ttf');
    final font = pw.Font.ttf(fontData);
    final textStyle = pw.TextStyle(font: font, fontSize: 10);

    final expanded = selectedProducts.expand((p) {
      final qty = _qty[p.id] ?? 1;
      return List.generate(qty, (_) => p);
    }).toList();

    final barcodeWidth = _getBarcodeWidth();
    final barcodeHeight = _getBarcodeHeight();
    final countPerPage = _selectedSize.countPerPage;
    final cols = _getColumns(_selectedSize);

    for (var i = 0; i < expanded.length; i += countPerPage) {
      final chunk = expanded.sublist(
        i,
        i + countPerPage > expanded.length
            ? expanded.length
            : i + countPerPage,
      );

      pdfDoc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: _buildBarcodeGrid(chunk, cols, barcodeWidth, barcodeHeight, textStyle),
            );
          },
        ),
      );
    }

    return pdfDoc;
  }

  pw.Widget _buildBarcodeGrid(
    List<Product> products,
    int cols,
    double barcodeWidth,
    double barcodeHeight,
    pw.TextStyle textStyle,
  ) {
    final rows = (products.length / cols).ceil();

    return pw.Table(
      children: List.generate(rows, (row) {
        return pw.TableRow(
          children: List.generate(cols, (col) {
            final index = row * cols + col;
            if (index >= products.length) {
              return pw.SizedBox();
            }
            final product = products[index];
            return pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  children: [
                    pw.SizedBox(
                      width: barcodeWidth,
                      height: barcodeHeight,
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.code128(),
                        data: product.barcode,
                        width: barcodeWidth,
                        height: barcodeHeight,
                        drawText: false,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      product.name,
                      style: textStyle,
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      '${product.price}円',
                      style: textStyle,
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  int _getColumns(BarcodePrintSize size) {
    switch (size) {
      case BarcodePrintSize.small:
        return 6;
      case BarcodePrintSize.medium:
        return 6;
      case BarcodePrintSize.large:
        return 4;
    }
  }

  double _getBarcodeWidth() {
    switch (_selectedSize) {
      case BarcodePrintSize.small:
        return 100;
      case BarcodePrintSize.medium:
        return 140;
      case BarcodePrintSize.large:
        return 200;
    }
  }

  double _getBarcodeHeight() {
    switch (_selectedSize) {
      case BarcodePrintSize.small:
        return 30;
      case BarcodePrintSize.medium:
        return 40;
      case BarcodePrintSize.large:
        return 50;
    }
  }
}