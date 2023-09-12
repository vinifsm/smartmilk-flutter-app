import 'package:floor/floor.dart';

@entity
class Usuario {
  @PrimaryKey(autoGenerate: true)
  final int? _id;
  late String _nome;
  late String _senha;

  Usuario(this._id, this._nome, this._senha);

  get id => _id;

  get nome => _nome;

  set nome(value) => _nome = value;

  get senha => _senha;

  set senha(value) => _senha = value;

  @override
  String toString() {
    return nome + " " + senha;
  }
}
