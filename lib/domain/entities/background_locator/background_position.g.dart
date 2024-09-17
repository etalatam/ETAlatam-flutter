// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_position.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBackgroundPositionCollection on Isar {
  IsarCollection<BackgroundPosition> get backgroundPositions =>
      this.collection();
}

const BackgroundPositionSchema = CollectionSchema(
  name: r'BackgroundPosition',
  id: -829610223071106823,
  properties: {
    r'accuracy': PropertySchema(
      id: 0,
      name: r'accuracy',
      type: IsarType.double,
    ),
    r'altitude': PropertySchema(
      id: 1,
      name: r'altitude',
      type: IsarType.double,
    ),
    r'heading': PropertySchema(
      id: 2,
      name: r'heading',
      type: IsarType.double,
    ),
    r'isMocked': PropertySchema(
      id: 3,
      name: r'isMocked',
      type: IsarType.bool,
    ),
    r'latitude': PropertySchema(
      id: 4,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 5,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'provider': PropertySchema(
      id: 6,
      name: r'provider',
      type: IsarType.string,
    ),
    r'speed': PropertySchema(
      id: 7,
      name: r'speed',
      type: IsarType.double,
    ),
    r'speedAccuracy': PropertySchema(
      id: 8,
      name: r'speedAccuracy',
      type: IsarType.double,
    ),
    r'time': PropertySchema(
      id: 9,
      name: r'time',
      type: IsarType.double,
    )
  },
  estimateSize: _backgroundPositionEstimateSize,
  serialize: _backgroundPositionSerialize,
  deserialize: _backgroundPositionDeserialize,
  deserializeProp: _backgroundPositionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _backgroundPositionGetId,
  getLinks: _backgroundPositionGetLinks,
  attach: _backgroundPositionAttach,
  version: '3.1.0+1',
);

int _backgroundPositionEstimateSize(
  BackgroundPosition object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.provider;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _backgroundPositionSerialize(
  BackgroundPosition object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.accuracy);
  writer.writeDouble(offsets[1], object.altitude);
  writer.writeDouble(offsets[2], object.heading);
  writer.writeBool(offsets[3], object.isMocked);
  writer.writeDouble(offsets[4], object.latitude);
  writer.writeDouble(offsets[5], object.longitude);
  writer.writeString(offsets[6], object.provider);
  writer.writeDouble(offsets[7], object.speed);
  writer.writeDouble(offsets[8], object.speedAccuracy);
  writer.writeDouble(offsets[9], object.time);
}

BackgroundPosition _backgroundPositionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BackgroundPosition(
    accuracy: reader.readDouble(offsets[0]),
    altitude: reader.readDouble(offsets[1]),
    heading: reader.readDouble(offsets[2]),
    isMocked: reader.readBool(offsets[3]),
    latitude: reader.readDouble(offsets[4]),
    longitude: reader.readDouble(offsets[5]),
    provider: reader.readStringOrNull(offsets[6]),
    speed: reader.readDouble(offsets[7]),
    speedAccuracy: reader.readDouble(offsets[8]),
    time: reader.readDouble(offsets[9]),
  );
  object.id = id;
  return object;
}

P _backgroundPositionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _backgroundPositionGetId(BackgroundPosition object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _backgroundPositionGetLinks(
    BackgroundPosition object) {
  return [];
}

void _backgroundPositionAttach(
    IsarCollection<dynamic> col, Id id, BackgroundPosition object) {
  object.id = id;
}

extension BackgroundPositionQueryWhereSort
    on QueryBuilder<BackgroundPosition, BackgroundPosition, QWhere> {
  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BackgroundPositionQueryWhere
    on QueryBuilder<BackgroundPosition, BackgroundPosition, QWhereClause> {
  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterWhereClause>
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

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterWhereClause>
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

extension BackgroundPositionQueryFilter
    on QueryBuilder<BackgroundPosition, BackgroundPosition, QFilterCondition> {
  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      accuracyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      accuracyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      accuracyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      accuracyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accuracy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      altitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'altitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      altitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'altitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      altitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'altitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      altitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'altitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      headingEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heading',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      headingGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'heading',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      headingLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'heading',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      headingBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'heading',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
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

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
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

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
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

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      isMockedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMocked',
        value: value,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      latitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      latitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      latitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      latitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      longitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      longitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      longitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      longitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      providerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'provider',
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      providerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'provider',
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      providerEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      providerGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      providerLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      providerBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'provider',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      providerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      providerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      providerContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      providerMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'provider',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      providerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'provider',
        value: '',
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      providerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'provider',
        value: '',
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      speedEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      speedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'speed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      speedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'speed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      speedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'speed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      speedAccuracyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speedAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      speedAccuracyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'speedAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      speedAccuracyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'speedAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      speedAccuracyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'speedAccuracy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      timeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'time',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      timeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'time',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      timeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'time',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterFilterCondition>
      timeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'time',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension BackgroundPositionQueryObject
    on QueryBuilder<BackgroundPosition, BackgroundPosition, QFilterCondition> {}

extension BackgroundPositionQueryLinks
    on QueryBuilder<BackgroundPosition, BackgroundPosition, QFilterCondition> {}

extension BackgroundPositionQuerySortBy
    on QueryBuilder<BackgroundPosition, BackgroundPosition, QSortBy> {
  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortByAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortByAltitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'altitude', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortByAltitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'altitude', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortByHeading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heading', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortByHeadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heading', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortByIsMocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMocked', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortByIsMockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMocked', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortByProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provider', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortByProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provider', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortBySpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortBySpeedAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedAccuracy', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortBySpeedAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedAccuracy', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      sortByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }
}

extension BackgroundPositionQuerySortThenBy
    on QueryBuilder<BackgroundPosition, BackgroundPosition, QSortThenBy> {
  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenByAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenByAltitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'altitude', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenByAltitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'altitude', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenByHeading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heading', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenByHeadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heading', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenByIsMocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMocked', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenByIsMockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMocked', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenByProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provider', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenByProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provider', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenBySpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenBySpeedAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedAccuracy', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenBySpeedAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedAccuracy', Sort.desc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QAfterSortBy>
      thenByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }
}

extension BackgroundPositionQueryWhereDistinct
    on QueryBuilder<BackgroundPosition, BackgroundPosition, QDistinct> {
  QueryBuilder<BackgroundPosition, BackgroundPosition, QDistinct>
      distinctByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accuracy');
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QDistinct>
      distinctByAltitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'altitude');
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QDistinct>
      distinctByHeading() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heading');
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QDistinct>
      distinctByIsMocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMocked');
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QDistinct>
      distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QDistinct>
      distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QDistinct>
      distinctByProvider({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'provider', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QDistinct>
      distinctBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speed');
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QDistinct>
      distinctBySpeedAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speedAccuracy');
    });
  }

  QueryBuilder<BackgroundPosition, BackgroundPosition, QDistinct>
      distinctByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'time');
    });
  }
}

extension BackgroundPositionQueryProperty
    on QueryBuilder<BackgroundPosition, BackgroundPosition, QQueryProperty> {
  QueryBuilder<BackgroundPosition, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BackgroundPosition, double, QQueryOperations>
      accuracyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accuracy');
    });
  }

  QueryBuilder<BackgroundPosition, double, QQueryOperations>
      altitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'altitude');
    });
  }

  QueryBuilder<BackgroundPosition, double, QQueryOperations> headingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heading');
    });
  }

  QueryBuilder<BackgroundPosition, bool, QQueryOperations> isMockedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMocked');
    });
  }

  QueryBuilder<BackgroundPosition, double, QQueryOperations>
      latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<BackgroundPosition, double, QQueryOperations>
      longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<BackgroundPosition, String?, QQueryOperations>
      providerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'provider');
    });
  }

  QueryBuilder<BackgroundPosition, double, QQueryOperations> speedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speed');
    });
  }

  QueryBuilder<BackgroundPosition, double, QQueryOperations>
      speedAccuracyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speedAccuracy');
    });
  }

  QueryBuilder<BackgroundPosition, double, QQueryOperations> timeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'time');
    });
  }
}
