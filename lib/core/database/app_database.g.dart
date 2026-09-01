// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AdminsTable extends Admins with TableInfo<$AdminsTable, Admin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdminsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'UNIQUE NOT NULL COLLATE NOCASE',
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaLengkapMeta = const VerificationMeta(
    'namaLengkap',
  );
  @override
  late final GeneratedColumn<String> namaLengkap = GeneratedColumn<String>(
    'nama_lengkap',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('admin'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastLoginAtMeta = const VerificationMeta(
    'lastLoginAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
    'last_login_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    passwordHash,
    namaLengkap,
    role,
    isActive,
    createdAt,
    updatedAt,
    lastLoginAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'admins';
  @override
  VerificationContext validateIntegrity(
    Insertable<Admin> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('nama_lengkap')) {
      context.handle(
        _namaLengkapMeta,
        namaLengkap.isAcceptableOrUnknown(
          data['nama_lengkap']!,
          _namaLengkapMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_namaLengkapMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
    if (data.containsKey('last_login_at')) {
      context.handle(
        _lastLoginAtMeta,
        lastLoginAt.isAcceptableOrUnknown(
          data['last_login_at']!,
          _lastLoginAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Admin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Admin(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      namaLengkap: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama_lengkap'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login_at'],
      ),
    );
  }

  @override
  $AdminsTable createAlias(String alias) {
    return $AdminsTable(attachedDatabase, alias);
  }
}

class Admin extends DataClass implements Insertable<Admin> {
  final int id;
  final String username;
  final String passwordHash;
  final String namaLengkap;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  const Admin({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.namaLengkap,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['password_hash'] = Variable<String>(passwordHash);
    map['nama_lengkap'] = Variable<String>(namaLengkap);
    map['role'] = Variable<String>(role);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastLoginAt != null) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    }
    return map;
  }

  AdminsCompanion toCompanion(bool nullToAbsent) {
    return AdminsCompanion(
      id: Value(id),
      username: Value(username),
      passwordHash: Value(passwordHash),
      namaLengkap: Value(namaLengkap),
      role: Value(role),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastLoginAt: lastLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginAt),
    );
  }

  factory Admin.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Admin(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      namaLengkap: serializer.fromJson<String>(json['namaLengkap']),
      role: serializer.fromJson<String>(json['role']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastLoginAt: serializer.fromJson<DateTime?>(json['lastLoginAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'namaLengkap': serializer.toJson<String>(namaLengkap),
      'role': serializer.toJson<String>(role),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastLoginAt': serializer.toJson<DateTime?>(lastLoginAt),
    };
  }

  Admin copyWith({
    int? id,
    String? username,
    String? passwordHash,
    String? namaLengkap,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastLoginAt = const Value.absent(),
  }) => Admin(
    id: id ?? this.id,
    username: username ?? this.username,
    passwordHash: passwordHash ?? this.passwordHash,
    namaLengkap: namaLengkap ?? this.namaLengkap,
    role: role ?? this.role,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastLoginAt: lastLoginAt.present ? lastLoginAt.value : this.lastLoginAt,
  );
  Admin copyWithCompanion(AdminsCompanion data) {
    return Admin(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      namaLengkap: data.namaLengkap.present
          ? data.namaLengkap.value
          : this.namaLengkap,
      role: data.role.present ? data.role.value : this.role,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastLoginAt: data.lastLoginAt.present
          ? data.lastLoginAt.value
          : this.lastLoginAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Admin(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('namaLengkap: $namaLengkap, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastLoginAt: $lastLoginAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    passwordHash,
    namaLengkap,
    role,
    isActive,
    createdAt,
    updatedAt,
    lastLoginAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Admin &&
          other.id == this.id &&
          other.username == this.username &&
          other.passwordHash == this.passwordHash &&
          other.namaLengkap == this.namaLengkap &&
          other.role == this.role &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastLoginAt == this.lastLoginAt);
}

class AdminsCompanion extends UpdateCompanion<Admin> {
  final Value<int> id;
  final Value<String> username;
  final Value<String> passwordHash;
  final Value<String> namaLengkap;
  final Value<String> role;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastLoginAt;
  const AdminsCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.namaLengkap = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
  });
  AdminsCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required String passwordHash,
    required String namaLengkap,
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
  }) : username = Value(username),
       passwordHash = Value(passwordHash),
       namaLengkap = Value(namaLengkap);
  static Insertable<Admin> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? passwordHash,
    Expression<String>? namaLengkap,
    Expression<String>? role,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastLoginAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (namaLengkap != null) 'nama_lengkap': namaLengkap,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
    });
  }

  AdminsCompanion copyWith({
    Value<int>? id,
    Value<String>? username,
    Value<String>? passwordHash,
    Value<String>? namaLengkap,
    Value<String>? role,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastLoginAt,
  }) {
    return AdminsCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (namaLengkap.present) {
      map['nama_lengkap'] = Variable<String>(namaLengkap.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdminsCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('namaLengkap: $namaLengkap, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastLoginAt: $lastLoginAt')
          ..write(')'))
        .toString();
  }
}

class $PesertasTable extends Pesertas with TableInfo<$PesertasTable, Peserta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PesertasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _kodePesertaMeta = const VerificationMeta(
    'kodePeserta',
  );
  @override
  late final GeneratedColumn<String> kodePeserta = GeneratedColumn<String>(
    'kode_peserta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'UNIQUE NOT NULL',
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nikMeta = const VerificationMeta('nik');
  @override
  late final GeneratedColumn<String> nik = GeneratedColumn<String>(
    'nik',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'UNIQUE NOT NULL',
  );
  static const VerificationMeta _jenisKelaminMeta = const VerificationMeta(
    'jenisKelamin',
  );
  @override
  late final GeneratedColumn<String> jenisKelamin = GeneratedColumn<String>(
    'jenis_kelamin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Laki-laki'),
  );
  static const VerificationMeta _tglLahirMeta = const VerificationMeta(
    'tglLahir',
  );
  @override
  late final GeneratedColumn<String> tglLahir = GeneratedColumn<String>(
    'tgl_lahir',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alamatMeta = const VerificationMeta('alamat');
  @override
  late final GeneratedColumn<String> alamat = GeneratedColumn<String>(
    'alamat',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noHpMeta = const VerificationMeta('noHp');
  @override
  late final GeneratedColumn<String> noHp = GeneratedColumn<String>(
    'no_hp',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _programMeta = const VerificationMeta(
    'program',
  );
  @override
  late final GeneratedColumn<String> program = GeneratedColumn<String>(
    'program',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('-'),
  );
  static const VerificationMeta _pernahKonsultasiMeta = const VerificationMeta(
    'pernahKonsultasi',
  );
  @override
  late final GeneratedColumn<bool> pernahKonsultasi = GeneratedColumn<bool>(
    'pernah_konsultasi',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pernah_konsultasi" IN (0, 1))',
    ),
  );
  static const VerificationMeta _pernahDapatObatMeta = const VerificationMeta(
    'pernahDapatObat',
  );
  @override
  late final GeneratedColumn<bool> pernahDapatObat = GeneratedColumn<bool>(
    'pernah_dapat_obat',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pernah_dapat_obat" IN (0, 1))',
    ),
  );
  static const VerificationMeta _tglKunjunganMeta = const VerificationMeta(
    'tglKunjungan',
  );
  @override
  late final GeneratedColumn<String> tglKunjungan = GeneratedColumn<String>(
    'tgl_kunjungan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jamKunjunganMeta = const VerificationMeta(
    'jamKunjungan',
  );
  @override
  late final GeneratedColumn<String> jamKunjungan = GeneratedColumn<String>(
    'jam_kunjungan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Terdaftar'),
  );
  static const VerificationMeta _tglDaftarMeta = const VerificationMeta(
    'tglDaftar',
  );
  @override
  late final GeneratedColumn<String> tglDaftar = GeneratedColumn<String>(
    'tgl_daftar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<int> createdBy = GeneratedColumn<int>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL REFERENCES admins(id) ON DELETE SET NULL',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kodePeserta,
    nama,
    nik,
    jenisKelamin,
    tglLahir,
    alamat,
    noHp,
    program,
    pernahKonsultasi,
    pernahDapatObat,
    tglKunjungan,
    jamKunjungan,
    status,
    tglDaftar,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pesertas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Peserta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kode_peserta')) {
      context.handle(
        _kodePesertaMeta,
        kodePeserta.isAcceptableOrUnknown(
          data['kode_peserta']!,
          _kodePesertaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kodePesertaMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('nik')) {
      context.handle(
        _nikMeta,
        nik.isAcceptableOrUnknown(data['nik']!, _nikMeta),
      );
    } else if (isInserting) {
      context.missing(_nikMeta);
    }
    if (data.containsKey('jenis_kelamin')) {
      context.handle(
        _jenisKelaminMeta,
        jenisKelamin.isAcceptableOrUnknown(
          data['jenis_kelamin']!,
          _jenisKelaminMeta,
        ),
      );
    }
    if (data.containsKey('tgl_lahir')) {
      context.handle(
        _tglLahirMeta,
        tglLahir.isAcceptableOrUnknown(data['tgl_lahir']!, _tglLahirMeta),
      );
    }
    if (data.containsKey('alamat')) {
      context.handle(
        _alamatMeta,
        alamat.isAcceptableOrUnknown(data['alamat']!, _alamatMeta),
      );
    }
    if (data.containsKey('no_hp')) {
      context.handle(
        _noHpMeta,
        noHp.isAcceptableOrUnknown(data['no_hp']!, _noHpMeta),
      );
    } else if (isInserting) {
      context.missing(_noHpMeta);
    }
    if (data.containsKey('program')) {
      context.handle(
        _programMeta,
        program.isAcceptableOrUnknown(data['program']!, _programMeta),
      );
    }
    if (data.containsKey('pernah_konsultasi')) {
      context.handle(
        _pernahKonsultasiMeta,
        pernahKonsultasi.isAcceptableOrUnknown(
          data['pernah_konsultasi']!,
          _pernahKonsultasiMeta,
        ),
      );
    }
    if (data.containsKey('pernah_dapat_obat')) {
      context.handle(
        _pernahDapatObatMeta,
        pernahDapatObat.isAcceptableOrUnknown(
          data['pernah_dapat_obat']!,
          _pernahDapatObatMeta,
        ),
      );
    }
    if (data.containsKey('tgl_kunjungan')) {
      context.handle(
        _tglKunjunganMeta,
        tglKunjungan.isAcceptableOrUnknown(
          data['tgl_kunjungan']!,
          _tglKunjunganMeta,
        ),
      );
    }
    if (data.containsKey('jam_kunjungan')) {
      context.handle(
        _jamKunjunganMeta,
        jamKunjungan.isAcceptableOrUnknown(
          data['jam_kunjungan']!,
          _jamKunjunganMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('tgl_daftar')) {
      context.handle(
        _tglDaftarMeta,
        tglDaftar.isAcceptableOrUnknown(data['tgl_daftar']!, _tglDaftarMeta),
      );
    } else if (isInserting) {
      context.missing(_tglDaftarMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Peserta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Peserta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kodePeserta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kode_peserta'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      nik: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nik'],
      )!,
      jenisKelamin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jenis_kelamin'],
      )!,
      tglLahir: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tgl_lahir'],
      ),
      alamat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alamat'],
      ),
      noHp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}no_hp'],
      )!,
      program: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}program'],
      )!,
      pernahKonsultasi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pernah_konsultasi'],
      ),
      pernahDapatObat: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pernah_dapat_obat'],
      ),
      tglKunjungan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tgl_kunjungan'],
      ),
      jamKunjungan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jam_kunjungan'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      tglDaftar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tgl_daftar'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PesertasTable createAlias(String alias) {
    return $PesertasTable(attachedDatabase, alias);
  }
}

class Peserta extends DataClass implements Insertable<Peserta> {
  final int id;
  final String kodePeserta;
  final String nama;
  final String nik;
  final String jenisKelamin;
  final String? tglLahir;
  final String? alamat;
  final String noHp;
  final String program;
  final bool? pernahKonsultasi;
  final bool? pernahDapatObat;
  final String? tglKunjungan;
  final String? jamKunjungan;
  final String status;
  final String tglDaftar;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Peserta({
    required this.id,
    required this.kodePeserta,
    required this.nama,
    required this.nik,
    required this.jenisKelamin,
    this.tglLahir,
    this.alamat,
    required this.noHp,
    required this.program,
    this.pernahKonsultasi,
    this.pernahDapatObat,
    this.tglKunjungan,
    this.jamKunjungan,
    required this.status,
    required this.tglDaftar,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kode_peserta'] = Variable<String>(kodePeserta);
    map['nama'] = Variable<String>(nama);
    map['nik'] = Variable<String>(nik);
    map['jenis_kelamin'] = Variable<String>(jenisKelamin);
    if (!nullToAbsent || tglLahir != null) {
      map['tgl_lahir'] = Variable<String>(tglLahir);
    }
    if (!nullToAbsent || alamat != null) {
      map['alamat'] = Variable<String>(alamat);
    }
    map['no_hp'] = Variable<String>(noHp);
    map['program'] = Variable<String>(program);
    if (!nullToAbsent || pernahKonsultasi != null) {
      map['pernah_konsultasi'] = Variable<bool>(pernahKonsultasi);
    }
    if (!nullToAbsent || pernahDapatObat != null) {
      map['pernah_dapat_obat'] = Variable<bool>(pernahDapatObat);
    }
    if (!nullToAbsent || tglKunjungan != null) {
      map['tgl_kunjungan'] = Variable<String>(tglKunjungan);
    }
    if (!nullToAbsent || jamKunjungan != null) {
      map['jam_kunjungan'] = Variable<String>(jamKunjungan);
    }
    map['status'] = Variable<String>(status);
    map['tgl_daftar'] = Variable<String>(tglDaftar);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<int>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PesertasCompanion toCompanion(bool nullToAbsent) {
    return PesertasCompanion(
      id: Value(id),
      kodePeserta: Value(kodePeserta),
      nama: Value(nama),
      nik: Value(nik),
      jenisKelamin: Value(jenisKelamin),
      tglLahir: tglLahir == null && nullToAbsent
          ? const Value.absent()
          : Value(tglLahir),
      alamat: alamat == null && nullToAbsent
          ? const Value.absent()
          : Value(alamat),
      noHp: Value(noHp),
      program: Value(program),
      pernahKonsultasi: pernahKonsultasi == null && nullToAbsent
          ? const Value.absent()
          : Value(pernahKonsultasi),
      pernahDapatObat: pernahDapatObat == null && nullToAbsent
          ? const Value.absent()
          : Value(pernahDapatObat),
      tglKunjungan: tglKunjungan == null && nullToAbsent
          ? const Value.absent()
          : Value(tglKunjungan),
      jamKunjungan: jamKunjungan == null && nullToAbsent
          ? const Value.absent()
          : Value(jamKunjungan),
      status: Value(status),
      tglDaftar: Value(tglDaftar),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Peserta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Peserta(
      id: serializer.fromJson<int>(json['id']),
      kodePeserta: serializer.fromJson<String>(json['kodePeserta']),
      nama: serializer.fromJson<String>(json['nama']),
      nik: serializer.fromJson<String>(json['nik']),
      jenisKelamin: serializer.fromJson<String>(json['jenisKelamin']),
      tglLahir: serializer.fromJson<String?>(json['tglLahir']),
      alamat: serializer.fromJson<String?>(json['alamat']),
      noHp: serializer.fromJson<String>(json['noHp']),
      program: serializer.fromJson<String>(json['program']),
      pernahKonsultasi: serializer.fromJson<bool?>(json['pernahKonsultasi']),
      pernahDapatObat: serializer.fromJson<bool?>(json['pernahDapatObat']),
      tglKunjungan: serializer.fromJson<String?>(json['tglKunjungan']),
      jamKunjungan: serializer.fromJson<String?>(json['jamKunjungan']),
      status: serializer.fromJson<String>(json['status']),
      tglDaftar: serializer.fromJson<String>(json['tglDaftar']),
      createdBy: serializer.fromJson<int?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kodePeserta': serializer.toJson<String>(kodePeserta),
      'nama': serializer.toJson<String>(nama),
      'nik': serializer.toJson<String>(nik),
      'jenisKelamin': serializer.toJson<String>(jenisKelamin),
      'tglLahir': serializer.toJson<String?>(tglLahir),
      'alamat': serializer.toJson<String?>(alamat),
      'noHp': serializer.toJson<String>(noHp),
      'program': serializer.toJson<String>(program),
      'pernahKonsultasi': serializer.toJson<bool?>(pernahKonsultasi),
      'pernahDapatObat': serializer.toJson<bool?>(pernahDapatObat),
      'tglKunjungan': serializer.toJson<String?>(tglKunjungan),
      'jamKunjungan': serializer.toJson<String?>(jamKunjungan),
      'status': serializer.toJson<String>(status),
      'tglDaftar': serializer.toJson<String>(tglDaftar),
      'createdBy': serializer.toJson<int?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Peserta copyWith({
    int? id,
    String? kodePeserta,
    String? nama,
    String? nik,
    String? jenisKelamin,
    Value<String?> tglLahir = const Value.absent(),
    Value<String?> alamat = const Value.absent(),
    String? noHp,
    String? program,
    Value<bool?> pernahKonsultasi = const Value.absent(),
    Value<bool?> pernahDapatObat = const Value.absent(),
    Value<String?> tglKunjungan = const Value.absent(),
    Value<String?> jamKunjungan = const Value.absent(),
    String? status,
    String? tglDaftar,
    Value<int?> createdBy = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Peserta(
    id: id ?? this.id,
    kodePeserta: kodePeserta ?? this.kodePeserta,
    nama: nama ?? this.nama,
    nik: nik ?? this.nik,
    jenisKelamin: jenisKelamin ?? this.jenisKelamin,
    tglLahir: tglLahir.present ? tglLahir.value : this.tglLahir,
    alamat: alamat.present ? alamat.value : this.alamat,
    noHp: noHp ?? this.noHp,
    program: program ?? this.program,
    pernahKonsultasi: pernahKonsultasi.present
        ? pernahKonsultasi.value
        : this.pernahKonsultasi,
    pernahDapatObat: pernahDapatObat.present
        ? pernahDapatObat.value
        : this.pernahDapatObat,
    tglKunjungan: tglKunjungan.present ? tglKunjungan.value : this.tglKunjungan,
    jamKunjungan: jamKunjungan.present ? jamKunjungan.value : this.jamKunjungan,
    status: status ?? this.status,
    tglDaftar: tglDaftar ?? this.tglDaftar,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Peserta copyWithCompanion(PesertasCompanion data) {
    return Peserta(
      id: data.id.present ? data.id.value : this.id,
      kodePeserta: data.kodePeserta.present
          ? data.kodePeserta.value
          : this.kodePeserta,
      nama: data.nama.present ? data.nama.value : this.nama,
      nik: data.nik.present ? data.nik.value : this.nik,
      jenisKelamin: data.jenisKelamin.present
          ? data.jenisKelamin.value
          : this.jenisKelamin,
      tglLahir: data.tglLahir.present ? data.tglLahir.value : this.tglLahir,
      alamat: data.alamat.present ? data.alamat.value : this.alamat,
      noHp: data.noHp.present ? data.noHp.value : this.noHp,
      program: data.program.present ? data.program.value : this.program,
      pernahKonsultasi: data.pernahKonsultasi.present
          ? data.pernahKonsultasi.value
          : this.pernahKonsultasi,
      pernahDapatObat: data.pernahDapatObat.present
          ? data.pernahDapatObat.value
          : this.pernahDapatObat,
      tglKunjungan: data.tglKunjungan.present
          ? data.tglKunjungan.value
          : this.tglKunjungan,
      jamKunjungan: data.jamKunjungan.present
          ? data.jamKunjungan.value
          : this.jamKunjungan,
      status: data.status.present ? data.status.value : this.status,
      tglDaftar: data.tglDaftar.present ? data.tglDaftar.value : this.tglDaftar,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Peserta(')
          ..write('id: $id, ')
          ..write('kodePeserta: $kodePeserta, ')
          ..write('nama: $nama, ')
          ..write('nik: $nik, ')
          ..write('jenisKelamin: $jenisKelamin, ')
          ..write('tglLahir: $tglLahir, ')
          ..write('alamat: $alamat, ')
          ..write('noHp: $noHp, ')
          ..write('program: $program, ')
          ..write('pernahKonsultasi: $pernahKonsultasi, ')
          ..write('pernahDapatObat: $pernahDapatObat, ')
          ..write('tglKunjungan: $tglKunjungan, ')
          ..write('jamKunjungan: $jamKunjungan, ')
          ..write('status: $status, ')
          ..write('tglDaftar: $tglDaftar, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kodePeserta,
    nama,
    nik,
    jenisKelamin,
    tglLahir,
    alamat,
    noHp,
    program,
    pernahKonsultasi,
    pernahDapatObat,
    tglKunjungan,
    jamKunjungan,
    status,
    tglDaftar,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Peserta &&
          other.id == this.id &&
          other.kodePeserta == this.kodePeserta &&
          other.nama == this.nama &&
          other.nik == this.nik &&
          other.jenisKelamin == this.jenisKelamin &&
          other.tglLahir == this.tglLahir &&
          other.alamat == this.alamat &&
          other.noHp == this.noHp &&
          other.program == this.program &&
          other.pernahKonsultasi == this.pernahKonsultasi &&
          other.pernahDapatObat == this.pernahDapatObat &&
          other.tglKunjungan == this.tglKunjungan &&
          other.jamKunjungan == this.jamKunjungan &&
          other.status == this.status &&
          other.tglDaftar == this.tglDaftar &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PesertasCompanion extends UpdateCompanion<Peserta> {
  final Value<int> id;
  final Value<String> kodePeserta;
  final Value<String> nama;
  final Value<String> nik;
  final Value<String> jenisKelamin;
  final Value<String?> tglLahir;
  final Value<String?> alamat;
  final Value<String> noHp;
  final Value<String> program;
  final Value<bool?> pernahKonsultasi;
  final Value<bool?> pernahDapatObat;
  final Value<String?> tglKunjungan;
  final Value<String?> jamKunjungan;
  final Value<String> status;
  final Value<String> tglDaftar;
  final Value<int?> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PesertasCompanion({
    this.id = const Value.absent(),
    this.kodePeserta = const Value.absent(),
    this.nama = const Value.absent(),
    this.nik = const Value.absent(),
    this.jenisKelamin = const Value.absent(),
    this.tglLahir = const Value.absent(),
    this.alamat = const Value.absent(),
    this.noHp = const Value.absent(),
    this.program = const Value.absent(),
    this.pernahKonsultasi = const Value.absent(),
    this.pernahDapatObat = const Value.absent(),
    this.tglKunjungan = const Value.absent(),
    this.jamKunjungan = const Value.absent(),
    this.status = const Value.absent(),
    this.tglDaftar = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PesertasCompanion.insert({
    this.id = const Value.absent(),
    required String kodePeserta,
    required String nama,
    required String nik,
    this.jenisKelamin = const Value.absent(),
    this.tglLahir = const Value.absent(),
    this.alamat = const Value.absent(),
    required String noHp,
    this.program = const Value.absent(),
    this.pernahKonsultasi = const Value.absent(),
    this.pernahDapatObat = const Value.absent(),
    this.tglKunjungan = const Value.absent(),
    this.jamKunjungan = const Value.absent(),
    this.status = const Value.absent(),
    required String tglDaftar,
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : kodePeserta = Value(kodePeserta),
       nama = Value(nama),
       nik = Value(nik),
       noHp = Value(noHp),
       tglDaftar = Value(tglDaftar);
  static Insertable<Peserta> custom({
    Expression<int>? id,
    Expression<String>? kodePeserta,
    Expression<String>? nama,
    Expression<String>? nik,
    Expression<String>? jenisKelamin,
    Expression<String>? tglLahir,
    Expression<String>? alamat,
    Expression<String>? noHp,
    Expression<String>? program,
    Expression<bool>? pernahKonsultasi,
    Expression<bool>? pernahDapatObat,
    Expression<String>? tglKunjungan,
    Expression<String>? jamKunjungan,
    Expression<String>? status,
    Expression<String>? tglDaftar,
    Expression<int>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kodePeserta != null) 'kode_peserta': kodePeserta,
      if (nama != null) 'nama': nama,
      if (nik != null) 'nik': nik,
      if (jenisKelamin != null) 'jenis_kelamin': jenisKelamin,
      if (tglLahir != null) 'tgl_lahir': tglLahir,
      if (alamat != null) 'alamat': alamat,
      if (noHp != null) 'no_hp': noHp,
      if (program != null) 'program': program,
      if (pernahKonsultasi != null) 'pernah_konsultasi': pernahKonsultasi,
      if (pernahDapatObat != null) 'pernah_dapat_obat': pernahDapatObat,
      if (tglKunjungan != null) 'tgl_kunjungan': tglKunjungan,
      if (jamKunjungan != null) 'jam_kunjungan': jamKunjungan,
      if (status != null) 'status': status,
      if (tglDaftar != null) 'tgl_daftar': tglDaftar,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PesertasCompanion copyWith({
    Value<int>? id,
    Value<String>? kodePeserta,
    Value<String>? nama,
    Value<String>? nik,
    Value<String>? jenisKelamin,
    Value<String?>? tglLahir,
    Value<String?>? alamat,
    Value<String>? noHp,
    Value<String>? program,
    Value<bool?>? pernahKonsultasi,
    Value<bool?>? pernahDapatObat,
    Value<String?>? tglKunjungan,
    Value<String?>? jamKunjungan,
    Value<String>? status,
    Value<String>? tglDaftar,
    Value<int?>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return PesertasCompanion(
      id: id ?? this.id,
      kodePeserta: kodePeserta ?? this.kodePeserta,
      nama: nama ?? this.nama,
      nik: nik ?? this.nik,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tglLahir: tglLahir ?? this.tglLahir,
      alamat: alamat ?? this.alamat,
      noHp: noHp ?? this.noHp,
      program: program ?? this.program,
      pernahKonsultasi: pernahKonsultasi ?? this.pernahKonsultasi,
      pernahDapatObat: pernahDapatObat ?? this.pernahDapatObat,
      tglKunjungan: tglKunjungan ?? this.tglKunjungan,
      jamKunjungan: jamKunjungan ?? this.jamKunjungan,
      status: status ?? this.status,
      tglDaftar: tglDaftar ?? this.tglDaftar,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kodePeserta.present) {
      map['kode_peserta'] = Variable<String>(kodePeserta.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (nik.present) {
      map['nik'] = Variable<String>(nik.value);
    }
    if (jenisKelamin.present) {
      map['jenis_kelamin'] = Variable<String>(jenisKelamin.value);
    }
    if (tglLahir.present) {
      map['tgl_lahir'] = Variable<String>(tglLahir.value);
    }
    if (alamat.present) {
      map['alamat'] = Variable<String>(alamat.value);
    }
    if (noHp.present) {
      map['no_hp'] = Variable<String>(noHp.value);
    }
    if (program.present) {
      map['program'] = Variable<String>(program.value);
    }
    if (pernahKonsultasi.present) {
      map['pernah_konsultasi'] = Variable<bool>(pernahKonsultasi.value);
    }
    if (pernahDapatObat.present) {
      map['pernah_dapat_obat'] = Variable<bool>(pernahDapatObat.value);
    }
    if (tglKunjungan.present) {
      map['tgl_kunjungan'] = Variable<String>(tglKunjungan.value);
    }
    if (jamKunjungan.present) {
      map['jam_kunjungan'] = Variable<String>(jamKunjungan.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (tglDaftar.present) {
      map['tgl_daftar'] = Variable<String>(tglDaftar.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<int>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PesertasCompanion(')
          ..write('id: $id, ')
          ..write('kodePeserta: $kodePeserta, ')
          ..write('nama: $nama, ')
          ..write('nik: $nik, ')
          ..write('jenisKelamin: $jenisKelamin, ')
          ..write('tglLahir: $tglLahir, ')
          ..write('alamat: $alamat, ')
          ..write('noHp: $noHp, ')
          ..write('program: $program, ')
          ..write('pernahKonsultasi: $pernahKonsultasi, ')
          ..write('pernahDapatObat: $pernahDapatObat, ')
          ..write('tglKunjungan: $tglKunjungan, ')
          ..write('jamKunjungan: $jamKunjungan, ')
          ..write('status: $status, ')
          ..write('tglDaftar: $tglDaftar, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SkriningRecordsTable extends SkriningRecords
    with TableInfo<$SkriningRecordsTable, SkriningRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkriningRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pesertaIdMeta = const VerificationMeta(
    'pesertaId',
  );
  @override
  late final GeneratedColumn<int> pesertaId = GeneratedColumn<int>(
    'peserta_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES pesertas(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _tanggalMeta = const VerificationMeta(
    'tanggal',
  );
  @override
  late final GeneratedColumn<String> tanggal = GeneratedColumn<String>(
    'tanggal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skorMeta = const VerificationMeta('skor');
  @override
  late final GeneratedColumn<int> skor = GeneratedColumn<int>(
    'skor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kategoriMeta = const VerificationMeta(
    'kategori',
  );
  @override
  late final GeneratedColumn<String> kategori = GeneratedColumn<String>(
    'kategori',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRedFlagMeta = const VerificationMeta(
    'isRedFlag',
  );
  @override
  late final GeneratedColumn<bool> isRedFlag = GeneratedColumn<bool>(
    'is_red_flag',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_red_flag" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rekomendasiMeta = const VerificationMeta(
    'rekomendasi',
  );
  @override
  late final GeneratedColumn<String> rekomendasi = GeneratedColumn<String>(
    'rekomendasi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<int> createdBy = GeneratedColumn<int>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL REFERENCES admins(id) ON DELETE SET NULL',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pesertaId,
    tanggal,
    skor,
    kategori,
    isRedFlag,
    rekomendasi,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'skrining_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SkriningRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('peserta_id')) {
      context.handle(
        _pesertaIdMeta,
        pesertaId.isAcceptableOrUnknown(data['peserta_id']!, _pesertaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pesertaIdMeta);
    }
    if (data.containsKey('tanggal')) {
      context.handle(
        _tanggalMeta,
        tanggal.isAcceptableOrUnknown(data['tanggal']!, _tanggalMeta),
      );
    } else if (isInserting) {
      context.missing(_tanggalMeta);
    }
    if (data.containsKey('skor')) {
      context.handle(
        _skorMeta,
        skor.isAcceptableOrUnknown(data['skor']!, _skorMeta),
      );
    }
    if (data.containsKey('kategori')) {
      context.handle(
        _kategoriMeta,
        kategori.isAcceptableOrUnknown(data['kategori']!, _kategoriMeta),
      );
    } else if (isInserting) {
      context.missing(_kategoriMeta);
    }
    if (data.containsKey('is_red_flag')) {
      context.handle(
        _isRedFlagMeta,
        isRedFlag.isAcceptableOrUnknown(data['is_red_flag']!, _isRedFlagMeta),
      );
    }
    if (data.containsKey('rekomendasi')) {
      context.handle(
        _rekomendasiMeta,
        rekomendasi.isAcceptableOrUnknown(
          data['rekomendasi']!,
          _rekomendasiMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rekomendasiMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SkriningRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SkriningRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pesertaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}peserta_id'],
      )!,
      tanggal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tanggal'],
      )!,
      skor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skor'],
      ),
      kategori: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kategori'],
      )!,
      isRedFlag: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_red_flag'],
      )!,
      rekomendasi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rekomendasi'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SkriningRecordsTable createAlias(String alias) {
    return $SkriningRecordsTable(attachedDatabase, alias);
  }
}

class SkriningRecord extends DataClass implements Insertable<SkriningRecord> {
  final int id;
  final int pesertaId;
  final String tanggal;
  final int? skor;
  final String kategori;
  final bool isRedFlag;
  final String rekomendasi;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SkriningRecord({
    required this.id,
    required this.pesertaId,
    required this.tanggal,
    this.skor,
    required this.kategori,
    required this.isRedFlag,
    required this.rekomendasi,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['peserta_id'] = Variable<int>(pesertaId);
    map['tanggal'] = Variable<String>(tanggal);
    if (!nullToAbsent || skor != null) {
      map['skor'] = Variable<int>(skor);
    }
    map['kategori'] = Variable<String>(kategori);
    map['is_red_flag'] = Variable<bool>(isRedFlag);
    map['rekomendasi'] = Variable<String>(rekomendasi);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<int>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SkriningRecordsCompanion toCompanion(bool nullToAbsent) {
    return SkriningRecordsCompanion(
      id: Value(id),
      pesertaId: Value(pesertaId),
      tanggal: Value(tanggal),
      skor: skor == null && nullToAbsent ? const Value.absent() : Value(skor),
      kategori: Value(kategori),
      isRedFlag: Value(isRedFlag),
      rekomendasi: Value(rekomendasi),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SkriningRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SkriningRecord(
      id: serializer.fromJson<int>(json['id']),
      pesertaId: serializer.fromJson<int>(json['pesertaId']),
      tanggal: serializer.fromJson<String>(json['tanggal']),
      skor: serializer.fromJson<int?>(json['skor']),
      kategori: serializer.fromJson<String>(json['kategori']),
      isRedFlag: serializer.fromJson<bool>(json['isRedFlag']),
      rekomendasi: serializer.fromJson<String>(json['rekomendasi']),
      createdBy: serializer.fromJson<int?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pesertaId': serializer.toJson<int>(pesertaId),
      'tanggal': serializer.toJson<String>(tanggal),
      'skor': serializer.toJson<int?>(skor),
      'kategori': serializer.toJson<String>(kategori),
      'isRedFlag': serializer.toJson<bool>(isRedFlag),
      'rekomendasi': serializer.toJson<String>(rekomendasi),
      'createdBy': serializer.toJson<int?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SkriningRecord copyWith({
    int? id,
    int? pesertaId,
    String? tanggal,
    Value<int?> skor = const Value.absent(),
    String? kategori,
    bool? isRedFlag,
    String? rekomendasi,
    Value<int?> createdBy = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SkriningRecord(
    id: id ?? this.id,
    pesertaId: pesertaId ?? this.pesertaId,
    tanggal: tanggal ?? this.tanggal,
    skor: skor.present ? skor.value : this.skor,
    kategori: kategori ?? this.kategori,
    isRedFlag: isRedFlag ?? this.isRedFlag,
    rekomendasi: rekomendasi ?? this.rekomendasi,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SkriningRecord copyWithCompanion(SkriningRecordsCompanion data) {
    return SkriningRecord(
      id: data.id.present ? data.id.value : this.id,
      pesertaId: data.pesertaId.present ? data.pesertaId.value : this.pesertaId,
      tanggal: data.tanggal.present ? data.tanggal.value : this.tanggal,
      skor: data.skor.present ? data.skor.value : this.skor,
      kategori: data.kategori.present ? data.kategori.value : this.kategori,
      isRedFlag: data.isRedFlag.present ? data.isRedFlag.value : this.isRedFlag,
      rekomendasi: data.rekomendasi.present
          ? data.rekomendasi.value
          : this.rekomendasi,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SkriningRecord(')
          ..write('id: $id, ')
          ..write('pesertaId: $pesertaId, ')
          ..write('tanggal: $tanggal, ')
          ..write('skor: $skor, ')
          ..write('kategori: $kategori, ')
          ..write('isRedFlag: $isRedFlag, ')
          ..write('rekomendasi: $rekomendasi, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pesertaId,
    tanggal,
    skor,
    kategori,
    isRedFlag,
    rekomendasi,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SkriningRecord &&
          other.id == this.id &&
          other.pesertaId == this.pesertaId &&
          other.tanggal == this.tanggal &&
          other.skor == this.skor &&
          other.kategori == this.kategori &&
          other.isRedFlag == this.isRedFlag &&
          other.rekomendasi == this.rekomendasi &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SkriningRecordsCompanion extends UpdateCompanion<SkriningRecord> {
  final Value<int> id;
  final Value<int> pesertaId;
  final Value<String> tanggal;
  final Value<int?> skor;
  final Value<String> kategori;
  final Value<bool> isRedFlag;
  final Value<String> rekomendasi;
  final Value<int?> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SkriningRecordsCompanion({
    this.id = const Value.absent(),
    this.pesertaId = const Value.absent(),
    this.tanggal = const Value.absent(),
    this.skor = const Value.absent(),
    this.kategori = const Value.absent(),
    this.isRedFlag = const Value.absent(),
    this.rekomendasi = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SkriningRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int pesertaId,
    required String tanggal,
    this.skor = const Value.absent(),
    required String kategori,
    this.isRedFlag = const Value.absent(),
    required String rekomendasi,
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : pesertaId = Value(pesertaId),
       tanggal = Value(tanggal),
       kategori = Value(kategori),
       rekomendasi = Value(rekomendasi);
  static Insertable<SkriningRecord> custom({
    Expression<int>? id,
    Expression<int>? pesertaId,
    Expression<String>? tanggal,
    Expression<int>? skor,
    Expression<String>? kategori,
    Expression<bool>? isRedFlag,
    Expression<String>? rekomendasi,
    Expression<int>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pesertaId != null) 'peserta_id': pesertaId,
      if (tanggal != null) 'tanggal': tanggal,
      if (skor != null) 'skor': skor,
      if (kategori != null) 'kategori': kategori,
      if (isRedFlag != null) 'is_red_flag': isRedFlag,
      if (rekomendasi != null) 'rekomendasi': rekomendasi,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SkriningRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? pesertaId,
    Value<String>? tanggal,
    Value<int?>? skor,
    Value<String>? kategori,
    Value<bool>? isRedFlag,
    Value<String>? rekomendasi,
    Value<int?>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return SkriningRecordsCompanion(
      id: id ?? this.id,
      pesertaId: pesertaId ?? this.pesertaId,
      tanggal: tanggal ?? this.tanggal,
      skor: skor ?? this.skor,
      kategori: kategori ?? this.kategori,
      isRedFlag: isRedFlag ?? this.isRedFlag,
      rekomendasi: rekomendasi ?? this.rekomendasi,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pesertaId.present) {
      map['peserta_id'] = Variable<int>(pesertaId.value);
    }
    if (tanggal.present) {
      map['tanggal'] = Variable<String>(tanggal.value);
    }
    if (skor.present) {
      map['skor'] = Variable<int>(skor.value);
    }
    if (kategori.present) {
      map['kategori'] = Variable<String>(kategori.value);
    }
    if (isRedFlag.present) {
      map['is_red_flag'] = Variable<bool>(isRedFlag.value);
    }
    if (rekomendasi.present) {
      map['rekomendasi'] = Variable<String>(rekomendasi.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<int>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkriningRecordsCompanion(')
          ..write('id: $id, ')
          ..write('pesertaId: $pesertaId, ')
          ..write('tanggal: $tanggal, ')
          ..write('skor: $skor, ')
          ..write('kategori: $kategori, ')
          ..write('isRedFlag: $isRedFlag, ')
          ..write('rekomendasi: $rekomendasi, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SkriningJawabansTable extends SkriningJawabans
    with TableInfo<$SkriningJawabansTable, SkriningJawaban> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkriningJawabansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _skriningIdMeta = const VerificationMeta(
    'skriningId',
  );
  @override
  late final GeneratedColumn<int> skriningId = GeneratedColumn<int>(
    'skrining_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES skrining_records(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _nomorMeta = const VerificationMeta('nomor');
  @override
  late final GeneratedColumn<int> nomor = GeneratedColumn<int>(
    'nomor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jawabanMeta = const VerificationMeta(
    'jawaban',
  );
  @override
  late final GeneratedColumn<bool> jawaban = GeneratedColumn<bool>(
    'jawaban',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("jawaban" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, skriningId, nomor, jawaban];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'skrining_jawabans';
  @override
  VerificationContext validateIntegrity(
    Insertable<SkriningJawaban> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('skrining_id')) {
      context.handle(
        _skriningIdMeta,
        skriningId.isAcceptableOrUnknown(data['skrining_id']!, _skriningIdMeta),
      );
    } else if (isInserting) {
      context.missing(_skriningIdMeta);
    }
    if (data.containsKey('nomor')) {
      context.handle(
        _nomorMeta,
        nomor.isAcceptableOrUnknown(data['nomor']!, _nomorMeta),
      );
    } else if (isInserting) {
      context.missing(_nomorMeta);
    }
    if (data.containsKey('jawaban')) {
      context.handle(
        _jawabanMeta,
        jawaban.isAcceptableOrUnknown(data['jawaban']!, _jawabanMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {skriningId, nomor},
  ];
  @override
  SkriningJawaban map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SkriningJawaban(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      skriningId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skrining_id'],
      )!,
      nomor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nomor'],
      )!,
      jawaban: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}jawaban'],
      ),
    );
  }

  @override
  $SkriningJawabansTable createAlias(String alias) {
    return $SkriningJawabansTable(attachedDatabase, alias);
  }
}

class SkriningJawaban extends DataClass implements Insertable<SkriningJawaban> {
  final int id;
  final int skriningId;
  final int nomor;
  final bool? jawaban;
  const SkriningJawaban({
    required this.id,
    required this.skriningId,
    required this.nomor,
    this.jawaban,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['skrining_id'] = Variable<int>(skriningId);
    map['nomor'] = Variable<int>(nomor);
    if (!nullToAbsent || jawaban != null) {
      map['jawaban'] = Variable<bool>(jawaban);
    }
    return map;
  }

  SkriningJawabansCompanion toCompanion(bool nullToAbsent) {
    return SkriningJawabansCompanion(
      id: Value(id),
      skriningId: Value(skriningId),
      nomor: Value(nomor),
      jawaban: jawaban == null && nullToAbsent
          ? const Value.absent()
          : Value(jawaban),
    );
  }

  factory SkriningJawaban.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SkriningJawaban(
      id: serializer.fromJson<int>(json['id']),
      skriningId: serializer.fromJson<int>(json['skriningId']),
      nomor: serializer.fromJson<int>(json['nomor']),
      jawaban: serializer.fromJson<bool?>(json['jawaban']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'skriningId': serializer.toJson<int>(skriningId),
      'nomor': serializer.toJson<int>(nomor),
      'jawaban': serializer.toJson<bool?>(jawaban),
    };
  }

  SkriningJawaban copyWith({
    int? id,
    int? skriningId,
    int? nomor,
    Value<bool?> jawaban = const Value.absent(),
  }) => SkriningJawaban(
    id: id ?? this.id,
    skriningId: skriningId ?? this.skriningId,
    nomor: nomor ?? this.nomor,
    jawaban: jawaban.present ? jawaban.value : this.jawaban,
  );
  SkriningJawaban copyWithCompanion(SkriningJawabansCompanion data) {
    return SkriningJawaban(
      id: data.id.present ? data.id.value : this.id,
      skriningId: data.skriningId.present
          ? data.skriningId.value
          : this.skriningId,
      nomor: data.nomor.present ? data.nomor.value : this.nomor,
      jawaban: data.jawaban.present ? data.jawaban.value : this.jawaban,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SkriningJawaban(')
          ..write('id: $id, ')
          ..write('skriningId: $skriningId, ')
          ..write('nomor: $nomor, ')
          ..write('jawaban: $jawaban')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, skriningId, nomor, jawaban);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SkriningJawaban &&
          other.id == this.id &&
          other.skriningId == this.skriningId &&
          other.nomor == this.nomor &&
          other.jawaban == this.jawaban);
}

class SkriningJawabansCompanion extends UpdateCompanion<SkriningJawaban> {
  final Value<int> id;
  final Value<int> skriningId;
  final Value<int> nomor;
  final Value<bool?> jawaban;
  const SkriningJawabansCompanion({
    this.id = const Value.absent(),
    this.skriningId = const Value.absent(),
    this.nomor = const Value.absent(),
    this.jawaban = const Value.absent(),
  });
  SkriningJawabansCompanion.insert({
    this.id = const Value.absent(),
    required int skriningId,
    required int nomor,
    this.jawaban = const Value.absent(),
  }) : skriningId = Value(skriningId),
       nomor = Value(nomor);
  static Insertable<SkriningJawaban> custom({
    Expression<int>? id,
    Expression<int>? skriningId,
    Expression<int>? nomor,
    Expression<bool>? jawaban,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (skriningId != null) 'skrining_id': skriningId,
      if (nomor != null) 'nomor': nomor,
      if (jawaban != null) 'jawaban': jawaban,
    });
  }

  SkriningJawabansCompanion copyWith({
    Value<int>? id,
    Value<int>? skriningId,
    Value<int>? nomor,
    Value<bool?>? jawaban,
  }) {
    return SkriningJawabansCompanion(
      id: id ?? this.id,
      skriningId: skriningId ?? this.skriningId,
      nomor: nomor ?? this.nomor,
      jawaban: jawaban ?? this.jawaban,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (skriningId.present) {
      map['skrining_id'] = Variable<int>(skriningId.value);
    }
    if (nomor.present) {
      map['nomor'] = Variable<int>(nomor.value);
    }
    if (jawaban.present) {
      map['jawaban'] = Variable<bool>(jawaban.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkriningJawabansCompanion(')
          ..write('id: $id, ')
          ..write('skriningId: $skriningId, ')
          ..write('nomor: $nomor, ')
          ..write('jawaban: $jawaban')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AdminsTable admins = $AdminsTable(this);
  late final $PesertasTable pesertas = $PesertasTable(this);
  late final $SkriningRecordsTable skriningRecords = $SkriningRecordsTable(
    this,
  );
  late final $SkriningJawabansTable skriningJawabans = $SkriningJawabansTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    admins,
    pesertas,
    skriningRecords,
    skriningJawabans,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'admins',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pesertas', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pesertas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('skrining_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'admins',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('skrining_records', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'skrining_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('skrining_jawabans', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AdminsTableCreateCompanionBuilder =
    AdminsCompanion Function({
      Value<int> id,
      required String username,
      required String passwordHash,
      required String namaLengkap,
      Value<String> role,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastLoginAt,
    });
typedef $$AdminsTableUpdateCompanionBuilder =
    AdminsCompanion Function({
      Value<int> id,
      Value<String> username,
      Value<String> passwordHash,
      Value<String> namaLengkap,
      Value<String> role,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastLoginAt,
    });

final class $$AdminsTableReferences
    extends BaseReferences<_$AppDatabase, $AdminsTable, Admin> {
  $$AdminsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PesertasTable, List<Peserta>> _pesertasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.pesertas,
    aliasName: 'admins__id__pesertas__created_by',
  );

  $$PesertasTableProcessedTableManager get pesertasRefs {
    final manager = $$PesertasTableTableManager(
      $_db,
      $_db.pesertas,
    ).filter((f) => f.createdBy.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pesertasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SkriningRecordsTable, List<SkriningRecord>>
  _skriningRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.skriningRecords,
    aliasName: 'admins__id__skrining_records__created_by',
  );

  $$SkriningRecordsTableProcessedTableManager get skriningRecordsRefs {
    final manager = $$SkriningRecordsTableTableManager(
      $_db,
      $_db.skriningRecords,
    ).filter((f) => f.createdBy.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _skriningRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AdminsTableFilterComposer
    extends Composer<_$AppDatabase, $AdminsTable> {
  $$AdminsTableFilterComposer({
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

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get namaLengkap => $composableBuilder(
    column: $table.namaLengkap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> pesertasRefs(
    Expression<bool> Function($$PesertasTableFilterComposer f) f,
  ) {
    final $$PesertasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pesertas,
      getReferencedColumn: (t) => t.createdBy,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PesertasTableFilterComposer(
            $db: $db,
            $table: $db.pesertas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> skriningRecordsRefs(
    Expression<bool> Function($$SkriningRecordsTableFilterComposer f) f,
  ) {
    final $$SkriningRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.skriningRecords,
      getReferencedColumn: (t) => t.createdBy,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkriningRecordsTableFilterComposer(
            $db: $db,
            $table: $db.skriningRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AdminsTableOrderingComposer
    extends Composer<_$AppDatabase, $AdminsTable> {
  $$AdminsTableOrderingComposer({
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

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get namaLengkap => $composableBuilder(
    column: $table.namaLengkap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdminsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdminsTable> {
  $$AdminsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get namaLengkap => $composableBuilder(
    column: $table.namaLengkap,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => column,
  );

  Expression<T> pesertasRefs<T extends Object>(
    Expression<T> Function($$PesertasTableAnnotationComposer a) f,
  ) {
    final $$PesertasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pesertas,
      getReferencedColumn: (t) => t.createdBy,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PesertasTableAnnotationComposer(
            $db: $db,
            $table: $db.pesertas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> skriningRecordsRefs<T extends Object>(
    Expression<T> Function($$SkriningRecordsTableAnnotationComposer a) f,
  ) {
    final $$SkriningRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.skriningRecords,
      getReferencedColumn: (t) => t.createdBy,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkriningRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.skriningRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AdminsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdminsTable,
          Admin,
          $$AdminsTableFilterComposer,
          $$AdminsTableOrderingComposer,
          $$AdminsTableAnnotationComposer,
          $$AdminsTableCreateCompanionBuilder,
          $$AdminsTableUpdateCompanionBuilder,
          (Admin, $$AdminsTableReferences),
          Admin,
          PrefetchHooks Function({bool pesertasRefs, bool skriningRecordsRefs})
        > {
  $$AdminsTableTableManager(_$AppDatabase db, $AdminsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdminsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdminsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdminsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String> namaLengkap = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
              }) => AdminsCompanion(
                id: id,
                username: username,
                passwordHash: passwordHash,
                namaLengkap: namaLengkap,
                role: role,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastLoginAt: lastLoginAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String username,
                required String passwordHash,
                required String namaLengkap,
                Value<String> role = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
              }) => AdminsCompanion.insert(
                id: id,
                username: username,
                passwordHash: passwordHash,
                namaLengkap: namaLengkap,
                role: role,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastLoginAt: lastLoginAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AdminsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({pesertasRefs = false, skriningRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (pesertasRefs) db.pesertas,
                    if (skriningRecordsRefs) db.skriningRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (pesertasRefs)
                        await $_getPrefetchedData<Admin, $AdminsTable, Peserta>(
                          currentTable: table,
                          referencedTable: $$AdminsTableReferences
                              ._pesertasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AdminsTableReferences(
                                db,
                                table,
                                p0,
                              ).pesertasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.createdBy == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (skriningRecordsRefs)
                        await $_getPrefetchedData<
                          Admin,
                          $AdminsTable,
                          SkriningRecord
                        >(
                          currentTable: table,
                          referencedTable: $$AdminsTableReferences
                              ._skriningRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AdminsTableReferences(
                                db,
                                table,
                                p0,
                              ).skriningRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.createdBy == item.id,
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

typedef $$AdminsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdminsTable,
      Admin,
      $$AdminsTableFilterComposer,
      $$AdminsTableOrderingComposer,
      $$AdminsTableAnnotationComposer,
      $$AdminsTableCreateCompanionBuilder,
      $$AdminsTableUpdateCompanionBuilder,
      (Admin, $$AdminsTableReferences),
      Admin,
      PrefetchHooks Function({bool pesertasRefs, bool skriningRecordsRefs})
    >;
typedef $$PesertasTableCreateCompanionBuilder =
    PesertasCompanion Function({
      Value<int> id,
      required String kodePeserta,
      required String nama,
      required String nik,
      Value<String> jenisKelamin,
      Value<String?> tglLahir,
      Value<String?> alamat,
      required String noHp,
      Value<String> program,
      Value<bool?> pernahKonsultasi,
      Value<bool?> pernahDapatObat,
      Value<String?> tglKunjungan,
      Value<String?> jamKunjungan,
      Value<String> status,
      required String tglDaftar,
      Value<int?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$PesertasTableUpdateCompanionBuilder =
    PesertasCompanion Function({
      Value<int> id,
      Value<String> kodePeserta,
      Value<String> nama,
      Value<String> nik,
      Value<String> jenisKelamin,
      Value<String?> tglLahir,
      Value<String?> alamat,
      Value<String> noHp,
      Value<String> program,
      Value<bool?> pernahKonsultasi,
      Value<bool?> pernahDapatObat,
      Value<String?> tglKunjungan,
      Value<String?> jamKunjungan,
      Value<String> status,
      Value<String> tglDaftar,
      Value<int?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$PesertasTableReferences
    extends BaseReferences<_$AppDatabase, $PesertasTable, Peserta> {
  $$PesertasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AdminsTable _createdByTable(_$AppDatabase db) =>
      db.admins.createAlias('pesertas__created_by__admins__id');

  $$AdminsTableProcessedTableManager? get createdBy {
    final $_column = $_itemColumn<int>('created_by');
    if ($_column == null) return null;
    final manager = $$AdminsTableTableManager(
      $_db,
      $_db.admins,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_createdByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SkriningRecordsTable, List<SkriningRecord>>
  _skriningRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.skriningRecords,
    aliasName: 'pesertas__id__skrining_records__peserta_id',
  );

  $$SkriningRecordsTableProcessedTableManager get skriningRecordsRefs {
    final manager = $$SkriningRecordsTableTableManager(
      $_db,
      $_db.skriningRecords,
    ).filter((f) => f.pesertaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _skriningRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PesertasTableFilterComposer
    extends Composer<_$AppDatabase, $PesertasTable> {
  $$PesertasTableFilterComposer({
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

  ColumnFilters<String> get kodePeserta => $composableBuilder(
    column: $table.kodePeserta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nik => $composableBuilder(
    column: $table.nik,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jenisKelamin => $composableBuilder(
    column: $table.jenisKelamin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tglLahir => $composableBuilder(
    column: $table.tglLahir,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alamat => $composableBuilder(
    column: $table.alamat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noHp => $composableBuilder(
    column: $table.noHp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get program => $composableBuilder(
    column: $table.program,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pernahKonsultasi => $composableBuilder(
    column: $table.pernahKonsultasi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pernahDapatObat => $composableBuilder(
    column: $table.pernahDapatObat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tglKunjungan => $composableBuilder(
    column: $table.tglKunjungan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jamKunjungan => $composableBuilder(
    column: $table.jamKunjungan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tglDaftar => $composableBuilder(
    column: $table.tglDaftar,
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

  $$AdminsTableFilterComposer get createdBy {
    final $$AdminsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdBy,
      referencedTable: $db.admins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdminsTableFilterComposer(
            $db: $db,
            $table: $db.admins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> skriningRecordsRefs(
    Expression<bool> Function($$SkriningRecordsTableFilterComposer f) f,
  ) {
    final $$SkriningRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.skriningRecords,
      getReferencedColumn: (t) => t.pesertaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkriningRecordsTableFilterComposer(
            $db: $db,
            $table: $db.skriningRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PesertasTableOrderingComposer
    extends Composer<_$AppDatabase, $PesertasTable> {
  $$PesertasTableOrderingComposer({
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

  ColumnOrderings<String> get kodePeserta => $composableBuilder(
    column: $table.kodePeserta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nik => $composableBuilder(
    column: $table.nik,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jenisKelamin => $composableBuilder(
    column: $table.jenisKelamin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tglLahir => $composableBuilder(
    column: $table.tglLahir,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alamat => $composableBuilder(
    column: $table.alamat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noHp => $composableBuilder(
    column: $table.noHp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get program => $composableBuilder(
    column: $table.program,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pernahKonsultasi => $composableBuilder(
    column: $table.pernahKonsultasi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pernahDapatObat => $composableBuilder(
    column: $table.pernahDapatObat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tglKunjungan => $composableBuilder(
    column: $table.tglKunjungan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jamKunjungan => $composableBuilder(
    column: $table.jamKunjungan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tglDaftar => $composableBuilder(
    column: $table.tglDaftar,
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

  $$AdminsTableOrderingComposer get createdBy {
    final $$AdminsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdBy,
      referencedTable: $db.admins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdminsTableOrderingComposer(
            $db: $db,
            $table: $db.admins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PesertasTableAnnotationComposer
    extends Composer<_$AppDatabase, $PesertasTable> {
  $$PesertasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kodePeserta => $composableBuilder(
    column: $table.kodePeserta,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get nik =>
      $composableBuilder(column: $table.nik, builder: (column) => column);

  GeneratedColumn<String> get jenisKelamin => $composableBuilder(
    column: $table.jenisKelamin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tglLahir =>
      $composableBuilder(column: $table.tglLahir, builder: (column) => column);

  GeneratedColumn<String> get alamat =>
      $composableBuilder(column: $table.alamat, builder: (column) => column);

  GeneratedColumn<String> get noHp =>
      $composableBuilder(column: $table.noHp, builder: (column) => column);

  GeneratedColumn<String> get program =>
      $composableBuilder(column: $table.program, builder: (column) => column);

  GeneratedColumn<bool> get pernahKonsultasi => $composableBuilder(
    column: $table.pernahKonsultasi,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pernahDapatObat => $composableBuilder(
    column: $table.pernahDapatObat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tglKunjungan => $composableBuilder(
    column: $table.tglKunjungan,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jamKunjungan => $composableBuilder(
    column: $table.jamKunjungan,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get tglDaftar =>
      $composableBuilder(column: $table.tglDaftar, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AdminsTableAnnotationComposer get createdBy {
    final $$AdminsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdBy,
      referencedTable: $db.admins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdminsTableAnnotationComposer(
            $db: $db,
            $table: $db.admins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> skriningRecordsRefs<T extends Object>(
    Expression<T> Function($$SkriningRecordsTableAnnotationComposer a) f,
  ) {
    final $$SkriningRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.skriningRecords,
      getReferencedColumn: (t) => t.pesertaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkriningRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.skriningRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PesertasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PesertasTable,
          Peserta,
          $$PesertasTableFilterComposer,
          $$PesertasTableOrderingComposer,
          $$PesertasTableAnnotationComposer,
          $$PesertasTableCreateCompanionBuilder,
          $$PesertasTableUpdateCompanionBuilder,
          (Peserta, $$PesertasTableReferences),
          Peserta,
          PrefetchHooks Function({bool createdBy, bool skriningRecordsRefs})
        > {
  $$PesertasTableTableManager(_$AppDatabase db, $PesertasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PesertasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PesertasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PesertasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kodePeserta = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String> nik = const Value.absent(),
                Value<String> jenisKelamin = const Value.absent(),
                Value<String?> tglLahir = const Value.absent(),
                Value<String?> alamat = const Value.absent(),
                Value<String> noHp = const Value.absent(),
                Value<String> program = const Value.absent(),
                Value<bool?> pernahKonsultasi = const Value.absent(),
                Value<bool?> pernahDapatObat = const Value.absent(),
                Value<String?> tglKunjungan = const Value.absent(),
                Value<String?> jamKunjungan = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> tglDaftar = const Value.absent(),
                Value<int?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PesertasCompanion(
                id: id,
                kodePeserta: kodePeserta,
                nama: nama,
                nik: nik,
                jenisKelamin: jenisKelamin,
                tglLahir: tglLahir,
                alamat: alamat,
                noHp: noHp,
                program: program,
                pernahKonsultasi: pernahKonsultasi,
                pernahDapatObat: pernahDapatObat,
                tglKunjungan: tglKunjungan,
                jamKunjungan: jamKunjungan,
                status: status,
                tglDaftar: tglDaftar,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kodePeserta,
                required String nama,
                required String nik,
                Value<String> jenisKelamin = const Value.absent(),
                Value<String?> tglLahir = const Value.absent(),
                Value<String?> alamat = const Value.absent(),
                required String noHp,
                Value<String> program = const Value.absent(),
                Value<bool?> pernahKonsultasi = const Value.absent(),
                Value<bool?> pernahDapatObat = const Value.absent(),
                Value<String?> tglKunjungan = const Value.absent(),
                Value<String?> jamKunjungan = const Value.absent(),
                Value<String> status = const Value.absent(),
                required String tglDaftar,
                Value<int?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PesertasCompanion.insert(
                id: id,
                kodePeserta: kodePeserta,
                nama: nama,
                nik: nik,
                jenisKelamin: jenisKelamin,
                tglLahir: tglLahir,
                alamat: alamat,
                noHp: noHp,
                program: program,
                pernahKonsultasi: pernahKonsultasi,
                pernahDapatObat: pernahDapatObat,
                tglKunjungan: tglKunjungan,
                jamKunjungan: jamKunjungan,
                status: status,
                tglDaftar: tglDaftar,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PesertasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({createdBy = false, skriningRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (skriningRecordsRefs) db.skriningRecords,
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
                        if (createdBy) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.createdBy,
                                    referencedTable: $$PesertasTableReferences
                                        ._createdByTable(db),
                                    referencedColumn: $$PesertasTableReferences
                                        ._createdByTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (skriningRecordsRefs)
                        await $_getPrefetchedData<
                          Peserta,
                          $PesertasTable,
                          SkriningRecord
                        >(
                          currentTable: table,
                          referencedTable: $$PesertasTableReferences
                              ._skriningRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PesertasTableReferences(
                                db,
                                table,
                                p0,
                              ).skriningRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pesertaId == item.id,
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

typedef $$PesertasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PesertasTable,
      Peserta,
      $$PesertasTableFilterComposer,
      $$PesertasTableOrderingComposer,
      $$PesertasTableAnnotationComposer,
      $$PesertasTableCreateCompanionBuilder,
      $$PesertasTableUpdateCompanionBuilder,
      (Peserta, $$PesertasTableReferences),
      Peserta,
      PrefetchHooks Function({bool createdBy, bool skriningRecordsRefs})
    >;
typedef $$SkriningRecordsTableCreateCompanionBuilder =
    SkriningRecordsCompanion Function({
      Value<int> id,
      required int pesertaId,
      required String tanggal,
      Value<int?> skor,
      required String kategori,
      Value<bool> isRedFlag,
      required String rekomendasi,
      Value<int?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$SkriningRecordsTableUpdateCompanionBuilder =
    SkriningRecordsCompanion Function({
      Value<int> id,
      Value<int> pesertaId,
      Value<String> tanggal,
      Value<int?> skor,
      Value<String> kategori,
      Value<bool> isRedFlag,
      Value<String> rekomendasi,
      Value<int?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$SkriningRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SkriningRecordsTable, SkriningRecord> {
  $$SkriningRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PesertasTable _pesertaIdTable(_$AppDatabase db) =>
      db.pesertas.createAlias('skrining_records__peserta_id__pesertas__id');

  $$PesertasTableProcessedTableManager get pesertaId {
    final $_column = $_itemColumn<int>('peserta_id')!;

    final manager = $$PesertasTableTableManager(
      $_db,
      $_db.pesertas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pesertaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AdminsTable _createdByTable(_$AppDatabase db) =>
      db.admins.createAlias('skrining_records__created_by__admins__id');

  $$AdminsTableProcessedTableManager? get createdBy {
    final $_column = $_itemColumn<int>('created_by');
    if ($_column == null) return null;
    final manager = $$AdminsTableTableManager(
      $_db,
      $_db.admins,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_createdByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SkriningJawabansTable, List<SkriningJawaban>>
  _skriningJawabansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.skriningJawabans,
    aliasName: 'skrining_records__id__skrining_jawabans__skrining_id',
  );

  $$SkriningJawabansTableProcessedTableManager get skriningJawabansRefs {
    final manager = $$SkriningJawabansTableTableManager(
      $_db,
      $_db.skriningJawabans,
    ).filter((f) => f.skriningId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _skriningJawabansRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SkriningRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SkriningRecordsTable> {
  $$SkriningRecordsTableFilterComposer({
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

  ColumnFilters<String> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skor => $composableBuilder(
    column: $table.skor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRedFlag => $composableBuilder(
    column: $table.isRedFlag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rekomendasi => $composableBuilder(
    column: $table.rekomendasi,
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

  $$PesertasTableFilterComposer get pesertaId {
    final $$PesertasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pesertaId,
      referencedTable: $db.pesertas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PesertasTableFilterComposer(
            $db: $db,
            $table: $db.pesertas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AdminsTableFilterComposer get createdBy {
    final $$AdminsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdBy,
      referencedTable: $db.admins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdminsTableFilterComposer(
            $db: $db,
            $table: $db.admins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> skriningJawabansRefs(
    Expression<bool> Function($$SkriningJawabansTableFilterComposer f) f,
  ) {
    final $$SkriningJawabansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.skriningJawabans,
      getReferencedColumn: (t) => t.skriningId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkriningJawabansTableFilterComposer(
            $db: $db,
            $table: $db.skriningJawabans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SkriningRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SkriningRecordsTable> {
  $$SkriningRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skor => $composableBuilder(
    column: $table.skor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kategori => $composableBuilder(
    column: $table.kategori,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRedFlag => $composableBuilder(
    column: $table.isRedFlag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rekomendasi => $composableBuilder(
    column: $table.rekomendasi,
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

  $$PesertasTableOrderingComposer get pesertaId {
    final $$PesertasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pesertaId,
      referencedTable: $db.pesertas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PesertasTableOrderingComposer(
            $db: $db,
            $table: $db.pesertas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AdminsTableOrderingComposer get createdBy {
    final $$AdminsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdBy,
      referencedTable: $db.admins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdminsTableOrderingComposer(
            $db: $db,
            $table: $db.admins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SkriningRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SkriningRecordsTable> {
  $$SkriningRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tanggal =>
      $composableBuilder(column: $table.tanggal, builder: (column) => column);

  GeneratedColumn<int> get skor =>
      $composableBuilder(column: $table.skor, builder: (column) => column);

  GeneratedColumn<String> get kategori =>
      $composableBuilder(column: $table.kategori, builder: (column) => column);

  GeneratedColumn<bool> get isRedFlag =>
      $composableBuilder(column: $table.isRedFlag, builder: (column) => column);

  GeneratedColumn<String> get rekomendasi => $composableBuilder(
    column: $table.rekomendasi,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PesertasTableAnnotationComposer get pesertaId {
    final $$PesertasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pesertaId,
      referencedTable: $db.pesertas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PesertasTableAnnotationComposer(
            $db: $db,
            $table: $db.pesertas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AdminsTableAnnotationComposer get createdBy {
    final $$AdminsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdBy,
      referencedTable: $db.admins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdminsTableAnnotationComposer(
            $db: $db,
            $table: $db.admins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> skriningJawabansRefs<T extends Object>(
    Expression<T> Function($$SkriningJawabansTableAnnotationComposer a) f,
  ) {
    final $$SkriningJawabansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.skriningJawabans,
      getReferencedColumn: (t) => t.skriningId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkriningJawabansTableAnnotationComposer(
            $db: $db,
            $table: $db.skriningJawabans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SkriningRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SkriningRecordsTable,
          SkriningRecord,
          $$SkriningRecordsTableFilterComposer,
          $$SkriningRecordsTableOrderingComposer,
          $$SkriningRecordsTableAnnotationComposer,
          $$SkriningRecordsTableCreateCompanionBuilder,
          $$SkriningRecordsTableUpdateCompanionBuilder,
          (SkriningRecord, $$SkriningRecordsTableReferences),
          SkriningRecord,
          PrefetchHooks Function({
            bool pesertaId,
            bool createdBy,
            bool skriningJawabansRefs,
          })
        > {
  $$SkriningRecordsTableTableManager(
    _$AppDatabase db,
    $SkriningRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SkriningRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SkriningRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SkriningRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pesertaId = const Value.absent(),
                Value<String> tanggal = const Value.absent(),
                Value<int?> skor = const Value.absent(),
                Value<String> kategori = const Value.absent(),
                Value<bool> isRedFlag = const Value.absent(),
                Value<String> rekomendasi = const Value.absent(),
                Value<int?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SkriningRecordsCompanion(
                id: id,
                pesertaId: pesertaId,
                tanggal: tanggal,
                skor: skor,
                kategori: kategori,
                isRedFlag: isRedFlag,
                rekomendasi: rekomendasi,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pesertaId,
                required String tanggal,
                Value<int?> skor = const Value.absent(),
                required String kategori,
                Value<bool> isRedFlag = const Value.absent(),
                required String rekomendasi,
                Value<int?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SkriningRecordsCompanion.insert(
                id: id,
                pesertaId: pesertaId,
                tanggal: tanggal,
                skor: skor,
                kategori: kategori,
                isRedFlag: isRedFlag,
                rekomendasi: rekomendasi,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SkriningRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                pesertaId = false,
                createdBy = false,
                skriningJawabansRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (skriningJawabansRefs) db.skriningJawabans,
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
                        if (pesertaId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.pesertaId,
                                    referencedTable:
                                        $$SkriningRecordsTableReferences
                                            ._pesertaIdTable(db),
                                    referencedColumn:
                                        $$SkriningRecordsTableReferences
                                            ._pesertaIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (createdBy) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.createdBy,
                                    referencedTable:
                                        $$SkriningRecordsTableReferences
                                            ._createdByTable(db),
                                    referencedColumn:
                                        $$SkriningRecordsTableReferences
                                            ._createdByTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (skriningJawabansRefs)
                        await $_getPrefetchedData<
                          SkriningRecord,
                          $SkriningRecordsTable,
                          SkriningJawaban
                        >(
                          currentTable: table,
                          referencedTable: $$SkriningRecordsTableReferences
                              ._skriningJawabansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SkriningRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).skriningJawabansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.skriningId == item.id,
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

typedef $$SkriningRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SkriningRecordsTable,
      SkriningRecord,
      $$SkriningRecordsTableFilterComposer,
      $$SkriningRecordsTableOrderingComposer,
      $$SkriningRecordsTableAnnotationComposer,
      $$SkriningRecordsTableCreateCompanionBuilder,
      $$SkriningRecordsTableUpdateCompanionBuilder,
      (SkriningRecord, $$SkriningRecordsTableReferences),
      SkriningRecord,
      PrefetchHooks Function({
        bool pesertaId,
        bool createdBy,
        bool skriningJawabansRefs,
      })
    >;
typedef $$SkriningJawabansTableCreateCompanionBuilder =
    SkriningJawabansCompanion Function({
      Value<int> id,
      required int skriningId,
      required int nomor,
      Value<bool?> jawaban,
    });
typedef $$SkriningJawabansTableUpdateCompanionBuilder =
    SkriningJawabansCompanion Function({
      Value<int> id,
      Value<int> skriningId,
      Value<int> nomor,
      Value<bool?> jawaban,
    });

final class $$SkriningJawabansTableReferences
    extends
        BaseReferences<_$AppDatabase, $SkriningJawabansTable, SkriningJawaban> {
  $$SkriningJawabansTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SkriningRecordsTable _skriningIdTable(_$AppDatabase db) => db
      .skriningRecords
      .createAlias('skrining_jawabans__skrining_id__skrining_records__id');

  $$SkriningRecordsTableProcessedTableManager get skriningId {
    final $_column = $_itemColumn<int>('skrining_id')!;

    final manager = $$SkriningRecordsTableTableManager(
      $_db,
      $_db.skriningRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_skriningIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SkriningJawabansTableFilterComposer
    extends Composer<_$AppDatabase, $SkriningJawabansTable> {
  $$SkriningJawabansTableFilterComposer({
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

  ColumnFilters<int> get nomor => $composableBuilder(
    column: $table.nomor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get jawaban => $composableBuilder(
    column: $table.jawaban,
    builder: (column) => ColumnFilters(column),
  );

  $$SkriningRecordsTableFilterComposer get skriningId {
    final $$SkriningRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skriningId,
      referencedTable: $db.skriningRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkriningRecordsTableFilterComposer(
            $db: $db,
            $table: $db.skriningRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SkriningJawabansTableOrderingComposer
    extends Composer<_$AppDatabase, $SkriningJawabansTable> {
  $$SkriningJawabansTableOrderingComposer({
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

  ColumnOrderings<int> get nomor => $composableBuilder(
    column: $table.nomor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get jawaban => $composableBuilder(
    column: $table.jawaban,
    builder: (column) => ColumnOrderings(column),
  );

  $$SkriningRecordsTableOrderingComposer get skriningId {
    final $$SkriningRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skriningId,
      referencedTable: $db.skriningRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkriningRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.skriningRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SkriningJawabansTableAnnotationComposer
    extends Composer<_$AppDatabase, $SkriningJawabansTable> {
  $$SkriningJawabansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get nomor =>
      $composableBuilder(column: $table.nomor, builder: (column) => column);

  GeneratedColumn<bool> get jawaban =>
      $composableBuilder(column: $table.jawaban, builder: (column) => column);

  $$SkriningRecordsTableAnnotationComposer get skriningId {
    final $$SkriningRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.skriningId,
      referencedTable: $db.skriningRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SkriningRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.skriningRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SkriningJawabansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SkriningJawabansTable,
          SkriningJawaban,
          $$SkriningJawabansTableFilterComposer,
          $$SkriningJawabansTableOrderingComposer,
          $$SkriningJawabansTableAnnotationComposer,
          $$SkriningJawabansTableCreateCompanionBuilder,
          $$SkriningJawabansTableUpdateCompanionBuilder,
          (SkriningJawaban, $$SkriningJawabansTableReferences),
          SkriningJawaban,
          PrefetchHooks Function({bool skriningId})
        > {
  $$SkriningJawabansTableTableManager(
    _$AppDatabase db,
    $SkriningJawabansTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SkriningJawabansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SkriningJawabansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SkriningJawabansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> skriningId = const Value.absent(),
                Value<int> nomor = const Value.absent(),
                Value<bool?> jawaban = const Value.absent(),
              }) => SkriningJawabansCompanion(
                id: id,
                skriningId: skriningId,
                nomor: nomor,
                jawaban: jawaban,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int skriningId,
                required int nomor,
                Value<bool?> jawaban = const Value.absent(),
              }) => SkriningJawabansCompanion.insert(
                id: id,
                skriningId: skriningId,
                nomor: nomor,
                jawaban: jawaban,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SkriningJawabansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({skriningId = false}) {
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
                    if (skriningId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.skriningId,
                                referencedTable:
                                    $$SkriningJawabansTableReferences
                                        ._skriningIdTable(db),
                                referencedColumn:
                                    $$SkriningJawabansTableReferences
                                        ._skriningIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$SkriningJawabansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SkriningJawabansTable,
      SkriningJawaban,
      $$SkriningJawabansTableFilterComposer,
      $$SkriningJawabansTableOrderingComposer,
      $$SkriningJawabansTableAnnotationComposer,
      $$SkriningJawabansTableCreateCompanionBuilder,
      $$SkriningJawabansTableUpdateCompanionBuilder,
      (SkriningJawaban, $$SkriningJawabansTableReferences),
      SkriningJawaban,
      PrefetchHooks Function({bool skriningId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AdminsTableTableManager get admins =>
      $$AdminsTableTableManager(_db, _db.admins);
  $$PesertasTableTableManager get pesertas =>
      $$PesertasTableTableManager(_db, _db.pesertas);
  $$SkriningRecordsTableTableManager get skriningRecords =>
      $$SkriningRecordsTableTableManager(_db, _db.skriningRecords);
  $$SkriningJawabansTableTableManager get skriningJawabans =>
      $$SkriningJawabansTableTableManager(_db, _db.skriningJawabans);
}
