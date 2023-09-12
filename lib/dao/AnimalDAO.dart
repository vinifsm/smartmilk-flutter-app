import 'package:floor/floor.dart';
import 'package:test_app/models/Animal.dart';

@dao
abstract class AnimalDAO {
  @Query('SELECT * FROM animal')
  Future<List<Animal>> findAllAnimal();
  @Query('SELECT * FROM animal WHERE _id = :id')
  Future<List<Animal>> findAnimalById(int id);
  @Query('SELECT * FROM animal WHERE _nome LIKE :texto OR _numero LIKE :texto')
  Future<List<Animal>> findAnimalWhereLike(String texto);
  @Query('SELECT * FROM animal WHERE _peso > :pesoMin AND _peso < :pesoMax')
  Future<List<Animal>> findAnimalFilter(double pesoMin, double pesoMax);
  @Query('SELECT * FROM animal WHERE _lote = :lote')
  Future<List<Animal>> findAnimalByLote(int lote);
  @Query('SELECT * FROM animal WHERE _lote IS null')
  Future<List<Animal>> findAnimalWithNullLote();
  @Query('Select * from animal order by _id desc limit 1')
  Future<List<Animal>> getMaxAnimal();
  @Query('SELECT * FROM animal order by _id desc')
  Stream<List<Animal>> fetchStreamData();
  @insert
  Future<void> insertAnimal(Animal animal);
  @insert
  Future<List<int>> insertAllAnimal(List<Animal> animal);
  @update
  Future<void> updateAnimal(Animal animal);
  @Query("delete from animal where _id = :id")
  Future<void> deleteAnimal(int id);
  @delete
  Future<int> deleteAll(List<Animal> list);
}
