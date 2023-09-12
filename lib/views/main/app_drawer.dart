import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:test_app/database/AppDatabase.dart';
import 'package:test_app/views/login/ViewLogin.dart';
import 'package:test_app/views/manage/ViewManageLote.dart';
import 'package:test_app/views/manage/ViewManageProducao.dart';
import 'package:test_app/views/search/ViewSearchAnimal.dart';
import 'package:test_app/views/main/home.dart';
import 'package:test_app/views/search/ViewSearchAplicacao.dart';
import 'package:test_app/views/search/ViewSearchGestacao.dart';
import 'package:test_app/views/search/ViewSearchMedicacao.dart';
import 'package:flutter_svg/flutter_svg.dart';

late int loggedUser;

String LOGGER_NAME = 'user';

class AppDrawer extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final int logged;

  const AppDrawer({
    Key? key,
    required this.scaffoldKey,
    required this.logged,
  }) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late int loggedUser;
  String LOGGER_NAME = 'user';

  @override
  void initState() {
    super.initState();
    loggedUser = widget.logged;
    loadUser();
  }

  Future<void> loadUser() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('database_test.db').build();
    final user = (await database.usuarioDao.findUsuarioById(loggedUser)).first;
    setState(() {
      LOGGER_NAME = user.nome;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/side-menu-bg.jpg'),
                  opacity: 0.2),
              color: Colors.transparent,
            ),
            accountName: Text(
              LOGGER_NAME[0].toUpperCase() + LOGGER_NAME.substring(1),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(''),
            currentAccountPictureSize: const Size.square(64),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child: SvgPicture.asset(
                  'assets/images/default-user.svg',
                  width: 64,
                  height: 64,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          ListTile(
              leading: const Icon(
                Icons.home,
                color: Colors.blue,
              ),
              title: const Text('Principal'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                dev.log('drawer.actions.home', name: LOGGER_NAME);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => HomePageWidget(loggedUser),
                ));
              }),
          ListTile(
              leading: SvgPicture.asset(
                'assets/images/cow-icon.svg',
                height: 30,
                color: Colors.blue,
              ),
              title: const Text('Animais'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                dev.log('drawer.actions.records', name: LOGGER_NAME);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ViewSearchAnimal(),
                ));
              }),
          ListTile(
              leading:
                  const Icon(FontAwesome5Solid.syringe, color: Colors.blue),
              title: const Text('Aplicações'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                dev.log('drawer.actions.records', name: LOGGER_NAME);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ViewSearchAplicacao(),
                ));
              }),
          ListTile(
              leading: SvgPicture.asset(
                'assets/images/fetus-icon.svg',
                height: 30,
                color: Colors.blue,
              ),
              title: const Text('Gestações'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                dev.log('drawer.actions.records', name: LOGGER_NAME);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ViewSearchGestacao(),
                ));
              }),
          ListTile(
              leading: const Icon(Icons.crop, color: Colors.blue),
              title: const Text('Lotes'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                dev.log('drawer.actions.records', name: LOGGER_NAME);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ViewManageLote(),
                ));
              }),
          ListTile(
              leading: const Icon(Icons.medical_services, color: Colors.blue),
              title: const Text('Medicações'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                dev.log('drawer.actions.records', name: LOGGER_NAME);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ViewSearchMedicacao(),
                ));
              }),
          ListTile(
              leading: SvgPicture.asset(
                'assets/images/milk-icon.svg',
                height: 30,
                color: Colors.blue,
              ),
              title: const Text('Produções'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                dev.log('drawer.actions.records', name: LOGGER_NAME);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ViewManageProducao(),
                ));
              }),
          const Divider(),
          const AboutListTile(
            icon: Icon(Icons.info, color: Colors.blue),
            applicationIcon: Icon(
              Icons.local_play,
            ),
            applicationName: 'SmartMilk',
            applicationVersion: '1.0.0',
            applicationLegalese: '© 2023 FEMA',
            aboutBoxChildren: <Widget>[
              SizedBox(height: 32),
              Text('Software Criado para o TCC de Vinícius Moreira'),
            ],
            child: Text('Sobre'),
          ),
          ListTile(
              leading: const Icon(Icons.logout,
                  color: Color.fromARGB(164, 33, 149, 243)),
              title: const Text('Sair'),
              onTap: () {
                dev.log('drawer.actions.logout', name: LOGGER_NAME);
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => ViewLogin()));
              }),
        ],
      ),
    );
  }
}
