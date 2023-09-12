import 'package:floor/floor.dart';
import 'package:test_app/models/Medicacao.dart';

@dao
abstract class MedicacaoDAO {
  @Query('SELECT * FROM medicacao')
  Future<List<Medicacao>> findAllMedicacao();
  @Query('SELECT * FROM medicacao WHERE _id = :id')
  Future<List<Medicacao>> findMedicacaoById(int id);
  @Query('SELECT * FROM medicacao WHERE _nome LIKE :texto')
  Future<List<Medicacao>> findAllMedicacaoWhereLikeNome(String texto);
  @Query('Select * from medicacao order by _id desc limit 1')
  Future<List<Medicacao>> getMaxMedicacao();
  @Query('SELECT * FROM medicacao order by _id desc')
  Stream<List<Medicacao>> fetchStreamData();
  @insert
  Future<void> insertMedicacao(Medicacao medicacao);
  @insert
  Future<List<int>> insertAllMedicacao(List<Medicacao> medicacao);
  @update
  Future<void> updateMedicacao(Medicacao medicacao);
  @Query("delete from medicacao where _id = :id")
  Future<void> deleteMedicacao(int id);
  @delete
  Future<int> deleteAll(List<Medicacao> list);
}
