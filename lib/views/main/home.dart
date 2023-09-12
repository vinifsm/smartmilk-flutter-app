import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:test_app/database/AppDatabase.dart';
import 'package:test_app/models/Animal.dart';
import 'package:test_app/reports/AnimalPrintReport.dart';
import 'package:test_app/reports/GestacaoPrintReport.dart';
import 'package:test_app/reports/ProducaoPrintReport.dart';
import 'package:test_app/util/dashboardCards.dart';
import 'package:test_app/views/main/app_drawer.dart';

late int loggedUser;
String LOGGER_NAME = 'user';

class HomePageWidget extends StatefulWidget {
  HomePageWidget(int logged) {
    loggedUser = logged;
  }
  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget>
    with SingleTickerProviderStateMixin {
  final List<DashboardCard> cards = DashboardCard.getData();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;

  String LOGGER_NAME = 'user';

  String selectedReport = 'Relatório de Animais';
  bool isProducingMilk = false;
  TextEditingController weightRangeFromController = TextEditingController();
  TextEditingController weightRangeToController = TextEditingController();
  TextEditingController startDateGestacaoController = TextEditingController();
  TextEditingController endDateGestacaoController = TextEditingController();
  TextEditingController startDateProducaoController = TextEditingController();
  TextEditingController endDateProducaoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: [
          DropdownButton<String>(
            value: selectedReport,
            icon: Icon(FontAwesome5.file_pdf, color: Colors.white),
            onChanged: (newValue) async {
              setState(() {
                selectedReport = newValue!;
                _navigateToSelectedReportScreen(context);
              });
            },
            items: <String>[
              'Relatório de Animais',
              'Relatório de Gestações',
              'Relatório de Produções'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            underline: Container(),
          ),
          SizedBox(
            width: 40,
          )
        ],
      ),
      drawer: AppDrawer(scaffoldKey: _scaffoldKey, logged: loggedUser),
      body: _buildContent(),
    );
  }

  void _navigateToSelectedReportScreen(BuildContext context) {
    if (selectedReport == 'Relatório de Animais') {
      _showFilterAnimal(context);
    } else if (selectedReport == 'Relatório de Gestações') {
      _showFilterGestacao(context);
    } else if (selectedReport == 'Relatório de Produções') {
      _showFilterProducao(context);
    }
  }

  void _showFilterAnimal(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Relatório de Animal'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Intervalo de Peso'),
                SizedBox(height: 10),
                TextFormField(
                  controller: weightRangeFromController,
                  keyboardType: TextInputType.number,
                  validator: validatorStartWeight,
                  decoration: InputDecoration(
                    hintText: 'De',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: weightRangeToController,
                  keyboardType: TextInputType.number,
                  validator: validatorEndWeight,
                  decoration: InputDecoration(
                    hintText: 'Até',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final database = await $FloorAppDatabase
                      .databaseBuilder('database_test.db')
                      .build();
                  final list = await database.animalDao.findAnimalFilter(
                    double.parse(weightRangeFromController.text),
                    double.parse(weightRangeToController.text),
                  );
                  final report = AnimalPrintReport(
                    report: AnimalReport(
                      user: LOGGER_NAME,
                      list: list,
                    ),
                  );
                  report.generatePDF();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Gerar'),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterGestacao(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Relatório de Gestações'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Período das Gestações'),
                SizedBox(height: 10),
                TextFormField(
                  controller: startDateGestacaoController,
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      startDateGestacaoController.text =
                          pickedDate.toLocal().toString().split(' ')[0];
                    }
                  },
                  readOnly: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validatorStartDateGestacao,
                  decoration: InputDecoration(
                    hintText: 'Data de Início',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: endDateGestacaoController,
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      endDateGestacaoController.text =
                          pickedDate.toLocal().toString().split(' ')[0];
                    }
                  },
                  readOnly: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validatorEndDateGestacao,
                  decoration: InputDecoration(
                    hintText: 'Data de Fim',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final database = await $FloorAppDatabase
                      .databaseBuilder('database_test.db')
                      .build();
                  final list = await database.gestacaoDao.findGestacaoBetween(
                    startDateGestacaoController.text,
                    endDateGestacaoController.text,
                  );

                  List<Animal> _animais =
                      await database.animalDao.findAllAnimal();
                  Map<int, Animal> animalMap = {
                    for (var animal in _animais) animal.id: animal
                  };
                  final report = GestacaoPrintReport(
                    report: GestacaoReport(
                      user: LOGGER_NAME,
                      list: list,
                    ),
                    animalMap: animalMap,
                  );
                  report.generatePDF();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Gerar'),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterProducao(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Relatório de Produções'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Período das Produções'),
                SizedBox(height: 10),
                TextFormField(
                  controller: startDateProducaoController,
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      startDateProducaoController.text =
                          pickedDate.toLocal().toString().split(' ')[0];
                    }
                  },
                  readOnly: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validatorStartDateProducao,
                  decoration: InputDecoration(
                    hintText: 'Data de Início',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: endDateProducaoController,
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      endDateProducaoController.text =
                          pickedDate.toLocal().toString().split(' ')[0];
                    }
                  },
                  readOnly: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validatorEndDateProducao,
                  decoration: InputDecoration(
                    hintText: 'Data de Fim',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final database = await $FloorAppDatabase
                      .databaseBuilder('database_test.db')
                      .build();
                  final list = await database.producaoDao.findProducaoBetween(
                    startDateProducaoController.text,
                    endDateProducaoController.text,
                  );
                  final report = ProducaoPrintReport(
                    report: ProducaoReport(
                      user: LOGGER_NAME,
                      list: list,
                    ),
                  );
                  report.generatePDF();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Gerar'),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align text to the top-left corner
        children: [
          SizedBox(height: 15),
          Text(
            'Bem Vindo ' +
                LOGGER_NAME[0].toUpperCase() +
                LOGGER_NAME.substring(1),
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Expanded(
            child: GridView.builder(
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                return _buildCard(context, cards[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, DashboardCard card) {
    return InkWell(
      onTap: () {
        _onCardTapped(context, card);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        elevation: 4,
        color: Colors.blueAccent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
                scale: _animationController.drive(
                  Tween<double>(begin: 1, end: 0.95)
                      .chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: card.icon != null
                    ? Icon(card.icon, size: 48, color: Colors.white)
                    : card.svg),
            SizedBox(height: 8),
            Text(
              card.title,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _onCardTapped(BuildContext context, DashboardCard card) {
    _animationController.forward(from: 0.0);
    Navigator.pushNamed(context, card.routeName);
  }

  static bool isNullOrEmpty(String? value) => value == null || value.isEmpty;

  String? validatorStartDateGestacao(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe uma data inicial';
    }
    return null;
  }

  String? validatorEndDateGestacao(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe uma data final';
    }
    return null;
  }

  String? validatorStartDateProducao(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe uma data inicial';
    }
    return null;
  }

  String? validatorEndDateProducao(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe uma data final';
    }
    return null;
  }

  String? validatorStartWeight(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe um peso minímo';
    } else {
      if (double.parse(value!) > double.parse(weightRangeToController.text)) {
        return 'O peso minímo deve ser \nmenor que o máximo';
      }
    }
    return null;
  }

  String? validatorEndWeight(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe um peso máximo';
    } else {
      if (double.parse(value!) < double.parse(weightRangeFromController.text)) {
        return 'O peso máximo deve ser \nmaior que o minímo';
      }
    }
    return null;
  }
}
