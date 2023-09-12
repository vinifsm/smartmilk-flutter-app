// **************************************************************************
// FloorGenerator
// **************************************************************************
part of 'AppDatabase.dart';

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  AnimalDAO? _animalDaoInstance;

  AplicacaoDAO? _aplicacaoDaoInstance;

  GestacaoDAO? _gestacaoDaoInstance;

  LoteDAO? _loteDaoInstance;

  MedicacaoDAO? _medicacaoDaoInstance;

  ProducaoDAO? _producaoDaoInstance;

  UsuarioDAO? _usuarioDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Animal` (`_id` INTEGER PRIMARY KEY AUTOINCREMENT, `_numero` INTEGER NOT NULL, `_nome` TEXT, `_peso` REAL, `_cor` TEXT, `_raca` INTEGER, `_produzLeite` INTEGER, `_lote` INTEGER, FOREIGN KEY (`_lote`) REFERENCES `Lote` (`_id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Aplicacao` (`_id` INTEGER PRIMARY KEY AUTOINCREMENT, `_medicacao` INTEGER, `_animal` INTEGER, `_lote` INTEGER, `_dataAplicacao` TEXT, FOREIGN KEY (`_medicacao`) REFERENCES `Medicacao` (`_id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`_animal`) REFERENCES `Animal` (`_id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`_lote`) REFERENCES `Lote` (`_id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Gestacao` (`_id` INTEGER PRIMARY KEY AUTOINCREMENT, `_animalGestante` INTEGER, `_animalSemen` TEXT NOT NULL, `_dataInicial` TEXT NOT NULL, `_dataFinal` TEXT, `_statusGest` TEXT, FOREIGN KEY (`_animalGestante`) REFERENCES `Animal` (`_id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Lote` (`_id` INTEGER PRIMARY KEY AUTOINCREMENT, `_nome` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Medicacao` (`_id` INTEGER PRIMARY KEY AUTOINCREMENT, `_nome` TEXT, `_descricao` TEXT, `_tipo` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Producao` (`_id` INTEGER PRIMARY KEY AUTOINCREMENT, `_dataProd` TEXT, `_quantidade` REAL, `_periodo` TEXT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Usuario` (`_id` INTEGER PRIMARY KEY AUTOINCREMENT, `_nome` TEXT NOT NULL, `_senha` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  AnimalDAO get animalDao {
    return _animalDaoInstance ??= _$AnimalDAO(database, changeListener);
  }

  @override
  AplicacaoDAO get aplicacaoDao {
    return _aplicacaoDaoInstance ??= _$AplicacaoDAO(database, changeListener);
  }

  @override
  GestacaoDAO get gestacaoDao {
    return _gestacaoDaoInstance ??= _$GestacaoDAO(database, changeListener);
  }

  @override
  LoteDAO get loteDao {
    return _loteDaoInstance ??= _$LoteDAO(database, changeListener);
  }

  @override
  MedicacaoDAO get medicacaoDao {
    return _medicacaoDaoInstance ??= _$MedicacaoDAO(database, changeListener);
  }

  @override
  ProducaoDAO get producaoDao {
    return _producaoDaoInstance ??= _$ProducaoDAO(database, changeListener);
  }

  @override
  UsuarioDAO get usuarioDao {
    return _usuarioDaoInstance ??= _$UsuarioDAO(database, changeListener);
  }
}

class _$AnimalDAO extends AnimalDAO {
  _$AnimalDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _animalInsertionAdapter = InsertionAdapter(
            database,
            'Animal',
            (Animal item) => <String, Object?>{
                  '_id': item.id,
                  '_numero': item.numero,
                  '_nome': item.nome,
                  '_peso': item.peso,
                  '_cor': item.cor,
                  '_raca': item.raca?.index,
                  '_produzLeite': item.produzLeite == null
                      ? null
                      : (item.produzLeite! ? 1 : 0),
                  '_lote': item.lote
                },
            changeListener),
        _animalUpdateAdapter = UpdateAdapter(
            database,
            'Animal',
            ['_id'],
            (Animal item) => <String, Object?>{
                  '_id': item.id,
                  '_numero': item.numero,
                  '_nome': item.nome,
                  '_peso': item.peso,
                  '_cor': item.cor,
                  '_raca': item.raca?.index,
                  '_produzLeite': item.produzLeite == null
                      ? null
                      : (item.produzLeite! ? 1 : 0),
                  '_lote': item.lote
                },
            changeListener),
        _animalDeletionAdapter = DeletionAdapter(
            database,
            'Animal',
            ['_id'],
            (Animal item) => <String, Object?>{
                  '_id': item.id,
                  '_numero': item.numero,
                  '_nome': item.nome,
                  '_peso': item.peso,
                  '_cor': item.cor,
                  '_raca': item.raca?.index,
                  '_produzLeite': item.produzLeite == null
                      ? null
                      : (item.produzLeite! ? 1 : 0),
                  '_lote': item.lote
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Animal> _animalInsertionAdapter;

  final UpdateAdapter<Animal> _animalUpdateAdapter;

  final DeletionAdapter<Animal> _animalDeletionAdapter;

  @override
  Future<List<Animal>> findAllAnimal() async {
    return _queryAdapter.queryList('SELECT * FROM animal',
        mapper: (Map<String, Object?> row) => Animal(
            row['_id'] as int?,
            row['_numero'] as int,
            row['_nome'] as String?,
            row['_peso'] as double?,
            row['_cor'] as String?,
            row['_raca'] == null ? null : Raca.values[row['_raca'] as int],
            row['_produzLeite'] == null
                ? null
                : (row['_produzLeite'] as int) != 0,
            row['_lote'] as int?));
  }

  @override
  Future<List<Animal>> findAnimalById(int id) async {
    return _queryAdapter.queryList('SELECT * FROM animal WHERE _id = ?1',
        mapper: (Map<String, Object?> row) => Animal(
            row['_id'] as int?,
            row['_numero'] as int,
            row['_nome'] as String?,
            row['_peso'] as double?,
            row['_cor'] as String?,
            row['_raca'] == null ? null : Raca.values[row['_raca'] as int],
            row['_produzLeite'] == null
                ? null
                : (row['_produzLeite'] as int) != 0,
            row['_lote'] as int?),
        arguments: [id]);
  }

  @override
  Future<List<Animal>> findAnimalWhereLike(String texto) async {
    return _queryAdapter.queryList(
        'SELECT * FROM animal WHERE _nome LIKE ?1 OR _numero LIKE ?1',
        mapper: (Map<String, Object?> row) => Animal(
            row['_id'] as int?,
            row['_numero'] as int,
            row['_nome'] as String?,
            row['_peso'] as double?,
            row['_cor'] as String?,
            row['_raca'] == null ? null : Raca.values[row['_raca'] as int],
            row['_produzLeite'] == null
                ? null
                : (row['_produzLeite'] as int) != 0,
            row['_lote'] as int?),
        arguments: [texto]);
  }

  @override
  Future<List<Animal>> findAnimalFilter(double pesoMin, double pesoMax) async {
    return _queryAdapter.queryList(
        'SELECT * FROM animal WHERE _peso > ?1 AND _peso < ?2',
        mapper: (Map<String, Object?> row) => Animal(
            row['_id'] as int?,
            row['_numero'] as int,
            row['_nome'] as String?,
            row['_peso'] as double?,
            row['_cor'] as String?,
            row['_raca'] == null ? null : Raca.values[row['_raca'] as int],
            row['_produzLeite'] == null
                ? null
                : (row['_produzLeite'] as int) != 0,
            row['_lote'] as int?),
        arguments: [pesoMin, pesoMax]);
  }

  @override
  Future<List<Animal>> findAnimalByLote(int lote) async {
    return _queryAdapter.queryList('SELECT * FROM animal WHERE _lote = ?1',
        mapper: (Map<String, Object?> row) => Animal(
            row['_id'] as int?,
            row['_numero'] as int,
            row['_nome'] as String?,
            row['_peso'] as double?,
            row['_cor'] as String?,
            row['_raca'] == null ? null : Raca.values[row['_raca'] as int],
            row['_produzLeite'] == null
                ? null
                : (row['_produzLeite'] as int) != 0,
            row['_lote'] as int?),
        arguments: [lote]);
  }

  @override
  Future<List<Animal>> findAnimalWithNullLote() async {
    return _queryAdapter.queryList('SELECT * FROM animal WHERE _lote IS null',
        mapper: (Map<String, Object?> row) => Animal(
            row['_id'] as int?,
            row['_numero'] as int,
            row['_nome'] as String?,
            row['_peso'] as double?,
            row['_cor'] as String?,
            row['_raca'] == null ? null : Raca.values[row['_raca'] as int],
            row['_produzLeite'] == null
                ? null
                : (row['_produzLeite'] as int) != 0,
            row['_lote'] as int?));
  }

  @override
  Future<List<Animal>> getMaxAnimal() async {
    return _queryAdapter.queryList(
        'Select * from animal order by _id desc limit 1',
        mapper: (Map<String, Object?> row) => Animal(
            row['_id'] as int?,
            row['_numero'] as int,
            row['_nome'] as String?,
            row['_peso'] as double?,
            row['_cor'] as String?,
            row['_raca'] == null ? null : Raca.values[row['_raca'] as int],
            row['_produzLeite'] == null
                ? null
                : (row['_produzLeite'] as int) != 0,
            row['_lote'] as int?));
  }

  @override
  Stream<List<Animal>> fetchStreamData() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM animal order by _id desc',
        mapper: (Map<String, Object?> row) => Animal(
            row['_id'] as int?,
            row['_numero'] as int,
            row['_nome'] as String?,
            row['_peso'] as double?,
            row['_cor'] as String?,
            row['_raca'] == null ? null : Raca.values[row['_raca'] as int],
            row['_produzLeite'] == null
                ? null
                : (row['_produzLeite'] as int) != 0,
            row['_lote'] as int?),
        queryableName: 'animal',
        isView: false);
  }

  @override
  Future<void> deleteAnimal(int id) async {
    await _queryAdapter
        .queryNoReturn('delete from animal where _id = ?1', arguments: [id]);
  }

  @override
  Future<void> insertAnimal(Animal animal) async {
    await _animalInsertionAdapter.insert(animal, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertAllAnimal(List<Animal> animal) {
    return _animalInsertionAdapter.insertListAndReturnIds(
        animal, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAnimal(Animal animal) async {
    await _animalUpdateAdapter.update(animal, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteAll(List<Animal> list) {
    return _animalDeletionAdapter.deleteListAndReturnChangedRows(list);
  }
}

class _$AplicacaoDAO extends AplicacaoDAO {
  _$AplicacaoDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _aplicacaoInsertionAdapter = InsertionAdapter(
            database,
            'Aplicacao',
            (Aplicacao item) => <String, Object?>{
                  '_id': item.id,
                  '_medicacao': item.medicacao,
                  '_animal': item.animal,
                  '_lote': item.lote,
                  '_dataAplicacao': item.dataAplicacao
                },
            changeListener),
        _aplicacaoUpdateAdapter = UpdateAdapter(
            database,
            'Aplicacao',
            ['_id'],
            (Aplicacao item) => <String, Object?>{
                  '_id': item.id,
                  '_medicacao': item.medicacao,
                  '_animal': item.animal,
                  '_lote': item.lote,
                  '_dataAplicacao': item.dataAplicacao
                },
            changeListener),
        _aplicacaoDeletionAdapter = DeletionAdapter(
            database,
            'Aplicacao',
            ['_id'],
            (Aplicacao item) => <String, Object?>{
                  '_id': item.id,
                  '_medicacao': item.medicacao,
                  '_animal': item.animal,
                  '_lote': item.lote,
                  '_dataAplicacao': item.dataAplicacao
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Aplicacao> _aplicacaoInsertionAdapter;

  final UpdateAdapter<Aplicacao> _aplicacaoUpdateAdapter;

  final DeletionAdapter<Aplicacao> _aplicacaoDeletionAdapter;

  @override
  Future<List<Aplicacao>> findAllAplicacao() async {
    return _queryAdapter.queryList('SELECT * FROM aplicacao',
        mapper: (Map<String, Object?> row) => Aplicacao(
            row['_id'] as int?,
            row['_medicacao'] as int?,
            row['_animal'] as int?,
            row['_lote'] as int?,
            row['_dataAplicacao'] as String?));
  }

  @override
  Future<List<Aplicacao>> findAplicacaoById(int id) async {
    return _queryAdapter.queryList('SELECT * FROM aplicacao WHERE _id LIKE ?1',
        mapper: (Map<String, Object?> row) => Aplicacao(
            row['_id'] as int?,
            row['_medicacao'] as int?,
            row['_animal'] as int?,
            row['_lote'] as int?,
            row['_dataAplicacao'] as String?),
        arguments: [id]);
  }

  @override
  Future<List<Aplicacao>> findAllAplicacaoWhereLike(String texto) async {
    return _queryAdapter.queryList(
        'SELECT * FROM aplicacao WHERE _dataAplicacao LIKE ?1',
        mapper: (Map<String, Object?> row) => Aplicacao(
            row['_id'] as int?,
            row['_medicacao'] as int?,
            row['_animal'] as int?,
            row['_lote'] as int?,
            row['_dataAplicacao'] as String?),
        arguments: [texto]);
  }

  @override
  Future<List<Aplicacao>> getMaxAplicacao() async {
    return _queryAdapter.queryList(
        'Select * from aplicacao order by _id desc limit 1',
        mapper: (Map<String, Object?> row) => Aplicacao(
            row['_id'] as int?,
            row['_medicacao'] as int?,
            row['_animal'] as int?,
            row['_lote'] as int?,
            row['_dataAplicacao'] as String?));
  }

  @override
  Stream<List<Aplicacao>> fetchStreamData() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM aplicacao order by _id desc',
        mapper: (Map<String, Object?> row) => Aplicacao(
            row['_id'] as int?,
            row['_medicacao'] as int?,
            row['_animal'] as int?,
            row['_lote'] as int?,
            row['_dataAplicacao'] as String?),
        queryableName: 'aplicacao',
        isView: false);
  }

  @override
  Future<void> deleteAplicacao(int id) async {
    await _queryAdapter
        .queryNoReturn('delete from aplicacao where _id = ?1', arguments: [id]);
  }

  @override
  Future<void> insertAplicacao(Aplicacao aplicacao) async {
    await _aplicacaoInsertionAdapter.insert(
        aplicacao, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertAllAplicacao(List<Aplicacao> aplicacao) {
    return _aplicacaoInsertionAdapter.insertListAndReturnIds(
        aplicacao, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAplicacao(Aplicacao aplicacao) async {
    await _aplicacaoUpdateAdapter.update(aplicacao, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteAll(List<Aplicacao> list) {
    return _aplicacaoDeletionAdapter.deleteListAndReturnChangedRows(list);
  }
}

class _$GestacaoDAO extends GestacaoDAO {
  _$GestacaoDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _gestacaoInsertionAdapter = InsertionAdapter(
            database,
            'Gestacao',
            (Gestacao item) => <String, Object?>{
                  '_id': item.id,
                  '_animalGestante': item.animalGestante,
                  '_animalSemen': item.animalSemen,
                  '_dataInicial': item.dataInicial,
                  '_dataFinal': item.dataFinal,
                  '_statusGest': item.statusGest
                },
            changeListener),
        _gestacaoUpdateAdapter = UpdateAdapter(
            database,
            'Gestacao',
            ['_id'],
            (Gestacao item) => <String, Object?>{
                  '_id': item.id,
                  '_animalGestante': item.animalGestante,
                  '_animalSemen': item.animalSemen,
                  '_dataInicial': item.dataInicial,
                  '_dataFinal': item.dataFinal,
                  '_statusGest': item.statusGest
                },
            changeListener),
        _gestacaoDeletionAdapter = DeletionAdapter(
            database,
            'Gestacao',
            ['_id'],
            (Gestacao item) => <String, Object?>{
                  '_id': item.id,
                  '_animalGestante': item.animalGestante,
                  '_animalSemen': item.animalSemen,
                  '_dataInicial': item.dataInicial,
                  '_dataFinal': item.dataFinal,
                  '_statusGest': item.statusGest
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Gestacao> _gestacaoInsertionAdapter;

  final UpdateAdapter<Gestacao> _gestacaoUpdateAdapter;

  final DeletionAdapter<Gestacao> _gestacaoDeletionAdapter;

  @override
  Future<List<Gestacao>> findAllGestacao() async {
    return _queryAdapter.queryList('SELECT * FROM gestacao',
        mapper: (Map<String, Object?> row) => Gestacao(
            row['_id'] as int?,
            row['_animalGestante'] as int?,
            row['_animalSemen'] as String,
            row['_dataInicial'] as String,
            row['_dataFinal'] as String?,
            row['_statusGest'] as String?));
  }

  @override
  Future<List<Gestacao>> findGestacaoById(int id) async {
    return _queryAdapter.queryList('SELECT * FROM gestacao WHERE _id = ?1',
        mapper: (Map<String, Object?> row) => Gestacao(
            row['_id'] as int?,
            row['_animalGestante'] as int?,
            row['_animalSemen'] as String,
            row['_dataInicial'] as String,
            row['_dataFinal'] as String?,
            row['_statusGest'] as String?),
        arguments: [id]);
  }

  @override
  Future<List<Gestacao>> findGestacaoWhereLike(String texto) async {
    return _queryAdapter.queryList(
        'SELECT * FROM gestacao WHERE _animalGestante IN (SELECT _id FROM animal WHERE _nome LIKE ?1);',
        mapper: (Map<String, Object?> row) => Gestacao(row['_id'] as int?, row['_animalGestante'] as int?, row['_animalSemen'] as String, row['_dataInicial'] as String, row['_dataFinal'] as String?, row['_statusGest'] as String?),
        arguments: [texto]);
  }

  @override
  Future<List<Gestacao>> findGestacaoBetween(
      String dataInicial, String dataFinal) async {
    return _queryAdapter.queryList(
        'SELECT * FROM gestacao WHERE _dataInicial BETWEEN ?1 AND ?2;',
        mapper: (Map<String, Object?> row) => Gestacao(
            row['_id'] as int?,
            row['_animalGestante'] as int?,
            row['_animalSemen'] as String,
            row['_dataInicial'] as String,
            row['_dataFinal'] as String?,
            row['_statusGest'] as String?),
        arguments: [dataInicial, dataFinal]);
  }

  @override
  Future<List<Gestacao>> getMaxGestacao() async {
    return _queryAdapter.queryList(
        'Select * from gestacao order by _id desc limit 1',
        mapper: (Map<String, Object?> row) => Gestacao(
            row['_id'] as int?,
            row['_animalGestante'] as int?,
            row['_animalSemen'] as String,
            row['_dataInicial'] as String,
            row['_dataFinal'] as String?,
            row['_statusGest'] as String?));
  }

  @override
  Stream<List<Gestacao>> fetchStreamData() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM gestacao order by _id desc',
        mapper: (Map<String, Object?> row) => Gestacao(
            row['_id'] as int?,
            row['_animalGestante'] as int?,
            row['_animalSemen'] as String,
            row['_dataInicial'] as String,
            row['_dataFinal'] as String?,
            row['_statusGest'] as String?),
        queryableName: 'gestacao',
        isView: false);
  }

  @override
  Future<void> deleteGestacao(int id) async {
    await _queryAdapter
        .queryNoReturn('delete from gestacao where _id = ?1', arguments: [id]);
  }

  @override
  Future<void> insertGestacao(Gestacao gestacao) async {
    await _gestacaoInsertionAdapter.insert(gestacao, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertAllGestacao(List<Gestacao> gestacao) {
    return _gestacaoInsertionAdapter.insertListAndReturnIds(
        gestacao, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateGestacao(Gestacao gestacao) async {
    await _gestacaoUpdateAdapter.update(gestacao, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteAll(List<Gestacao> list) {
    return _gestacaoDeletionAdapter.deleteListAndReturnChangedRows(list);
  }
}

class _$LoteDAO extends LoteDAO {
  _$LoteDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _loteInsertionAdapter = InsertionAdapter(
            database,
            'Lote',
            (Lote item) =>
                <String, Object?>{'_id': item.id, '_nome': item.nome},
            changeListener),
        _loteUpdateAdapter = UpdateAdapter(
            database,
            'Lote',
            ['_id'],
            (Lote item) =>
                <String, Object?>{'_id': item.id, '_nome': item.nome},
            changeListener),
        _loteDeletionAdapter = DeletionAdapter(
            database,
            'Lote',
            ['_id'],
            (Lote item) =>
                <String, Object?>{'_id': item.id, '_nome': item.nome},
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Lote> _loteInsertionAdapter;

  final UpdateAdapter<Lote> _loteUpdateAdapter;

  final DeletionAdapter<Lote> _loteDeletionAdapter;

  @override
  Future<List<Lote>> findAllLote() async {
    return _queryAdapter.queryList('SELECT * FROM lote',
        mapper: (Map<String, Object?> row) =>
            Lote(row['_id'] as int?, row['_nome'] as String));
  }

  @override
  Future<List<Lote>> findLoteWhereLike(String texto) async {
    return _queryAdapter.queryList('SELECT * FROM lote WHERE _nome LIKE ?1',
        mapper: (Map<String, Object?> row) =>
            Lote(row['_id'] as int?, row['_nome'] as String),
        arguments: [texto]);
  }

  @override
  Future<List<Lote>> getMaxLote() async {
    return _queryAdapter.queryList(
        'Select * from lote order by _id desc limit 1',
        mapper: (Map<String, Object?> row) =>
            Lote(row['_id'] as int?, row['_nome'] as String));
  }

  @override
  Stream<List<Lote>> fetchStreamData() {
    return _queryAdapter.queryListStream('SELECT * FROM lote order by _id desc',
        mapper: (Map<String, Object?> row) =>
            Lote(row['_id'] as int?, row['_nome'] as String),
        queryableName: 'lote',
        isView: false);
  }

  @override
  Future<void> deleteLote(int id) async {
    await _queryAdapter
        .queryNoReturn('delete from lote where _id = ?1', arguments: [id]);
  }

  @override
  Future<void> insertLote(Lote lote) async {
    await _loteInsertionAdapter.insert(lote, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertAllLote(List<Lote> lote) {
    return _loteInsertionAdapter.insertListAndReturnIds(
        lote, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateLote(Lote lote) async {
    await _loteUpdateAdapter.update(lote, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteAll(List<Lote> list) {
    return _loteDeletionAdapter.deleteListAndReturnChangedRows(list);
  }
}

class _$MedicacaoDAO extends MedicacaoDAO {
  _$MedicacaoDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _medicacaoInsertionAdapter = InsertionAdapter(
            database,
            'Medicacao',
            (Medicacao item) => <String, Object?>{
                  '_id': item.id,
                  '_nome': item.nome,
                  '_descricao': item.descricao,
                  '_tipo': item.tipo?.index
                },
            changeListener),
        _medicacaoUpdateAdapter = UpdateAdapter(
            database,
            'Medicacao',
            ['_id'],
            (Medicacao item) => <String, Object?>{
                  '_id': item.id,
                  '_nome': item.nome,
                  '_descricao': item.descricao,
                  '_tipo': item.tipo?.index
                },
            changeListener),
        _medicacaoDeletionAdapter = DeletionAdapter(
            database,
            'Medicacao',
            ['_id'],
            (Medicacao item) => <String, Object?>{
                  '_id': item.id,
                  '_nome': item.nome,
                  '_descricao': item.descricao,
                  '_tipo': item.tipo?.index
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Medicacao> _medicacaoInsertionAdapter;

  final UpdateAdapter<Medicacao> _medicacaoUpdateAdapter;

  final DeletionAdapter<Medicacao> _medicacaoDeletionAdapter;

  @override
  Future<List<Medicacao>> findAllMedicacao() async {
    return _queryAdapter.queryList('SELECT * FROM medicacao',
        mapper: (Map<String, Object?> row) => Medicacao(
            row['_id'] as int?,
            row['_nome'] as String?,
            row['_descricao'] as String?,
            row['_tipo'] == null
                ? null
                : TipoMedicacao.values[row['_tipo'] as int]));
  }

  @override
  Future<List<Medicacao>> findMedicacaoById(int id) async {
    return _queryAdapter.queryList('SELECT * FROM medicacao WHERE _id = ?1',
        mapper: (Map<String, Object?> row) => Medicacao(
            row['_id'] as int?,
            row['_nome'] as String?,
            row['_descricao'] as String?,
            row['_tipo'] == null
                ? null
                : TipoMedicacao.values[row['_tipo'] as int]),
        arguments: [id]);
  }

  @override
  Future<List<Medicacao>> findAllMedicacaoWhereLikeNome(String texto) async {
    return _queryAdapter.queryList(
        'SELECT * FROM medicacao WHERE _nome LIKE ?1',
        mapper: (Map<String, Object?> row) => Medicacao(
            row['_id'] as int?,
            row['_nome'] as String?,
            row['_descricao'] as String?,
            row['_tipo'] == null
                ? null
                : TipoMedicacao.values[row['_tipo'] as int]),
        arguments: [texto]);
  }

  @override
  Future<List<Medicacao>> getMaxMedicacao() async {
    return _queryAdapter.queryList(
        'Select * from medicacao order by _id desc limit 1',
        mapper: (Map<String, Object?> row) => Medicacao(
            row['_id'] as int?,
            row['_nome'] as String?,
            row['_descricao'] as String?,
            row['_tipo'] == null
                ? null
                : TipoMedicacao.values[row['_tipo'] as int]));
  }

  @override
  Stream<List<Medicacao>> fetchStreamData() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM medicacao order by _id desc',
        mapper: (Map<String, Object?> row) => Medicacao(
            row['_id'] as int?,
            row['_nome'] as String?,
            row['_descricao'] as String?,
            row['_tipo'] == null
                ? null
                : TipoMedicacao.values[row['_tipo'] as int]),
        queryableName: 'medicacao',
        isView: false);
  }

  @override
  Future<void> deleteMedicacao(int id) async {
    await _queryAdapter
        .queryNoReturn('delete from medicacao where _id = ?1', arguments: [id]);
  }

  @override
  Future<void> insertMedicacao(Medicacao medicacao) async {
    await _medicacaoInsertionAdapter.insert(
        medicacao, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertAllMedicacao(List<Medicacao> medicacao) {
    return _medicacaoInsertionAdapter.insertListAndReturnIds(
        medicacao, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateMedicacao(Medicacao medicacao) async {
    await _medicacaoUpdateAdapter.update(medicacao, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteAll(List<Medicacao> list) {
    return _medicacaoDeletionAdapter.deleteListAndReturnChangedRows(list);
  }
}

class _$ProducaoDAO extends ProducaoDAO {
  _$ProducaoDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _producaoInsertionAdapter = InsertionAdapter(
            database,
            'Producao',
            (Producao item) => <String, Object?>{
                  '_id': item.id,
                  '_dataProd': item.dataProd,
                  '_quantidade': item.quantidade,
                  '_periodo': item.periodo
                },
            changeListener),
        _producaoUpdateAdapter = UpdateAdapter(
            database,
            'Producao',
            ['_id'],
            (Producao item) => <String, Object?>{
                  '_id': item.id,
                  '_dataProd': item.dataProd,
                  '_quantidade': item.quantidade,
                  '_periodo': item.periodo
                },
            changeListener),
        _producaoDeletionAdapter = DeletionAdapter(
            database,
            'Producao',
            ['_id'],
            (Producao item) => <String, Object?>{
                  '_id': item.id,
                  '_dataProd': item.dataProd,
                  '_quantidade': item.quantidade,
                  '_periodo': item.periodo
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Producao> _producaoInsertionAdapter;

  final UpdateAdapter<Producao> _producaoUpdateAdapter;

  final DeletionAdapter<Producao> _producaoDeletionAdapter;

  @override
  Future<List<Producao>> findAllProducao() async {
    return _queryAdapter.queryList('SELECT * FROM producao',
        mapper: (Map<String, Object?> row) => Producao(
            row['_id'] as int?,
            row['_dataProd'] as String?,
            row['_quantidade'] as double?,
            row['_periodo'] as String?));
  }

  @override
  Future<List<Producao>> getMaxProducao() async {
    return _queryAdapter.queryList(
        'Select * from producao order by _id desc limit 1',
        mapper: (Map<String, Object?> row) => Producao(
            row['_id'] as int?,
            row['_dataProd'] as String?,
            row['_quantidade'] as double?,
            row['_periodo'] as String?));
  }

  @override
  Future<List<Producao>> findProducaoById(int id) async {
    return _queryAdapter.queryList('SELECT * FROM producao WHERE _id = ?1',
        mapper: (Map<String, Object?> row) => Producao(
            row['_id'] as int?,
            row['_dataProd'] as String?,
            row['_quantidade'] as double?,
            row['_periodo'] as String?),
        arguments: [id]);
  }

  @override
  Future<List<Producao>> findProducaoWhereLike(String texto) async {
    return _queryAdapter.queryList(
        'SELECT * FROM producao WHERE _dataProd LIKE ?1 OR _quantidade LIKE ?1',
        mapper: (Map<String, Object?> row) => Producao(
            row['_id'] as int?,
            row['_dataProd'] as String?,
            row['_quantidade'] as double?,
            row['_periodo'] as String?),
        arguments: [texto]);
  }

  @override
  Future<List<Producao>> findProducaoBetween(
      String dataInicial, String dataFinal) async {
    return _queryAdapter.queryList(
        'SELECT * FROM producao WHERE _dataProd BETWEEN ?1 AND ?2',
        mapper: (Map<String, Object?> row) => Producao(
            row['_id'] as int?,
            row['_dataProd'] as String?,
            row['_quantidade'] as double?,
            row['_periodo'] as String?),
        arguments: [dataInicial, dataFinal]);
  }

  @override
  Stream<List<Producao>> fetchStreamData() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM producao order by _id desc',
        mapper: (Map<String, Object?> row) => Producao(
            row['_id'] as int?,
            row['_dataProd'] as String?,
            row['_quantidade'] as double?,
            row['_periodo'] as String?),
        queryableName: 'producao',
        isView: false);
  }

  @override
  Future<void> deleteProducao(int id) async {
    await _queryAdapter
        .queryNoReturn('delete from producao where _id = ?1', arguments: [id]);
  }

  @override
  Future<void> insertProducao(Producao producao) async {
    await _producaoInsertionAdapter.insert(producao, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertAllProducao(List<Producao> producao) {
    return _producaoInsertionAdapter.insertListAndReturnIds(
        producao, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateProducao(Producao producao) async {
    await _producaoUpdateAdapter.update(producao, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteAll(List<Producao> list) {
    return _producaoDeletionAdapter.deleteListAndReturnChangedRows(list);
  }
}

class _$UsuarioDAO extends UsuarioDAO {
  _$UsuarioDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _usuarioInsertionAdapter = InsertionAdapter(
            database,
            'Usuario',
            (Usuario item) => <String, Object?>{
                  '_id': item.id,
                  '_nome': item.nome,
                  '_senha': item.senha
                }),
        _usuarioUpdateAdapter = UpdateAdapter(
            database,
            'Usuario',
            ['_id'],
            (Usuario item) => <String, Object?>{
                  '_id': item.id,
                  '_nome': item.nome,
                  '_senha': item.senha
                }),
        _usuarioDeletionAdapter = DeletionAdapter(
            database,
            'Usuario',
            ['_id'],
            (Usuario item) => <String, Object?>{
                  '_id': item.id,
                  '_nome': item.nome,
                  '_senha': item.senha
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Usuario> _usuarioInsertionAdapter;

  final UpdateAdapter<Usuario> _usuarioUpdateAdapter;

  final DeletionAdapter<Usuario> _usuarioDeletionAdapter;

  @override
  Future<List<Usuario>> findAllUsuario() async {
    return _queryAdapter.queryList('SELECT * FROM usuario',
        mapper: (Map<String, Object?> row) => Usuario(row['_id'] as int?,
            row['_nome'] as String, row['_senha'] as String));
  }

  @override
  Future<List<Usuario>> findUsuarioById(int id) async {
    return _queryAdapter.queryList('SELECT * FROM usuario WHERE _id = ?1',
        mapper: (Map<String, Object?> row) => Usuario(row['_id'] as int?,
            row['_nome'] as String, row['_senha'] as String),
        arguments: [id]);
  }

  @override
  Future<List<Usuario>> findUsuarioByCredentials(
    String nome,
    String senha,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM usuario WHERE _nome = ?1 AND _senha = ?2',
        mapper: (Map<String, Object?> row) => Usuario(row['_id'] as int?,
            row['_nome'] as String, row['_senha'] as String),
        arguments: [nome, senha]);
  }

  @override
  Future<List<Usuario>> findUsuarioByNome(String nome) async {
    return _queryAdapter.queryList('SELECT * FROM usuario WHERE _nome = ?1',
        mapper: (Map<String, Object?> row) => Usuario(row['_id'] as int?,
            row['_nome'] as String, row['_senha'] as String),
        arguments: [nome]);
  }

  @override
  Future<void> deleteUsuario(int id) async {
    await _queryAdapter
        .queryNoReturn('delete from usuario where _id = ?1', arguments: [id]);
  }

  @override
  Future<void> insertUsuario(Usuario usuario) async {
    await _usuarioInsertionAdapter.insert(usuario, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateUsuario(Usuario usuario) async {
    await _usuarioUpdateAdapter.update(usuario, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteAll(List<Usuario> list) {
    return _usuarioDeletionAdapter.deleteListAndReturnChangedRows(list);
  }
}
