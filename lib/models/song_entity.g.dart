// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSongEntityCollection on Isar {
  IsarCollection<SongEntity> get songEntitys => this.collection();
}

const SongEntitySchema = CollectionSchema(
  name: r'SongEntity',
  id: -4322515446108572550,
  properties: {
    r'addedAt': PropertySchema(
      id: 0,
      name: r'addedAt',
      type: IsarType.dateTime,
    ),
    r'album': PropertySchema(
      id: 1,
      name: r'album',
      type: IsarType.string,
    ),
    r'artist': PropertySchema(
      id: 2,
      name: r'artist',
      type: IsarType.string,
    ),
    r'bitrate': PropertySchema(
      id: 3,
      name: r'bitrate',
      type: IsarType.long,
    ),
    r'codec': PropertySchema(
      id: 4,
      name: r'codec',
      type: IsarType.string,
    ),
    r'duration': PropertySchema(
      id: 5,
      name: r'duration',
      type: IsarType.long,
    ),
    r'filePath': PropertySchema(
      id: 6,
      name: r'filePath',
      type: IsarType.string,
    ),
    r'isBitPerfect': PropertySchema(
      id: 7,
      name: r'isBitPerfect',
      type: IsarType.bool,
    ),
    r'isLocalFile': PropertySchema(
      id: 8,
      name: r'isLocalFile',
      type: IsarType.bool,
    ),
    r'lastPlayedAt': PropertySchema(
      id: 9,
      name: r'lastPlayedAt',
      type: IsarType.dateTime,
    ),
    r'playCount': PropertySchema(
      id: 10,
      name: r'playCount',
      type: IsarType.long,
    ),
    r'sampleRate': PropertySchema(
      id: 11,
      name: r'sampleRate',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 12,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _songEntityEstimateSize,
  serialize: _songEntitySerialize,
  deserialize: _songEntityDeserialize,
  deserializeProp: _songEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _songEntityGetId,
  getLinks: _songEntityGetLinks,
  attach: _songEntityAttach,
  version: '3.1.0+1',
);

int _songEntityEstimateSize(
  SongEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.album.length * 3;
  bytesCount += 3 + object.artist.length * 3;
  {
    final value = object.codec;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.filePath.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _songEntitySerialize(
  SongEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.addedAt);
  writer.writeString(offsets[1], object.album);
  writer.writeString(offsets[2], object.artist);
  writer.writeLong(offsets[3], object.bitrate);
  writer.writeString(offsets[4], object.codec);
  writer.writeLong(offsets[5], object.duration);
  writer.writeString(offsets[6], object.filePath);
  writer.writeBool(offsets[7], object.isBitPerfect);
  writer.writeBool(offsets[8], object.isLocalFile);
  writer.writeDateTime(offsets[9], object.lastPlayedAt);
  writer.writeLong(offsets[10], object.playCount);
  writer.writeLong(offsets[11], object.sampleRate);
  writer.writeString(offsets[12], object.title);
}

SongEntity _songEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SongEntity(
    addedAt: reader.readDateTimeOrNull(offsets[0]),
    album: reader.readString(offsets[1]),
    artist: reader.readString(offsets[2]),
    bitrate: reader.readLongOrNull(offsets[3]),
    codec: reader.readStringOrNull(offsets[4]),
    duration: reader.readLongOrNull(offsets[5]),
    filePath: reader.readString(offsets[6]),
    id: id,
    isBitPerfect: reader.readBoolOrNull(offsets[7]) ?? false,
    isLocalFile: reader.readBoolOrNull(offsets[8]) ?? true,
    lastPlayedAt: reader.readDateTimeOrNull(offsets[9]),
    playCount: reader.readLongOrNull(offsets[10]) ?? 0,
    sampleRate: reader.readLongOrNull(offsets[11]),
    title: reader.readString(offsets[12]),
  );
  return object;
}

P _songEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 8:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _songEntityGetId(SongEntity object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _songEntityGetLinks(SongEntity object) {
  return [];
}

void _songEntityAttach(IsarCollection<dynamic> col, Id id, SongEntity object) {
  object.id = id;
}

extension SongEntityQueryWhereSort
    on QueryBuilder<SongEntity, SongEntity, QWhere> {
  QueryBuilder<SongEntity, SongEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SongEntityQueryWhere
    on QueryBuilder<SongEntity, SongEntity, QWhereClause> {
  QueryBuilder<SongEntity, SongEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<SongEntity, SongEntity, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterWhereClause> idBetween(
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

extension SongEntityQueryFilter
    on QueryBuilder<SongEntity, SongEntity, QFilterCondition> {
  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> addedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'addedAt',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      addedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'addedAt',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> addedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      addedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> addedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> addedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'addedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> albumEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> albumGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> albumLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> albumBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'album',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> albumStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> albumEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> albumContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> albumMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'album',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> albumIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'album',
        value: '',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      albumIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'album',
        value: '',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> artistEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> artistGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> artistLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> artistBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artist',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> artistStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> artistEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> artistContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> artistMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artist',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> artistIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      artistIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> bitrateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bitrate',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      bitrateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bitrate',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> bitrateEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bitrate',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      bitrateGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bitrate',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> bitrateLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bitrate',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> bitrateBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bitrate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> codecIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'codec',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> codecIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'codec',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> codecEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codec',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> codecGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codec',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> codecLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codec',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> codecBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codec',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> codecStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codec',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> codecEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codec',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> codecContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codec',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> codecMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codec',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> codecIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codec',
        value: '',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      codecIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codec',
        value: '',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> durationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      durationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> durationEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      durationGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> durationLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> durationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'duration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> filePathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      filePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> filePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> filePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      filePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> filePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> filePathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> filePathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'filePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      filePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      filePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> idEqualTo(
      Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      isBitPerfectEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isBitPerfect',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      isLocalFileEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isLocalFile',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      lastPlayedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPlayedAt',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      lastPlayedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPlayedAt',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      lastPlayedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPlayedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      lastPlayedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPlayedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      lastPlayedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPlayedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      lastPlayedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPlayedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> playCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      playCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> playCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> playCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      sampleRateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sampleRate',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      sampleRateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sampleRate',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> sampleRateEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sampleRate',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      sampleRateGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sampleRate',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      sampleRateLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sampleRate',
        value: value,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> sampleRateBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sampleRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension SongEntityQueryObject
    on QueryBuilder<SongEntity, SongEntity, QFilterCondition> {}

extension SongEntityQueryLinks
    on QueryBuilder<SongEntity, SongEntity, QFilterCondition> {}

extension SongEntityQuerySortBy
    on QueryBuilder<SongEntity, SongEntity, QSortBy> {
  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByBitrate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bitrate', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByBitrateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bitrate', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByCodec() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codec', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByCodecDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codec', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByIsBitPerfect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBitPerfect', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByIsBitPerfectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBitPerfect', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByIsLocalFile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalFile', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByIsLocalFileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalFile', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByLastPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByPlayCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortBySampleRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleRate', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortBySampleRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleRate', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension SongEntityQuerySortThenBy
    on QueryBuilder<SongEntity, SongEntity, QSortThenBy> {
  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByBitrate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bitrate', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByBitrateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bitrate', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByCodec() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codec', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByCodecDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codec', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByIsBitPerfect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBitPerfect', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByIsBitPerfectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBitPerfect', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByIsLocalFile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalFile', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByIsLocalFileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalFile', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByLastPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByPlayCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenBySampleRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleRate', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenBySampleRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleRate', Sort.desc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension SongEntityQueryWhereDistinct
    on QueryBuilder<SongEntity, SongEntity, QDistinct> {
  QueryBuilder<SongEntity, SongEntity, QDistinct> distinctByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addedAt');
    });
  }

  QueryBuilder<SongEntity, SongEntity, QDistinct> distinctByAlbum(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'album', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QDistinct> distinctByArtist(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artist', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QDistinct> distinctByBitrate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bitrate');
    });
  }

  QueryBuilder<SongEntity, SongEntity, QDistinct> distinctByCodec(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codec', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QDistinct> distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<SongEntity, SongEntity, QDistinct> distinctByFilePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SongEntity, SongEntity, QDistinct> distinctByIsBitPerfect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBitPerfect');
    });
  }

  QueryBuilder<SongEntity, SongEntity, QDistinct> distinctByIsLocalFile() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLocalFile');
    });
  }

  QueryBuilder<SongEntity, SongEntity, QDistinct> distinctByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayedAt');
    });
  }

  QueryBuilder<SongEntity, SongEntity, QDistinct> distinctByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playCount');
    });
  }

  QueryBuilder<SongEntity, SongEntity, QDistinct> distinctBySampleRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sampleRate');
    });
  }

  QueryBuilder<SongEntity, SongEntity, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension SongEntityQueryProperty
    on QueryBuilder<SongEntity, SongEntity, QQueryProperty> {
  QueryBuilder<SongEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SongEntity, DateTime?, QQueryOperations> addedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addedAt');
    });
  }

  QueryBuilder<SongEntity, String, QQueryOperations> albumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'album');
    });
  }

  QueryBuilder<SongEntity, String, QQueryOperations> artistProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artist');
    });
  }

  QueryBuilder<SongEntity, int?, QQueryOperations> bitrateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bitrate');
    });
  }

  QueryBuilder<SongEntity, String?, QQueryOperations> codecProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codec');
    });
  }

  QueryBuilder<SongEntity, int?, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<SongEntity, String, QQueryOperations> filePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filePath');
    });
  }

  QueryBuilder<SongEntity, bool, QQueryOperations> isBitPerfectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBitPerfect');
    });
  }

  QueryBuilder<SongEntity, bool, QQueryOperations> isLocalFileProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLocalFile');
    });
  }

  QueryBuilder<SongEntity, DateTime?, QQueryOperations> lastPlayedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayedAt');
    });
  }

  QueryBuilder<SongEntity, int, QQueryOperations> playCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playCount');
    });
  }

  QueryBuilder<SongEntity, int?, QQueryOperations> sampleRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sampleRate');
    });
  }

  QueryBuilder<SongEntity, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
