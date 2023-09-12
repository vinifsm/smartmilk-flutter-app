import 'package:floor/floor.dart';
import 'package:test_app/models/Gestacao.dart';

@dao
abstract class GestacaoDAO {
  @Query('SELECT * FROM gestacao')
  Future<List<Gestacao>> findAllGestacao();
  @Query('SELECT * FROM gestacao WHERE _id = :id')
  Future<List<Gestacao>> findGestacaoById(int id);
  @Query(
      'SELECT * FROM gestacao WHERE _animalGestante IN (SELECT _id FROM animal WHERE _nome LIKE :texto);')
  Future<List<Gestacao>> findGestacaoWhereLike(String texto);
  @Query(
      'SELECT * FROM gestacao WHERE _dataInicial BETWEEN :dataInicial AND :dataFinal')
  Future<List<Gestacao>> findGestacaoBetween(
      String dataInicial, String dataFinal);
  @Query('Select * from gestacao order by _id desc limit 1')
  Future<List<Gestacao>> getMaxGestacao();
  @Query('SELECT * FROM gestacao order by _id desc')
  Stream<List<Gestacao>> fetchStreamData();
  @insert
  Future<void> insertGestacao(Gestacao gestacao);
  @insert
  Future<List<int>> insertAllGestacao(List<Gestacao> gestacao);
  @update
  Future<void> updateGestacao(Gestacao gestacao);
  @Query("delete from gestacao where _id = :id")
  Future<void> deleteGestacao(int id);
  @delete
  Future<int> deleteAll(List<Gestacao> list);
}
