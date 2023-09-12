import 'package:floor/floor.dart';

@entity
class Producao {
  @PrimaryKey(autoGenerate: true)
  final int? _id;
  String? _dataProd;
  double? _quantidade;
  String? _periodo;

  Producao(this._id, this._dataProd, this._quantidade, this._periodo);

  get id => _id;

  get dataProd => _dataProd;

  set dataProd(value) => _dataProd = value;

  get quantidade => _quantidade;

  set quantidade(value) => _quantidade = value;

  get periodo => _periodo;

  set periodo(value) => _periodo = value;
}
