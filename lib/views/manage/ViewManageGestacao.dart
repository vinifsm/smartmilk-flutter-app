import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:test_app/database/AppDatabase.dart';
import 'package:test_app/models/Animal.dart';
import 'package:test_app/models/Gestacao.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimelineItem {
  final int id;
  final String nome;
  final int min;
  final int max;
  final IconData? icon;
  final SvgPicture? svg;

  TimelineItem(this.id, this.nome, this.min, this.max, this.icon, this.svg);
}

class ViewManageGestacao extends StatefulWidget {
  final List<TimelineItem> items = [
    TimelineItem(1, "Fase Embrionária", 0, 30, null, null),
    TimelineItem(2, "Fase de Bolsa", 31, 90, null, null),
    TimelineItem(3, "Fase de Balão", 91, 150, null, null),
    TimelineItem(4, "Fase Final", 151, 280, null, null),
  ];

  final Gestacao gestacao;

  ViewManageGestacao({super.key, required this.gestacao});

  @override
  _ViewManageGestacaoState createState() =>
      _ViewManageGestacaoState(items, gestacao);
}

class _ViewManageGestacaoState extends State<ViewManageGestacao> {
  List<TimelineItem> items;
  Gestacao gestacao;
  Animal? animal;
  bool confirmButton = false;
  bool cancelButton = true;

  _ViewManageGestacaoState(this.items, this.gestacao);

  Future<void> compareItemList() async {
    if (DateTime.now()
            .difference(DateTime.parse(gestacao.dataInicial))
            .inDays >=
        280) {
      if (gestacao.statusGest == "1") {
        items.add(TimelineItem(6, "Animal nasceu", 0, 0, null, null));
      } else if (gestacao.statusGest == "2") {
        items.add(TimelineItem(7, "Animal morreu", 0, 0, null, null));
      } else {
        confirmButton = true;
        items
            .add(TimelineItem(5, "Aguardando Confirmação", 280, 0, null, null));
      }
    }
    final animalList = (await (await $FloorAppDatabase
                .databaseBuilder('database_test.db')
                .build())
            .animalDao
            .findAnimalById(gestacao.animalGestante))
        .first;
    setState(() {
      animal = animalList;
    });
  }

  @override
  void initState() {
    super.initState();
    compareItemList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fases da Gestação'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 8.0,
              margin: EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(16.0),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dados da Gestação',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text('Data Inicial: ${gestacao.dataInicial}'),
                    SizedBox(height: 10),
                    Text('Provedor do Sêmen: ${gestacao.animalSemen}'),
                    SizedBox(height: 10),
                    Text('Animal em gestação: ${animal?.nome}'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final days = DateTime.now()
                      .difference(DateTime.parse(gestacao.dataInicial))
                      .inDays;
                  final item = items[index];
                  return TimelineTile(
                    alignment: TimelineAlign.manual,
                    lineXY: 0.1,
                    isFirst: index == 0,
                    isLast: index == items.length - 1,
                    indicatorStyle: IndicatorStyle(
                      width: 15,
                      color: days >= item.min ? Colors.blue : Colors.black38,
                    ),
                    endChild: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        alignment: Alignment.center,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              16.0), // Adjust the radius as needed
                          child: Card(
                            color:
                                days >= item.min ? Colors.blue : Colors.white,
                            elevation: 5.0,
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text('${item.nome}'),
                              textColor: days >= item.min
                                  ? const Color.fromRGBO(255, 255, 255, 1)
                                  : Colors
                                      .black, // Change these colors as needed
                              subtitle: Text(
                                'Início: ${DateFormat('yyyy/MM/dd').format(DateTime.parse(gestacao.dataInicial).add(Duration(days: item.min)))} \nFim: ${DateFormat('yyyy/MM/dd').format(DateTime.parse(gestacao.dataInicial).add(Duration(days: item.max)))}',
                              ),
                              trailing: days >= item.min
                                  ? Icon(Icons.check_circle,
                                      color: Colors
                                          .white) // Change the icon and color as needed
                                  : Icon(Icons.pending,
                                      color: Colors
                                          .black38), // Change the icon and color as needed
                            ),
                          ),
                        )),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (confirmButton) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          bool isBorn = false;
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return AlertDialog(
                                title: Text("Confirmação"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Escolha o resultado da gestação:"),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Morreu"),
                                        Switch(
                                          value: isBorn,
                                          onChanged: (newValue) {
                                            setState(() {
                                              isBorn = newValue;
                                            });
                                          },
                                        ),
                                        Text("Nasceu"),
                                      ],
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      gestacao.dataFinal = DateTime.now()
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0];
                                      gestacao.statusGest = isBorn ? "1" : "2";
                                      final database = await $FloorAppDatabase
                                          .databaseBuilder('database_test.db')
                                          .build();
                                      database.gestacaoDao
                                          .updateGestacao(gestacao);
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Confirmar"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancelar"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text('Finalizar Gestação'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (cancelButton) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Cancelar"),
                            content: Text(
                                "Tem certeza que deseja cancelar a gestação?"),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  final database = await $FloorAppDatabase
                                      .databaseBuilder('database_test.db')
                                      .build();
                                  database.gestacaoDao
                                      .deleteGestacao(gestacao.id);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                child: Text("Sim"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancelar"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black87),
                  child: Text('Cancelar Gestação'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
