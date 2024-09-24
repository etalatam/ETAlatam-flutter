// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_information.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLoginInformationCollection on Isar {
  IsarCollection<LoginInformation> get loginInformations => this.collection();
}

const LoginInformationSchema = CollectionSchema(
  name: r'LoginInformation',
  id: -8797082235721741082,
  properties: {
    r'apeUsu': PropertySchema(
      id: 0,
      name: r'apeUsu',
      type: IsarType.string,
    ),
    r'avatar': PropertySchema(
      id: 1,
      name: r'avatar',
      type: IsarType.bool,
    ),
    r'dniUsu': PropertySchema(
      id: 2,
      name: r'dniUsu',
      type: IsarType.long,
    ),
    r'emaUsu': PropertySchema(
      id: 3,
      name: r'emaUsu',
      type: IsarType.string,
    ),
    r'fecCre': PropertySchema(
      id: 4,
      name: r'fecCre',
      type: IsarType.dateTime,
    ),
    r'idUsu': PropertySchema(
      id: 5,
      name: r'idUsu',
      type: IsarType.long,
    ),
    r'nomUsu': PropertySchema(
      id: 6,
      name: r'nomUsu',
      type: IsarType.string,
    ),
    r'permissions': PropertySchema(
      id: 7,
      name: r'permissions',
      type: IsarType.string,
    ),
    r'relationId': PropertySchema(
      id: 8,
      name: r'relationId',
      type: IsarType.long,
    ),
    r'relationName': PropertySchema(
      id: 9,
      name: r'relationName',
      type: IsarType.string,
    ),
    r'telUsu': PropertySchema(
      id: 10,
      name: r'telUsu',
      type: IsarType.string,
    ),
    r'token': PropertySchema(
      id: 11,
      name: r'token',
      type: IsarType.string,
    )
  },
  estimateSize: _loginInformationEstimateSize,
  serialize: _loginInformationSerialize,
  deserialize: _loginInformationDeserialize,
  deserializeProp: _loginInformationDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _loginInformationGetId,
  getLinks: _loginInformationGetLinks,
  attach: _loginInformationAttach,
  version: '3.1.0+1',
);

int _loginInformationEstimateSize(
  LoginInformation object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.apeUsu.length * 3;
  bytesCount += 3 + object.emaUsu.length * 3;
  bytesCount += 3 + object.nomUsu.length * 3;
  {
    final value = object.permissions;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.relationName.length * 3;
  bytesCount += 3 + object.telUsu.length * 3;
  bytesCount += 3 + object.token.length * 3;
  return bytesCount;
}

void _loginInformationSerialize(
  LoginInformation object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.apeUsu);
  writer.writeBool(offsets[1], object.avatar);
  writer.writeLong(offsets[2], object.dniUsu);
  writer.writeString(offsets[3], object.emaUsu);
  writer.writeDateTime(offsets[4], object.fecCre);
  writer.writeLong(offsets[5], object.idUsu);
  writer.writeString(offsets[6], object.nomUsu);
  writer.writeString(offsets[7], object.permissions);
  writer.writeLong(offsets[8], object.relationId);
  writer.writeString(offsets[9], object.relationName);
  writer.writeString(offsets[10], object.telUsu);
  writer.writeString(offsets[11], object.token);
}

LoginInformation _loginInformationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LoginInformation(
    apeUsu: reader.readString(offsets[0]),
    avatar: reader.readBool(offsets[1]),
    dniUsu: reader.readLongOrNull(offsets[2]),
    emaUsu: reader.readString(offsets[3]),
    fecCre: reader.readDateTime(offsets[4]),
    idUsu: reader.readLong(offsets[5]),
    nomUsu: reader.readString(offsets[6]),
    permissions: reader.readStringOrNull(offsets[7]),
    relationId: reader.readLong(offsets[8]),
    relationName: reader.readString(offsets[9]),
    telUsu: reader.readString(offsets[10]),
    token: reader.readString(offsets[11]),
  );
  object.id = id;
  return object;
}

P _loginInformationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _loginInformationGetId(LoginInformation object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _loginInformationGetLinks(LoginInformation object) {
  return [];
}

void _loginInformationAttach(
    IsarCollection<dynamic> col, Id id, LoginInformation object) {
  object.id = id;
}

extension LoginInformationQueryWhereSort
    on QueryBuilder<LoginInformation, LoginInformation, QWhere> {
  QueryBuilder<LoginInformation, LoginInformation, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LoginInformationQueryWhere
    on QueryBuilder<LoginInformation, LoginInformation, QWhereClause> {
  QueryBuilder<LoginInformation, LoginInformation, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterWhereClause>
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

  QueryBuilder<LoginInformation, LoginInformation, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterWhereClause> idBetween(
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

extension LoginInformationQueryFilter
    on QueryBuilder<LoginInformation, LoginInformation, QFilterCondition> {
  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      apeUsuEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apeUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      apeUsuGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'apeUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      apeUsuLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'apeUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      apeUsuBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'apeUsu',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      apeUsuStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'apeUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      apeUsuEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'apeUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      apeUsuContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'apeUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      apeUsuMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'apeUsu',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      apeUsuIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apeUsu',
        value: '',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      apeUsuIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'apeUsu',
        value: '',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      avatarEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatar',
        value: value,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      dniUsuIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dniUsu',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      dniUsuIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dniUsu',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      dniUsuEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dniUsu',
        value: value,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      dniUsuGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dniUsu',
        value: value,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      dniUsuLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dniUsu',
        value: value,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      dniUsuBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dniUsu',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      emaUsuEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emaUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      emaUsuGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'emaUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      emaUsuLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'emaUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      emaUsuBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'emaUsu',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      emaUsuStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'emaUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      emaUsuEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'emaUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      emaUsuContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'emaUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      emaUsuMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'emaUsu',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      emaUsuIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emaUsu',
        value: '',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      emaUsuIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'emaUsu',
        value: '',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      fecCreEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fecCre',
        value: value,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      fecCreGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fecCre',
        value: value,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      fecCreLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fecCre',
        value: value,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      fecCreBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fecCre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
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

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
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

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
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

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      idUsuEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idUsu',
        value: value,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      idUsuGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idUsu',
        value: value,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      idUsuLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idUsu',
        value: value,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      idUsuBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idUsu',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      nomUsuEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nomUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      nomUsuGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nomUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      nomUsuLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nomUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      nomUsuBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nomUsu',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      nomUsuStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nomUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      nomUsuEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nomUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      nomUsuContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nomUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      nomUsuMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nomUsu',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      nomUsuIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nomUsu',
        value: '',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      nomUsuIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nomUsu',
        value: '',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      permissionsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'permissions',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      permissionsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'permissions',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      permissionsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      permissionsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      permissionsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      permissionsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'permissions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      permissionsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      permissionsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      permissionsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      permissionsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'permissions',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      permissionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permissions',
        value: '',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      permissionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'permissions',
        value: '',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      relationIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationId',
        value: value,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      relationIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relationId',
        value: value,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      relationIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relationId',
        value: value,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      relationIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      relationNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      relationNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      relationNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      relationNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relationName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      relationNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      relationNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      relationNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      relationNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relationName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      relationNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationName',
        value: '',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      relationNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relationName',
        value: '',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      telUsuEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'telUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      telUsuGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'telUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      telUsuLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'telUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      telUsuBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'telUsu',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      telUsuStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'telUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      telUsuEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'telUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      telUsuContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'telUsu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      telUsuMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'telUsu',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      telUsuIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'telUsu',
        value: '',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      telUsuIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'telUsu',
        value: '',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      tokenEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      tokenGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      tokenLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      tokenBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'token',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      tokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      tokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      tokenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      tokenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'token',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      tokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'token',
        value: '',
      ));
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterFilterCondition>
      tokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'token',
        value: '',
      ));
    });
  }
}

extension LoginInformationQueryObject
    on QueryBuilder<LoginInformation, LoginInformation, QFilterCondition> {}

extension LoginInformationQueryLinks
    on QueryBuilder<LoginInformation, LoginInformation, QFilterCondition> {}

extension LoginInformationQuerySortBy
    on QueryBuilder<LoginInformation, LoginInformation, QSortBy> {
  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByApeUsu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apeUsu', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByApeUsuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apeUsu', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByDniUsu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dniUsu', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByDniUsuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dniUsu', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByEmaUsu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emaUsu', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByEmaUsuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emaUsu', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByFecCre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecCre', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByFecCreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecCre', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy> sortByIdUsu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idUsu', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByIdUsuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idUsu', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByNomUsu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomUsu', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByNomUsuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomUsu', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByPermissions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permissions', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByPermissionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permissions', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByRelationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationId', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByRelationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationId', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByRelationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationName', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByRelationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationName', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByTelUsu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telUsu', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByTelUsuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telUsu', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy> sortByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      sortByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.desc);
    });
  }
}

extension LoginInformationQuerySortThenBy
    on QueryBuilder<LoginInformation, LoginInformation, QSortThenBy> {
  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByApeUsu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apeUsu', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByApeUsuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apeUsu', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByDniUsu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dniUsu', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByDniUsuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dniUsu', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByEmaUsu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emaUsu', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByEmaUsuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emaUsu', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByFecCre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecCre', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByFecCreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecCre', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy> thenByIdUsu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idUsu', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByIdUsuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idUsu', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByNomUsu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomUsu', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByNomUsuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomUsu', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByPermissions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permissions', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByPermissionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permissions', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByRelationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationId', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByRelationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationId', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByRelationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationName', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByRelationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationName', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByTelUsu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telUsu', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByTelUsuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telUsu', Sort.desc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy> thenByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.asc);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QAfterSortBy>
      thenByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.desc);
    });
  }
}

extension LoginInformationQueryWhereDistinct
    on QueryBuilder<LoginInformation, LoginInformation, QDistinct> {
  QueryBuilder<LoginInformation, LoginInformation, QDistinct> distinctByApeUsu(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'apeUsu', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QDistinct>
      distinctByAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avatar');
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QDistinct>
      distinctByDniUsu() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dniUsu');
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QDistinct> distinctByEmaUsu(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emaUsu', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QDistinct>
      distinctByFecCre() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fecCre');
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QDistinct>
      distinctByIdUsu() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idUsu');
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QDistinct> distinctByNomUsu(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nomUsu', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QDistinct>
      distinctByPermissions({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'permissions', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QDistinct>
      distinctByRelationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relationId');
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QDistinct>
      distinctByRelationName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relationName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QDistinct> distinctByTelUsu(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'telUsu', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoginInformation, LoginInformation, QDistinct> distinctByToken(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'token', caseSensitive: caseSensitive);
    });
  }
}

extension LoginInformationQueryProperty
    on QueryBuilder<LoginInformation, LoginInformation, QQueryProperty> {
  QueryBuilder<LoginInformation, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LoginInformation, String, QQueryOperations> apeUsuProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'apeUsu');
    });
  }

  QueryBuilder<LoginInformation, bool, QQueryOperations> avatarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avatar');
    });
  }

  QueryBuilder<LoginInformation, int?, QQueryOperations> dniUsuProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dniUsu');
    });
  }

  QueryBuilder<LoginInformation, String, QQueryOperations> emaUsuProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emaUsu');
    });
  }

  QueryBuilder<LoginInformation, DateTime, QQueryOperations> fecCreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fecCre');
    });
  }

  QueryBuilder<LoginInformation, int, QQueryOperations> idUsuProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idUsu');
    });
  }

  QueryBuilder<LoginInformation, String, QQueryOperations> nomUsuProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nomUsu');
    });
  }

  QueryBuilder<LoginInformation, String?, QQueryOperations>
      permissionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'permissions');
    });
  }

  QueryBuilder<LoginInformation, int, QQueryOperations> relationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relationId');
    });
  }

  QueryBuilder<LoginInformation, String, QQueryOperations>
      relationNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relationName');
    });
  }

  QueryBuilder<LoginInformation, String, QQueryOperations> telUsuProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'telUsu');
    });
  }

  QueryBuilder<LoginInformation, String, QQueryOperations> tokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'token');
    });
  }
}
