// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingsEntityCollection on Isar {
  IsarCollection<AppSettingsEntity> get appSettingsEntitys => this.collection();
}

const AppSettingsEntitySchema = CollectionSchema(
  name: r'AppSettingsEntity',
  id: 5506238605616873742,
  properties: {
    r'accentColor': PropertySchema(
      id: 0,
      name: r'accentColor',
      type: IsarType.long,
    ),
    r'autoPlayEnabled': PropertySchema(
      id: 1,
      name: r'autoPlayEnabled',
      type: IsarType.bool,
    ),
    r'cloudSyncEnabled': PropertySchema(
      id: 2,
      name: r'cloudSyncEnabled',
      type: IsarType.bool,
    ),
    r'crossfadeDuration': PropertySchema(
      id: 3,
      name: r'crossfadeDuration',
      type: IsarType.long,
    ),
    r'downloadQuality': PropertySchema(
      id: 4,
      name: r'downloadQuality',
      type: IsarType.string,
    ),
    r'equalizerPreset': PropertySchema(
      id: 5,
      name: r'equalizerPreset',
      type: IsarType.string,
    ),
    r'lastLibraryScanAt': PropertySchema(
      id: 6,
      name: r'lastLibraryScanAt',
      type: IsarType.dateTime,
    ),
    r'loopMode': PropertySchema(
      id: 7,
      name: r'loopMode',
      type: IsarType.string,
    ),
    r'preferredLanguage': PropertySchema(
      id: 8,
      name: r'preferredLanguage',
      type: IsarType.string,
    ),
    r'shuffleEnabled': PropertySchema(
      id: 9,
      name: r'shuffleEnabled',
      type: IsarType.bool,
    ),
    r'sleepTimerMinutes': PropertySchema(
      id: 10,
      name: r'sleepTimerMinutes',
      type: IsarType.long,
    ),
    r'theme': PropertySchema(
      id: 11,
      name: r'theme',
      type: IsarType.string,
    ),
    r'volume': PropertySchema(
      id: 12,
      name: r'volume',
      type: IsarType.double,
    )
  },
  estimateSize: _appSettingsEntityEstimateSize,
  serialize: _appSettingsEntitySerialize,
  deserialize: _appSettingsEntityDeserialize,
  deserializeProp: _appSettingsEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appSettingsEntityGetId,
  getLinks: _appSettingsEntityGetLinks,
  attach: _appSettingsEntityAttach,
  version: '3.1.0+1',
);

int _appSettingsEntityEstimateSize(
  AppSettingsEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.downloadQuality.length * 3;
  bytesCount += 3 + object.equalizerPreset.length * 3;
  bytesCount += 3 + object.loopMode.length * 3;
  bytesCount += 3 + object.preferredLanguage.length * 3;
  bytesCount += 3 + object.theme.length * 3;
  return bytesCount;
}

void _appSettingsEntitySerialize(
  AppSettingsEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.accentColor);
  writer.writeBool(offsets[1], object.autoPlayEnabled);
  writer.writeBool(offsets[2], object.cloudSyncEnabled);
  writer.writeLong(offsets[3], object.crossfadeDuration);
  writer.writeString(offsets[4], object.downloadQuality);
  writer.writeString(offsets[5], object.equalizerPreset);
  writer.writeDateTime(offsets[6], object.lastLibraryScanAt);
  writer.writeString(offsets[7], object.loopMode);
  writer.writeString(offsets[8], object.preferredLanguage);
  writer.writeBool(offsets[9], object.shuffleEnabled);
  writer.writeLong(offsets[10], object.sleepTimerMinutes);
  writer.writeString(offsets[11], object.theme);
  writer.writeDouble(offsets[12], object.volume);
}

AppSettingsEntity _appSettingsEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettingsEntity(
    accentColor: reader.readLongOrNull(offsets[0]) ?? 0xFF6C5CE7,
    autoPlayEnabled: reader.readBoolOrNull(offsets[1]) ?? true,
    cloudSyncEnabled: reader.readBoolOrNull(offsets[2]) ?? false,
    crossfadeDuration: reader.readLongOrNull(offsets[3]) ?? 0,
    downloadQuality: reader.readStringOrNull(offsets[4]) ?? 'high',
    equalizerPreset: reader.readStringOrNull(offsets[5]) ?? 'normal',
    id: id,
    lastLibraryScanAt: reader.readDateTimeOrNull(offsets[6]),
    loopMode: reader.readStringOrNull(offsets[7]) ?? 'off',
    preferredLanguage: reader.readStringOrNull(offsets[8]) ?? 'en',
    shuffleEnabled: reader.readBoolOrNull(offsets[9]) ?? false,
    sleepTimerMinutes: reader.readLongOrNull(offsets[10]),
    theme: reader.readStringOrNull(offsets[11]) ?? 'dark',
    volume: reader.readDoubleOrNull(offsets[12]) ?? 1.0,
  );
  return object;
}

P _appSettingsEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0xFF6C5CE7) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 4:
      return (reader.readStringOrNull(offset) ?? 'high') as P;
    case 5:
      return (reader.readStringOrNull(offset) ?? 'normal') as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset) ?? 'off') as P;
    case 8:
      return (reader.readStringOrNull(offset) ?? 'en') as P;
    case 9:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset) ?? 'dark') as P;
    case 12:
      return (reader.readDoubleOrNull(offset) ?? 1.0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appSettingsEntityGetId(AppSettingsEntity object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _appSettingsEntityGetLinks(
    AppSettingsEntity object) {
  return [];
}

void _appSettingsEntityAttach(
    IsarCollection<dynamic> col, Id id, AppSettingsEntity object) {
  object.id = id;
}

extension AppSettingsEntityQueryWhereSort
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QWhere> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingsEntityQueryWhere
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QWhereClause> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AppSettingsEntityQueryFilter
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QFilterCondition> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      accentColorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accentColor',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      accentColorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accentColor',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      accentColorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accentColor',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      accentColorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accentColor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      autoPlayEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoPlayEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      cloudSyncEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cloudSyncEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      crossfadeDurationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'crossfadeDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      crossfadeDurationGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'crossfadeDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      crossfadeDurationLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'crossfadeDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      crossfadeDurationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'crossfadeDuration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      downloadQualityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadQuality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      downloadQualityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'downloadQuality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      downloadQualityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'downloadQuality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      downloadQualityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'downloadQuality',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      downloadQualityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'downloadQuality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      downloadQualityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'downloadQuality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      downloadQualityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'downloadQuality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      downloadQualityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'downloadQuality',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      downloadQualityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadQuality',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      downloadQualityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'downloadQuality',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      equalizerPresetEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'equalizerPreset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      equalizerPresetGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'equalizerPreset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      equalizerPresetLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'equalizerPreset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      equalizerPresetBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'equalizerPreset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      equalizerPresetStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'equalizerPreset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      equalizerPresetEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'equalizerPreset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      equalizerPresetContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'equalizerPreset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      equalizerPresetMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'equalizerPreset',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      equalizerPresetIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'equalizerPreset',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      equalizerPresetIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'equalizerPreset',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      idGreaterThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      idLessThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      idBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      lastLibraryScanAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastLibraryScanAt',
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      lastLibraryScanAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastLibraryScanAt',
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      lastLibraryScanAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastLibraryScanAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      lastLibraryScanAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastLibraryScanAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      lastLibraryScanAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastLibraryScanAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      lastLibraryScanAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastLibraryScanAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      loopModeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loopMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      loopModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'loopMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      loopModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'loopMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      loopModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'loopMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      loopModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'loopMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      loopModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'loopMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      loopModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'loopMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      loopModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'loopMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      loopModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loopMode',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      loopModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'loopMode',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      preferredLanguageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preferredLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      preferredLanguageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'preferredLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      preferredLanguageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'preferredLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      preferredLanguageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'preferredLanguage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      preferredLanguageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'preferredLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      preferredLanguageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'preferredLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      preferredLanguageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'preferredLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      preferredLanguageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'preferredLanguage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      preferredLanguageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preferredLanguage',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      preferredLanguageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'preferredLanguage',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      shuffleEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shuffleEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      sleepTimerMinutesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sleepTimerMinutes',
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      sleepTimerMinutesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sleepTimerMinutes',
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      sleepTimerMinutesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sleepTimerMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      sleepTimerMinutesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sleepTimerMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      sleepTimerMinutesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sleepTimerMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      sleepTimerMinutesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sleepTimerMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      themeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      themeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      themeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      themeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'theme',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      themeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      themeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      themeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      themeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'theme',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      themeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'theme',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      themeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'theme',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      volumeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      volumeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      volumeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
      volumeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'volume',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension AppSettingsEntityQueryObject
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QFilterCondition> {}

extension AppSettingsEntityQueryLinks
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QFilterCondition> {}

extension AppSettingsEntityQuerySortBy
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QSortBy> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByAccentColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByAutoPlayEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByAutoPlayEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByCloudSyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudSyncEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByCloudSyncEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudSyncEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByCrossfadeDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossfadeDuration', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByCrossfadeDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossfadeDuration', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByDownloadQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadQuality', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByDownloadQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadQuality', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByEqualizerPreset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'equalizerPreset', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByEqualizerPresetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'equalizerPreset', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByLastLibraryScanAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLibraryScanAt', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByLastLibraryScanAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLibraryScanAt', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByLoopMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loopMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByLoopModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loopMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByPreferredLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredLanguage', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByPreferredLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredLanguage', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByShuffleEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffleEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByShuffleEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffleEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortBySleepTimerMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimerMinutes', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortBySleepTimerMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimerMinutes', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      sortByVolumeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.desc);
    });
  }
}

extension AppSettingsEntityQuerySortThenBy
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QSortThenBy> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByAccentColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByAutoPlayEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByAutoPlayEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoPlayEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByCloudSyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudSyncEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByCloudSyncEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudSyncEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByCrossfadeDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossfadeDuration', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByCrossfadeDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'crossfadeDuration', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByDownloadQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadQuality', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByDownloadQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadQuality', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByEqualizerPreset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'equalizerPreset', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByEqualizerPresetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'equalizerPreset', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByLastLibraryScanAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLibraryScanAt', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByLastLibraryScanAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLibraryScanAt', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByLoopMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loopMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByLoopModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loopMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByPreferredLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredLanguage', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByPreferredLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredLanguage', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByShuffleEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffleEnabled', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByShuffleEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffleEnabled', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenBySleepTimerMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimerMinutes', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenBySleepTimerMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepTimerMinutes', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
      thenByVolumeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.desc);
    });
  }
}

extension AppSettingsEntityQueryWhereDistinct
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
      distinctByAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accentColor');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
      distinctByAutoPlayEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoPlayEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
      distinctByCloudSyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudSyncEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
      distinctByCrossfadeDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'crossfadeDuration');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
      distinctByDownloadQuality({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadQuality',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
      distinctByEqualizerPreset({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'equalizerPreset',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
      distinctByLastLibraryScanAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastLibraryScanAt');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
      distinctByLoopMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loopMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
      distinctByPreferredLanguage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preferredLanguage',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
      distinctByShuffleEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shuffleEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
      distinctBySleepTimerMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepTimerMinutes');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct> distinctByTheme(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'theme', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
      distinctByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'volume');
    });
  }
}

extension AppSettingsEntityQueryProperty
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QQueryProperty> {
  QueryBuilder<AppSettingsEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppSettingsEntity, int, QQueryOperations> accentColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accentColor');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
      autoPlayEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoPlayEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
      cloudSyncEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudSyncEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, int, QQueryOperations>
      crossfadeDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'crossfadeDuration');
    });
  }

  QueryBuilder<AppSettingsEntity, String, QQueryOperations>
      downloadQualityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadQuality');
    });
  }

  QueryBuilder<AppSettingsEntity, String, QQueryOperations>
      equalizerPresetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'equalizerPreset');
    });
  }

  QueryBuilder<AppSettingsEntity, DateTime?, QQueryOperations>
      lastLibraryScanAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastLibraryScanAt');
    });
  }

  QueryBuilder<AppSettingsEntity, String, QQueryOperations> loopModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loopMode');
    });
  }

  QueryBuilder<AppSettingsEntity, String, QQueryOperations>
      preferredLanguageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preferredLanguage');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
      shuffleEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shuffleEnabled');
    });
  }

  QueryBuilder<AppSettingsEntity, int?, QQueryOperations>
      sleepTimerMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepTimerMinutes');
    });
  }

  QueryBuilder<AppSettingsEntity, String, QQueryOperations> themeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'theme');
    });
  }

  QueryBuilder<AppSettingsEntity, double, QQueryOperations> volumeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'volume');
    });
  }
}
