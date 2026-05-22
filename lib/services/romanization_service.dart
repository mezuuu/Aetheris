import '../models/lrc_line.dart';

class RomanizationService {
  Future<List<LrcLine>> romanizeLrcLines(List<LrcLine> lines) async {
    return lines
        .map((line) {
          final romanized = romanizeText(line.text);
          return romanized == null ? line : line.copyWith(romanization: romanized);
        })
        .toList(growable: false);
  }

  String? romanizeText(String text) {
    final buffer = StringBuffer();
    var changed = false;

    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      final romanizedHangul = _romanizeHangulSyllable(rune);
      if (romanizedHangul != null) {
        _writeRomanized(buffer, romanizedHangul);
        changed = true;
        continue;
      }

      final romanizedKana = _kanaMap[char];
      if (romanizedKana != null) {
        _writeRomanized(buffer, romanizedKana);
        changed = true;
        continue;
      }

      buffer.write(char);
    }

    final result = buffer
        .toString()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAllMapped(RegExp(r'\s+([,.!?;:])'), (match) => match.group(1)!)
        .trim();
    if (!changed || result.isEmpty || result == text.trim()) {
      return null;
    }
    return result;
  }

  static void _writeRomanized(StringBuffer buffer, String value) {
    if (buffer.isNotEmpty && !_endsWithWhitespaceOrPunctuation(buffer.toString())) {
      buffer.write(' ');
    }
    buffer.write(value);
  }

  static bool _endsWithWhitespaceOrPunctuation(String value) {
    if (value.isEmpty) return true;
    final last = value[value.length - 1];
    return RegExp(r'[\s\-,.!?;:/()[\]{}]').hasMatch(last);
  }

  static String? _romanizeHangulSyllable(int codeUnit) {
    const base = 0xAC00;
    const last = 0xD7A3;
    if (codeUnit < base || codeUnit > last) {
      return null;
    }

    final index = codeUnit - base;
    final initial = index ~/ 588;
    final medial = (index % 588) ~/ 28;
    final finalIndex = index % 28;
    return '${_hangulInitials[initial]}${_hangulMedials[medial]}${_hangulFinals[finalIndex]}';
  }

  static const _hangulInitials = [
    'g',
    'kk',
    'n',
    'd',
    'tt',
    'r',
    'm',
    'b',
    'pp',
    's',
    'ss',
    '',
    'j',
    'jj',
    'ch',
    'k',
    't',
    'p',
    'h',
  ];

  static const _hangulMedials = [
    'a',
    'ae',
    'ya',
    'yae',
    'eo',
    'e',
    'yeo',
    'ye',
    'o',
    'wa',
    'wae',
    'oe',
    'yo',
    'u',
    'wo',
    'we',
    'wi',
    'yu',
    'eu',
    'ui',
    'i',
  ];

  static const _hangulFinals = [
    '',
    'k',
    'k',
    'ks',
    'n',
    'nj',
    'nh',
    't',
    'l',
    'lk',
    'lm',
    'lb',
    'ls',
    'lt',
    'lp',
    'lh',
    'm',
    'p',
    'ps',
    't',
    't',
    'ng',
    't',
    't',
    'k',
    't',
    'p',
    'h',
  ];

  static const Map<String, String> _kanaMap = {
    'あ': 'a',
    'い': 'i',
    'う': 'u',
    'え': 'e',
    'お': 'o',
    'か': 'ka',
    'き': 'ki',
    'く': 'ku',
    'け': 'ke',
    'こ': 'ko',
    'さ': 'sa',
    'し': 'shi',
    'す': 'su',
    'せ': 'se',
    'そ': 'so',
    'た': 'ta',
    'ち': 'chi',
    'つ': 'tsu',
    'て': 'te',
    'と': 'to',
    'な': 'na',
    'に': 'ni',
    'ぬ': 'nu',
    'ね': 'ne',
    'の': 'no',
    'は': 'ha',
    'ひ': 'hi',
    'ふ': 'fu',
    'へ': 'he',
    'ほ': 'ho',
    'ま': 'ma',
    'み': 'mi',
    'む': 'mu',
    'め': 'me',
    'も': 'mo',
    'や': 'ya',
    'ゆ': 'yu',
    'よ': 'yo',
    'ら': 'ra',
    'り': 'ri',
    'る': 'ru',
    'れ': 're',
    'ろ': 'ro',
    'わ': 'wa',
    'を': 'wo',
    'ん': 'n',
    'ア': 'a',
    'イ': 'i',
    'ウ': 'u',
    'エ': 'e',
    'オ': 'o',
    'カ': 'ka',
    'キ': 'ki',
    'ク': 'ku',
    'ケ': 'ke',
    'コ': 'ko',
    'サ': 'sa',
    'シ': 'shi',
    'ス': 'su',
    'セ': 'se',
    'ソ': 'so',
    'タ': 'ta',
    'チ': 'chi',
    'ツ': 'tsu',
    'テ': 'te',
    'ト': 'to',
    'ナ': 'na',
    'ニ': 'ni',
    'ヌ': 'nu',
    'ネ': 'ne',
    'ノ': 'no',
    'ハ': 'ha',
    'ヒ': 'hi',
    'フ': 'fu',
    'ヘ': 'he',
    'ホ': 'ho',
    'マ': 'ma',
    'ミ': 'mi',
    'ム': 'mu',
    'メ': 'me',
    'モ': 'mo',
    'ヤ': 'ya',
    'ユ': 'yu',
    'ヨ': 'yo',
    'ラ': 'ra',
    'リ': 'ri',
    'ル': 'ru',
    'レ': 're',
    'ロ': 'ro',
    'ワ': 'wa',
    'ヲ': 'wo',
    'ン': 'n',
  };
}
