import 'package:flutter/material.dart';
import 'package:test_app/views/main/home.dart';

import 'views/crud/ViewAplicacaoAvancado.dart';
import 'views/crud/ViewAplicacaoSimples.dart';
import 'views/login/ViewLogin.dart';
import 'views/manage/ViewManageLote.dart';
import 'views/manage/ViewManageProducao.dart';
import 'views/search/ViewSearchAnimal.dart';
import 'views/search/ViewSearchAplicacao.dart';
import 'views/search/ViewSearchGestacao.dart';
import 'views/search/ViewSearchMedicacao.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inicio',
      initialRoute: '/login',
      routes: {
        '/login': (context) => ViewLogin(),
        '/ViewSearchAnimal': (context) => ViewSearchAnimal(),
        '/ViewSearchMedicacao': (context) => ViewSearchMedicacao(),
        '/ViewManageLote': (context) => ViewManageLote(),
        '/ViewManageProducao': (context) => ViewManageProducao(),
        '/ViewSearchGestacao': (context) => ViewSearchGestacao(),
        '/ViewSearchAplicacao': (context) => ViewSearchAplicacao(),
        '/ViewAplicacaoSimples': (context) => ViewAplicacaoSimples(),
        '/ViewAplicacaoAvancado': (context) => ViewAplicacaoAvancado(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
