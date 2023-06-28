import 'Animal.dart';

class Lote {
  late String _id;
  late String _nome;
  late List<Animal> _animais = [];

  get id => this._id;

  set id(value) => this._id = value;

  get nome => this._nome;

  set nome(value) => this._nome = value;

  get animais => this._animais;

  set animais(value) => this._animais = value;
}
