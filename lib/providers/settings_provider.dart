import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool isHiraganaOnly;
  final bool isRandomSound;
  final int displaySeconds;

  SettingsState({
    required this.isHiraganaOnly,
    required this.isRandomSound,
    required this.displaySeconds,
  });

  SettingsState copyWith({
    bool? isHiraganaOnly,
    bool? isRandomSound,
    int? displaySeconds,
  }) {
    return SettingsState(
      isHiraganaOnly: isHiraganaOnly ?? this.isHiraganaOnly,
      isRandomSound: isRandomSound ?? this.isRandomSound,
      displaySeconds: displaySeconds ?? this.displaySeconds,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(SettingsState(
          isHiraganaOnly: false,
          isRandomSound: false,
          displaySeconds: 3,
        )) {
    _loadSettings();
  }

  static const _hiraganaKey = 'settings_hiragana';
  static const _randomSoundKey = 'settings_random_sound';
  static const _displaySecondsKey = 'settings_display_seconds';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      isHiraganaOnly: prefs.getBool(_hiraganaKey) ?? false,
      isRandomSound: prefs.getBool(_randomSoundKey) ?? false,
      displaySeconds: prefs.getInt(_displaySecondsKey) ?? 3,
    );
  }

  Future<void> setHiraganaOnly(bool value) async {
    state = state.copyWith(isHiraganaOnly: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hiraganaKey, value);
  }

  Future<void> setRandomSound(bool value) async {
    state = state.copyWith(isRandomSound: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_randomSoundKey, value);
  }

  Future<void> setDisplaySeconds(int value) async {
    state = state.copyWith(displaySeconds: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_displaySecondsKey, value);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

extension HiraganaLocalizer on String {
  String toHiragana(bool isHiraganaOnly) {
    if (!isHiraganaOnly) return this;
    switch (this) {
      case 'おままごとレジ':
        return 'おままごとれじ';
      case '商品一覧':
        return 'しょうひんいちらん';
      case '商品を検索':
        return 'しょうひんをさがす';
      case '検索':
        return 'さがす';
      case '編集':
        return 'へんしゅう';
      case '削除':
        return 'さくじょ';
      case '商品追加':
        return 'しょうひんついか';
      case '印刷へ進む':
        return 'いんさつへすすむ';
      case 'スキャン開始':
        return 'すきゃんかいし';
      case '設定':
        return 'せってい';
      case '商品管理':
        return 'しょうひんかんり';
      case '商品登録':
        return 'しょうひんとうろく';
      case '商品編集':
        return 'しょうひんへんしゅう';
      case '商品名':
        return 'しょうひんめい';
      case '価格':
        return 'かかく';
      case '円':
        return 'えん';
      case '保存':
        return 'ほぞん';
      case 'キャンセル':
        return 'きゃんせる';
      case 'バーコード印刷':
        return 'ばーこーどいんさつ';
      case '選択した商品を削除しますか？':
        return 'せんたくしたしょうひんをさくじょしますか？';
      case '確認':
        return 'かくにん';
      case 'はい':
        return 'はい';
      case 'いいえ':
        return 'いいえ';
      default:
        return this;
    }
  }
}
