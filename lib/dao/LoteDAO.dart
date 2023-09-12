import 'package:floor/floor.dart';
import 'package:test_app/models/Lote.dart';

@dao
abstract class LoteDAO {
  @Query('SELECT * FROM lote')
  Future<List<Lote>> findAllLote();
  @Query('SELECT * FROM lote WHERE _nome LIKE :texto')
  Future<List<Lote>> findLoteWhereLike(String texto);
  @Query('Select * from lote order by _id desc limit 1')
  Future<List<Lote>> getMaxLote();
  @Query('SELECT * FROM lote order by _id desc')
  Stream<List<Lote>> fetchStreamData();
  @insert
  Future<void> insertLote(Lote lote);
  @insert
  Future<List<int>> insertAllLote(List<Lote> lote);
  @update
  Future<void> updateLote(Lote lote);
  @Query("delete from lote where _id = :id")
  Future<void> deleteLote(int id);
  @delete
  Future<int> deleteAll(List<Lote> list);
}
