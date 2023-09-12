import 'package:floor/floor.dart';
import 'package:test_app/models/Producao.dart';

@dao
abstract class ProducaoDAO {
  @Query('SELECT * FROM producao')
  Future<List<Producao>> findAllProducao();
  @Query('Select * from producao order by _id desc limit 1')
  Future<List<Producao>> getMaxProducao();
  @Query('SELECT * FROM producao WHERE _id = :id')
  Future<List<Producao>> findProducaoById(int id);
  @Query(
      'SELECT * FROM producao WHERE _dataProd LIKE :texto OR _quantidade LIKE :texto')
  Future<List<Producao>> findProducaoWhereLike(String texto);
  @Query(
      'SELECT * FROM producao WHERE _dataProd BETWEEN :dataInicial AND :dataFinal')
  Future<List<Producao>> findProducaoBetween(
      String dataInicial, String dataFinal);
  @Query('SELECT * FROM producao order by _id desc')
  Stream<List<Producao>> fetchStreamData();
  @insert
  Future<void> insertProducao(Producao producao);
  @insert
  Future<List<int>> insertAllProducao(List<Producao> producao);
  @update
  Future<void> updateProducao(Producao producao);
  @Query("delete from producao where _id = :id")
  Future<void> deleteProducao(int id);
  @delete
  Future<int> deleteAll(List<Producao> list);
}
