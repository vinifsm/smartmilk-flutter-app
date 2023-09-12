import 'package:floor/floor.dart';
import 'package:test_app/models/Aplicacao.dart';

@dao
abstract class AplicacaoDAO {
  @Query('SELECT * FROM aplicacao')
  Future<List<Aplicacao>> findAllAplicacao();
  @Query('SELECT * FROM aplicacao WHERE _id LIKE :id')
  Future<List<Aplicacao>> findAplicacaoById(int id);
  @Query('SELECT * FROM aplicacao WHERE _dataAplicacao LIKE :texto')
  Future<List<Aplicacao>> findAllAplicacaoWhereLike(String texto);
  @Query('Select * from aplicacao order by _id desc limit 1')
  Future<List<Aplicacao>> getMaxAplicacao();
  @Query('SELECT * FROM aplicacao order by _id desc')
  Stream<List<Aplicacao>> fetchStreamData();
  @insert
  Future<void> insertAplicacao(Aplicacao aplicacao);
  @insert
  Future<List<int>> insertAllAplicacao(List<Aplicacao> aplicacao);
  @update
  Future<void> updateAplicacao(Aplicacao aplicacao);
  @Query("delete from aplicacao where _id = :id")
  Future<void> deleteAplicacao(int id);
  @delete
  Future<int> deleteAll(List<Aplicacao> list);
}
