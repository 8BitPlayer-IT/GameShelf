// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class Consoles extends Table with TableInfo<Consoles, ConsoleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Consoles(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(name)) > 0)',
  );
  static const VerificationMeta _nameNormMeta = const VerificationMeta(
    'nameNorm',
  );
  late final GeneratedColumn<String> nameNorm = GeneratedColumn<String>(
    'name_norm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _shortLabelMeta = const VerificationMeta(
    'shortLabel',
  );
  late final GeneratedColumn<String> shortLabel = GeneratedColumn<String>(
    'short_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(short_label) BETWEEN 1 AND 10 AND trim(short_label) <> \'\')',
  );
  static const VerificationMeta _familyMeta = const VerificationMeta('family');
  late final GeneratedColumn<String> family = GeneratedColumn<String>(
    'family',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'altro\' CHECK (family IN (\'nintendo\', \'playstation\', \'xbox\', \'sega\', \'pc\', \'altro\'))',
    defaultValue: const CustomExpression('\'altro\''),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1000',
    defaultValue: const CustomExpression('1000'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nameNorm,
    shortLabel,
    family,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'consoles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConsoleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_norm')) {
      context.handle(
        _nameNormMeta,
        nameNorm.isAcceptableOrUnknown(data['name_norm']!, _nameNormMeta),
      );
    } else if (isInserting) {
      context.missing(_nameNormMeta);
    }
    if (data.containsKey('short_label')) {
      context.handle(
        _shortLabelMeta,
        shortLabel.isAcceptableOrUnknown(data['short_label']!, _shortLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_shortLabelMeta);
    }
    if (data.containsKey('family')) {
      context.handle(
        _familyMeta,
        family.isAcceptableOrUnknown(data['family']!, _familyMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConsoleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConsoleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_norm'],
      )!,
      shortLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_label'],
      )!,
      family: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  Consoles createAlias(String alias) {
    return Consoles(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class ConsoleRow extends DataClass implements Insertable<ConsoleRow> {
  final int id;
  final String name;
  final String nameNorm;

  /// Il limite di 10 caratteri vale sulla stringa davvero salvata, perché è quella
  /// che viene disegnata nel badge della console; in più non può essere tutta spazi.
  final String shortLabel;
  final String family;
  final int sortOrder;
  const ConsoleRow({
    required this.id,
    required this.name,
    required this.nameNorm,
    required this.shortLabel,
    required this.family,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['name_norm'] = Variable<String>(nameNorm);
    map['short_label'] = Variable<String>(shortLabel);
    map['family'] = Variable<String>(family);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ConsolesCompanion toCompanion(bool nullToAbsent) {
    return ConsolesCompanion(
      id: Value(id),
      name: Value(name),
      nameNorm: Value(nameNorm),
      shortLabel: Value(shortLabel),
      family: Value(family),
      sortOrder: Value(sortOrder),
    );
  }

  factory ConsoleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConsoleRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameNorm: serializer.fromJson<String>(json['name_norm']),
      shortLabel: serializer.fromJson<String>(json['short_label']),
      family: serializer.fromJson<String>(json['family']),
      sortOrder: serializer.fromJson<int>(json['sort_order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'name_norm': serializer.toJson<String>(nameNorm),
      'short_label': serializer.toJson<String>(shortLabel),
      'family': serializer.toJson<String>(family),
      'sort_order': serializer.toJson<int>(sortOrder),
    };
  }

  ConsoleRow copyWith({
    int? id,
    String? name,
    String? nameNorm,
    String? shortLabel,
    String? family,
    int? sortOrder,
  }) => ConsoleRow(
    id: id ?? this.id,
    name: name ?? this.name,
    nameNorm: nameNorm ?? this.nameNorm,
    shortLabel: shortLabel ?? this.shortLabel,
    family: family ?? this.family,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ConsoleRow copyWithCompanion(ConsolesCompanion data) {
    return ConsoleRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameNorm: data.nameNorm.present ? data.nameNorm.value : this.nameNorm,
      shortLabel: data.shortLabel.present
          ? data.shortLabel.value
          : this.shortLabel,
      family: data.family.present ? data.family.value : this.family,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConsoleRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNorm: $nameNorm, ')
          ..write('shortLabel: $shortLabel, ')
          ..write('family: $family, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, nameNorm, shortLabel, family, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConsoleRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameNorm == this.nameNorm &&
          other.shortLabel == this.shortLabel &&
          other.family == this.family &&
          other.sortOrder == this.sortOrder);
}

class ConsolesCompanion extends UpdateCompanion<ConsoleRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nameNorm;
  final Value<String> shortLabel;
  final Value<String> family;
  final Value<int> sortOrder;
  const ConsolesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameNorm = const Value.absent(),
    this.shortLabel = const Value.absent(),
    this.family = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  ConsolesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String nameNorm,
    required String shortLabel,
    this.family = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       nameNorm = Value(nameNorm),
       shortLabel = Value(shortLabel);
  static Insertable<ConsoleRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameNorm,
    Expression<String>? shortLabel,
    Expression<String>? family,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameNorm != null) 'name_norm': nameNorm,
      if (shortLabel != null) 'short_label': shortLabel,
      if (family != null) 'family': family,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  ConsolesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? nameNorm,
    Value<String>? shortLabel,
    Value<String>? family,
    Value<int>? sortOrder,
  }) {
    return ConsolesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameNorm: nameNorm ?? this.nameNorm,
      shortLabel: shortLabel ?? this.shortLabel,
      family: family ?? this.family,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameNorm.present) {
      map['name_norm'] = Variable<String>(nameNorm.value);
    }
    if (shortLabel.present) {
      map['short_label'] = Variable<String>(shortLabel.value);
    }
    if (family.present) {
      map['family'] = Variable<String>(family.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConsolesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNorm: $nameNorm, ')
          ..write('shortLabel: $shortLabel, ')
          ..write('family: $family, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class Genres extends Table with TableInfo<Genres, Genre> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Genres(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(name)) > 0)',
  );
  static const VerificationMeta _nameNormMeta = const VerificationMeta(
    'nameNorm',
  );
  late final GeneratedColumn<String> nameNorm = GeneratedColumn<String>(
    'name_norm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, nameNorm];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'genres';
  @override
  VerificationContext validateIntegrity(
    Insertable<Genre> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_norm')) {
      context.handle(
        _nameNormMeta,
        nameNorm.isAcceptableOrUnknown(data['name_norm']!, _nameNormMeta),
      );
    } else if (isInserting) {
      context.missing(_nameNormMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Genre map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Genre(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_norm'],
      )!,
    );
  }

  @override
  Genres createAlias(String alias) {
    return Genres(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Genre extends DataClass implements Insertable<Genre> {
  final int id;
  final String name;
  final String nameNorm;
  const Genre({required this.id, required this.name, required this.nameNorm});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['name_norm'] = Variable<String>(nameNorm);
    return map;
  }

  GenresCompanion toCompanion(bool nullToAbsent) {
    return GenresCompanion(
      id: Value(id),
      name: Value(name),
      nameNorm: Value(nameNorm),
    );
  }

  factory Genre.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Genre(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameNorm: serializer.fromJson<String>(json['name_norm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'name_norm': serializer.toJson<String>(nameNorm),
    };
  }

  Genre copyWith({int? id, String? name, String? nameNorm}) => Genre(
    id: id ?? this.id,
    name: name ?? this.name,
    nameNorm: nameNorm ?? this.nameNorm,
  );
  Genre copyWithCompanion(GenresCompanion data) {
    return Genre(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameNorm: data.nameNorm.present ? data.nameNorm.value : this.nameNorm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Genre(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNorm: $nameNorm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, nameNorm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Genre &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameNorm == this.nameNorm);
}

class GenresCompanion extends UpdateCompanion<Genre> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nameNorm;
  const GenresCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameNorm = const Value.absent(),
  });
  GenresCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String nameNorm,
  }) : name = Value(name),
       nameNorm = Value(nameNorm);
  static Insertable<Genre> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameNorm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameNorm != null) 'name_norm': nameNorm,
    });
  }

  GenresCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? nameNorm,
  }) {
    return GenresCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameNorm: nameNorm ?? this.nameNorm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameNorm.present) {
      map['name_norm'] = Variable<String>(nameNorm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GenresCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNorm: $nameNorm')
          ..write(')'))
        .toString();
  }
}

class Series extends Table with TableInfo<Series, SeriesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Series(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(name)) > 0)',
  );
  static const VerificationMeta _nameNormMeta = const VerificationMeta(
    'nameNorm',
  );
  late final GeneratedColumn<String> nameNorm = GeneratedColumn<String>(
    'name_norm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, nameNorm];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_norm')) {
      context.handle(
        _nameNormMeta,
        nameNorm.isAcceptableOrUnknown(data['name_norm']!, _nameNormMeta),
      );
    } else if (isInserting) {
      context.missing(_nameNormMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SeriesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_norm'],
      )!,
    );
  }

  @override
  Series createAlias(String alias) {
    return Series(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SeriesRow extends DataClass implements Insertable<SeriesRow> {
  final int id;
  final String name;
  final String nameNorm;
  const SeriesRow({
    required this.id,
    required this.name,
    required this.nameNorm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['name_norm'] = Variable<String>(nameNorm);
    return map;
  }

  SeriesCompanion toCompanion(bool nullToAbsent) {
    return SeriesCompanion(
      id: Value(id),
      name: Value(name),
      nameNorm: Value(nameNorm),
    );
  }

  factory SeriesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameNorm: serializer.fromJson<String>(json['name_norm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'name_norm': serializer.toJson<String>(nameNorm),
    };
  }

  SeriesRow copyWith({int? id, String? name, String? nameNorm}) => SeriesRow(
    id: id ?? this.id,
    name: name ?? this.name,
    nameNorm: nameNorm ?? this.nameNorm,
  );
  SeriesRow copyWithCompanion(SeriesCompanion data) {
    return SeriesRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameNorm: data.nameNorm.present ? data.nameNorm.value : this.nameNorm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNorm: $nameNorm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, nameNorm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameNorm == this.nameNorm);
}

class SeriesCompanion extends UpdateCompanion<SeriesRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nameNorm;
  const SeriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameNorm = const Value.absent(),
  });
  SeriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String nameNorm,
  }) : name = Value(name),
       nameNorm = Value(nameNorm);
  static Insertable<SeriesRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameNorm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameNorm != null) 'name_norm': nameNorm,
    });
  }

  SeriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? nameNorm,
  }) {
    return SeriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameNorm: nameNorm ?? this.nameNorm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameNorm.present) {
      map['name_norm'] = Variable<String>(nameNorm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNorm: $nameNorm')
          ..write(')'))
        .toString();
  }
}

class Companies extends Table with TableInfo<Companies, Company> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Companies(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(name)) > 0)',
  );
  static const VerificationMeta _nameNormMeta = const VerificationMeta(
    'nameNorm',
  );
  late final GeneratedColumn<String> nameNorm = GeneratedColumn<String>(
    'name_norm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, nameNorm];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Company> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_norm')) {
      context.handle(
        _nameNormMeta,
        nameNorm.isAcceptableOrUnknown(data['name_norm']!, _nameNormMeta),
      );
    } else if (isInserting) {
      context.missing(_nameNormMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Company map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Company(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_norm'],
      )!,
    );
  }

  @override
  Companies createAlias(String alias) {
    return Companies(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Company extends DataClass implements Insertable<Company> {
  final int id;
  final String name;
  final String nameNorm;
  const Company({required this.id, required this.name, required this.nameNorm});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['name_norm'] = Variable<String>(nameNorm);
    return map;
  }

  CompaniesCompanion toCompanion(bool nullToAbsent) {
    return CompaniesCompanion(
      id: Value(id),
      name: Value(name),
      nameNorm: Value(nameNorm),
    );
  }

  factory Company.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Company(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameNorm: serializer.fromJson<String>(json['name_norm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'name_norm': serializer.toJson<String>(nameNorm),
    };
  }

  Company copyWith({int? id, String? name, String? nameNorm}) => Company(
    id: id ?? this.id,
    name: name ?? this.name,
    nameNorm: nameNorm ?? this.nameNorm,
  );
  Company copyWithCompanion(CompaniesCompanion data) {
    return Company(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameNorm: data.nameNorm.present ? data.nameNorm.value : this.nameNorm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Company(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNorm: $nameNorm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, nameNorm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Company &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameNorm == this.nameNorm);
}

class CompaniesCompanion extends UpdateCompanion<Company> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nameNorm;
  const CompaniesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameNorm = const Value.absent(),
  });
  CompaniesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String nameNorm,
  }) : name = Value(name),
       nameNorm = Value(nameNorm);
  static Insertable<Company> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameNorm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameNorm != null) 'name_norm': nameNorm,
    });
  }

  CompaniesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? nameNorm,
  }) {
    return CompaniesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameNorm: nameNorm ?? this.nameNorm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameNorm.present) {
      map['name_norm'] = Variable<String>(nameNorm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompaniesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNorm: $nameNorm')
          ..write(')'))
        .toString();
  }
}

class Games extends Table with TableInfo<Games, Game> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Games(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(title)) > 0)',
  );
  static const VerificationMeta _titleNormMeta = const VerificationMeta(
    'titleNorm',
  );
  late final GeneratedColumn<String> titleNorm = GeneratedColumn<String>(
    'title_norm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sortTitleMeta = const VerificationMeta(
    'sortTitle',
  );
  late final GeneratedColumn<String> sortTitle = GeneratedColumn<String>(
    'sort_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES series(id)ON DELETE SET NULL',
  );
  static const VerificationMeta _developerIdMeta = const VerificationMeta(
    'developerId',
  );
  late final GeneratedColumn<int> developerId = GeneratedColumn<int>(
    'developer_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES companies(id)ON DELETE SET NULL',
  );
  static const VerificationMeta _publisherIdMeta = const VerificationMeta(
    'publisherId',
  );
  late final GeneratedColumn<int> publisherId = GeneratedColumn<int>(
    'publisher_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES companies(id)ON DELETE SET NULL',
  );
  static const VerificationMeta _releaseYearMeta = const VerificationMeta(
    'releaseYear',
  );
  late final GeneratedColumn<int> releaseYear = GeneratedColumn<int>(
    'release_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (release_year IS NULL OR release_year BETWEEN 1950 AND 2100)',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'backlog\' CHECK (status IN (\'backlog\', \'arcade\', \'abbandonato\', \'in_corso\', \'finito\', \'completato\'))',
    defaultValue: const CustomExpression('\'backlog\''),
  );
  static const VerificationMeta _isReplayableMeta = const VerificationMeta(
    'isReplayable',
  );
  late final GeneratedColumn<bool> isReplayable = GeneratedColumn<bool>(
    'is_replayable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT FALSE CHECK (is_replayable IN (0, 1))',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _hasPostGameMeta = const VerificationMeta(
    'hasPostGame',
  );
  late final GeneratedColumn<bool> hasPostGame = GeneratedColumn<bool>(
    'has_post_game',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT FALSE CHECK (has_post_game IN (0, 1))',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _hasAchievementsMeta = const VerificationMeta(
    'hasAchievements',
  );
  late final GeneratedColumn<bool> hasAchievements = GeneratedColumn<bool>(
    'has_achievements',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT FALSE CHECK (has_achievements IN (0, 1))',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _allAchievementsUnlockedMeta =
      const VerificationMeta('allAchievementsUnlocked');
  late final GeneratedColumn<bool>
  allAchievementsUnlocked = GeneratedColumn<bool>(
    'all_achievements_unlocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT FALSE CHECK (all_achievements_unlocked IN (0, 1))',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _hasDlcMeta = const VerificationMeta('hasDlc');
  late final GeneratedColumn<bool> hasDlc = GeneratedColumn<bool>(
    'has_dlc',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT FALSE CHECK (has_dlc IN (0, 1))',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _isCollectionMeta = const VerificationMeta(
    'isCollection',
  );
  late final GeneratedColumn<bool> isCollection = GeneratedColumn<bool>(
    'is_collection',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT FALSE CHECK (is_collection IN (0, 1))',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _ratingStoryMeta = const VerificationMeta(
    'ratingStory',
  );
  late final GeneratedColumn<double> ratingStory = GeneratedColumn<double>(
    'rating_story',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (rating_story IS NULL OR(rating_story BETWEEN 0 AND 10 AND rating_story * 2 = CAST(rating_story * 2 AS INTEGER)))',
  );
  static const VerificationMeta _ratingGameplayMeta = const VerificationMeta(
    'ratingGameplay',
  );
  late final GeneratedColumn<double> ratingGameplay = GeneratedColumn<double>(
    'rating_gameplay',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (rating_gameplay IS NULL OR(rating_gameplay BETWEEN 0 AND 10 AND rating_gameplay * 2 = CAST(rating_gameplay * 2 AS INTEGER)))',
  );
  static const VerificationMeta _ratingGraphicsMeta = const VerificationMeta(
    'ratingGraphics',
  );
  late final GeneratedColumn<double> ratingGraphics = GeneratedColumn<double>(
    'rating_graphics',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (rating_graphics IS NULL OR(rating_graphics BETWEEN 0 AND 10 AND rating_graphics * 2 = CAST(rating_graphics * 2 AS INTEGER)))',
  );
  static const VerificationMeta _ratingSoundtrackMeta = const VerificationMeta(
    'ratingSoundtrack',
  );
  late final GeneratedColumn<double> ratingSoundtrack = GeneratedColumn<double>(
    'rating_soundtrack',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (rating_soundtrack IS NULL OR(rating_soundtrack BETWEEN 0 AND 10 AND rating_soundtrack * 2 = CAST(rating_soundtrack * 2 AS INTEGER)))',
  );
  static const VerificationMeta _overallRatingMeta = const VerificationMeta(
    'overallRating',
  );
  late final GeneratedColumn<double> overallRating = GeneratedColumn<double>(
    'overall_rating',
    aliasedName,
    true,
    generatedAs: GeneratedAs(
      const CustomExpression(
        'CASE WHEN COALESCE(rating_story, rating_gameplay, rating_graphics, rating_soundtrack) IS NULL THEN NULL ELSE(COALESCE(rating_story, 0) + COALESCE(rating_gameplay, 0) + COALESCE(rating_graphics, 0) + COALESCE(rating_soundtrack, 0))* 1.0 /((rating_story IS NOT NULL)+(rating_gameplay IS NOT NULL)+(rating_graphics IS NOT NULL)+(rating_soundtrack IS NOT NULL))END',
      ),
      false,
    ),
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'GENERATED ALWAYS AS (CASE WHEN COALESCE(rating_story, rating_gameplay, rating_graphics, rating_soundtrack) IS NULL THEN NULL ELSE(COALESCE(rating_story, 0) + COALESCE(rating_gameplay, 0) + COALESCE(rating_graphics, 0) + COALESCE(rating_soundtrack, 0))* 1.0 /((rating_story IS NOT NULL)+(rating_gameplay IS NOT NULL)+(rating_graphics IS NOT NULL)+(rating_soundtrack IS NOT NULL))END) VIRTUAL',
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT (unixepoch())',
    defaultValue: const CustomExpression('unixepoch()'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT (unixepoch())',
    defaultValue: const CustomExpression('unixepoch()'),
  );
  static const VerificationMeta _playersMeta = const VerificationMeta(
    'players',
  );
  late final GeneratedColumn<int> players = GeneratedColumn<int>(
    'players',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (players IS NULL OR players IN (1, 2, 4))',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    titleNorm,
    sortTitle,
    seriesId,
    developerId,
    publisherId,
    releaseYear,
    status,
    isReplayable,
    hasPostGame,
    hasAchievements,
    allAchievementsUnlocked,
    hasDlc,
    isCollection,
    ratingStory,
    ratingGameplay,
    ratingGraphics,
    ratingSoundtrack,
    overallRating,
    coverPath,
    createdAt,
    updatedAt,
    players,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(
    Insertable<Game> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('title_norm')) {
      context.handle(
        _titleNormMeta,
        titleNorm.isAcceptableOrUnknown(data['title_norm']!, _titleNormMeta),
      );
    } else if (isInserting) {
      context.missing(_titleNormMeta);
    }
    if (data.containsKey('sort_title')) {
      context.handle(
        _sortTitleMeta,
        sortTitle.isAcceptableOrUnknown(data['sort_title']!, _sortTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_sortTitleMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    if (data.containsKey('developer_id')) {
      context.handle(
        _developerIdMeta,
        developerId.isAcceptableOrUnknown(
          data['developer_id']!,
          _developerIdMeta,
        ),
      );
    }
    if (data.containsKey('publisher_id')) {
      context.handle(
        _publisherIdMeta,
        publisherId.isAcceptableOrUnknown(
          data['publisher_id']!,
          _publisherIdMeta,
        ),
      );
    }
    if (data.containsKey('release_year')) {
      context.handle(
        _releaseYearMeta,
        releaseYear.isAcceptableOrUnknown(
          data['release_year']!,
          _releaseYearMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('is_replayable')) {
      context.handle(
        _isReplayableMeta,
        isReplayable.isAcceptableOrUnknown(
          data['is_replayable']!,
          _isReplayableMeta,
        ),
      );
    }
    if (data.containsKey('has_post_game')) {
      context.handle(
        _hasPostGameMeta,
        hasPostGame.isAcceptableOrUnknown(
          data['has_post_game']!,
          _hasPostGameMeta,
        ),
      );
    }
    if (data.containsKey('has_achievements')) {
      context.handle(
        _hasAchievementsMeta,
        hasAchievements.isAcceptableOrUnknown(
          data['has_achievements']!,
          _hasAchievementsMeta,
        ),
      );
    }
    if (data.containsKey('all_achievements_unlocked')) {
      context.handle(
        _allAchievementsUnlockedMeta,
        allAchievementsUnlocked.isAcceptableOrUnknown(
          data['all_achievements_unlocked']!,
          _allAchievementsUnlockedMeta,
        ),
      );
    }
    if (data.containsKey('has_dlc')) {
      context.handle(
        _hasDlcMeta,
        hasDlc.isAcceptableOrUnknown(data['has_dlc']!, _hasDlcMeta),
      );
    }
    if (data.containsKey('is_collection')) {
      context.handle(
        _isCollectionMeta,
        isCollection.isAcceptableOrUnknown(
          data['is_collection']!,
          _isCollectionMeta,
        ),
      );
    }
    if (data.containsKey('rating_story')) {
      context.handle(
        _ratingStoryMeta,
        ratingStory.isAcceptableOrUnknown(
          data['rating_story']!,
          _ratingStoryMeta,
        ),
      );
    }
    if (data.containsKey('rating_gameplay')) {
      context.handle(
        _ratingGameplayMeta,
        ratingGameplay.isAcceptableOrUnknown(
          data['rating_gameplay']!,
          _ratingGameplayMeta,
        ),
      );
    }
    if (data.containsKey('rating_graphics')) {
      context.handle(
        _ratingGraphicsMeta,
        ratingGraphics.isAcceptableOrUnknown(
          data['rating_graphics']!,
          _ratingGraphicsMeta,
        ),
      );
    }
    if (data.containsKey('rating_soundtrack')) {
      context.handle(
        _ratingSoundtrackMeta,
        ratingSoundtrack.isAcceptableOrUnknown(
          data['rating_soundtrack']!,
          _ratingSoundtrackMeta,
        ),
      );
    }
    if (data.containsKey('overall_rating')) {
      context.handle(
        _overallRatingMeta,
        overallRating.isAcceptableOrUnknown(
          data['overall_rating']!,
          _overallRatingMeta,
        ),
      );
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('players')) {
      context.handle(
        _playersMeta,
        players.isAcceptableOrUnknown(data['players']!, _playersMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Game map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Game(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      titleNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_norm'],
      )!,
      sortTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sort_title'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_id'],
      ),
      developerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}developer_id'],
      ),
      publisherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}publisher_id'],
      ),
      releaseYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}release_year'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isReplayable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_replayable'],
      )!,
      hasPostGame: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_post_game'],
      )!,
      hasAchievements: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_achievements'],
      )!,
      allAchievementsUnlocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}all_achievements_unlocked'],
      )!,
      hasDlc: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_dlc'],
      )!,
      isCollection: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_collection'],
      )!,
      ratingStory: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating_story'],
      ),
      ratingGameplay: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating_gameplay'],
      ),
      ratingGraphics: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating_graphics'],
      ),
      ratingSoundtrack: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating_soundtrack'],
      ),
      overallRating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overall_rating'],
      ),
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      players: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}players'],
      ),
    );
  }

  @override
  Games createAlias(String alias) {
    return Games(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CHECK(all_achievements_unlocked = 0 OR has_achievements = 1)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Game extends DataClass implements Insertable<Game> {
  final int id;
  final String title;

  /// Forma normalizzata per la ricerca: «pokemon» deve trovare «Pokémon».
  final String titleNorm;

  /// Chiave di ordinamento: numeri riempiti di zeri e articolo iniziale tolto,
  /// così «FIFA 9» viene prima di «FIFA 23» e «The Last of Us» si ordina alla L.
  final String sortTitle;
  final int? seriesId;
  final int? developerId;
  final int? publisherId;

  /// Può restare vuoto: «anno sconosciuto» è uno stato legittimo.
  final int? releaseYear;
  final String status;

  /// BOOLEAN in Dart diventa `bool`, ma drift NON aggiunge alcun vincolo alle
  /// colonne dichiarate in un file .drift: il CHECK va scritto a mano, altrimenti
  /// un valore diverso da 0/1 verrebbe letto come `true` in Dart mentre tutti i
  /// confronti « = 1 » in SQL (viste, trigger, statistiche) risulterebbero falsi.
  final bool isReplayable;
  final bool hasPostGame;
  final bool hasAchievements;
  final bool allAchievementsUnlocked;
  final bool hasDlc;

  /// Una raccolta che contiene altri giochi (vedi collection_items). Dalla v3 un
  /// gioco può stare in più collection e avere comunque copie proprie.
  final bool isCollection;

  /// Voti 0-10 a mezzi punti. Il CHECK sul doppio esclude valori come 7,3:
  /// 7,5 * 2 = 15 è intero, 7,3 * 2 = 14,6 no.
  final double? ratingStory;
  final double? ratingGameplay;
  final double? ratingGraphics;
  final double? ratingSoundtrack;

  /// Voto complessivo: media delle sole categorie valutate, calcolata dal database
  /// così interfaccia, ordinamenti e statistiche non possono divergere.
  /// Il « * 1.0 » è obbligatorio: fra interi SQLite troncherebbe, e la media di
  /// 9, 8 e 7 diventerebbe 8 invece di 8,0. Nessuna categoria valutata = NULL,
  /// che non è zero: un gioco non valutato va in fondo, non in cima.
  final double? overallRating;

  /// Percorso RELATIVO alla cartella documenti dell'app: un percorso assoluto
  /// si romperebbe dopo un ripristino, una reinstallazione o un cambio telefono.
  final String? coverPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Numero massimo di giocatori (1, 2 o 4), vuoto se non indicato.
  final int? players;
  const Game({
    required this.id,
    required this.title,
    required this.titleNorm,
    required this.sortTitle,
    this.seriesId,
    this.developerId,
    this.publisherId,
    this.releaseYear,
    required this.status,
    required this.isReplayable,
    required this.hasPostGame,
    required this.hasAchievements,
    required this.allAchievementsUnlocked,
    required this.hasDlc,
    required this.isCollection,
    this.ratingStory,
    this.ratingGameplay,
    this.ratingGraphics,
    this.ratingSoundtrack,
    this.overallRating,
    this.coverPath,
    required this.createdAt,
    required this.updatedAt,
    this.players,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['title_norm'] = Variable<String>(titleNorm);
    map['sort_title'] = Variable<String>(sortTitle);
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<int>(seriesId);
    }
    if (!nullToAbsent || developerId != null) {
      map['developer_id'] = Variable<int>(developerId);
    }
    if (!nullToAbsent || publisherId != null) {
      map['publisher_id'] = Variable<int>(publisherId);
    }
    if (!nullToAbsent || releaseYear != null) {
      map['release_year'] = Variable<int>(releaseYear);
    }
    map['status'] = Variable<String>(status);
    map['is_replayable'] = Variable<bool>(isReplayable);
    map['has_post_game'] = Variable<bool>(hasPostGame);
    map['has_achievements'] = Variable<bool>(hasAchievements);
    map['all_achievements_unlocked'] = Variable<bool>(allAchievementsUnlocked);
    map['has_dlc'] = Variable<bool>(hasDlc);
    map['is_collection'] = Variable<bool>(isCollection);
    if (!nullToAbsent || ratingStory != null) {
      map['rating_story'] = Variable<double>(ratingStory);
    }
    if (!nullToAbsent || ratingGameplay != null) {
      map['rating_gameplay'] = Variable<double>(ratingGameplay);
    }
    if (!nullToAbsent || ratingGraphics != null) {
      map['rating_graphics'] = Variable<double>(ratingGraphics);
    }
    if (!nullToAbsent || ratingSoundtrack != null) {
      map['rating_soundtrack'] = Variable<double>(ratingSoundtrack);
    }
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || players != null) {
      map['players'] = Variable<int>(players);
    }
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      title: Value(title),
      titleNorm: Value(titleNorm),
      sortTitle: Value(sortTitle),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      developerId: developerId == null && nullToAbsent
          ? const Value.absent()
          : Value(developerId),
      publisherId: publisherId == null && nullToAbsent
          ? const Value.absent()
          : Value(publisherId),
      releaseYear: releaseYear == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseYear),
      status: Value(status),
      isReplayable: Value(isReplayable),
      hasPostGame: Value(hasPostGame),
      hasAchievements: Value(hasAchievements),
      allAchievementsUnlocked: Value(allAchievementsUnlocked),
      hasDlc: Value(hasDlc),
      isCollection: Value(isCollection),
      ratingStory: ratingStory == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingStory),
      ratingGameplay: ratingGameplay == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingGameplay),
      ratingGraphics: ratingGraphics == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingGraphics),
      ratingSoundtrack: ratingSoundtrack == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingSoundtrack),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      players: players == null && nullToAbsent
          ? const Value.absent()
          : Value(players),
    );
  }

  factory Game.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Game(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      titleNorm: serializer.fromJson<String>(json['title_norm']),
      sortTitle: serializer.fromJson<String>(json['sort_title']),
      seriesId: serializer.fromJson<int?>(json['series_id']),
      developerId: serializer.fromJson<int?>(json['developer_id']),
      publisherId: serializer.fromJson<int?>(json['publisher_id']),
      releaseYear: serializer.fromJson<int?>(json['release_year']),
      status: serializer.fromJson<String>(json['status']),
      isReplayable: serializer.fromJson<bool>(json['is_replayable']),
      hasPostGame: serializer.fromJson<bool>(json['has_post_game']),
      hasAchievements: serializer.fromJson<bool>(json['has_achievements']),
      allAchievementsUnlocked: serializer.fromJson<bool>(
        json['all_achievements_unlocked'],
      ),
      hasDlc: serializer.fromJson<bool>(json['has_dlc']),
      isCollection: serializer.fromJson<bool>(json['is_collection']),
      ratingStory: serializer.fromJson<double?>(json['rating_story']),
      ratingGameplay: serializer.fromJson<double?>(json['rating_gameplay']),
      ratingGraphics: serializer.fromJson<double?>(json['rating_graphics']),
      ratingSoundtrack: serializer.fromJson<double?>(json['rating_soundtrack']),
      overallRating: serializer.fromJson<double?>(json['overall_rating']),
      coverPath: serializer.fromJson<String?>(json['cover_path']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
      players: serializer.fromJson<int?>(json['players']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'title_norm': serializer.toJson<String>(titleNorm),
      'sort_title': serializer.toJson<String>(sortTitle),
      'series_id': serializer.toJson<int?>(seriesId),
      'developer_id': serializer.toJson<int?>(developerId),
      'publisher_id': serializer.toJson<int?>(publisherId),
      'release_year': serializer.toJson<int?>(releaseYear),
      'status': serializer.toJson<String>(status),
      'is_replayable': serializer.toJson<bool>(isReplayable),
      'has_post_game': serializer.toJson<bool>(hasPostGame),
      'has_achievements': serializer.toJson<bool>(hasAchievements),
      'all_achievements_unlocked': serializer.toJson<bool>(
        allAchievementsUnlocked,
      ),
      'has_dlc': serializer.toJson<bool>(hasDlc),
      'is_collection': serializer.toJson<bool>(isCollection),
      'rating_story': serializer.toJson<double?>(ratingStory),
      'rating_gameplay': serializer.toJson<double?>(ratingGameplay),
      'rating_graphics': serializer.toJson<double?>(ratingGraphics),
      'rating_soundtrack': serializer.toJson<double?>(ratingSoundtrack),
      'overall_rating': serializer.toJson<double?>(overallRating),
      'cover_path': serializer.toJson<String?>(coverPath),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
      'players': serializer.toJson<int?>(players),
    };
  }

  Game copyWith({
    int? id,
    String? title,
    String? titleNorm,
    String? sortTitle,
    Value<int?> seriesId = const Value.absent(),
    Value<int?> developerId = const Value.absent(),
    Value<int?> publisherId = const Value.absent(),
    Value<int?> releaseYear = const Value.absent(),
    String? status,
    bool? isReplayable,
    bool? hasPostGame,
    bool? hasAchievements,
    bool? allAchievementsUnlocked,
    bool? hasDlc,
    bool? isCollection,
    Value<double?> ratingStory = const Value.absent(),
    Value<double?> ratingGameplay = const Value.absent(),
    Value<double?> ratingGraphics = const Value.absent(),
    Value<double?> ratingSoundtrack = const Value.absent(),
    Value<double?> overallRating = const Value.absent(),
    Value<String?> coverPath = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<int?> players = const Value.absent(),
  }) => Game(
    id: id ?? this.id,
    title: title ?? this.title,
    titleNorm: titleNorm ?? this.titleNorm,
    sortTitle: sortTitle ?? this.sortTitle,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
    developerId: developerId.present ? developerId.value : this.developerId,
    publisherId: publisherId.present ? publisherId.value : this.publisherId,
    releaseYear: releaseYear.present ? releaseYear.value : this.releaseYear,
    status: status ?? this.status,
    isReplayable: isReplayable ?? this.isReplayable,
    hasPostGame: hasPostGame ?? this.hasPostGame,
    hasAchievements: hasAchievements ?? this.hasAchievements,
    allAchievementsUnlocked:
        allAchievementsUnlocked ?? this.allAchievementsUnlocked,
    hasDlc: hasDlc ?? this.hasDlc,
    isCollection: isCollection ?? this.isCollection,
    ratingStory: ratingStory.present ? ratingStory.value : this.ratingStory,
    ratingGameplay: ratingGameplay.present
        ? ratingGameplay.value
        : this.ratingGameplay,
    ratingGraphics: ratingGraphics.present
        ? ratingGraphics.value
        : this.ratingGraphics,
    ratingSoundtrack: ratingSoundtrack.present
        ? ratingSoundtrack.value
        : this.ratingSoundtrack,
    overallRating: overallRating.present
        ? overallRating.value
        : this.overallRating,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    players: players.present ? players.value : this.players,
  );
  @override
  String toString() {
    return (StringBuffer('Game(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('titleNorm: $titleNorm, ')
          ..write('sortTitle: $sortTitle, ')
          ..write('seriesId: $seriesId, ')
          ..write('developerId: $developerId, ')
          ..write('publisherId: $publisherId, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('status: $status, ')
          ..write('isReplayable: $isReplayable, ')
          ..write('hasPostGame: $hasPostGame, ')
          ..write('hasAchievements: $hasAchievements, ')
          ..write('allAchievementsUnlocked: $allAchievementsUnlocked, ')
          ..write('hasDlc: $hasDlc, ')
          ..write('isCollection: $isCollection, ')
          ..write('ratingStory: $ratingStory, ')
          ..write('ratingGameplay: $ratingGameplay, ')
          ..write('ratingGraphics: $ratingGraphics, ')
          ..write('ratingSoundtrack: $ratingSoundtrack, ')
          ..write('overallRating: $overallRating, ')
          ..write('coverPath: $coverPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('players: $players')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    titleNorm,
    sortTitle,
    seriesId,
    developerId,
    publisherId,
    releaseYear,
    status,
    isReplayable,
    hasPostGame,
    hasAchievements,
    allAchievementsUnlocked,
    hasDlc,
    isCollection,
    ratingStory,
    ratingGameplay,
    ratingGraphics,
    ratingSoundtrack,
    overallRating,
    coverPath,
    createdAt,
    updatedAt,
    players,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Game &&
          other.id == this.id &&
          other.title == this.title &&
          other.titleNorm == this.titleNorm &&
          other.sortTitle == this.sortTitle &&
          other.seriesId == this.seriesId &&
          other.developerId == this.developerId &&
          other.publisherId == this.publisherId &&
          other.releaseYear == this.releaseYear &&
          other.status == this.status &&
          other.isReplayable == this.isReplayable &&
          other.hasPostGame == this.hasPostGame &&
          other.hasAchievements == this.hasAchievements &&
          other.allAchievementsUnlocked == this.allAchievementsUnlocked &&
          other.hasDlc == this.hasDlc &&
          other.isCollection == this.isCollection &&
          other.ratingStory == this.ratingStory &&
          other.ratingGameplay == this.ratingGameplay &&
          other.ratingGraphics == this.ratingGraphics &&
          other.ratingSoundtrack == this.ratingSoundtrack &&
          other.overallRating == this.overallRating &&
          other.coverPath == this.coverPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.players == this.players);
}

class GamesCompanion extends UpdateCompanion<Game> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> titleNorm;
  final Value<String> sortTitle;
  final Value<int?> seriesId;
  final Value<int?> developerId;
  final Value<int?> publisherId;
  final Value<int?> releaseYear;
  final Value<String> status;
  final Value<bool> isReplayable;
  final Value<bool> hasPostGame;
  final Value<bool> hasAchievements;
  final Value<bool> allAchievementsUnlocked;
  final Value<bool> hasDlc;
  final Value<bool> isCollection;
  final Value<double?> ratingStory;
  final Value<double?> ratingGameplay;
  final Value<double?> ratingGraphics;
  final Value<double?> ratingSoundtrack;
  final Value<String?> coverPath;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int?> players;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.titleNorm = const Value.absent(),
    this.sortTitle = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.developerId = const Value.absent(),
    this.publisherId = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.status = const Value.absent(),
    this.isReplayable = const Value.absent(),
    this.hasPostGame = const Value.absent(),
    this.hasAchievements = const Value.absent(),
    this.allAchievementsUnlocked = const Value.absent(),
    this.hasDlc = const Value.absent(),
    this.isCollection = const Value.absent(),
    this.ratingStory = const Value.absent(),
    this.ratingGameplay = const Value.absent(),
    this.ratingGraphics = const Value.absent(),
    this.ratingSoundtrack = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.players = const Value.absent(),
  });
  GamesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String titleNorm,
    required String sortTitle,
    this.seriesId = const Value.absent(),
    this.developerId = const Value.absent(),
    this.publisherId = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.status = const Value.absent(),
    this.isReplayable = const Value.absent(),
    this.hasPostGame = const Value.absent(),
    this.hasAchievements = const Value.absent(),
    this.allAchievementsUnlocked = const Value.absent(),
    this.hasDlc = const Value.absent(),
    this.isCollection = const Value.absent(),
    this.ratingStory = const Value.absent(),
    this.ratingGameplay = const Value.absent(),
    this.ratingGraphics = const Value.absent(),
    this.ratingSoundtrack = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.players = const Value.absent(),
  }) : title = Value(title),
       titleNorm = Value(titleNorm),
       sortTitle = Value(sortTitle);
  static Insertable<Game> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? titleNorm,
    Expression<String>? sortTitle,
    Expression<int>? seriesId,
    Expression<int>? developerId,
    Expression<int>? publisherId,
    Expression<int>? releaseYear,
    Expression<String>? status,
    Expression<bool>? isReplayable,
    Expression<bool>? hasPostGame,
    Expression<bool>? hasAchievements,
    Expression<bool>? allAchievementsUnlocked,
    Expression<bool>? hasDlc,
    Expression<bool>? isCollection,
    Expression<double>? ratingStory,
    Expression<double>? ratingGameplay,
    Expression<double>? ratingGraphics,
    Expression<double>? ratingSoundtrack,
    Expression<String>? coverPath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? players,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (titleNorm != null) 'title_norm': titleNorm,
      if (sortTitle != null) 'sort_title': sortTitle,
      if (seriesId != null) 'series_id': seriesId,
      if (developerId != null) 'developer_id': developerId,
      if (publisherId != null) 'publisher_id': publisherId,
      if (releaseYear != null) 'release_year': releaseYear,
      if (status != null) 'status': status,
      if (isReplayable != null) 'is_replayable': isReplayable,
      if (hasPostGame != null) 'has_post_game': hasPostGame,
      if (hasAchievements != null) 'has_achievements': hasAchievements,
      if (allAchievementsUnlocked != null)
        'all_achievements_unlocked': allAchievementsUnlocked,
      if (hasDlc != null) 'has_dlc': hasDlc,
      if (isCollection != null) 'is_collection': isCollection,
      if (ratingStory != null) 'rating_story': ratingStory,
      if (ratingGameplay != null) 'rating_gameplay': ratingGameplay,
      if (ratingGraphics != null) 'rating_graphics': ratingGraphics,
      if (ratingSoundtrack != null) 'rating_soundtrack': ratingSoundtrack,
      if (coverPath != null) 'cover_path': coverPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (players != null) 'players': players,
    });
  }

  GamesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? titleNorm,
    Value<String>? sortTitle,
    Value<int?>? seriesId,
    Value<int?>? developerId,
    Value<int?>? publisherId,
    Value<int?>? releaseYear,
    Value<String>? status,
    Value<bool>? isReplayable,
    Value<bool>? hasPostGame,
    Value<bool>? hasAchievements,
    Value<bool>? allAchievementsUnlocked,
    Value<bool>? hasDlc,
    Value<bool>? isCollection,
    Value<double?>? ratingStory,
    Value<double?>? ratingGameplay,
    Value<double?>? ratingGraphics,
    Value<double?>? ratingSoundtrack,
    Value<String?>? coverPath,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int?>? players,
  }) {
    return GamesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      titleNorm: titleNorm ?? this.titleNorm,
      sortTitle: sortTitle ?? this.sortTitle,
      seriesId: seriesId ?? this.seriesId,
      developerId: developerId ?? this.developerId,
      publisherId: publisherId ?? this.publisherId,
      releaseYear: releaseYear ?? this.releaseYear,
      status: status ?? this.status,
      isReplayable: isReplayable ?? this.isReplayable,
      hasPostGame: hasPostGame ?? this.hasPostGame,
      hasAchievements: hasAchievements ?? this.hasAchievements,
      allAchievementsUnlocked:
          allAchievementsUnlocked ?? this.allAchievementsUnlocked,
      hasDlc: hasDlc ?? this.hasDlc,
      isCollection: isCollection ?? this.isCollection,
      ratingStory: ratingStory ?? this.ratingStory,
      ratingGameplay: ratingGameplay ?? this.ratingGameplay,
      ratingGraphics: ratingGraphics ?? this.ratingGraphics,
      ratingSoundtrack: ratingSoundtrack ?? this.ratingSoundtrack,
      coverPath: coverPath ?? this.coverPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      players: players ?? this.players,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (titleNorm.present) {
      map['title_norm'] = Variable<String>(titleNorm.value);
    }
    if (sortTitle.present) {
      map['sort_title'] = Variable<String>(sortTitle.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<int>(seriesId.value);
    }
    if (developerId.present) {
      map['developer_id'] = Variable<int>(developerId.value);
    }
    if (publisherId.present) {
      map['publisher_id'] = Variable<int>(publisherId.value);
    }
    if (releaseYear.present) {
      map['release_year'] = Variable<int>(releaseYear.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isReplayable.present) {
      map['is_replayable'] = Variable<bool>(isReplayable.value);
    }
    if (hasPostGame.present) {
      map['has_post_game'] = Variable<bool>(hasPostGame.value);
    }
    if (hasAchievements.present) {
      map['has_achievements'] = Variable<bool>(hasAchievements.value);
    }
    if (allAchievementsUnlocked.present) {
      map['all_achievements_unlocked'] = Variable<bool>(
        allAchievementsUnlocked.value,
      );
    }
    if (hasDlc.present) {
      map['has_dlc'] = Variable<bool>(hasDlc.value);
    }
    if (isCollection.present) {
      map['is_collection'] = Variable<bool>(isCollection.value);
    }
    if (ratingStory.present) {
      map['rating_story'] = Variable<double>(ratingStory.value);
    }
    if (ratingGameplay.present) {
      map['rating_gameplay'] = Variable<double>(ratingGameplay.value);
    }
    if (ratingGraphics.present) {
      map['rating_graphics'] = Variable<double>(ratingGraphics.value);
    }
    if (ratingSoundtrack.present) {
      map['rating_soundtrack'] = Variable<double>(ratingSoundtrack.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (players.present) {
      map['players'] = Variable<int>(players.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('titleNorm: $titleNorm, ')
          ..write('sortTitle: $sortTitle, ')
          ..write('seriesId: $seriesId, ')
          ..write('developerId: $developerId, ')
          ..write('publisherId: $publisherId, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('status: $status, ')
          ..write('isReplayable: $isReplayable, ')
          ..write('hasPostGame: $hasPostGame, ')
          ..write('hasAchievements: $hasAchievements, ')
          ..write('allAchievementsUnlocked: $allAchievementsUnlocked, ')
          ..write('hasDlc: $hasDlc, ')
          ..write('isCollection: $isCollection, ')
          ..write('ratingStory: $ratingStory, ')
          ..write('ratingGameplay: $ratingGameplay, ')
          ..write('ratingGraphics: $ratingGraphics, ')
          ..write('ratingSoundtrack: $ratingSoundtrack, ')
          ..write('coverPath: $coverPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('players: $players')
          ..write(')'))
        .toString();
  }
}

class GameCopies extends Table with TableInfo<GameCopies, GameCopy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  GameCopies(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES games(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _consoleIdMeta = const VerificationMeta(
    'consoleId',
  );
  late final GeneratedColumn<int> consoleId = GeneratedColumn<int>(
    'console_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES consoles(id)',
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (format IN (\'fisico\', \'digitale\'))',
  );
  @override
  List<GeneratedColumn> get $columns => [id, gameId, consoleId, format];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_copies';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameCopy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('console_id')) {
      context.handle(
        _consoleIdMeta,
        consoleId.isAcceptableOrUnknown(data['console_id']!, _consoleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_consoleIdMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {gameId, consoleId, format},
  ];
  @override
  GameCopy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameCopy(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      consoleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}console_id'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
    );
  }

  @override
  GameCopies createAlias(String alias) {
    return GameCopies(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'UNIQUE(game_id, console_id, format)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class GameCopy extends DataClass implements Insertable<GameCopy> {
  final int id;
  final int gameId;
  final int consoleId;
  final String format;
  const GameCopy({
    required this.id,
    required this.gameId,
    required this.consoleId,
    required this.format,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_id'] = Variable<int>(gameId);
    map['console_id'] = Variable<int>(consoleId);
    map['format'] = Variable<String>(format);
    return map;
  }

  GameCopiesCompanion toCompanion(bool nullToAbsent) {
    return GameCopiesCompanion(
      id: Value(id),
      gameId: Value(gameId),
      consoleId: Value(consoleId),
      format: Value(format),
    );
  }

  factory GameCopy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameCopy(
      id: serializer.fromJson<int>(json['id']),
      gameId: serializer.fromJson<int>(json['game_id']),
      consoleId: serializer.fromJson<int>(json['console_id']),
      format: serializer.fromJson<String>(json['format']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'game_id': serializer.toJson<int>(gameId),
      'console_id': serializer.toJson<int>(consoleId),
      'format': serializer.toJson<String>(format),
    };
  }

  GameCopy copyWith({int? id, int? gameId, int? consoleId, String? format}) =>
      GameCopy(
        id: id ?? this.id,
        gameId: gameId ?? this.gameId,
        consoleId: consoleId ?? this.consoleId,
        format: format ?? this.format,
      );
  GameCopy copyWithCompanion(GameCopiesCompanion data) {
    return GameCopy(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      consoleId: data.consoleId.present ? data.consoleId.value : this.consoleId,
      format: data.format.present ? data.format.value : this.format,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameCopy(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('consoleId: $consoleId, ')
          ..write('format: $format')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, gameId, consoleId, format);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameCopy &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.consoleId == this.consoleId &&
          other.format == this.format);
}

class GameCopiesCompanion extends UpdateCompanion<GameCopy> {
  final Value<int> id;
  final Value<int> gameId;
  final Value<int> consoleId;
  final Value<String> format;
  const GameCopiesCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.consoleId = const Value.absent(),
    this.format = const Value.absent(),
  });
  GameCopiesCompanion.insert({
    this.id = const Value.absent(),
    required int gameId,
    required int consoleId,
    required String format,
  }) : gameId = Value(gameId),
       consoleId = Value(consoleId),
       format = Value(format);
  static Insertable<GameCopy> custom({
    Expression<int>? id,
    Expression<int>? gameId,
    Expression<int>? consoleId,
    Expression<String>? format,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (consoleId != null) 'console_id': consoleId,
      if (format != null) 'format': format,
    });
  }

  GameCopiesCompanion copyWith({
    Value<int>? id,
    Value<int>? gameId,
    Value<int>? consoleId,
    Value<String>? format,
  }) {
    return GameCopiesCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      consoleId: consoleId ?? this.consoleId,
      format: format ?? this.format,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (consoleId.present) {
      map['console_id'] = Variable<int>(consoleId.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameCopiesCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('consoleId: $consoleId, ')
          ..write('format: $format')
          ..write(')'))
        .toString();
  }
}

class CollectionItems extends Table
    with TableInfo<CollectionItems, CollectionItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CollectionItems(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES games(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES games(id)ON DELETE CASCADE',
  );
  @override
  List<GeneratedColumn> get $columns => [collectionId, gameId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collectionId, gameId};
  @override
  CollectionItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionItem(
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collection_id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
    );
  }

  @override
  CollectionItems createAlias(String alias) {
    return CollectionItems(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(collection_id, game_id)',
    'CHECK(collection_id <> game_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class CollectionItem extends DataClass implements Insertable<CollectionItem> {
  final int collectionId;
  final int gameId;
  const CollectionItem({required this.collectionId, required this.gameId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collection_id'] = Variable<int>(collectionId);
    map['game_id'] = Variable<int>(gameId);
    return map;
  }

  CollectionItemsCompanion toCompanion(bool nullToAbsent) {
    return CollectionItemsCompanion(
      collectionId: Value(collectionId),
      gameId: Value(gameId),
    );
  }

  factory CollectionItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionItem(
      collectionId: serializer.fromJson<int>(json['collection_id']),
      gameId: serializer.fromJson<int>(json['game_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collection_id': serializer.toJson<int>(collectionId),
      'game_id': serializer.toJson<int>(gameId),
    };
  }

  CollectionItem copyWith({int? collectionId, int? gameId}) => CollectionItem(
    collectionId: collectionId ?? this.collectionId,
    gameId: gameId ?? this.gameId,
  );
  CollectionItem copyWithCompanion(CollectionItemsCompanion data) {
    return CollectionItem(
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionItem(')
          ..write('collectionId: $collectionId, ')
          ..write('gameId: $gameId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(collectionId, gameId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionItem &&
          other.collectionId == this.collectionId &&
          other.gameId == this.gameId);
}

class CollectionItemsCompanion extends UpdateCompanion<CollectionItem> {
  final Value<int> collectionId;
  final Value<int> gameId;
  final Value<int> rowid;
  const CollectionItemsCompanion({
    this.collectionId = const Value.absent(),
    this.gameId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionItemsCompanion.insert({
    required int collectionId,
    required int gameId,
    this.rowid = const Value.absent(),
  }) : collectionId = Value(collectionId),
       gameId = Value(gameId);
  static Insertable<CollectionItem> custom({
    Expression<int>? collectionId,
    Expression<int>? gameId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collectionId != null) 'collection_id': collectionId,
      if (gameId != null) 'game_id': gameId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionItemsCompanion copyWith({
    Value<int>? collectionId,
    Value<int>? gameId,
    Value<int>? rowid,
  }) {
    return CollectionItemsCompanion(
      collectionId: collectionId ?? this.collectionId,
      gameId: gameId ?? this.gameId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionItemsCompanion(')
          ..write('collectionId: $collectionId, ')
          ..write('gameId: $gameId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class GamePlatforms extends Table with TableInfo<GamePlatforms, GamePlatform> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  GamePlatforms(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES games(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _consoleIdMeta = const VerificationMeta(
    'consoleId',
  );
  late final GeneratedColumn<int> consoleId = GeneratedColumn<int>(
    'console_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES consoles(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, consoleId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_platforms';
  @override
  VerificationContext validateIntegrity(
    Insertable<GamePlatform> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('console_id')) {
      context.handle(
        _consoleIdMeta,
        consoleId.isAcceptableOrUnknown(data['console_id']!, _consoleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_consoleIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, consoleId};
  @override
  GamePlatform map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GamePlatform(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      consoleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}console_id'],
      )!,
    );
  }

  @override
  GamePlatforms createAlias(String alias) {
    return GamePlatforms(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(game_id, console_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class GamePlatform extends DataClass implements Insertable<GamePlatform> {
  final int gameId;
  final int consoleId;
  const GamePlatform({required this.gameId, required this.consoleId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<int>(gameId);
    map['console_id'] = Variable<int>(consoleId);
    return map;
  }

  GamePlatformsCompanion toCompanion(bool nullToAbsent) {
    return GamePlatformsCompanion(
      gameId: Value(gameId),
      consoleId: Value(consoleId),
    );
  }

  factory GamePlatform.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GamePlatform(
      gameId: serializer.fromJson<int>(json['game_id']),
      consoleId: serializer.fromJson<int>(json['console_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'game_id': serializer.toJson<int>(gameId),
      'console_id': serializer.toJson<int>(consoleId),
    };
  }

  GamePlatform copyWith({int? gameId, int? consoleId}) => GamePlatform(
    gameId: gameId ?? this.gameId,
    consoleId: consoleId ?? this.consoleId,
  );
  GamePlatform copyWithCompanion(GamePlatformsCompanion data) {
    return GamePlatform(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      consoleId: data.consoleId.present ? data.consoleId.value : this.consoleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GamePlatform(')
          ..write('gameId: $gameId, ')
          ..write('consoleId: $consoleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, consoleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GamePlatform &&
          other.gameId == this.gameId &&
          other.consoleId == this.consoleId);
}

class GamePlatformsCompanion extends UpdateCompanion<GamePlatform> {
  final Value<int> gameId;
  final Value<int> consoleId;
  final Value<int> rowid;
  const GamePlatformsCompanion({
    this.gameId = const Value.absent(),
    this.consoleId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GamePlatformsCompanion.insert({
    required int gameId,
    required int consoleId,
    this.rowid = const Value.absent(),
  }) : gameId = Value(gameId),
       consoleId = Value(consoleId);
  static Insertable<GamePlatform> custom({
    Expression<int>? gameId,
    Expression<int>? consoleId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (consoleId != null) 'console_id': consoleId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GamePlatformsCompanion copyWith({
    Value<int>? gameId,
    Value<int>? consoleId,
    Value<int>? rowid,
  }) {
    return GamePlatformsCompanion(
      gameId: gameId ?? this.gameId,
      consoleId: consoleId ?? this.consoleId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (consoleId.present) {
      map['console_id'] = Variable<int>(consoleId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamePlatformsCompanion(')
          ..write('gameId: $gameId, ')
          ..write('consoleId: $consoleId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class GameGenres extends Table with TableInfo<GameGenres, GameGenre> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  GameGenres(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES games(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _genreIdMeta = const VerificationMeta(
    'genreId',
  );
  late final GeneratedColumn<int> genreId = GeneratedColumn<int>(
    'genre_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES genres(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, genreId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_genres';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameGenre> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('genre_id')) {
      context.handle(
        _genreIdMeta,
        genreId.isAcceptableOrUnknown(data['genre_id']!, _genreIdMeta),
      );
    } else if (isInserting) {
      context.missing(_genreIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, genreId};
  @override
  GameGenre map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameGenre(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      genreId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}genre_id'],
      )!,
    );
  }

  @override
  GameGenres createAlias(String alias) {
    return GameGenres(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(game_id, genre_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class GameGenre extends DataClass implements Insertable<GameGenre> {
  final int gameId;
  final int genreId;
  const GameGenre({required this.gameId, required this.genreId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<int>(gameId);
    map['genre_id'] = Variable<int>(genreId);
    return map;
  }

  GameGenresCompanion toCompanion(bool nullToAbsent) {
    return GameGenresCompanion(gameId: Value(gameId), genreId: Value(genreId));
  }

  factory GameGenre.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameGenre(
      gameId: serializer.fromJson<int>(json['game_id']),
      genreId: serializer.fromJson<int>(json['genre_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'game_id': serializer.toJson<int>(gameId),
      'genre_id': serializer.toJson<int>(genreId),
    };
  }

  GameGenre copyWith({int? gameId, int? genreId}) => GameGenre(
    gameId: gameId ?? this.gameId,
    genreId: genreId ?? this.genreId,
  );
  GameGenre copyWithCompanion(GameGenresCompanion data) {
    return GameGenre(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      genreId: data.genreId.present ? data.genreId.value : this.genreId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameGenre(')
          ..write('gameId: $gameId, ')
          ..write('genreId: $genreId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, genreId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameGenre &&
          other.gameId == this.gameId &&
          other.genreId == this.genreId);
}

class GameGenresCompanion extends UpdateCompanion<GameGenre> {
  final Value<int> gameId;
  final Value<int> genreId;
  final Value<int> rowid;
  const GameGenresCompanion({
    this.gameId = const Value.absent(),
    this.genreId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameGenresCompanion.insert({
    required int gameId,
    required int genreId,
    this.rowid = const Value.absent(),
  }) : gameId = Value(gameId),
       genreId = Value(genreId);
  static Insertable<GameGenre> custom({
    Expression<int>? gameId,
    Expression<int>? genreId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (genreId != null) 'genre_id': genreId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameGenresCompanion copyWith({
    Value<int>? gameId,
    Value<int>? genreId,
    Value<int>? rowid,
  }) {
    return GameGenresCompanion(
      gameId: gameId ?? this.gameId,
      genreId: genreId ?? this.genreId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (genreId.present) {
      map['genre_id'] = Variable<int>(genreId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameGenresCompanion(')
          ..write('gameId: $gameId, ')
          ..write('genreId: $genreId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Settings extends Table with TableInfo<Settings, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Settings(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [name, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  Settings createAlias(String alias) {
    return Settings(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Setting extends DataClass implements Insertable<Setting> {
  final String name;
  final String value;
  const Setting({required this.name, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(name: Value(name), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? name, String? value}) =>
      Setting(name: name ?? this.name, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      name: data.name.present ? data.name.value : this.name,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.name == this.name &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> name;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.name = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String name,
    required String value,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? name,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? name,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      name: name ?? this.name,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class EffectiveCopy extends DataClass {
  final int gameId;
  final int consoleId;
  final String format;
  const EffectiveCopy({
    required this.gameId,
    required this.consoleId,
    required this.format,
  });
  factory EffectiveCopy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EffectiveCopy(
      gameId: serializer.fromJson<int>(json['game_id']),
      consoleId: serializer.fromJson<int>(json['console_id']),
      format: serializer.fromJson<String>(json['format']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'game_id': serializer.toJson<int>(gameId),
      'console_id': serializer.toJson<int>(consoleId),
      'format': serializer.toJson<String>(format),
    };
  }

  EffectiveCopy copyWith({int? gameId, int? consoleId, String? format}) =>
      EffectiveCopy(
        gameId: gameId ?? this.gameId,
        consoleId: consoleId ?? this.consoleId,
        format: format ?? this.format,
      );
  @override
  String toString() {
    return (StringBuffer('EffectiveCopy(')
          ..write('gameId: $gameId, ')
          ..write('consoleId: $consoleId, ')
          ..write('format: $format')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, consoleId, format);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EffectiveCopy &&
          other.gameId == this.gameId &&
          other.consoleId == this.consoleId &&
          other.format == this.format);
}

class EffectiveCopies extends ViewInfo<EffectiveCopies, EffectiveCopy>
    implements HasResultSet {
  final String? _alias;
  @override
  final _$AppDatabase attachedDatabase;
  EffectiveCopies(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [gameId, consoleId, format];
  @override
  String get aliasedName => _alias ?? entityName;
  @override
  String get entityName => 'effective_copies';
  @override
  Map<SqlDialect, String> get createViewStatements => {
    SqlDialect.sqlite: 'CREATE VIEW effective_copies AS SELECT c.game_id AS game_id, c.console_id AS console_id, c.format AS format FROM game_copies AS c UNION SELECT ci.game_id AS game_id, c.console_id AS console_id, c.format AS format FROM collection_items AS ci JOIN game_copies AS c ON c.game_id = ci.collection_id',
  };
  @override
  EffectiveCopies get asDslTable => this;
  @override
  EffectiveCopy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EffectiveCopy(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      consoleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}console_id'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
    );
  }

  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
  );
  late final GeneratedColumn<int> consoleId = GeneratedColumn<int>(
    'console_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
  );
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
  );
  @override
  EffectiveCopies createAlias(String alias) {
    return EffectiveCopies(attachedDatabase, alias);
  }

  @override
  Query? get query => null;
  @override
  Set<String> get readTables => const {
    'game_copies',
    'collection_items',
    'games',
    'series',
    'companies',
    'consoles',
  };
}

class GameConsole extends DataClass {
  final int gameId;
  final int consoleId;
  final String? format;
  const GameConsole({
    required this.gameId,
    required this.consoleId,
    this.format,
  });
  factory GameConsole.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameConsole(
      gameId: serializer.fromJson<int>(json['game_id']),
      consoleId: serializer.fromJson<int>(json['console_id']),
      format: serializer.fromJson<String?>(json['format']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'game_id': serializer.toJson<int>(gameId),
      'console_id': serializer.toJson<int>(consoleId),
      'format': serializer.toJson<String?>(format),
    };
  }

  GameConsole copyWith({
    int? gameId,
    int? consoleId,
    Value<String?> format = const Value.absent(),
  }) => GameConsole(
    gameId: gameId ?? this.gameId,
    consoleId: consoleId ?? this.consoleId,
    format: format.present ? format.value : this.format,
  );
  @override
  String toString() {
    return (StringBuffer('GameConsole(')
          ..write('gameId: $gameId, ')
          ..write('consoleId: $consoleId, ')
          ..write('format: $format')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, consoleId, format);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameConsole &&
          other.gameId == this.gameId &&
          other.consoleId == this.consoleId &&
          other.format == this.format);
}

class GameConsoles extends ViewInfo<GameConsoles, GameConsole>
    implements HasResultSet {
  final String? _alias;
  @override
  final _$AppDatabase attachedDatabase;
  GameConsoles(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [gameId, consoleId, format];
  @override
  String get aliasedName => _alias ?? entityName;
  @override
  String get entityName => 'game_consoles';
  @override
  Map<SqlDialect, String> get createViewStatements => {
    SqlDialect.sqlite: 'CREATE VIEW game_consoles AS SELECT game_id, console_id, format FROM effective_copies UNION ALL SELECT game_id, console_id, NULL AS format FROM game_platforms',
  };
  @override
  GameConsoles get asDslTable => this;
  @override
  GameConsole map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameConsole(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      consoleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}console_id'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      ),
    );
  }

  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
  );
  late final GeneratedColumn<int> consoleId = GeneratedColumn<int>(
    'console_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
  );
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    true,
    type: DriftSqlType.string,
  );
  @override
  GameConsoles createAlias(String alias) {
    return GameConsoles(attachedDatabase, alias);
  }

  @override
  Query? get query => null;
  @override
  Set<String> get readTables => const {
    'game_platforms',
    'games',
    'consoles',
    'series',
    'companies',
    'game_copies',
    'collection_items',
  };
}

class StatGame extends DataClass {
  final int gameId;
  const StatGame({required this.gameId});
  factory StatGame.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatGame(gameId: serializer.fromJson<int>(json['game_id']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'game_id': serializer.toJson<int>(gameId)};
  }

  StatGame copyWith({int? gameId}) => StatGame(gameId: gameId ?? this.gameId);
  @override
  String toString() {
    return (StringBuffer('StatGame(')
          ..write('gameId: $gameId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => gameId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatGame && other.gameId == this.gameId);
}

class StatGames extends ViewInfo<StatGames, StatGame> implements HasResultSet {
  final String? _alias;
  @override
  final _$AppDatabase attachedDatabase;
  StatGames(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [gameId];
  @override
  String get aliasedName => _alias ?? entityName;
  @override
  String get entityName => 'stat_games';
  @override
  Map<SqlDialect, String> get createViewStatements => {
    SqlDialect.sqlite: 'CREATE VIEW stat_games AS SELECT g.id AS game_id FROM games AS g WHERE g.is_collection = 0 OR NOT EXISTS (SELECT 1 FROM collection_items AS ci WHERE ci.collection_id = g.id)',
  };
  @override
  StatGames get asDslTable => this;
  @override
  StatGame map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatGame(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
    );
  }

  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
  );
  @override
  StatGames createAlias(String alias) {
    return StatGames(attachedDatabase, alias);
  }

  @override
  Query? get query => null;
  @override
  Set<String> get readTables => const {
    'games',
    'collection_items',
    'series',
    'companies',
  };
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final Consoles consoles = Consoles(this);
  late final Genres genres = Genres(this);
  late final Series series = Series(this);
  late final Companies companies = Companies(this);
  late final Games games = Games(this);
  late final GameCopies gameCopies = GameCopies(this);
  late final CollectionItems collectionItems = CollectionItems(this);
  late final GamePlatforms gamePlatforms = GamePlatforms(this);
  late final GameGenres gameGenres = GameGenres(this);
  late final Settings settings = Settings(this);
  late final EffectiveCopies effectiveCopies = EffectiveCopies(this);
  late final GameConsoles gameConsoles = GameConsoles(this);
  late final StatGames statGames = StatGames(this);
  late final Index gamesSortTitle = Index(
    'games_sort_title',
    'CREATE INDEX games_sort_title ON games (sort_title)',
  );
  late final Index gamesTitleNorm = Index(
    'games_title_norm',
    'CREATE INDEX games_title_norm ON games (title_norm)',
  );
  late final Index gamesStatus = Index(
    'games_status',
    'CREATE INDEX games_status ON games (status)',
  );
  late final Index gamesReleaseYear = Index(
    'games_release_year',
    'CREATE INDEX games_release_year ON games (release_year)',
  );
  late final Index gamesOverallRating = Index(
    'games_overall_rating',
    'CREATE INDEX games_overall_rating ON games (overall_rating)',
  );
  late final Index gameCopiesConsoleId = Index(
    'game_copies_console_id',
    'CREATE INDEX game_copies_console_id ON game_copies (console_id)',
  );
  late final Index gamePlatformsConsoleId = Index(
    'game_platforms_console_id',
    'CREATE INDEX game_platforms_console_id ON game_platforms (console_id)',
  );
  late final Index gameGenresGenreId = Index(
    'game_genres_genre_id',
    'CREATE INDEX game_genres_genre_id ON game_genres (genre_id)',
  );
  late final Index collectionItemsGameId = Index(
    'collection_items_game_id',
    'CREATE INDEX collection_items_game_id ON collection_items (game_id)',
  );
  late final Trigger collectionMustBeCollectionInsert = Trigger(
    'CREATE TRIGGER collection_must_be_collection_insert BEFORE INSERT ON collection_items BEGIN SELECT RAISE (ABORT, \'Un gioco può essere contenuto solo in una collection\') WHERE COALESCE((SELECT is_collection FROM games WHERE id = NEW.collection_id), 0) <> 1;END',
    'collection_must_be_collection_insert',
  );
  late final Trigger collectionMustBeCollectionUpdate = Trigger(
    'CREATE TRIGGER collection_must_be_collection_update BEFORE UPDATE ON collection_items BEGIN SELECT RAISE (ABORT, \'Un gioco può essere contenuto solo in una collection\') WHERE COALESCE((SELECT is_collection FROM games WHERE id = NEW.collection_id), 0) <> 1;END',
    'collection_must_be_collection_update',
  );
  late final Trigger noNestedCollections = Trigger(
    'CREATE TRIGGER no_nested_collections BEFORE INSERT ON collection_items BEGIN SELECT RAISE (ABORT, \'Una collection non può essere contenuta in una collection\') WHERE COALESCE((SELECT is_collection FROM games WHERE id = NEW.game_id), 0) = 1;END',
    'no_nested_collections',
  );
  late final Trigger collectionWithItemsCannotBeDemoted = Trigger(
    'CREATE TRIGGER collection_with_items_cannot_be_demoted BEFORE UPDATE ON games BEGIN SELECT RAISE (ABORT, \'La collection contiene ancora dei giochi: scioglila prima\') WHERE OLD.is_collection = 1 AND NEW.is_collection = 0 AND EXISTS (SELECT 1 FROM collection_items AS ci WHERE ci.collection_id = OLD.id);END',
    'collection_with_items_cannot_be_demoted',
  );
  late final Trigger itemCannotBecomeCollection = Trigger(
    'CREATE TRIGGER item_cannot_become_collection BEFORE UPDATE ON games BEGIN SELECT RAISE (ABORT, \'Una collection non può essere contenuta in una collection\') WHERE OLD.is_collection = 0 AND NEW.is_collection = 1 AND EXISTS (SELECT 1 FROM collection_items AS ci WHERE ci.game_id = OLD.id);END',
    'item_cannot_become_collection',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    consoles,
    genres,
    series,
    companies,
    games,
    gameCopies,
    collectionItems,
    gamePlatforms,
    gameGenres,
    settings,
    effectiveCopies,
    gameConsoles,
    statGames,
    gamesSortTitle,
    gamesTitleNorm,
    gamesStatus,
    gamesReleaseYear,
    gamesOverallRating,
    gameCopiesConsoleId,
    gamePlatformsConsoleId,
    gameGenresGenreId,
    collectionItemsGameId,
    collectionMustBeCollectionInsert,
    collectionMustBeCollectionUpdate,
    noNestedCollections,
    collectionWithItemsCannotBeDemoted,
    itemCannotBecomeCollection,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'series',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('games', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('games', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('games', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('game_copies', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('collection_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('collection_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('game_platforms', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('game_genres', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'collection_items',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'collection_items',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'collection_items',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
  ]);
}

typedef $ConsolesCreateCompanionBuilder = ConsolesCompanion Function({
  Value<int> id,
  required String name,
  required String nameNorm,
  required String shortLabel,
  Value<String> family,
  Value<int> sortOrder,
});
typedef $ConsolesUpdateCompanionBuilder = ConsolesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> nameNorm,
  Value<String> shortLabel,
  Value<String> family,
  Value<int> sortOrder,
});

final class $ConsolesReferences
    extends BaseReferences<_$AppDatabase, Consoles, ConsoleRow> {
  $ConsolesReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<GameCopies, List<GameCopy>> _gameCopiesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.gameCopies,
    aliasName: 'consoles__id__game_copies__console_id',
  );

  $GameCopiesProcessedTableManager get gameCopiesRefs {
    final manager = $GameCopiesTableManager(
      $_db,
      $_db.gameCopies,
    ).filter((f) => f.consoleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameCopiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<GamePlatforms, List<GamePlatform>>
  _gamePlatformsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gamePlatforms,
    aliasName: 'consoles__id__game_platforms__console_id',
  );

  $GamePlatformsProcessedTableManager get gamePlatformsRefs {
    final manager = $GamePlatformsTableManager(
      $_db,
      $_db.gamePlatforms,
    ).filter((f) => f.consoleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gamePlatformsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ConsolesFilterComposer extends Composer<_$AppDatabase, Consoles> {
  $ConsolesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortLabel => $composableBuilder(
    column: $table.shortLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gameCopiesRefs(
    Expression<bool> Function($GameCopiesFilterComposer f) f,
  ) {
    final $GameCopiesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameCopies,
      getReferencedColumn: (t) => t.consoleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GameCopiesFilterComposer(
            $db: $db,
            $table: $db.gameCopies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gamePlatformsRefs(
    Expression<bool> Function($GamePlatformsFilterComposer f) f,
  ) {
    final $GamePlatformsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gamePlatforms,
      getReferencedColumn: (t) => t.consoleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamePlatformsFilterComposer(
            $db: $db,
            $table: $db.gamePlatforms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ConsolesOrderingComposer extends Composer<_$AppDatabase, Consoles> {
  $ConsolesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortLabel => $composableBuilder(
    column: $table.shortLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ConsolesAnnotationComposer extends Composer<_$AppDatabase, Consoles> {
  $ConsolesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameNorm =>
      $composableBuilder(column: $table.nameNorm, builder: (column) => column);

  GeneratedColumn<String> get shortLabel => $composableBuilder(
    column: $table.shortLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get family =>
      $composableBuilder(column: $table.family, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> gameCopiesRefs<T extends Object>(
    Expression<T> Function($GameCopiesAnnotationComposer a) f,
  ) {
    final $GameCopiesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameCopies,
      getReferencedColumn: (t) => t.consoleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GameCopiesAnnotationComposer(
            $db: $db,
            $table: $db.gameCopies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gamePlatformsRefs<T extends Object>(
    Expression<T> Function($GamePlatformsAnnotationComposer a) f,
  ) {
    final $GamePlatformsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gamePlatforms,
      getReferencedColumn: (t) => t.consoleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamePlatformsAnnotationComposer(
            $db: $db,
            $table: $db.gamePlatforms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ConsolesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Consoles,
          ConsoleRow,
          $ConsolesFilterComposer,
          $ConsolesOrderingComposer,
          $ConsolesAnnotationComposer,
          $ConsolesCreateCompanionBuilder,
          $ConsolesUpdateCompanionBuilder,
          (ConsoleRow, $ConsolesReferences),
          ConsoleRow,
          PrefetchHooks Function({bool gameCopiesRefs, bool gamePlatformsRefs})
        > {
  $ConsolesTableManager(_$AppDatabase db, Consoles table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ConsolesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ConsolesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ConsolesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameNorm = const Value.absent(),
                Value<String> shortLabel = const Value.absent(),
                Value<String> family = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => ConsolesCompanion(
                id: id,
                name: name,
                nameNorm: nameNorm,
                shortLabel: shortLabel,
                family: family,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String nameNorm,
                required String shortLabel,
                Value<String> family = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => ConsolesCompanion.insert(
                id: id,
                name: name,
                nameNorm: nameNorm,
                shortLabel: shortLabel,
                family: family,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Consoles, ConsoleRow>(table),
                  $ConsolesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({gameCopiesRefs = false, gamePlatformsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (gameCopiesRefs) db.gameCopies,
                    if (gamePlatformsRefs) db.gamePlatforms,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gameCopiesRefs)
                        await $_getPrefetchedData<
                          ConsoleRow,
                          Consoles,
                          GameCopy
                        >(
                          currentTable: table,
                          referencedTable: $ConsolesReferences
                              ._gameCopiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ConsolesReferences(db, table, p0).gameCopiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.consoleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (gamePlatformsRefs)
                        await $_getPrefetchedData<
                          ConsoleRow,
                          Consoles,
                          GamePlatform
                        >(
                          currentTable: table,
                          referencedTable: $ConsolesReferences
                              ._gamePlatformsRefsTable(db),
                          managerFromTypedResult: (p0) => $ConsolesReferences(
                            db,
                            table,
                            p0,
                          ).gamePlatformsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.consoleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $ConsolesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Consoles,
      ConsoleRow,
      $ConsolesFilterComposer,
      $ConsolesOrderingComposer,
      $ConsolesAnnotationComposer,
      $ConsolesCreateCompanionBuilder,
      $ConsolesUpdateCompanionBuilder,
      (ConsoleRow, $ConsolesReferences),
      ConsoleRow,
      PrefetchHooks Function({bool gameCopiesRefs, bool gamePlatformsRefs})
    >;
typedef $GenresCreateCompanionBuilder = GenresCompanion Function({
  Value<int> id,
  required String name,
  required String nameNorm,
});
typedef $GenresUpdateCompanionBuilder = GenresCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> nameNorm,
});

final class $GenresReferences
    extends BaseReferences<_$AppDatabase, Genres, Genre> {
  $GenresReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<GameGenres, List<GameGenre>> _gameGenresRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.gameGenres,
    aliasName: 'genres__id__game_genres__genre_id',
  );

  $GameGenresProcessedTableManager get gameGenresRefs {
    final manager = $GameGenresTableManager(
      $_db,
      $_db.gameGenres,
    ).filter((f) => f.genreId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameGenresRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $GenresFilterComposer extends Composer<_$AppDatabase, Genres> {
  $GenresFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gameGenresRefs(
    Expression<bool> Function($GameGenresFilterComposer f) f,
  ) {
    final $GameGenresFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameGenres,
      getReferencedColumn: (t) => t.genreId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GameGenresFilterComposer(
            $db: $db,
            $table: $db.gameGenres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $GenresOrderingComposer extends Composer<_$AppDatabase, Genres> {
  $GenresOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $GenresAnnotationComposer extends Composer<_$AppDatabase, Genres> {
  $GenresAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameNorm =>
      $composableBuilder(column: $table.nameNorm, builder: (column) => column);

  Expression<T> gameGenresRefs<T extends Object>(
    Expression<T> Function($GameGenresAnnotationComposer a) f,
  ) {
    final $GameGenresAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameGenres,
      getReferencedColumn: (t) => t.genreId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GameGenresAnnotationComposer(
            $db: $db,
            $table: $db.gameGenres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $GenresTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Genres,
          Genre,
          $GenresFilterComposer,
          $GenresOrderingComposer,
          $GenresAnnotationComposer,
          $GenresCreateCompanionBuilder,
          $GenresUpdateCompanionBuilder,
          (Genre, $GenresReferences),
          Genre,
          PrefetchHooks Function({bool gameGenresRefs})
        > {
  $GenresTableManager(_$AppDatabase db, Genres table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $GenresFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $GenresOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $GenresAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> nameNorm = const Value.absent(),
          }) => GenresCompanion(id: id, name: name, nameNorm: nameNorm),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String nameNorm,
          }) => GenresCompanion.insert(id: id, name: name, nameNorm: nameNorm),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Genres, Genre>(table),
                  $GenresReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameGenresRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (gameGenresRefs) db.gameGenres],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gameGenresRefs)
                    await $_getPrefetchedData<Genre, Genres, GameGenre>(
                      currentTable: table,
                      referencedTable: $GenresReferences._gameGenresRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $GenresReferences(db, table, p0).gameGenresRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.genreId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $GenresProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Genres,
      Genre,
      $GenresFilterComposer,
      $GenresOrderingComposer,
      $GenresAnnotationComposer,
      $GenresCreateCompanionBuilder,
      $GenresUpdateCompanionBuilder,
      (Genre, $GenresReferences),
      Genre,
      PrefetchHooks Function({bool gameGenresRefs})
    >;
typedef $SeriesCreateCompanionBuilder = SeriesCompanion Function({
  Value<int> id,
  required String name,
  required String nameNorm,
});
typedef $SeriesUpdateCompanionBuilder = SeriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> nameNorm,
});

final class $SeriesReferences
    extends BaseReferences<_$AppDatabase, Series, SeriesRow> {
  $SeriesReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Games, List<Game>> _gamesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.games,
    aliasName: 'series__id__games__series_id',
  );

  $GamesProcessedTableManager get gamesRefs {
    final manager = $GamesTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.seriesId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gamesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $SeriesFilterComposer extends Composer<_$AppDatabase, Series> {
  $SeriesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gamesRefs(
    Expression<bool> Function($GamesFilterComposer f) f,
  ) {
    final $GamesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamesFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SeriesOrderingComposer extends Composer<_$AppDatabase, Series> {
  $SeriesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SeriesAnnotationComposer extends Composer<_$AppDatabase, Series> {
  $SeriesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameNorm =>
      $composableBuilder(column: $table.nameNorm, builder: (column) => column);

  Expression<T> gamesRefs<T extends Object>(
    Expression<T> Function($GamesAnnotationComposer a) f,
  ) {
    final $GamesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamesAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SeriesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Series,
          SeriesRow,
          $SeriesFilterComposer,
          $SeriesOrderingComposer,
          $SeriesAnnotationComposer,
          $SeriesCreateCompanionBuilder,
          $SeriesUpdateCompanionBuilder,
          (SeriesRow, $SeriesReferences),
          SeriesRow,
          PrefetchHooks Function({bool gamesRefs})
        > {
  $SeriesTableManager(_$AppDatabase db, Series table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SeriesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SeriesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SeriesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> nameNorm = const Value.absent(),
          }) => SeriesCompanion(id: id, name: name, nameNorm: nameNorm),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String nameNorm,
          }) => SeriesCompanion.insert(id: id, name: name, nameNorm: nameNorm),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Series, SeriesRow>(table),
                  $SeriesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gamesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (gamesRefs) db.games],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gamesRefs)
                    await $_getPrefetchedData<SeriesRow, Series, Game>(
                      currentTable: table,
                      referencedTable: $SeriesReferences._gamesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $SeriesReferences(db, table, p0).gamesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.seriesId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $SeriesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Series,
      SeriesRow,
      $SeriesFilterComposer,
      $SeriesOrderingComposer,
      $SeriesAnnotationComposer,
      $SeriesCreateCompanionBuilder,
      $SeriesUpdateCompanionBuilder,
      (SeriesRow, $SeriesReferences),
      SeriesRow,
      PrefetchHooks Function({bool gamesRefs})
    >;
typedef $CompaniesCreateCompanionBuilder = CompaniesCompanion Function({
  Value<int> id,
  required String name,
  required String nameNorm,
});
typedef $CompaniesUpdateCompanionBuilder = CompaniesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> nameNorm,
});

class $CompaniesFilterComposer extends Composer<_$AppDatabase, Companies> {
  $CompaniesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
    builder: (column) => ColumnFilters(column),
  );
}

class $CompaniesOrderingComposer extends Composer<_$AppDatabase, Companies> {
  $CompaniesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $CompaniesAnnotationComposer extends Composer<_$AppDatabase, Companies> {
  $CompaniesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameNorm =>
      $composableBuilder(column: $table.nameNorm, builder: (column) => column);
}

class $CompaniesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Companies,
          Company,
          $CompaniesFilterComposer,
          $CompaniesOrderingComposer,
          $CompaniesAnnotationComposer,
          $CompaniesCreateCompanionBuilder,
          $CompaniesUpdateCompanionBuilder,
          (Company, BaseReferences<_$AppDatabase, Companies, Company>),
          Company,
          PrefetchHooks Function()
        > {
  $CompaniesTableManager(_$AppDatabase db, Companies table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CompaniesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CompaniesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CompaniesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> nameNorm = const Value.absent(),
          }) => CompaniesCompanion(id: id, name: name, nameNorm: nameNorm),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String nameNorm,
              }) => CompaniesCompanion.insert(
                id: id,
                name: name,
                nameNorm: nameNorm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Companies, Company>(table),
                  BaseReferences<_$AppDatabase, Companies, Company>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $CompaniesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Companies,
      Company,
      $CompaniesFilterComposer,
      $CompaniesOrderingComposer,
      $CompaniesAnnotationComposer,
      $CompaniesCreateCompanionBuilder,
      $CompaniesUpdateCompanionBuilder,
      (Company, BaseReferences<_$AppDatabase, Companies, Company>),
      Company,
      PrefetchHooks Function()
    >;
typedef $GamesCreateCompanionBuilder = GamesCompanion Function({
  Value<int> id,
  required String title,
  required String titleNorm,
  required String sortTitle,
  Value<int?> seriesId,
  Value<int?> developerId,
  Value<int?> publisherId,
  Value<int?> releaseYear,
  Value<String> status,
  Value<bool> isReplayable,
  Value<bool> hasPostGame,
  Value<bool> hasAchievements,
  Value<bool> allAchievementsUnlocked,
  Value<bool> hasDlc,
  Value<bool> isCollection,
  Value<double?> ratingStory,
  Value<double?> ratingGameplay,
  Value<double?> ratingGraphics,
  Value<double?> ratingSoundtrack,
  Value<String?> coverPath,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int?> players,
});
typedef $GamesUpdateCompanionBuilder = GamesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> titleNorm,
  Value<String> sortTitle,
  Value<int?> seriesId,
  Value<int?> developerId,
  Value<int?> publisherId,
  Value<int?> releaseYear,
  Value<String> status,
  Value<bool> isReplayable,
  Value<bool> hasPostGame,
  Value<bool> hasAchievements,
  Value<bool> allAchievementsUnlocked,
  Value<bool> hasDlc,
  Value<bool> isCollection,
  Value<double?> ratingStory,
  Value<double?> ratingGameplay,
  Value<double?> ratingGraphics,
  Value<double?> ratingSoundtrack,
  Value<String?> coverPath,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int?> players,
});

final class $GamesReferences
    extends BaseReferences<_$AppDatabase, Games, Game> {
  $GamesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Series _seriesIdTable(_$AppDatabase db) =>
      db.series.createAlias('games__series_id__series__id');

  $SeriesProcessedTableManager? get seriesId {
    final $_column = $_itemColumn<int>('series_id');
    if ($_column == null) return null;
    final manager = $SeriesTableManager(
      $_db,
      $_db.series,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Companies _developerIdTable(_$AppDatabase db) =>
      db.companies.createAlias('games__developer_id__companies__id');

  $CompaniesProcessedTableManager? get developerId {
    final $_column = $_itemColumn<int>('developer_id');
    if ($_column == null) return null;
    final manager = $CompaniesTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_developerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Companies _publisherIdTable(_$AppDatabase db) =>
      db.companies.createAlias('games__publisher_id__companies__id');

  $CompaniesProcessedTableManager? get publisherId {
    final $_column = $_itemColumn<int>('publisher_id');
    if ($_column == null) return null;
    final manager = $CompaniesTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_publisherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<GameCopies, List<GameCopy>> _gameCopiesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.gameCopies,
    aliasName: 'games__id__game_copies__game_id',
  );

  $GameCopiesProcessedTableManager get gameCopiesRefs {
    final manager = $GameCopiesTableManager(
      $_db,
      $_db.gameCopies,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameCopiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<GamePlatforms, List<GamePlatform>>
  _gamePlatformsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gamePlatforms,
    aliasName: 'games__id__game_platforms__game_id',
  );

  $GamePlatformsProcessedTableManager get gamePlatformsRefs {
    final manager = $GamePlatformsTableManager(
      $_db,
      $_db.gamePlatforms,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gamePlatformsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<GameGenres, List<GameGenre>> _gameGenresRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.gameGenres,
    aliasName: 'games__id__game_genres__game_id',
  );

  $GameGenresProcessedTableManager get gameGenresRefs {
    final manager = $GameGenresTableManager(
      $_db,
      $_db.gameGenres,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameGenresRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $GamesFilterComposer extends Composer<_$AppDatabase, Games> {
  $GamesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleNorm => $composableBuilder(
    column: $table.titleNorm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sortTitle => $composableBuilder(
    column: $table.sortTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isReplayable => $composableBuilder(
    column: $table.isReplayable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasPostGame => $composableBuilder(
    column: $table.hasPostGame,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasAchievements => $composableBuilder(
    column: $table.hasAchievements,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allAchievementsUnlocked => $composableBuilder(
    column: $table.allAchievementsUnlocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasDlc => $composableBuilder(
    column: $table.hasDlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCollection => $composableBuilder(
    column: $table.isCollection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ratingStory => $composableBuilder(
    column: $table.ratingStory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ratingGameplay => $composableBuilder(
    column: $table.ratingGameplay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ratingGraphics => $composableBuilder(
    column: $table.ratingGraphics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ratingSoundtrack => $composableBuilder(
    column: $table.ratingSoundtrack,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overallRating => $composableBuilder(
    column: $table.overallRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get players => $composableBuilder(
    column: $table.players,
    builder: (column) => ColumnFilters(column),
  );

  $SeriesFilterComposer get seriesId {
    final $SeriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.series,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SeriesFilterComposer(
            $db: $db,
            $table: $db.series,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CompaniesFilterComposer get developerId {
    final $CompaniesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.developerId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CompaniesFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CompaniesFilterComposer get publisherId {
    final $CompaniesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.publisherId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CompaniesFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> gameCopiesRefs(
    Expression<bool> Function($GameCopiesFilterComposer f) f,
  ) {
    final $GameCopiesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameCopies,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GameCopiesFilterComposer(
            $db: $db,
            $table: $db.gameCopies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gamePlatformsRefs(
    Expression<bool> Function($GamePlatformsFilterComposer f) f,
  ) {
    final $GamePlatformsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gamePlatforms,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamePlatformsFilterComposer(
            $db: $db,
            $table: $db.gamePlatforms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gameGenresRefs(
    Expression<bool> Function($GameGenresFilterComposer f) f,
  ) {
    final $GameGenresFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameGenres,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GameGenresFilterComposer(
            $db: $db,
            $table: $db.gameGenres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $GamesOrderingComposer extends Composer<_$AppDatabase, Games> {
  $GamesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleNorm => $composableBuilder(
    column: $table.titleNorm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sortTitle => $composableBuilder(
    column: $table.sortTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isReplayable => $composableBuilder(
    column: $table.isReplayable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasPostGame => $composableBuilder(
    column: $table.hasPostGame,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasAchievements => $composableBuilder(
    column: $table.hasAchievements,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allAchievementsUnlocked => $composableBuilder(
    column: $table.allAchievementsUnlocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasDlc => $composableBuilder(
    column: $table.hasDlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCollection => $composableBuilder(
    column: $table.isCollection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ratingStory => $composableBuilder(
    column: $table.ratingStory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ratingGameplay => $composableBuilder(
    column: $table.ratingGameplay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ratingGraphics => $composableBuilder(
    column: $table.ratingGraphics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ratingSoundtrack => $composableBuilder(
    column: $table.ratingSoundtrack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overallRating => $composableBuilder(
    column: $table.overallRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get players => $composableBuilder(
    column: $table.players,
    builder: (column) => ColumnOrderings(column),
  );

  $SeriesOrderingComposer get seriesId {
    final $SeriesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.series,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SeriesOrderingComposer(
            $db: $db,
            $table: $db.series,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CompaniesOrderingComposer get developerId {
    final $CompaniesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.developerId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CompaniesOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CompaniesOrderingComposer get publisherId {
    final $CompaniesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.publisherId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CompaniesOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $GamesAnnotationComposer extends Composer<_$AppDatabase, Games> {
  $GamesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get titleNorm =>
      $composableBuilder(column: $table.titleNorm, builder: (column) => column);

  GeneratedColumn<String> get sortTitle =>
      $composableBuilder(column: $table.sortTitle, builder: (column) => column);

  GeneratedColumn<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isReplayable => $composableBuilder(
    column: $table.isReplayable,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasPostGame => $composableBuilder(
    column: $table.hasPostGame,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasAchievements => $composableBuilder(
    column: $table.hasAchievements,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allAchievementsUnlocked => $composableBuilder(
    column: $table.allAchievementsUnlocked,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasDlc =>
      $composableBuilder(column: $table.hasDlc, builder: (column) => column);

  GeneratedColumn<bool> get isCollection => $composableBuilder(
    column: $table.isCollection,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ratingStory => $composableBuilder(
    column: $table.ratingStory,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ratingGameplay => $composableBuilder(
    column: $table.ratingGameplay,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ratingGraphics => $composableBuilder(
    column: $table.ratingGraphics,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ratingSoundtrack => $composableBuilder(
    column: $table.ratingSoundtrack,
    builder: (column) => column,
  );

  GeneratedColumn<double> get overallRating => $composableBuilder(
    column: $table.overallRating,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get players =>
      $composableBuilder(column: $table.players, builder: (column) => column);

  $SeriesAnnotationComposer get seriesId {
    final $SeriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.series,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SeriesAnnotationComposer(
            $db: $db,
            $table: $db.series,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CompaniesAnnotationComposer get developerId {
    final $CompaniesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.developerId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CompaniesAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CompaniesAnnotationComposer get publisherId {
    final $CompaniesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.publisherId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CompaniesAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> gameCopiesRefs<T extends Object>(
    Expression<T> Function($GameCopiesAnnotationComposer a) f,
  ) {
    final $GameCopiesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameCopies,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GameCopiesAnnotationComposer(
            $db: $db,
            $table: $db.gameCopies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gamePlatformsRefs<T extends Object>(
    Expression<T> Function($GamePlatformsAnnotationComposer a) f,
  ) {
    final $GamePlatformsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gamePlatforms,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamePlatformsAnnotationComposer(
            $db: $db,
            $table: $db.gamePlatforms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gameGenresRefs<T extends Object>(
    Expression<T> Function($GameGenresAnnotationComposer a) f,
  ) {
    final $GameGenresAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameGenres,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GameGenresAnnotationComposer(
            $db: $db,
            $table: $db.gameGenres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $GamesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Games,
          Game,
          $GamesFilterComposer,
          $GamesOrderingComposer,
          $GamesAnnotationComposer,
          $GamesCreateCompanionBuilder,
          $GamesUpdateCompanionBuilder,
          (Game, $GamesReferences),
          Game,
          PrefetchHooks Function({
            bool seriesId,
            bool developerId,
            bool publisherId,
            bool gameCopiesRefs,
            bool gamePlatformsRefs,
            bool gameGenresRefs,
          })
        > {
  $GamesTableManager(_$AppDatabase db, Games table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $GamesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $GamesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $GamesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> titleNorm = const Value.absent(),
                Value<String> sortTitle = const Value.absent(),
                Value<int?> seriesId = const Value.absent(),
                Value<int?> developerId = const Value.absent(),
                Value<int?> publisherId = const Value.absent(),
                Value<int?> releaseYear = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isReplayable = const Value.absent(),
                Value<bool> hasPostGame = const Value.absent(),
                Value<bool> hasAchievements = const Value.absent(),
                Value<bool> allAchievementsUnlocked = const Value.absent(),
                Value<bool> hasDlc = const Value.absent(),
                Value<bool> isCollection = const Value.absent(),
                Value<double?> ratingStory = const Value.absent(),
                Value<double?> ratingGameplay = const Value.absent(),
                Value<double?> ratingGraphics = const Value.absent(),
                Value<double?> ratingSoundtrack = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int?> players = const Value.absent(),
              }) => GamesCompanion(
                id: id,
                title: title,
                titleNorm: titleNorm,
                sortTitle: sortTitle,
                seriesId: seriesId,
                developerId: developerId,
                publisherId: publisherId,
                releaseYear: releaseYear,
                status: status,
                isReplayable: isReplayable,
                hasPostGame: hasPostGame,
                hasAchievements: hasAchievements,
                allAchievementsUnlocked: allAchievementsUnlocked,
                hasDlc: hasDlc,
                isCollection: isCollection,
                ratingStory: ratingStory,
                ratingGameplay: ratingGameplay,
                ratingGraphics: ratingGraphics,
                ratingSoundtrack: ratingSoundtrack,
                coverPath: coverPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                players: players,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String titleNorm,
                required String sortTitle,
                Value<int?> seriesId = const Value.absent(),
                Value<int?> developerId = const Value.absent(),
                Value<int?> publisherId = const Value.absent(),
                Value<int?> releaseYear = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isReplayable = const Value.absent(),
                Value<bool> hasPostGame = const Value.absent(),
                Value<bool> hasAchievements = const Value.absent(),
                Value<bool> allAchievementsUnlocked = const Value.absent(),
                Value<bool> hasDlc = const Value.absent(),
                Value<bool> isCollection = const Value.absent(),
                Value<double?> ratingStory = const Value.absent(),
                Value<double?> ratingGameplay = const Value.absent(),
                Value<double?> ratingGraphics = const Value.absent(),
                Value<double?> ratingSoundtrack = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int?> players = const Value.absent(),
              }) => GamesCompanion.insert(
                id: id,
                title: title,
                titleNorm: titleNorm,
                sortTitle: sortTitle,
                seriesId: seriesId,
                developerId: developerId,
                publisherId: publisherId,
                releaseYear: releaseYear,
                status: status,
                isReplayable: isReplayable,
                hasPostGame: hasPostGame,
                hasAchievements: hasAchievements,
                allAchievementsUnlocked: allAchievementsUnlocked,
                hasDlc: hasDlc,
                isCollection: isCollection,
                ratingStory: ratingStory,
                ratingGameplay: ratingGameplay,
                ratingGraphics: ratingGraphics,
                ratingSoundtrack: ratingSoundtrack,
                coverPath: coverPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                players: players,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Games, Game>(table),
                  $GamesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                seriesId = false,
                developerId = false,
                publisherId = false,
                gameCopiesRefs = false,
                gamePlatformsRefs = false,
                gameGenresRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (gameCopiesRefs) db.gameCopies,
                    if (gamePlatformsRefs) db.gamePlatforms,
                    if (gameGenresRefs) db.gameGenres,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (seriesId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.seriesId,
                            referencedTable: $GamesReferences._seriesIdTable(
                              db,
                            ),
                            referencedColumn: $GamesReferences
                                ._seriesIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (developerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.developerId,
                            referencedTable: $GamesReferences._developerIdTable(
                              db,
                            ),
                            referencedColumn: $GamesReferences
                                ._developerIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (publisherId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.publisherId,
                            referencedTable: $GamesReferences._publisherIdTable(
                              db,
                            ),
                            referencedColumn: $GamesReferences
                                ._publisherIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gameCopiesRefs)
                        await $_getPrefetchedData<Game, Games, GameCopy>(
                          currentTable: table,
                          referencedTable: $GamesReferences
                              ._gameCopiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $GamesReferences(db, table, p0).gameCopiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (gamePlatformsRefs)
                        await $_getPrefetchedData<Game, Games, GamePlatform>(
                          currentTable: table,
                          referencedTable: $GamesReferences
                              ._gamePlatformsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $GamesReferences(db, table, p0).gamePlatformsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (gameGenresRefs)
                        await $_getPrefetchedData<Game, Games, GameGenre>(
                          currentTable: table,
                          referencedTable: $GamesReferences
                              ._gameGenresRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $GamesReferences(db, table, p0).gameGenresRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $GamesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Games,
      Game,
      $GamesFilterComposer,
      $GamesOrderingComposer,
      $GamesAnnotationComposer,
      $GamesCreateCompanionBuilder,
      $GamesUpdateCompanionBuilder,
      (Game, $GamesReferences),
      Game,
      PrefetchHooks Function({
        bool seriesId,
        bool developerId,
        bool publisherId,
        bool gameCopiesRefs,
        bool gamePlatformsRefs,
        bool gameGenresRefs,
      })
    >;
typedef $GameCopiesCreateCompanionBuilder = GameCopiesCompanion Function({
  Value<int> id,
  required int gameId,
  required int consoleId,
  required String format,
});
typedef $GameCopiesUpdateCompanionBuilder = GameCopiesCompanion Function({
  Value<int> id,
  Value<int> gameId,
  Value<int> consoleId,
  Value<String> format,
});

final class $GameCopiesReferences
    extends BaseReferences<_$AppDatabase, GameCopies, GameCopy> {
  $GameCopiesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Games _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('game_copies__game_id__games__id');

  $GamesProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $GamesTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Consoles _consoleIdTable(_$AppDatabase db) =>
      db.consoles.createAlias('game_copies__console_id__consoles__id');

  $ConsolesProcessedTableManager get consoleId {
    final $_column = $_itemColumn<int>('console_id')!;

    final manager = $ConsolesTableManager(
      $_db,
      $_db.consoles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_consoleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $GameCopiesFilterComposer extends Composer<_$AppDatabase, GameCopies> {
  $GameCopiesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  $GamesFilterComposer get gameId {
    final $GamesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamesFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ConsolesFilterComposer get consoleId {
    final $ConsolesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConsolesFilterComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $GameCopiesOrderingComposer extends Composer<_$AppDatabase, GameCopies> {
  $GameCopiesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  $GamesOrderingComposer get gameId {
    final $GamesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamesOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ConsolesOrderingComposer get consoleId {
    final $ConsolesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConsolesOrderingComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $GameCopiesAnnotationComposer
    extends Composer<_$AppDatabase, GameCopies> {
  $GameCopiesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  $GamesAnnotationComposer get gameId {
    final $GamesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamesAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ConsolesAnnotationComposer get consoleId {
    final $ConsolesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConsolesAnnotationComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $GameCopiesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          GameCopies,
          GameCopy,
          $GameCopiesFilterComposer,
          $GameCopiesOrderingComposer,
          $GameCopiesAnnotationComposer,
          $GameCopiesCreateCompanionBuilder,
          $GameCopiesUpdateCompanionBuilder,
          (GameCopy, $GameCopiesReferences),
          GameCopy,
          PrefetchHooks Function({bool gameId, bool consoleId})
        > {
  $GameCopiesTableManager(_$AppDatabase db, GameCopies table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $GameCopiesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $GameCopiesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $GameCopiesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gameId = const Value.absent(),
                Value<int> consoleId = const Value.absent(),
                Value<String> format = const Value.absent(),
              }) => GameCopiesCompanion(
                id: id,
                gameId: gameId,
                consoleId: consoleId,
                format: format,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameId,
                required int consoleId,
                required String format,
              }) => GameCopiesCompanion.insert(
                id: id,
                gameId: gameId,
                consoleId: consoleId,
                format: format,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<GameCopies, GameCopy>(table),
                  $GameCopiesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false, consoleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.gameId,
                        referencedTable: $GameCopiesReferences._gameIdTable(db),
                        referencedColumn: $GameCopiesReferences
                            ._gameIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (consoleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.consoleId,
                        referencedTable: $GameCopiesReferences._consoleIdTable(
                          db,
                        ),
                        referencedColumn: $GameCopiesReferences
                            ._consoleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $GameCopiesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      GameCopies,
      GameCopy,
      $GameCopiesFilterComposer,
      $GameCopiesOrderingComposer,
      $GameCopiesAnnotationComposer,
      $GameCopiesCreateCompanionBuilder,
      $GameCopiesUpdateCompanionBuilder,
      (GameCopy, $GameCopiesReferences),
      GameCopy,
      PrefetchHooks Function({bool gameId, bool consoleId})
    >;
typedef $CollectionItemsCreateCompanionBuilder =
    CollectionItemsCompanion Function({
      required int collectionId,
      required int gameId,
      Value<int> rowid,
    });
typedef $CollectionItemsUpdateCompanionBuilder =
    CollectionItemsCompanion Function({
      Value<int> collectionId,
      Value<int> gameId,
      Value<int> rowid,
    });

final class $CollectionItemsReferences
    extends BaseReferences<_$AppDatabase, CollectionItems, CollectionItem> {
  $CollectionItemsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Games _collectionIdTable(_$AppDatabase db) =>
      db.games.createAlias('collection_items__collection_id__games__id');

  $GamesProcessedTableManager get collectionId {
    final $_column = $_itemColumn<int>('collection_id')!;

    final manager = $GamesTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Games _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('collection_items__game_id__games__id');

  $GamesProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $GamesTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $CollectionItemsFilterComposer
    extends Composer<_$AppDatabase, CollectionItems> {
  $CollectionItemsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $GamesFilterComposer get collectionId {
    final $GamesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamesFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $GamesFilterComposer get gameId {
    final $GamesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamesFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CollectionItemsOrderingComposer
    extends Composer<_$AppDatabase, CollectionItems> {
  $CollectionItemsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $GamesOrderingComposer get collectionId {
    final $GamesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamesOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $GamesOrderingComposer get gameId {
    final $GamesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamesOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CollectionItemsAnnotationComposer
    extends Composer<_$AppDatabase, CollectionItems> {
  $CollectionItemsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $GamesAnnotationComposer get collectionId {
    final $GamesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamesAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $GamesAnnotationComposer get gameId {
    final $GamesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamesAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CollectionItemsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          CollectionItems,
          CollectionItem,
          $CollectionItemsFilterComposer,
          $CollectionItemsOrderingComposer,
          $CollectionItemsAnnotationComposer,
          $CollectionItemsCreateCompanionBuilder,
          $CollectionItemsUpdateCompanionBuilder,
          (CollectionItem, $CollectionItemsReferences),
          CollectionItem,
          PrefetchHooks Function({bool collectionId, bool gameId})
        > {
  $CollectionItemsTableManager(_$AppDatabase db, CollectionItems table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CollectionItemsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CollectionItemsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CollectionItemsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> collectionId = const Value.absent(),
                Value<int> gameId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionItemsCompanion(
                collectionId: collectionId,
                gameId: gameId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int collectionId,
                required int gameId,
                Value<int> rowid = const Value.absent(),
              }) => CollectionItemsCompanion.insert(
                collectionId: collectionId,
                gameId: gameId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<CollectionItems, CollectionItem>(table),
                  $CollectionItemsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionId = false, gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (collectionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.collectionId,
                        referencedTable: $CollectionItemsReferences
                            ._collectionIdTable(db),
                        referencedColumn: $CollectionItemsReferences
                            ._collectionIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (gameId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.gameId,
                        referencedTable: $CollectionItemsReferences
                            ._gameIdTable(db),
                        referencedColumn: $CollectionItemsReferences
                            ._gameIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $CollectionItemsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      CollectionItems,
      CollectionItem,
      $CollectionItemsFilterComposer,
      $CollectionItemsOrderingComposer,
      $CollectionItemsAnnotationComposer,
      $CollectionItemsCreateCompanionBuilder,
      $CollectionItemsUpdateCompanionBuilder,
      (CollectionItem, $CollectionItemsReferences),
      CollectionItem,
      PrefetchHooks Function({bool collectionId, bool gameId})
    >;
typedef $GamePlatformsCreateCompanionBuilder = GamePlatformsCompanion Function({
  required int gameId,
  required int consoleId,
  Value<int> rowid,
});
typedef $GamePlatformsUpdateCompanionBuilder = GamePlatformsCompanion Function({
  Value<int> gameId,
  Value<int> consoleId,
  Value<int> rowid,
});

final class $GamePlatformsReferences
    extends BaseReferences<_$AppDatabase, GamePlatforms, GamePlatform> {
  $GamePlatformsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Games _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('game_platforms__game_id__games__id');

  $GamesProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $GamesTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Consoles _consoleIdTable(_$AppDatabase db) =>
      db.consoles.createAlias('game_platforms__console_id__consoles__id');

  $ConsolesProcessedTableManager get consoleId {
    final $_column = $_itemColumn<int>('console_id')!;

    final manager = $ConsolesTableManager(
      $_db,
      $_db.consoles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_consoleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $GamePlatformsFilterComposer
    extends Composer<_$AppDatabase, GamePlatforms> {
  $GamePlatformsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $GamesFilterComposer get gameId {
    final $GamesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamesFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ConsolesFilterComposer get consoleId {
    final $ConsolesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConsolesFilterComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $GamePlatformsOrderingComposer
    extends Composer<_$AppDatabase, GamePlatforms> {
  $GamePlatformsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $GamesOrderingComposer get gameId {
    final $GamesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamesOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ConsolesOrderingComposer get consoleId {
    final $ConsolesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConsolesOrderingComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $GamePlatformsAnnotationComposer
    extends Composer<_$AppDatabase, GamePlatforms> {
  $GamePlatformsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $GamesAnnotationComposer get gameId {
    final $GamesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamesAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ConsolesAnnotationComposer get consoleId {
    final $ConsolesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConsolesAnnotationComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $GamePlatformsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          GamePlatforms,
          GamePlatform,
          $GamePlatformsFilterComposer,
          $GamePlatformsOrderingComposer,
          $GamePlatformsAnnotationComposer,
          $GamePlatformsCreateCompanionBuilder,
          $GamePlatformsUpdateCompanionBuilder,
          (GamePlatform, $GamePlatformsReferences),
          GamePlatform,
          PrefetchHooks Function({bool gameId, bool consoleId})
        > {
  $GamePlatformsTableManager(_$AppDatabase db, GamePlatforms table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $GamePlatformsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $GamePlatformsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $GamePlatformsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> gameId = const Value.absent(),
                Value<int> consoleId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GamePlatformsCompanion(
                gameId: gameId,
                consoleId: consoleId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int gameId,
                required int consoleId,
                Value<int> rowid = const Value.absent(),
              }) => GamePlatformsCompanion.insert(
                gameId: gameId,
                consoleId: consoleId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<GamePlatforms, GamePlatform>(table),
                  $GamePlatformsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false, consoleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.gameId,
                        referencedTable: $GamePlatformsReferences._gameIdTable(
                          db,
                        ),
                        referencedColumn: $GamePlatformsReferences
                            ._gameIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (consoleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.consoleId,
                        referencedTable: $GamePlatformsReferences
                            ._consoleIdTable(db),
                        referencedColumn: $GamePlatformsReferences
                            ._consoleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $GamePlatformsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      GamePlatforms,
      GamePlatform,
      $GamePlatformsFilterComposer,
      $GamePlatformsOrderingComposer,
      $GamePlatformsAnnotationComposer,
      $GamePlatformsCreateCompanionBuilder,
      $GamePlatformsUpdateCompanionBuilder,
      (GamePlatform, $GamePlatformsReferences),
      GamePlatform,
      PrefetchHooks Function({bool gameId, bool consoleId})
    >;
typedef $GameGenresCreateCompanionBuilder = GameGenresCompanion Function({
  required int gameId,
  required int genreId,
  Value<int> rowid,
});
typedef $GameGenresUpdateCompanionBuilder = GameGenresCompanion Function({
  Value<int> gameId,
  Value<int> genreId,
  Value<int> rowid,
});

final class $GameGenresReferences
    extends BaseReferences<_$AppDatabase, GameGenres, GameGenre> {
  $GameGenresReferences(super.$_db, super.$_table, super.$_typedResult);

  static Games _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('game_genres__game_id__games__id');

  $GamesProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $GamesTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Genres _genreIdTable(_$AppDatabase db) =>
      db.genres.createAlias('game_genres__genre_id__genres__id');

  $GenresProcessedTableManager get genreId {
    final $_column = $_itemColumn<int>('genre_id')!;

    final manager = $GenresTableManager(
      $_db,
      $_db.genres,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_genreIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $GameGenresFilterComposer extends Composer<_$AppDatabase, GameGenres> {
  $GameGenresFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $GamesFilterComposer get gameId {
    final $GamesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamesFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $GenresFilterComposer get genreId {
    final $GenresFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genreId,
      referencedTable: $db.genres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GenresFilterComposer(
            $db: $db,
            $table: $db.genres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $GameGenresOrderingComposer extends Composer<_$AppDatabase, GameGenres> {
  $GameGenresOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $GamesOrderingComposer get gameId {
    final $GamesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamesOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $GenresOrderingComposer get genreId {
    final $GenresOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genreId,
      referencedTable: $db.genres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GenresOrderingComposer(
            $db: $db,
            $table: $db.genres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $GameGenresAnnotationComposer
    extends Composer<_$AppDatabase, GameGenres> {
  $GameGenresAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $GamesAnnotationComposer get gameId {
    final $GamesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GamesAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $GenresAnnotationComposer get genreId {
    final $GenresAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genreId,
      referencedTable: $db.genres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GenresAnnotationComposer(
            $db: $db,
            $table: $db.genres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $GameGenresTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          GameGenres,
          GameGenre,
          $GameGenresFilterComposer,
          $GameGenresOrderingComposer,
          $GameGenresAnnotationComposer,
          $GameGenresCreateCompanionBuilder,
          $GameGenresUpdateCompanionBuilder,
          (GameGenre, $GameGenresReferences),
          GameGenre,
          PrefetchHooks Function({bool gameId, bool genreId})
        > {
  $GameGenresTableManager(_$AppDatabase db, GameGenres table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $GameGenresFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $GameGenresOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $GameGenresAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> gameId = const Value.absent(),
                Value<int> genreId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameGenresCompanion(
                gameId: gameId,
                genreId: genreId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int gameId,
                required int genreId,
                Value<int> rowid = const Value.absent(),
              }) => GameGenresCompanion.insert(
                gameId: gameId,
                genreId: genreId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<GameGenres, GameGenre>(table),
                  $GameGenresReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false, genreId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.gameId,
                        referencedTable: $GameGenresReferences._gameIdTable(db),
                        referencedColumn: $GameGenresReferences
                            ._gameIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (genreId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.genreId,
                        referencedTable: $GameGenresReferences._genreIdTable(
                          db,
                        ),
                        referencedColumn: $GameGenresReferences
                            ._genreIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $GameGenresProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      GameGenres,
      GameGenre,
      $GameGenresFilterComposer,
      $GameGenresOrderingComposer,
      $GameGenresAnnotationComposer,
      $GameGenresCreateCompanionBuilder,
      $GameGenresUpdateCompanionBuilder,
      (GameGenre, $GameGenresReferences),
      GameGenre,
      PrefetchHooks Function({bool gameId, bool genreId})
    >;
typedef $SettingsCreateCompanionBuilder = SettingsCompanion Function({
  required String name,
  required String value,
  Value<int> rowid,
});
typedef $SettingsUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> name,
  Value<String> value,
  Value<int> rowid,
});

class $SettingsFilterComposer extends Composer<_$AppDatabase, Settings> {
  $SettingsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $SettingsOrderingComposer extends Composer<_$AppDatabase, Settings> {
  $SettingsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SettingsAnnotationComposer extends Composer<_$AppDatabase, Settings> {
  $SettingsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $SettingsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Settings,
          Setting,
          $SettingsFilterComposer,
          $SettingsOrderingComposer,
          $SettingsAnnotationComposer,
          $SettingsCreateCompanionBuilder,
          $SettingsUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, Settings, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $SettingsTableManager(_$AppDatabase db, Settings table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SettingsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SettingsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SettingsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> name = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(name: name, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String name,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                name: name,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Settings, Setting>(table),
                  BaseReferences<_$AppDatabase, Settings, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SettingsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Settings,
      Setting,
      $SettingsFilterComposer,
      $SettingsOrderingComposer,
      $SettingsAnnotationComposer,
      $SettingsCreateCompanionBuilder,
      $SettingsUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, Settings, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $ConsolesTableManager get consoles =>
      $ConsolesTableManager(_db, _db.consoles);
  $GenresTableManager get genres => $GenresTableManager(_db, _db.genres);
  $SeriesTableManager get series => $SeriesTableManager(_db, _db.series);
  $CompaniesTableManager get companies =>
      $CompaniesTableManager(_db, _db.companies);
  $GamesTableManager get games => $GamesTableManager(_db, _db.games);
  $GameCopiesTableManager get gameCopies =>
      $GameCopiesTableManager(_db, _db.gameCopies);
  $CollectionItemsTableManager get collectionItems =>
      $CollectionItemsTableManager(_db, _db.collectionItems);
  $GamePlatformsTableManager get gamePlatforms =>
      $GamePlatformsTableManager(_db, _db.gamePlatforms);
  $GameGenresTableManager get gameGenres =>
      $GameGenresTableManager(_db, _db.gameGenres);
  $SettingsTableManager get settings =>
      $SettingsTableManager(_db, _db.settings);
}
