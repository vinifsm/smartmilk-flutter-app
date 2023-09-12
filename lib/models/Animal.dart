import 'package:floor/floor.dart';
import 'package:test_app/models/Lote.dart';

enum Raca {
  NaoEspecificada,
  Holandesa,
  Jersey,
  Angus,
  Hereford,
  Brahman,
  Charoles,
  Limousin,
  Simental,
  Ayrshire,
  Guernsey,
  Brangus,
  Braford,
  RedAngus,
  Gelbvieh,
  BrownSwiss,
  Senepol,
  Shorthorn,
  Canchim,
  Murrah,
  Nellore
}

@Entity(foreignKeys: [
  ForeignKey(
    childColumns: ['_lote'],
    parentColumns: ['_id'],
    entity: Lote,
  )
])
class Animal {
  @PrimaryKey(autoGenerate: true)
  final int? _id;
  late int _numero;
  String? _nome;
  double? _peso;
  String? _cor;
  Raca? _raca;
  bool? _produzLeite;
  int? _lote;

  Animal(this._id, this._numero, this._nome, this._peso, this._cor, this._raca,
      this._produzLeite, this._lote);

  get id => _id;

  get numero => _numero;

  set numero(value) => _numero = value;

  get nome => _nome;

  set nome(value) => _nome = value;

  get peso => _peso;

  set peso(value) => _peso = value;

  get cor => _cor;

  set cor(value) => _cor = value;

  get raca => _raca;

  set raca(value) => _raca = value;

  get produzLeite => _produzLeite;

  set produzLeite(value) => _produzLeite = value;

  get lote => _lote;

  set lote(value) => _lote = value;
}
