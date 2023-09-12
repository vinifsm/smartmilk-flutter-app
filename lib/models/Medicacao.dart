import 'package:floor/floor.dart';
import 'dart:convert';

enum TipoMedicacao {
  Antibioticos,
  AntiInflamatorios,
  Antiparasitarios,
  Matabicheira,
  PomadasTerapeuticas,
  ProdutosTratamentoCasco,
  Mosquicidas,
  Carrapaticidas,
  SuplementosVitaminicosMinerais,
  Antitoxicos,
}

@entity
class Medicacao {
  @PrimaryKey(autoGenerate: true)
  final int? _id;
  String? _nome;
  String? _descricao;
  TipoMedicacao? _tipo;

  Medicacao(this._id, this._nome, this._descricao, this._tipo);

  get id => _id;

  get nome => _nome;

  set nome(value) => _nome = value;

  get descricao => _descricao;

  set descricao(value) => _descricao = value;

  get tipo => _tipo;

  set tipo(value) => _tipo = value;

  @override
  String toString() {
    return nome + " " + descricao + " " + tipo;
  }
}
