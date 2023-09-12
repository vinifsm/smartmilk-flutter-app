import 'package:floor/floor.dart';

import 'Animal.dart';

@Entity(foreignKeys: [
  ForeignKey(
    childColumns: ['_animalGestante'],
    parentColumns: ['_id'],
    entity: Animal,
  )
])
class Gestacao {
  @PrimaryKey(autoGenerate: true)
  final int? _id;
  int? _animalGestante;
  late String _animalSemen;
  late String _dataInicial;
  String? _dataFinal;
  String? _statusGest;

  Gestacao(this._id, this._animalGestante, this._animalSemen, this._dataInicial,
      this._dataFinal, this._statusGest);

  get id => _id;

  get animalGestante => _animalGestante;

  set animalGestante(value) => _animalGestante = value;

  get animalSemen => _animalSemen;

  set animalSemen(value) => _animalSemen = value;

  get dataInicial => _dataInicial;

  set dataInicial(value) => _dataInicial = value;

  get dataFinal => _dataFinal;

  set dataFinal(value) => _dataFinal = value;

  get statusGest => _statusGest;

  set statusGest(value) => _statusGest = value;
}
