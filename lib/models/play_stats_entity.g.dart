// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_stats_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlayStatsEntityCollection on Isar {
  IsarCollection<PlayStatsEntity> get playStatsEntitys => this.collection();
}

const PlayStatsEntitySchema = CollectionSchema(
  name: r'PlayStatsEntity',
  id: 6605003788206285053,
  properties: {
    r'duration': PropertySchema(
      id: 0,
      name: r'duration',
      type: IsarType.long,
    ),
    r'playedAt': PropertySchema(
      id: 1,
      name: r'playedAt',
      type: IsarType.dateTime,
    ),
    r'songId': PropertySchema(
      id: 2,
      name: r'songId',
      type: IsarType.string,
    )
  },
  estimateSize: _playStatsEntityEstimateSize,
  serialize: _playStatsEntitySerialize,
  deserialize: _playStatsEntityDeserialize,
  deserializeProp: _playStatsEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _playStatsEntityGetId,
  getLinks: _playStatsEntityGetLinks,
  attach: _playStatsEntityAttach,
  version: '3.1.0+1',
);

int _playStatsEntityEstimateSize(
  PlayStatsEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.songId.length * 3;
  return bytesCount;
}

void _playStatsEntitySerialize(
  PlayStatsEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.duration);
  writer.writeDateTime(offsets[1], object.playedAt);
  writer.writeString(offsets[2], object.songId);
}

PlayStatsEntity _playStatsEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlayStatsEntity(
    duration: reader.readLongOrNull(offsets[0]),
    id: id,
    playedAt: reader.readDateTime(offsets[1]),
    songId: reader.readString(offsets[2]),
  );
  return object;
}

P _playStatsEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playStatsEntityGetId(PlayStatsEntity object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _playStatsEntityGetLinks(PlayStatsEntity object) {
  return [];
}

void _playStatsEntityAttach(
    IsarCollection<dynamic> col, Id id, PlayStatsEntity object) {
  object.id = id;
}

extension PlayStatsEntityQueryWhereSort
    on QueryBuilder<PlayStatsEntity, PlayStatsEntity, QWhere> {
  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlayStatsEntityQueryWhere
    on QueryBuilder<PlayStatsEntity, PlayStatsEntity, QWhereClause> {
  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterWhereClause>
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

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterWhereClause> idBetween(
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

extension PlayStatsEntityQueryFilter
    on QueryBuilder<PlayStatsEntity, PlayStatsEntity, QFilterCondition> {
  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      durationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      durationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      durationEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
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

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      durationLessThan(
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

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      durationBetween(
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

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
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

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
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

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
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

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      playedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      playedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      playedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      playedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      songIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'songId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      songIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'songId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      songIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'songId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      songIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'songId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      songIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'songId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      songIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'songId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      songIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'songId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      songIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'songId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      songIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'songId',
        value: '',
      ));
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterFilterCondition>
      songIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'songId',
        value: '',
      ));
    });
  }
}

extension PlayStatsEntityQueryObject
    on QueryBuilder<PlayStatsEntity, PlayStatsEntity, QFilterCondition> {}

extension PlayStatsEntityQueryLinks
    on QueryBuilder<PlayStatsEntity, PlayStatsEntity, QFilterCondition> {}

extension PlayStatsEntityQuerySortBy
    on QueryBuilder<PlayStatsEntity, PlayStatsEntity, QSortBy> {
  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterSortBy>
      sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterSortBy>
      sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterSortBy>
      sortByPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playedAt', Sort.asc);
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterSortBy>
      sortByPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playedAt', Sort.desc);
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterSortBy> sortBySongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songId', Sort.asc);
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterSortBy>
      sortBySongIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songId', Sort.desc);
    });
  }
}

extension PlayStatsEntityQuerySortThenBy
    on QueryBuilder<PlayStatsEntity, PlayStatsEntity, QSortThenBy> {
  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterSortBy>
      thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterSortBy>
      thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterSortBy>
      thenByPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playedAt', Sort.asc);
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterSortBy>
      thenByPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playedAt', Sort.desc);
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterSortBy> thenBySongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songId', Sort.asc);
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QAfterSortBy>
      thenBySongIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songId', Sort.desc);
    });
  }
}

extension PlayStatsEntityQueryWhereDistinct
    on QueryBuilder<PlayStatsEntity, PlayStatsEntity, QDistinct> {
  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QDistinct>
      distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QDistinct>
      distinctByPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playedAt');
    });
  }

  QueryBuilder<PlayStatsEntity, PlayStatsEntity, QDistinct> distinctBySongId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'songId', caseSensitive: caseSensitive);
    });
  }
}

extension PlayStatsEntityQueryProperty
    on QueryBuilder<PlayStatsEntity, PlayStatsEntity, QQueryProperty> {
  QueryBuilder<PlayStatsEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlayStatsEntity, int?, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<PlayStatsEntity, DateTime, QQueryOperations> playedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playedAt');
    });
  }

  QueryBuilder<PlayStatsEntity, String, QQueryOperations> songIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'songId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetListeningStatisticsCollection on Isar {
  IsarCollection<ListeningStatistics> get listeningStatistics =>
      this.collection();
}

const ListeningStatisticsSchema = CollectionSchema(
  name: r'ListeningStatistics',
  id: 3138817521845093368,
  properties: {
    r'topArtists': PropertySchema(
      id: 0,
      name: r'topArtists',
      type: IsarType.stringList,
    ),
    r'topGenres': PropertySchema(
      id: 1,
      name: r'topGenres',
      type: IsarType.stringList,
    ),
    r'totalListeningTime': PropertySchema(
      id: 2,
      name: r'totalListeningTime',
      type: IsarType.long,
    ),
    r'totalSongsPlayed': PropertySchema(
      id: 3,
      name: r'totalSongsPlayed',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 4,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _listeningStatisticsEstimateSize,
  serialize: _listeningStatisticsSerialize,
  deserialize: _listeningStatisticsDeserialize,
  deserializeProp: _listeningStatisticsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _listeningStatisticsGetId,
  getLinks: _listeningStatisticsGetLinks,
  attach: _listeningStatisticsAttach,
  version: '3.1.0+1',
);

int _listeningStatisticsEstimateSize(
  ListeningStatistics object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.topArtists.length * 3;
  {
    for (var i = 0; i < object.topArtists.length; i++) {
      final value = object.topArtists[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.topGenres.length * 3;
  {
    for (var i = 0; i < object.topGenres.length; i++) {
      final value = object.topGenres[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _listeningStatisticsSerialize(
  ListeningStatistics object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.topArtists);
  writer.writeStringList(offsets[1], object.topGenres);
  writer.writeLong(offsets[2], object.totalListeningTime);
  writer.writeLong(offsets[3], object.totalSongsPlayed);
  writer.writeDateTime(offsets[4], object.updatedAt);
}

ListeningStatistics _listeningStatisticsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ListeningStatistics(
    id: id,
    topArtists: reader.readStringList(offsets[0]) ?? const [],
    topGenres: reader.readStringList(offsets[1]) ?? const [],
    totalListeningTime: reader.readLongOrNull(offsets[2]) ?? 0,
    totalSongsPlayed: reader.readLongOrNull(offsets[3]) ?? 0,
    updatedAt: reader.readDateTimeOrNull(offsets[4]),
  );
  return object;
}

P _listeningStatisticsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? const []) as P;
    case 1:
      return (reader.readStringList(offset) ?? const []) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _listeningStatisticsGetId(ListeningStatistics object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _listeningStatisticsGetLinks(
    ListeningStatistics object) {
  return [];
}

void _listeningStatisticsAttach(
    IsarCollection<dynamic> col, Id id, ListeningStatistics object) {
  object.id = id;
}

extension ListeningStatisticsQueryWhereSort
    on QueryBuilder<ListeningStatistics, ListeningStatistics, QWhere> {
  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ListeningStatisticsQueryWhere
    on QueryBuilder<ListeningStatistics, ListeningStatistics, QWhereClause> {
  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterWhereClause>
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

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterWhereClause>
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

extension ListeningStatisticsQueryFilter on QueryBuilder<ListeningStatistics,
    ListeningStatistics, QFilterCondition> {
  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
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

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
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

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
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

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topArtistsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topArtists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topArtistsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topArtists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topArtistsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topArtists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topArtistsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topArtists',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topArtistsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'topArtists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topArtistsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'topArtists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topArtistsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'topArtists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topArtistsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'topArtists',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topArtistsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topArtists',
        value: '',
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topArtistsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'topArtists',
        value: '',
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topArtistsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topArtists',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topArtistsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topArtists',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topArtistsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topArtists',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topArtistsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topArtists',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topArtistsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topArtists',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topArtistsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topArtists',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topGenresElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topGenres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topGenresElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topGenres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topGenresElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topGenres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topGenresElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topGenres',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topGenresElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'topGenres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topGenresElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'topGenres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topGenresElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'topGenres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topGenresElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'topGenres',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topGenresElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topGenres',
        value: '',
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topGenresElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'topGenres',
        value: '',
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topGenresLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topGenres',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topGenresIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topGenres',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topGenresIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topGenres',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topGenresLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topGenres',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topGenresLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topGenres',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      topGenresLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topGenres',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      totalListeningTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalListeningTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      totalListeningTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalListeningTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      totalListeningTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalListeningTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      totalListeningTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalListeningTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      totalSongsPlayedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalSongsPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      totalSongsPlayedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalSongsPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      totalSongsPlayedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalSongsPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      totalSongsPlayedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalSongsPlayed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterFilterCondition>
      updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ListeningStatisticsQueryObject on QueryBuilder<ListeningStatistics,
    ListeningStatistics, QFilterCondition> {}

extension ListeningStatisticsQueryLinks on QueryBuilder<ListeningStatistics,
    ListeningStatistics, QFilterCondition> {}

extension ListeningStatisticsQuerySortBy
    on QueryBuilder<ListeningStatistics, ListeningStatistics, QSortBy> {
  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterSortBy>
      sortByTotalListeningTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalListeningTime', Sort.asc);
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterSortBy>
      sortByTotalListeningTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalListeningTime', Sort.desc);
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterSortBy>
      sortByTotalSongsPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSongsPlayed', Sort.asc);
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterSortBy>
      sortByTotalSongsPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSongsPlayed', Sort.desc);
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ListeningStatisticsQuerySortThenBy
    on QueryBuilder<ListeningStatistics, ListeningStatistics, QSortThenBy> {
  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterSortBy>
      thenByTotalListeningTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalListeningTime', Sort.asc);
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterSortBy>
      thenByTotalListeningTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalListeningTime', Sort.desc);
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterSortBy>
      thenByTotalSongsPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSongsPlayed', Sort.asc);
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterSortBy>
      thenByTotalSongsPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSongsPlayed', Sort.desc);
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ListeningStatisticsQueryWhereDistinct
    on QueryBuilder<ListeningStatistics, ListeningStatistics, QDistinct> {
  QueryBuilder<ListeningStatistics, ListeningStatistics, QDistinct>
      distinctByTopArtists() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topArtists');
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QDistinct>
      distinctByTopGenres() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topGenres');
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QDistinct>
      distinctByTotalListeningTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalListeningTime');
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QDistinct>
      distinctByTotalSongsPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalSongsPlayed');
    });
  }

  QueryBuilder<ListeningStatistics, ListeningStatistics, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ListeningStatisticsQueryProperty
    on QueryBuilder<ListeningStatistics, ListeningStatistics, QQueryProperty> {
  QueryBuilder<ListeningStatistics, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ListeningStatistics, List<String>, QQueryOperations>
      topArtistsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topArtists');
    });
  }

  QueryBuilder<ListeningStatistics, List<String>, QQueryOperations>
      topGenresProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topGenres');
    });
  }

  QueryBuilder<ListeningStatistics, int, QQueryOperations>
      totalListeningTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalListeningTime');
    });
  }

  QueryBuilder<ListeningStatistics, int, QQueryOperations>
      totalSongsPlayedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalSongsPlayed');
    });
  }

  QueryBuilder<ListeningStatistics, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
