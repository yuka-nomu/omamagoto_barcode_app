import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omamagoto_barcode_app/providers/product_provider.dart';
import 'package:omamagoto_barcode_app/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isHiraganaOnly = settings.isHiraganaOnly;

    return Scaffold(
      appBar: AppBar(
        title: Text('設定'.toHiragana(isHiraganaOnly)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Hiragana Only Toggle
          SwitchListTile(
            title: Text('ひらがなのみ'.toHiragana(isHiraganaOnly)),
            subtitle: Text(
              isHiraganaOnly
                  ? 'ひらがなのみでひょうじします。'
                  : '画面の表示や商品登録をひらがなのみに制限します。',
            ),
            value: settings.isHiraganaOnly,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setHiraganaOnly(value);
            },
          ),
          const Divider(),

          // Random Sound Toggle
          SwitchListTile(
            title: Text('ランダム音'.toHiragana(isHiraganaOnly)),
            subtitle: Text(
              isHiraganaOnly
                  ? 'すきゃんしたときにおとをらんだむにします。'
                  : 'スキャン成功時のサウンドをランダムにします。',
            ),
            value: settings.isRandomSound,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setRandomSound(value);
            },
          ),
          const Divider(),

          // Display Seconds Adjustment
          ListTile(
            title: Text('表示時間'.toHiragana(isHiraganaOnly)),
            subtitle: Text(
              isHiraganaOnly
                  ? 'しょうひんをひょうじするじかん。'
                  : 'スキャン後に商品ポップアップを表示する秒数です。',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: settings.displaySeconds > 1
                      ? () => ref
                          .read(settingsProvider.notifier)
                          .setDisplaySeconds(settings.displaySeconds - 1)
                      : null,
                ),
                Text(
                  '${settings.displaySeconds} 秒'.toHiragana(isHiraganaOnly),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: settings.displaySeconds < 10
                      ? () => ref
                          .read(settingsProvider.notifier)
                          .setDisplaySeconds(settings.displaySeconds + 1)
                      : null,
                ),
              ],
            ),
          ),
          const Divider(),

          const SizedBox(height: 24),

          // Play Sound (Volume check)
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'ピピッ！ (レジ音再生)'.toHiragana(isHiraganaOnly),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.volume_up),
            label: Text('音量確認'.toHiragana(isHiraganaOnly)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),

          // Reset Database Button
          OutlinedButton.icon(
            onPressed: () => _confirmReset(context, ref, isHiraganaOnly),
            icon: const Icon(Icons.restore, color: Colors.red),
            label: Text(
              'データ初期化'.toHiragana(isHiraganaOnly),
              style: const TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref, bool isHiraganaOnly) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('確認'.toHiragana(isHiraganaOnly)),
          content: Text(
            'データを初期化してよろしいですか？'.toHiragana(isHiraganaOnly),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('いいえ'.toHiragana(isHiraganaOnly)),
            ),
            TextButton(
              onPressed: () {
                ref.read(productListProvider.notifier).resetToDefault();
                ref.read(selectedProductIdsProvider.notifier).clear();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'しょきかしました。'.toHiragana(isHiraganaOnly),
                    ),
                  ),
                );
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