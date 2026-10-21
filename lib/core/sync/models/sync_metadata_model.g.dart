// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_metadata_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyncMetadataModelCollection on Isar {
  IsarCollection<SyncMetadataModel> get syncMetadataModels => this.collection();
}

const SyncMetadataModelSchema = CollectionSchema(
  name: r'SyncMetadataModel',
  id: 8356937239338297293,
  properties: {
    r'entityName': PropertySchema(
      id: 0,
      name: r'entityName',
      type: IsarType.string,
    ),
    r'lastPulledAt': PropertySchema(
      id: 1,
      name: r'lastPulledAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _syncMetadataModelEstimateSize,
  serialize: _syncMetadataModelSerialize,
  deserialize: _syncMetadataModelDeserialize,
  deserializeProp: _syncMetadataModelDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'entityName': IndexSchema(
      id: -1749110902930819992,
      name: r'entityName',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'entityName',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _syncMetadataModelGetId,
  getLinks: _syncMetadataModelGetLinks,
  attach: _syncMetadataModelAttach,
  version: '3.3.0',
);

int _syncMetadataModelEstimateSize(
  SyncMetadataModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.entityName.length * 3;
  return bytesCount;
}

void _syncMetadataModelSerialize(
  SyncMetadataModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.entityName);
  writer.writeDateTime(offsets[1], object.lastPulledAt);
}

SyncMetadataModel _syncMetadataModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncMetadataModel();
  object.entityName = reader.readString(offsets[0]);
  object.isarId = id;
  object.lastPulledAt = reader.readDateTimeOrNull(offsets[1]);
  return object;
}

P _syncMetadataModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syncMetadataModelGetId(SyncMetadataModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _syncMetadataModelGetLinks(
  SyncMetadataModel object,
) {
  return [];
}

void _syncMetadataModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  SyncMetadataModel object,
) {
  object.isarId = id;
}

extension SyncMetadataModelByIndex on IsarCollection<SyncMetadataModel> {
  Future<SyncMetadataModel?> getByEntityName(String entityName) {
    return getByIndex(r'entityName', [entityName]);
  }

  SyncMetadataModel? getByEntityNameSync(String entityName) {
    return getByIndexSync(r'entityName', [entityName]);
  }

  Future<bool> deleteByEntityName(String entityName) {
    return deleteByIndex(r'entityName', [entityName]);
  }

  bool deleteByEntityNameSync(String entityName) {
    return deleteByIndexSync(r'entityName', [entityName]);
  }

  Future<List<SyncMetadataModel?>> getAllByEntityName(
    List<String> entityNameValues,
  ) {
    final values = entityNameValues.map((e) => [e]).toList();
    return getAllByIndex(r'entityName', values);
  }

  List<SyncMetadataModel?> getAllByEntityNameSync(
    List<String> entityNameValues,
  ) {
    final values = entityNameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'entityName', values);
  }

  Future<int> deleteAllByEntityName(List<String> entityNameValues) {
    final values = entityNameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'entityName', values);
  }

  int deleteAllByEntityNameSync(List<String> entityNameValues) {
    final values = entityNameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'entityName', values);
  }

  Future<Id> putByEntityName(SyncMetadataModel object) {
    return putByIndex(r'entityName', object);
  }

  Id putByEntityNameSync(SyncMetadataModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'entityName', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEntityName(List<SyncMetadataModel> objects) {
    return putAllByIndex(r'entityName', objects);
  }

  List<Id> putAllByEntityNameSync(
    List<SyncMetadataModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'entityName', objects, saveLinks: saveLinks);
  }
}

extension SyncMetadataModelQueryWhereSort
    on QueryBuilder<SyncMetadataModel, SyncMetadataModel, QWhere> {
  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SyncMetadataModelQueryWhere
    on QueryBuilder<SyncMetadataModel, SyncMetadataModel, QWhereClause> {
  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterWhereClause>
  isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: isarId, upper: isarId),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterWhereClause>
  isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterWhereClause>
  isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterWhereClause>
  isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterWhereClause>
  isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerIsarId,
          includeLower: includeLower,
          upper: upperIsarId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterWhereClause>
  entityNameEqualTo(String entityName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'entityName', value: [entityName]),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterWhereClause>
  entityNameNotEqualTo(String entityName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entityName',
                lower: [],
                upper: [entityName],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entityName',
                lower: [entityName],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entityName',
                lower: [entityName],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entityName',
                lower: [],
                upper: [entityName],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension SyncMetadataModelQueryFilter
    on QueryBuilder<SyncMetadataModel, SyncMetadataModel, QFilterCondition> {
  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  entityNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'entityName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  entityNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entityName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  entityNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entityName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  entityNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entityName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  entityNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'entityName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  entityNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'entityName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  entityNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'entityName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  entityNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'entityName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  entityNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entityName', value: ''),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  entityNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'entityName', value: ''),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isarId', value: value),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  isarIdGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  isarIdLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'isarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  lastPulledAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastPulledAt'),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  lastPulledAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastPulledAt'),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  lastPulledAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastPulledAt', value: value),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  lastPulledAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastPulledAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  lastPulledAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastPulledAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterFilterCondition>
  lastPulledAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastPulledAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SyncMetadataModelQueryObject
    on QueryBuilder<SyncMetadataModel, SyncMetadataModel, QFilterCondition> {}

extension SyncMetadataModelQueryLinks
    on QueryBuilder<SyncMetadataModel, SyncMetadataModel, QFilterCondition> {}

extension SyncMetadataModelQuerySortBy
    on QueryBuilder<SyncMetadataModel, SyncMetadataModel, QSortBy> {
  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterSortBy>
  sortByEntityName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityName', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterSortBy>
  sortByEntityNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityName', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterSortBy>
  sortByLastPulledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPulledAt', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterSortBy>
  sortByLastPulledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPulledAt', Sort.desc);
    });
  }
}

extension SyncMetadataModelQuerySortThenBy
    on QueryBuilder<SyncMetadataModel, SyncMetadataModel, QSortThenBy> {
  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterSortBy>
  thenByEntityName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityName', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterSortBy>
  thenByEntityNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityName', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterSortBy>
  thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterSortBy>
  thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterSortBy>
  thenByLastPulledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPulledAt', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QAfterSortBy>
  thenByLastPulledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPulledAt', Sort.desc);
    });
  }
}

extension SyncMetadataModelQueryWhereDistinct
    on QueryBuilder<SyncMetadataModel, SyncMetadataModel, QDistinct> {
  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QDistinct>
  distinctByEntityName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncMetadataModel, SyncMetadataModel, QDistinct>
  distinctByLastPulledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPulledAt');
    });
  }
}

extension SyncMetadataModelQueryProperty
    on QueryBuilder<SyncMetadataModel, SyncMetadataModel, QQueryProperty> {
  QueryBuilder<SyncMetadataModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<SyncMetadataModel, String, QQueryOperations>
  entityNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityName');
    });
  }

  QueryBuilder<SyncMetadataModel, DateTime?, QQueryOperations>
  lastPulledAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPulledAt');
    });
  }
}
