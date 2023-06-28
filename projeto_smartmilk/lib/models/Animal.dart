import 'package:uuid/uuid.dart';

enum Raca {
  NAO_ESPECIFICADA,
  HOLANDESA,
  JERSEY,
  ANGUS,
  HEREFORD,
  BRAHMAN,
  CHAROLES,
  LIMOUSIN,
  SIMENTAL,
  AYRSHIRE,
  GUERNSEY,
  BRANGUS,
  BRAFORD,
  RED_ANGUS,
  GELBVIEH,
  BROWN_SWISS,
  SENEPOL,
  SHORTHORN,
  CANCHIM,
  MURRAH,
  NELLORE
}

class Animal {
  late String _id;
  late int _numero;
  String? _nome;
  double? _peso;
  String? _cor;
  Raca? _raca;

  Animal(
      {required int numero,
      String nome = "Sem nome",
      double peso = 0.0,
      String cor = "Não especificada",
      Raca raca = Raca.NAO_ESPECIFICADA}) {
    _id = const Uuid().v4();
    _numero = numero;
    _nome = nome;
    _peso = peso;
    _cor = cor;
    _raca = raca;
  }

  get id => _id;

  set id(value) => _id = value;

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
}
