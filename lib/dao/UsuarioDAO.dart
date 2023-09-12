import 'package:floor/floor.dart';
import 'package:test_app/models/Usuario.dart';

@dao
abstract class UsuarioDAO {
  @Query('SELECT * FROM usuario')
  Future<List<Usuario>> findAllUsuario();
  @Query('SELECT * FROM usuario WHERE _id = :id')
  Future<List<Usuario>> findUsuarioById(int id);
  @Query('SELECT * FROM usuario WHERE _nome = :nome AND _senha = :senha')
  Future<List<Usuario>> findUsuarioByCredentials(String nome, String senha);
  @Query('SELECT * FROM usuario WHERE _nome = :nome')
  Future<List<Usuario>> findUsuarioByNome(String nome);
  @insert
  Future<void> insertUsuario(Usuario usuario);
  @update
  Future<void> updateUsuario(Usuario usuario);
  @Query("delete from usuario where _id = :id")
  Future<void> deleteUsuario(int id);
  @delete
  Future<int> deleteAll(List<Usuario> list);
}
