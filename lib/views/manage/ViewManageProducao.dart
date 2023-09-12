import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:test_app/database/AppDatabase.dart';
import 'package:test_app/models/Producao.dart';
import 'package:test_app/views/crud/ViewProducao.dart';

enum ComparisonPeriod {
  LastWeek,
  Last15,
  LastMonth,
}

class ViewManageProducao extends StatefulWidget {
  @override
  _ViewManageProducaoState createState() => _ViewManageProducaoState();
}

class _ViewManageProducaoState extends State<ViewManageProducao> {
  List<Producao> _producoes = [];
  ComparisonPeriod _selectedPeriod = ComparisonPeriod.LastWeek;
  double _chartHeight = 280.0;
  Producao? selectedProducao;
  final TextEditingController _searchController = TextEditingController();
  List<Producao> _searchResults = [];
  double widthContainer = 400;
  double heightContainer = 300;
  bool _isSearchFocused = false;

  FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  static bool isNullOrEmpty(String? value) => value == null || value.isEmpty;

  String? validatorNome(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe um nome';
    }
    return null;
  }

  void _onSearchChanged() async {
    final query = _searchController.text;
    final database =
        await $FloorAppDatabase.databaseBuilder('database_test.db').build();
    final dao = database.producaoDao;

    List<Producao> results = [];
    if (query.isEmpty) {
      results = await dao.findAllProducao();
    } else {
      results = await dao.findProducaoWhereLike("%$query%");
    }
    setState(() {
      _searchResults = results;
    });
  }

  void _onFocusChange() {
    if (!_searchFocusNode.hasFocus) {}
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _onSearchChanged();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChange);
    _combineLists();
  }

  void _combineLists() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('database_test.db').build();
    final results = await database.producaoDao.findAllProducao();
    setState(() {
      _producoes.addAll(results);
      _producoes.sort((a, b) => a.dataProd!.compareTo(b.dataProd!));
      build(context);
    });
  }

  void _editById(int id) async {
    final database =
        await $FloorAppDatabase.databaseBuilder('database_test.db').build();
    final item = (await database.producaoDao.findProducaoById(id)).first;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ViewProducao(producao: item),
    ));
  }

  void _deleteById(int id) async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir'),
          content: Text('Tem certeza que deseja excluir?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final database = await $FloorAppDatabase
                    .databaseBuilder('database_test.db')
                    .build();
                await database.producaoDao.deleteProducao(id);
                Navigator.of(context).pop();
                _onSearchChanged();
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _loadData() {
    DateTime now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      DateTime day = DateTime(now.year, now.month, (now.day - i));
      _producoes.add(Producao(i, day.toIso8601String(),
          Random().nextInt(1000).toDouble() + 1000, 'Manhã'));
      _producoes.add(Producao(i, day.toString(),
          Random().nextInt(1000).toDouble() + 1000, 'Tarde'));
    }

    DateTime lastMidMonth = DateTime(now.year, now.month, (now.day - 7));
    for (int i = 0; i < 7; i++) {
      DateTime day =
          DateTime(lastMidMonth.year, lastMidMonth.month, lastMidMonth.day - i);
      _producoes.add(Producao(i + 7, day.toString(),
          Random().nextInt(1000).toDouble() + 1000, 'Manhã'));
      _producoes.add(Producao(i + 7, day.toString(),
          Random().nextInt(1000).toDouble() + 1000, 'Tarde'));
    }

    DateTime lastMonth = DateTime(now.year, now.month, (now.day - 21));
    for (int i = 0; i < 7; i++) {
      DateTime day =
          DateTime(lastMonth.year, lastMonth.month, lastMonth.day - i);
      _producoes.add(Producao(i + 21, day.toString(),
          Random().nextInt(1000).toDouble() + 1000, 'Manhã'));
      _producoes.add(Producao(i + 21, day.toString(),
          Random().nextInt(1000).toDouble() + 1000, 'Tarde'));
    }

    _producoes.sort((a, b) => a.dataProd!.compareTo(b.dataProd!));
  }

  List<FlSpot> _filteredSpots() {
    List<Producao> filteredProducoes = [];

    switch (_selectedPeriod) {
      case ComparisonPeriod.LastWeek:
        filteredProducoes = _producoes.where((producao) {
          DateTime data = DateTime.parse(producao.dataProd!);
          return data.isAfter(DateTime.now().subtract(Duration(days: 7)));
        }).toList();
        break;
      case ComparisonPeriod.Last15:
        filteredProducoes = _producoes.where((producao) {
          DateTime data = DateTime.parse(producao.dataProd!);
          return data.isAfter(DateTime.now().subtract(Duration(days: 15)));
        }).toList();
        break;
      case ComparisonPeriod.LastMonth:
        filteredProducoes = _producoes.where((producao) {
          DateTime data = DateTime.parse(producao.dataProd!);
          return data.isAfter(DateTime.now().subtract(Duration(days: 30)));
        }).toList();
        break;
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < filteredProducoes.length; i++) {
      DateTime dateTime = DateTime.parse(filteredProducoes[i].dataProd!);
      spots.add(FlSpot(i.toDouble(), filteredProducoes[i].quantidade ?? 0.0));
    }

    return spots;
  }

  void _updateChartSize() {
    double newHeight;
    switch (_selectedPeriod) {
      case ComparisonPeriod.LastWeek:
        newHeight = 300.0;
        break;
      case ComparisonPeriod.Last15:
        newHeight = 200.0;
        break;
      case ComparisonPeriod.LastMonth:
        newHeight = 100.0;
        break;
    }

    setState(() {
      _chartHeight = newHeight;
    });
  }

  String _formatDate(int index) {
    if (index >= 0 && index < _producoes.length) {
      DateTime dateTime = DateTime.parse(_producoes[index].dataProd!);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produções'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (context) => const ViewProducao(producao: null),
                    ))
                    .then((_) => _onSearchChanged());
              }),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: widthContainer,
            height: _isSearchFocused ? 160.0 : heightContainer,
            margin: EdgeInsets.fromLTRB(16, 16, 16, 5),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: _isSearchFocused ? 4.5 : 1.5,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      backgroundColor: Colors.blue.shade200,
                      titlesData: FlTitlesData(
                        bottomTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTextStyles: (context, value) => const TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                          ),
                          getTitles: (value) {
                            int index = value.toInt();
                            if (index.isNegative ||
                                index >= _filteredSpots().length) {
                              return '';
                            }
                            return _formatDate(
                                _filteredSpots()[index].x.toInt());
                          },
                        ),
                        rightTitles: SideTitles(showTitles: false),
                        topTitles: SideTitles(showTitles: false),
                      ),
                      borderData: FlBorderData(
                          show: true, border: Border.all(color: Colors.black)),
                      minX: 0,
                      maxX: _filteredSpots().length.toDouble() - 1,
                      minY: 0,
                      maxY: _filteredSpots().map((spot) => spot.y).reduce(
                              (max, current) => max > current ? max : current) +
                          5,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _filteredSpots(),
                          isCurved: true,
                          colors: [Colors.white],
                          dotData: FlDotData(show: true),
                          barWidth: 2,
                          belowBarData:
                              BarAreaData(show: true, colors: [Colors.white70]),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.blueAccent,
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((touchedSpot) {
                              final spotIndex = touchedSpot.spotIndex;
                              final producao = _producoes[spotIndex];
                              return LineTooltipItem(
                                'Data: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(producao.dataProd!))}\nLitros: ${producao.quantidade}',
                                const TextStyle(color: Colors.white),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildComparisonButton(
                        'Semanal', ComparisonPeriod.LastWeek),
                    SizedBox(width: 16),
                    _buildComparisonButton(
                        'Quinzenal', ComparisonPeriod.Last15),
                    SizedBox(width: 16),
                    _buildComparisonButton(
                        'Mensal', ComparisonPeriod.LastMonth),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(
                iconColor: Colors.black,
                labelText: 'Buscar',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onTap: () {
                setState(() {
                  _isSearchFocused = true;
                });
                _searchFocusNode.requestFocus(); // Request focus here
              },
              onEditingComplete: () {
                setState(() {
                  _isSearchFocused = false;
                });
                _searchFocusNode.unfocus(); // Unfocus when editing is complete
              },
              onSubmitted: (value) {
                setState(() {
                  _isSearchFocused = false;
                });
                _searchFocusNode.unfocus();
              },
              onTapOutside: (event) {
                setState(() {
                  _isSearchFocused = false;
                });
                _searchFocusNode.unfocus();
              },
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: GestureDetector(
              // Use GestureDetector for tap outside
              onTap: () {
                setState(() {
                  _isSearchFocused = false;
                });
                _searchFocusNode.unfocus(); // Unfocus when tapping outside
              },
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final producao = _searchResults[index];
                  return ListTile(
                    title: Text('Data: ${producao.dataProd}'),
                    subtitle: Text('Quantidade: ${producao.quantidade}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editById(_searchResults[index].id!);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.remove_circle),
                          onPressed: () {
                            _deleteById(_searchResults[index].id!);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        selectedProducao = producao;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonButton(String label, ComparisonPeriod period) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedPeriod = period;
          _updateChartSize();
        });
      },
      child: Text(label),
    );
  }
}
