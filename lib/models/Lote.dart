import 'package:floor/floor.dart';

@entity
class Lote {
  @PrimaryKey(autoGenerate: true)
  final int? _id;
  late String _nome;

  Lote(this._id, this._nome);

  get id => _id;

  get nome => _nome;

  set nome(value) => _nome = value;
}
