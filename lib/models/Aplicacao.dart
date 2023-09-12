import 'Lote.dart';
import 'Animal.dart';
import 'Medicacao.dart';
import 'package:floor/floor.dart';

@Entity(foreignKeys: [
  ForeignKey(
    childColumns: ['_medicacao'],
    parentColumns: ['_id'],
    entity: Medicacao,
  ),
  ForeignKey(
    childColumns: ['_animal'],
    parentColumns: ['_id'],
    entity: Animal,
  ),
  ForeignKey(
    childColumns: ['_lote'],
    parentColumns: ['_id'],
    entity: Lote,
  )
])
class Aplicacao {
  @PrimaryKey(autoGenerate: true)
  final int? _id;
  int? _medicacao;
  int? _animal;
  int? _lote;
  String? _dataAplicacao;

  Aplicacao(
      this._id, this._medicacao, this._animal, this._lote, this._dataAplicacao);

  get id => _id;

  get medicacao => _medicacao;

  set medicacao(value) => _medicacao = value;

  get animal => _animal;

  set animal(value) => _animal = value;

  get lote => _lote;

  set lote(value) => _lote = value;

  get dataAplicacao => _dataAplicacao;

  set dataAplicacao(value) => _dataAplicacao = value;
}
