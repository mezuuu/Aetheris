/// Comprehensive list of 195 languages for the translation feature.
///
/// Each entry includes an ISO 639-1 (or 639-3 where necessary) code,
/// English name, native name, and a representative flag emoji.
/// Provides search by name/code and quick lookup by ISO code.
library;

/// Represents a language with its code, name, native name, and flag.
class AppLanguage {
  /// Creates an [AppLanguage].
  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  /// ISO 639-1 language code (e.g. `'en'`, `'id'`, `'ko'`).
  final String code;

  /// English language name (e.g. `'English'`).
  final String name;

  /// Native language name (e.g. `'한국어'`).
  final String nativeName;

  /// Representative flag emoji (e.g. `'🇺🇸'`).
  final String flag;

  @override
  String toString() => 'AppLanguage($code, $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLanguage && code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// Full list of 195 languages with search and lookup support.
class LanguageList {
  LanguageList._();

  /// Popular language codes shown at the top of picker UIs.
  static const List<String> popularCodes = [
    'en', 'id', 'ko', 'ja', 'zh', 'es', 'fr', 'de', 'pt', 'ar',
    'hi', 'ru', 'th', 'vi', 'tr',
  ];

  /// Returns popular languages in the order defined by [popularCodes].
  static List<AppLanguage> get popular {
    return popularCodes
        .map((code) => getByCode(code))
        .whereType<AppLanguage>()
        .toList(growable: false);
  }

  /// Search languages by name, native name, or code.
  ///
  /// Returns all languages where the query matches the start of the
  /// code, name, or native name (case-insensitive).
  static List<AppLanguage> search(String query) {
    if (query.trim().isEmpty) return List.unmodifiable(all);

    final q = query.trim().toLowerCase();
    return all.where((lang) {
      return lang.code.toLowerCase().startsWith(q) ||
          lang.name.toLowerCase().contains(q) ||
          lang.nativeName.toLowerCase().contains(q);
    }).toList(growable: false);
  }

  /// Get a language by its ISO code, or `null` if not found.
  static AppLanguage? getByCode(String code) {
    final lc = code.toLowerCase();
    for (final lang in all) {
      if (lang.code.toLowerCase() == lc) return lang;
    }
    return null;
  }

  /// Complete list of 195 languages.
  static const List<AppLanguage> all = [
    // ── Major World Languages ──────────────────────────────────────
    AppLanguage(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
    AppLanguage(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    AppLanguage(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    AppLanguage(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
    AppLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇧🇷'),
    AppLanguage(code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹'),
    AppLanguage(code: 'nl', name: 'Dutch', nativeName: 'Nederlands', flag: '🇳🇱'),
    AppLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺'),
    AppLanguage(code: 'pl', name: 'Polish', nativeName: 'Polski', flag: '🇵🇱'),
    AppLanguage(code: 'uk', name: 'Ukrainian', nativeName: 'Українська', flag: '🇺🇦'),

    // ── East Asian Languages ───────────────────────────────────────
    AppLanguage(code: 'zh', name: 'Chinese (Simplified)', nativeName: '简体中文', flag: '🇨🇳'),
    AppLanguage(code: 'zt', name: 'Chinese (Traditional)', nativeName: '繁體中文', flag: '🇹🇼'),
    AppLanguage(code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵'),
    AppLanguage(code: 'ko', name: 'Korean', nativeName: '한국어', flag: '🇰🇷'),

    // ── Southeast Asian Languages ──────────────────────────────────
    AppLanguage(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia', flag: '🇮🇩'),
    AppLanguage(code: 'ms', name: 'Malay', nativeName: 'Bahasa Melayu', flag: '🇲🇾'),
    AppLanguage(code: 'th', name: 'Thai', nativeName: 'ไทย', flag: '🇹🇭'),
    AppLanguage(code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt', flag: '🇻🇳'),
    AppLanguage(code: 'tl', name: 'Filipino', nativeName: 'Filipino', flag: '🇵🇭'),
    AppLanguage(code: 'my', name: 'Burmese', nativeName: 'ဗမာစာ', flag: '🇲🇲'),
    AppLanguage(code: 'km', name: 'Khmer', nativeName: 'ខ្មែរ', flag: '🇰🇭'),
    AppLanguage(code: 'lo', name: 'Lao', nativeName: 'ລາວ', flag: '🇱🇦'),
    AppLanguage(code: 'jv', name: 'Javanese', nativeName: 'Basa Jawa', flag: '🇮🇩'),
    AppLanguage(code: 'su', name: 'Sundanese', nativeName: 'Basa Sunda', flag: '🇮🇩'),
    AppLanguage(code: 'ceb', name: 'Cebuano', nativeName: 'Cebuano', flag: '🇵🇭'),

    // ── South Asian Languages ──────────────────────────────────────
    AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
    AppLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', flag: '🇧🇩'),
    AppLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', flag: '🇮🇳'),
    AppLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు', flag: '🇮🇳'),
    AppLanguage(code: 'mr', name: 'Marathi', nativeName: 'मराठी', flag: '🇮🇳'),
    AppLanguage(code: 'ur', name: 'Urdu', nativeName: 'اردو', flag: '🇵🇰'),
    AppLanguage(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી', flag: '🇮🇳'),
    AppLanguage(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ', flag: '🇮🇳'),
    AppLanguage(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം', flag: '🇮🇳'),
    AppLanguage(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ', flag: '🇮🇳'),
    AppLanguage(code: 'or', name: 'Odia', nativeName: 'ଓଡ଼ିଆ', flag: '🇮🇳'),
    AppLanguage(code: 'si', name: 'Sinhala', nativeName: 'සිංහල', flag: '🇱🇰'),
    AppLanguage(code: 'ne', name: 'Nepali', nativeName: 'नेपाली', flag: '🇳🇵'),
    AppLanguage(code: 'as', name: 'Assamese', nativeName: 'অসমীয়া', flag: '🇮🇳'),
    AppLanguage(code: 'sd', name: 'Sindhi', nativeName: 'سنڌي', flag: '🇵🇰'),
    AppLanguage(code: 'sa', name: 'Sanskrit', nativeName: 'संस्कृतम्', flag: '🇮🇳'),
    AppLanguage(code: 'dv', name: 'Dhivehi', nativeName: 'ދިވެހި', flag: '🇲🇻'),

    // ── Middle Eastern & Central Asian Languages ───────────────────
    AppLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦'),
    AppLanguage(code: 'tr', name: 'Turkish', nativeName: 'Türkçe', flag: '🇹🇷'),
    AppLanguage(code: 'fa', name: 'Persian', nativeName: 'فارسی', flag: '🇮🇷'),
    AppLanguage(code: 'he', name: 'Hebrew', nativeName: 'עברית', flag: '🇮🇱'),
    AppLanguage(code: 'ku', name: 'Kurdish', nativeName: 'Kurdî', flag: '🇮🇶'),
    AppLanguage(code: 'ps', name: 'Pashto', nativeName: 'پښتو', flag: '🇦🇫'),
    AppLanguage(code: 'uz', name: 'Uzbek', nativeName: 'Oʻzbek', flag: '🇺🇿'),
    AppLanguage(code: 'kk', name: 'Kazakh', nativeName: 'Қазақ', flag: '🇰🇿'),
    AppLanguage(code: 'ky', name: 'Kyrgyz', nativeName: 'Кыргызча', flag: '🇰🇬'),
    AppLanguage(code: 'tg', name: 'Tajik', nativeName: 'Тоҷикӣ', flag: '🇹🇯'),
    AppLanguage(code: 'tk', name: 'Turkmen', nativeName: 'Türkmen', flag: '🇹🇲'),
    AppLanguage(code: 'az', name: 'Azerbaijani', nativeName: 'Azərbaycan', flag: '🇦🇿'),
    AppLanguage(code: 'hy', name: 'Armenian', nativeName: 'Հայերեն', flag: '🇦🇲'),
    AppLanguage(code: 'ka', name: 'Georgian', nativeName: 'ქართული', flag: '🇬🇪'),

    // ── Northern European Languages ────────────────────────────────
    AppLanguage(code: 'sv', name: 'Swedish', nativeName: 'Svenska', flag: '🇸🇪'),
    AppLanguage(code: 'no', name: 'Norwegian', nativeName: 'Norsk', flag: '🇳🇴'),
    AppLanguage(code: 'da', name: 'Danish', nativeName: 'Dansk', flag: '🇩🇰'),
    AppLanguage(code: 'fi', name: 'Finnish', nativeName: 'Suomi', flag: '🇫🇮'),
    AppLanguage(code: 'is', name: 'Icelandic', nativeName: 'Íslenska', flag: '🇮🇸'),
    AppLanguage(code: 'et', name: 'Estonian', nativeName: 'Eesti', flag: '🇪🇪'),
    AppLanguage(code: 'lv', name: 'Latvian', nativeName: 'Latviešu', flag: '🇱🇻'),
    AppLanguage(code: 'lt', name: 'Lithuanian', nativeName: 'Lietuvių', flag: '🇱🇹'),

    // ── Central & Eastern European Languages ───────────────────────
    AppLanguage(code: 'cs', name: 'Czech', nativeName: 'Čeština', flag: '🇨🇿'),
    AppLanguage(code: 'sk', name: 'Slovak', nativeName: 'Slovenčina', flag: '🇸🇰'),
    AppLanguage(code: 'hu', name: 'Hungarian', nativeName: 'Magyar', flag: '🇭🇺'),
    AppLanguage(code: 'ro', name: 'Romanian', nativeName: 'Română', flag: '🇷🇴'),
    AppLanguage(code: 'bg', name: 'Bulgarian', nativeName: 'Български', flag: '🇧🇬'),
    AppLanguage(code: 'hr', name: 'Croatian', nativeName: 'Hrvatski', flag: '🇭🇷'),
    AppLanguage(code: 'sr', name: 'Serbian', nativeName: 'Српски', flag: '🇷🇸'),
    AppLanguage(code: 'sl', name: 'Slovenian', nativeName: 'Slovenščina', flag: '🇸🇮'),
    AppLanguage(code: 'bs', name: 'Bosnian', nativeName: 'Bosanski', flag: '🇧🇦'),
    AppLanguage(code: 'mk', name: 'Macedonian', nativeName: 'Македонски', flag: '🇲🇰'),
    AppLanguage(code: 'sq', name: 'Albanian', nativeName: 'Shqip', flag: '🇦🇱'),
    AppLanguage(code: 'be', name: 'Belarusian', nativeName: 'Беларуская', flag: '🇧🇾'),
    AppLanguage(code: 'mt', name: 'Maltese', nativeName: 'Malti', flag: '🇲🇹'),

    // ── Western European Languages ─────────────────────────────────
    AppLanguage(code: 'el', name: 'Greek', nativeName: 'Ελληνικά', flag: '🇬🇷'),
    AppLanguage(code: 'ca', name: 'Catalan', nativeName: 'Català', flag: '🇪🇸'),
    AppLanguage(code: 'gl', name: 'Galician', nativeName: 'Galego', flag: '🇪🇸'),
    AppLanguage(code: 'eu', name: 'Basque', nativeName: 'Euskara', flag: '🇪🇸'),
    AppLanguage(code: 'cy', name: 'Welsh', nativeName: 'Cymraeg', flag: '🏴󠁧󠁢󠁷󠁬󠁳󠁿'),
    AppLanguage(code: 'ga', name: 'Irish', nativeName: 'Gaeilge', flag: '🇮🇪'),
    AppLanguage(code: 'gd', name: 'Scottish Gaelic', nativeName: 'Gàidhlig', flag: '🏴󠁧󠁢󠁳󠁣󠁴󠁿'),
    AppLanguage(code: 'lb', name: 'Luxembourgish', nativeName: 'Lëtzebuergesch', flag: '🇱🇺'),
    AppLanguage(code: 'fy', name: 'Frisian', nativeName: 'Frysk', flag: '🇳🇱'),
    AppLanguage(code: 'br', name: 'Breton', nativeName: 'Brezhoneg', flag: '🇫🇷'),
    AppLanguage(code: 'co', name: 'Corsican', nativeName: 'Corsu', flag: '🇫🇷'),
    AppLanguage(code: 'oc', name: 'Occitan', nativeName: 'Occitan', flag: '🇫🇷'),
    AppLanguage(code: 'la', name: 'Latin', nativeName: 'Latina', flag: '🇻🇦'),
    AppLanguage(code: 'af', name: 'Afrikaans', nativeName: 'Afrikaans', flag: '🇿🇦'),

    // ── African Languages ──────────────────────────────────────────
    AppLanguage(code: 'sw', name: 'Swahili', nativeName: 'Kiswahili', flag: '🇹🇿'),
    AppLanguage(code: 'am', name: 'Amharic', nativeName: 'አማርኛ', flag: '🇪🇹'),
    AppLanguage(code: 'ha', name: 'Hausa', nativeName: 'Hausa', flag: '🇳🇬'),
    AppLanguage(code: 'yo', name: 'Yoruba', nativeName: 'Yorùbá', flag: '🇳🇬'),
    AppLanguage(code: 'ig', name: 'Igbo', nativeName: 'Igbo', flag: '🇳🇬'),
    AppLanguage(code: 'zu', name: 'Zulu', nativeName: 'isiZulu', flag: '🇿🇦'),
    AppLanguage(code: 'xh', name: 'Xhosa', nativeName: 'isiXhosa', flag: '🇿🇦'),
    AppLanguage(code: 'st', name: 'Sesotho', nativeName: 'Sesotho', flag: '🇱🇸'),
    AppLanguage(code: 'sn', name: 'Shona', nativeName: 'chiShona', flag: '🇿🇼'),
    AppLanguage(code: 'ny', name: 'Chichewa', nativeName: 'Chichewa', flag: '🇲🇼'),
    AppLanguage(code: 'so', name: 'Somali', nativeName: 'Soomaali', flag: '🇸🇴'),
    AppLanguage(code: 'mg', name: 'Malagasy', nativeName: 'Malagasy', flag: '🇲🇬'),
    AppLanguage(code: 'rw', name: 'Kinyarwanda', nativeName: 'Ikinyarwanda', flag: '🇷🇼'),
    AppLanguage(code: 'ti', name: 'Tigrinya', nativeName: 'ትግርኛ', flag: '🇪🇷'),
    AppLanguage(code: 'om', name: 'Oromo', nativeName: 'Afaan Oromoo', flag: '🇪🇹'),
    AppLanguage(code: 'wo', name: 'Wolof', nativeName: 'Wolof', flag: '🇸🇳'),
    AppLanguage(code: 'ff', name: 'Fulah', nativeName: 'Fulfulde', flag: '🇬🇳'),
    AppLanguage(code: 'ln', name: 'Lingala', nativeName: 'Lingála', flag: '🇨🇩'),
    AppLanguage(code: 'lg', name: 'Luganda', nativeName: 'Luganda', flag: '🇺🇬'),
    AppLanguage(code: 'rn', name: 'Kirundi', nativeName: 'Ikirundi', flag: '🇧🇮'),
    AppLanguage(code: 'ts', name: 'Tsonga', nativeName: 'Xitsonga', flag: '🇿🇦'),
    AppLanguage(code: 'tn', name: 'Tswana', nativeName: 'Setswana', flag: '🇧🇼'),
    AppLanguage(code: 'ss', name: 'Swati', nativeName: 'SiSwati', flag: '🇸🇿'),
    AppLanguage(code: 've', name: 'Venda', nativeName: 'Tshivenḓa', flag: '🇿🇦'),
    AppLanguage(code: 'nr', name: 'South Ndebele', nativeName: 'isiNdebele', flag: '🇿🇦'),
    AppLanguage(code: 'nd', name: 'North Ndebele', nativeName: 'isiNdebele', flag: '🇿🇼'),
    AppLanguage(code: 'ak', name: 'Akan', nativeName: 'Akan', flag: '🇬🇭'),
    AppLanguage(code: 'ee', name: 'Ewe', nativeName: 'Eʋegbe', flag: '🇬🇭'),
    AppLanguage(code: 'tw', name: 'Twi', nativeName: 'Twi', flag: '🇬🇭'),
    AppLanguage(code: 'bm', name: 'Bambara', nativeName: 'Bamanankan', flag: '🇲🇱'),
    AppLanguage(code: 'ki', name: 'Kikuyu', nativeName: 'Gĩkũyũ', flag: '🇰🇪'),
    AppLanguage(code: 'lu', name: 'Luba-Katanga', nativeName: 'Tshiluba', flag: '🇨🇩'),
    AppLanguage(code: 'sg', name: 'Sango', nativeName: 'Sängö', flag: '🇨🇫'),

    // ── Pacific & Oceanic Languages ────────────────────────────────
    AppLanguage(code: 'mi', name: 'Maori', nativeName: 'Te Reo Māori', flag: '🇳🇿'),
    AppLanguage(code: 'sm', name: 'Samoan', nativeName: 'Gagana Samoa', flag: '🇼🇸'),
    AppLanguage(code: 'haw', name: 'Hawaiian', nativeName: 'ʻŌlelo Hawaiʻi', flag: '🇺🇸'),
    AppLanguage(code: 'to', name: 'Tongan', nativeName: 'Lea Faka-Tonga', flag: '🇹🇴'),
    AppLanguage(code: 'fj', name: 'Fijian', nativeName: 'Vosa Vakaviti', flag: '🇫🇯'),
    AppLanguage(code: 'ty', name: 'Tahitian', nativeName: 'Reo Tahiti', flag: '🇵🇫'),
    AppLanguage(code: 'mh', name: 'Marshallese', nativeName: 'Kajin M̧ajeļ', flag: '🇲🇭'),
    AppLanguage(code: 'ch', name: 'Chamorro', nativeName: 'Chamoru', flag: '🇬🇺'),
    AppLanguage(code: 'bi', name: 'Bislama', nativeName: 'Bislama', flag: '🇻🇺'),
    AppLanguage(code: 'ho', name: 'Hiri Motu', nativeName: 'Hiri Motu', flag: '🇵🇬'),
    AppLanguage(code: 'na', name: 'Nauru', nativeName: 'Dorerin Naoero', flag: '🇳🇷'),

    // ── Caucasian & Uralic Languages ───────────────────────────────
    AppLanguage(code: 'mn', name: 'Mongolian', nativeName: 'Монгол', flag: '🇲🇳'),
    AppLanguage(code: 'ce', name: 'Chechen', nativeName: 'Нохчийн', flag: '🇷🇺'),
    AppLanguage(code: 'ab', name: 'Abkhazian', nativeName: 'Аԥсуа', flag: '🇬🇪'),
    AppLanguage(code: 'os', name: 'Ossetian', nativeName: 'Ирон', flag: '🇷🇺'),
    AppLanguage(code: 'av', name: 'Avaric', nativeName: 'Авар', flag: '🇷🇺'),

    // ── Constructed & Classical Languages ──────────────────────────
    AppLanguage(code: 'eo', name: 'Esperanto', nativeName: 'Esperanto', flag: '🌍'),

    // ── Additional Asian Languages ─────────────────────────────────
    AppLanguage(code: 'bo', name: 'Tibetan', nativeName: 'བོད་སྐད', flag: '🇨🇳'),
    AppLanguage(code: 'ug', name: 'Uyghur', nativeName: 'ئۇيغۇرچە', flag: '🇨🇳'),
    AppLanguage(code: 'dz', name: 'Dzongkha', nativeName: 'རྫོང་ཁ', flag: '🇧🇹'),

    // ── Native American Languages ──────────────────────────────────
    AppLanguage(code: 'gn', name: 'Guarani', nativeName: "Avañe'ẽ", flag: '🇵🇾'),
    AppLanguage(code: 'qu', name: 'Quechua', nativeName: 'Runa Simi', flag: '🇵🇪'),
    AppLanguage(code: 'ay', name: 'Aymara', nativeName: 'Aymar aru', flag: '🇧🇴'),
    AppLanguage(code: 'nv', name: 'Navajo', nativeName: 'Diné bizaad', flag: '🇺🇸'),
    AppLanguage(code: 'cr', name: 'Cree', nativeName: 'ᓀᐦᐃᔭᐍᐏᐣ', flag: '🇨🇦'),
    AppLanguage(code: 'oj', name: 'Ojibwe', nativeName: 'ᐊᓂᔑᓈᐯᒧᐎᓐ', flag: '🇨🇦'),
    AppLanguage(code: 'iu', name: 'Inuktitut', nativeName: 'ᐃᓄᒃᑎᑐᑦ', flag: '🇨🇦'),
    AppLanguage(code: 'kl', name: 'Kalaallisut', nativeName: 'Kalaallisut', flag: '🇬🇱'),

    // ── Creole & Pidgin Languages ──────────────────────────────────
    AppLanguage(code: 'ht', name: 'Haitian Creole', nativeName: 'Kreyòl Ayisyen', flag: '🇭🇹'),

    // ── Additional Slavic Languages ────────────────────────────────
    AppLanguage(code: 'hsb', name: 'Upper Sorbian', nativeName: 'Hornjoserbšćina', flag: '🇩🇪'),
    AppLanguage(code: 'dsb', name: 'Lower Sorbian', nativeName: 'Dolnoserbšćina', flag: '🇩🇪'),

    // ── Additional Romance Languages ───────────────────────────────
    AppLanguage(code: 'rm', name: 'Romansh', nativeName: 'Rumantsch', flag: '🇨🇭'),
    AppLanguage(code: 'sc', name: 'Sardinian', nativeName: 'Sardu', flag: '🇮🇹'),
    AppLanguage(code: 'an', name: 'Aragonese', nativeName: 'Aragonés', flag: '🇪🇸'),
    AppLanguage(code: 'ast', name: 'Asturian', nativeName: 'Asturianu', flag: '🇪🇸'),

    // ── Additional Germanic Languages ──────────────────────────────
    AppLanguage(code: 'fo', name: 'Faroese', nativeName: 'Føroyskt', flag: '🇫🇴'),

    // ── Turkic Languages ───────────────────────────────────────────
    AppLanguage(code: 'tt', name: 'Tatar', nativeName: 'Татарча', flag: '🇷🇺'),
    AppLanguage(code: 'ba', name: 'Bashkir', nativeName: 'Башҡортса', flag: '🇷🇺'),
    AppLanguage(code: 'cv', name: 'Chuvash', nativeName: 'Чӑвашла', flag: '🇷🇺'),

    // ── Finno-Ugric Languages ──────────────────────────────────────
    AppLanguage(code: 'se', name: 'Northern Sami', nativeName: 'Davvisámegiella', flag: '🇳🇴'),
    AppLanguage(code: 'kv', name: 'Komi', nativeName: 'Коми кыв', flag: '🇷🇺'),
    AppLanguage(code: 'udm', name: 'Udmurt', nativeName: 'Удмурт кыл', flag: '🇷🇺'),

    // ── Sino-Tibetan Languages ─────────────────────────────────────
    AppLanguage(code: 'ii', name: 'Sichuan Yi', nativeName: 'ꆈꌠ꒿', flag: '🇨🇳'),
    AppLanguage(code: 'za', name: 'Zhuang', nativeName: 'Vahcuengh', flag: '🇨🇳'),

    // ── Additional Indic Languages ─────────────────────────────────
    AppLanguage(code: 'ks', name: 'Kashmiri', nativeName: 'कॉशुर', flag: '🇮🇳'),
    AppLanguage(code: 'mai', name: 'Maithili', nativeName: 'मैथिली', flag: '🇮🇳'),
    AppLanguage(code: 'doi', name: 'Dogri', nativeName: 'डोगरी', flag: '🇮🇳'),
    AppLanguage(code: 'mni', name: 'Manipuri', nativeName: 'মৈতৈলোন্', flag: '🇮🇳'),
    AppLanguage(code: 'bho', name: 'Bhojpuri', nativeName: 'भोजपुरी', flag: '🇮🇳'),
    AppLanguage(code: 'raj', name: 'Rajasthani', nativeName: 'राजस्थानी', flag: '🇮🇳'),
    AppLanguage(code: 'kok', name: 'Konkani', nativeName: 'कोंकणी', flag: '🇮🇳'),

    // ── Dravidian Languages ────────────────────────────────────────
    AppLanguage(code: 'tcy', name: 'Tulu', nativeName: 'ತುಳು', flag: '🇮🇳'),

    // ── Iranian Languages ──────────────────────────────────────────
    AppLanguage(code: 'bal', name: 'Balochi', nativeName: 'بلوچی', flag: '🇵🇰'),

    // ── Semitic Languages ──────────────────────────────────────────
    AppLanguage(code: 'syc', name: 'Syriac', nativeName: 'ܣܘܪܝܝܐ', flag: '🇮🇶'),

    // ── Additional African Languages ───────────────────────────────
    AppLanguage(code: 'ber', name: 'Berber', nativeName: 'ⵜⴰⵎⴰⵣⵉⵖⵜ', flag: '🇲🇦'),
    AppLanguage(code: 'kr', name: 'Kanuri', nativeName: 'Kanuri', flag: '🇳🇬'),
    AppLanguage(code: 'fy', name: 'Western Frisian', nativeName: 'Frysk', flag: '🇳🇱'),
    AppLanguage(code: 'gv', name: 'Manx', nativeName: 'Gaelg', flag: '🇮🇲'),
    AppLanguage(code: 'kw', name: 'Cornish', nativeName: 'Kernewek', flag: '🇬🇧'),
    AppLanguage(code: 'ik', name: 'Inupiaq', nativeName: 'Iñupiaq', flag: '🇺🇸'),
    AppLanguage(code: 'ng', name: 'Ndonga', nativeName: 'Owambo', flag: '🇳🇦'),
    AppLanguage(code: 'hz', name: 'Herero', nativeName: 'Otjiherero', flag: '🇳🇦'),
    AppLanguage(code: 'mus', name: 'Creek', nativeName: 'Mvskoke', flag: '🇺🇸'),
    AppLanguage(code: 'chr', name: 'Cherokee', nativeName: 'ᏣᎳᎩ', flag: '🇺🇸'),
    AppLanguage(code: 'pi', name: 'Pali', nativeName: 'पालि', flag: '🇮🇳'),

    // ── Tai & Austroasiatic Languages ──────────────────────────────
    AppLanguage(code: 'hmn', name: 'Hmong', nativeName: 'Hmoob', flag: '🇱🇦'),

    // ── Additional Austronesian Languages ──────────────────────────
    AppLanguage(code: 'mg', name: 'Malagasy', nativeName: 'Malagasy', flag: '🇲🇬'),
    AppLanguage(code: 'war', name: 'Waray', nativeName: 'Winaray', flag: '🇵🇭'),
    AppLanguage(code: 'ilo', name: 'Ilocano', nativeName: 'Ilokano', flag: '🇵🇭'),
    AppLanguage(code: 'pag', name: 'Pangasinan', nativeName: 'Pangasinan', flag: '🇵🇭'),
    AppLanguage(code: 'min', name: 'Minangkabau', nativeName: 'Baso Minangkabau', flag: '🇮🇩'),
    AppLanguage(code: 'ban', name: 'Balinese', nativeName: 'Basa Bali', flag: '🇮🇩'),
    AppLanguage(code: 'ace', name: 'Acehnese', nativeName: 'Basa Acèh', flag: '🇮🇩'),
    AppLanguage(code: 'bug', name: 'Buginese', nativeName: 'Basa Ugi', flag: '🇮🇩'),
    AppLanguage(code: 'mad', name: 'Madurese', nativeName: 'Basa Madura', flag: '🇮🇩'),
    AppLanguage(code: 'bjn', name: 'Banjar', nativeName: 'Basa Banjar', flag: '🇮🇩'),

    // ── Miscellaneous ──────────────────────────────────────────────
    AppLanguage(code: 'vo', name: 'Volapük', nativeName: 'Volapük', flag: '🌍'),
    AppLanguage(code: 'ia', name: 'Interlingua', nativeName: 'Interlingua', flag: '🌍'),
    AppLanguage(code: 'ie', name: 'Interlingue', nativeName: 'Interlingue', flag: '🌍'),
    AppLanguage(code: 'io', name: 'Ido', nativeName: 'Ido', flag: '🌍'),
    AppLanguage(code: 'jbo', name: 'Lojban', nativeName: 'Lojban', flag: '🌍'),
    AppLanguage(code: 'tok', name: 'Toki Pona', nativeName: 'Toki Pona', flag: '🌍'),
    AppLanguage(code: 'yi', name: 'Yiddish', nativeName: 'ייִדיש', flag: '🇮🇱'),
    AppLanguage(code: 'cu', name: 'Church Slavonic', nativeName: 'Словѣньскъ', flag: '🇧🇬'),
    AppLanguage(code: 'ang', name: 'Old English', nativeName: 'Englisc', flag: '🇬🇧'),
    AppLanguage(code: 'got', name: 'Gothic', nativeName: '𐌲𐌿𐍄𐌹𐍃𐌺', flag: '🇪🇺'),
  ];
}
