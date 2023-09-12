import 'package:floor/floor.dart';
import 'package:test_app/dao/AnimalDAO.dart';
import 'package:test_app/dao/AplicacaoDAO.dart';
import 'package:test_app/dao/GestacaoDAO.dart';
import 'package:test_app/dao/LoteDAO.dart';
import 'package:test_app/dao/MedicacaoDAO.dart';
import 'package:test_app/dao/ProducaoDAO.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:test_app/dao/UsuarioDAO.dart';
import 'dart:async';
import 'package:test_app/models/Animal.dart';
import 'package:test_app/models/Aplicacao.dart';
import 'package:test_app/models/Gestacao.dart';
import 'package:test_app/models/Lote.dart';
import 'package:test_app/models/Medicacao.dart';
import 'package:test_app/models/Producao.dart';
import 'package:test_app/models/Usuario.dart';
part 'AppDatabase.floor.g.dart';

@Database(
    version: 1,
    entities: [Animal, Aplicacao, Gestacao, Lote, Medicacao, Producao, Usuario])
abstract class AppDatabase extends FloorDatabase {
  AnimalDAO get animalDao;
  AplicacaoDAO get aplicacaoDao;
  GestacaoDAO get gestacaoDao;
  LoteDAO get loteDao;
  MedicacaoDAO get medicacaoDao;
  ProducaoDAO get producaoDao;
  UsuarioDAO get usuarioDao;
}
