import 'package:flutter/material.dart';
import 'package:test_app/database/AppDatabase.dart';
import 'package:test_app/models/Aplicacao.dart';
import 'package:test_app/views/crud/ViewAplicacaoAvancado.dart';

import 'package:test_app/views/crud/ViewAplicacaoSimples.dart';

import '../../models/Animal.dart';
import '../../models/Lote.dart';
import '../../models/Medicacao.dart';

class ViewSearchAplicacao extends StatefulWidget {
  @override
  _ViewSearchAplicacao createState() => _ViewSearchAplicacao();
}

class Screens {
  late int id;
  late String name;
  late String routes;

  Screens(this.id, this.name, this.routes);
}

class _ViewSearchAplicacao extends State<ViewSearchAplicacao> {
  final TextEditingController _searchController = TextEditingController();
  List<Aplicacao> _searchResults = [];
  int _selectedRowIndex = -1;

  late Map<int?, Animal> _animalMap;

  late Map<int?, Medicacao> _medicacaoMap;

  late Map<int?, Lote> _loteMap;

  List<Screens> _screens = [
    Screens(1, "Aplicação Individual", "/ViewAplicacaoSimples"),
    Screens(2, "Aplicação em Lotes", "/ViewAplicacaoAvancado")
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _onSearchChanged();
  }

  void _onSearchChanged() async {
    final query = _searchController.text;
    final database =
        await $FloorAppDatabase.databaseBuilder('database_test.db').build();
    final dao = database.aplicacaoDao;

    List<Aplicacao> results = [];
    if (query.isEmpty) {
      results = await dao.findAllAplicacao();
    } else {
      results = await dao.findAllAplicacaoWhereLike('%${query}%');
    }
    List<Animal> _animais = await database.animalDao.findAllAnimal();

    List<Medicacao> _medicacoes =
        await database.medicacaoDao.findAllMedicacao();

    List<Lote> _lotes = await database.loteDao.findAllLote();
    setState(() {
      _searchResults = results;
      _animalMap = Map.fromIterable(
        _animais,
        key: (animal) => animal.id,
        value: (animal) => animal,
      );
      _medicacaoMap = Map.fromIterable(
        _medicacoes,
        key: (medicacao) => medicacao.id,
        value: (medicacao) => medicacao,
      );
      _loteMap = Map.fromIterable(
        _lotes,
        key: (lote) => lote.id,
        value: (lote) => lote,
      );
    });
  }

  // Function to handle row taps
  Future<void> _onRowTap(int index) async {
    setState(() {
      if (_selectedRowIndex == index) {
        _selectedRowIndex = -1; // Toggle off if tapped again
      } else {
        _selectedRowIndex = index; // Set selected row index
      }
    });
    final Aplicacao selectedItem = _searchResults[index];
    final screenBack = ViewAplicacaoSimples(aplicacao: selectedItem);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screenBack,
      ),
    );
  }

  void _editById(int id) async {
    final database =
        await $FloorAppDatabase.databaseBuilder('database_test.db').build();
    final item = (await database.aplicacaoDao.findAplicacaoById(id)).first;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ViewAplicacaoSimples(aplicacao: item),
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
                await database.aplicacaoDao.deleteAplicacao(id);
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

  void _aplicacaoAvancada(String route) async {
    int selectedMedicacaoIndex = 0;
    int selectedLoteIndex = 0;
    final database =
        await $FloorAppDatabase.databaseBuilder('database_test.db').build();
    final _medicacoes = await database.medicacaoDao.findAllMedicacao();
    final _lotes = await database.loteDao.findAllLote();

    // ignore: use_build_context_synchronously
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Iniciar Aplicação'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: selectedMedicacaoIndex,
                    onChanged: (int? newIndex) {
                      setState(() {
                        selectedMedicacaoIndex = newIndex!;
                      });
                    },
                    items: List.generate(_medicacoes.length, (index) {
                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text(_medicacoes[index]
                            .nome), // Replace with your animal property
                      );
                    }),
                  ),
                  DropdownButton<int>(
                    value: selectedLoteIndex,
                    onChanged: (int? newIndex) {
                      setState(() {
                        selectedLoteIndex = newIndex!;
                      });
                    },
                    items: List.generate(_lotes.length, (index) {
                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text(_lotes[index]
                            .nome), // Replace with your lote property
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ViewAplicacaoAvancado(
                            medicacao: _medicacoes[selectedMedicacaoIndex],
                            lote: _lotes[selectedLoteIndex])));
                  },
                  child: Text('Confimar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplicações'),
        backgroundColor: Colors.black,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              _onSearchChanged();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                    builder: (context) =>
                        const ViewAplicacaoSimples(aplicacao: null),
                  ))
                  .then((_) => _onSearchChanged());
            },
          ),
          PopupMenuButton<Screens>(
            onSelected: (Screens selectedScreen) {
              if (selectedScreen.id == 1) {
                Navigator.pushNamed(context, selectedScreen.routes);
              } else {
                _aplicacaoAvancada(selectedScreen.routes);
              }
            },
            itemBuilder: (BuildContext context) {
              return _screens.map((Screens screen) {
                return PopupMenuItem<Screens>(
                  value: screen,
                  child: Text(screen.name),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                iconColor: Colors.black,
                labelText: 'Buscar',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, i) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                    color: Colors.black12,
                    width: 2.0,
                  ),
                ),
                margin: const EdgeInsets.all(10),
                color: Colors.white,
                child: ListTile(
                  title: Text(
                      '${_searchResults[i].id} - ${_animalMap[_searchResults[i].animal]?.nome}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Medicação: ${_medicacaoMap[_searchResults[i].medicacao]?.nome}'),
                      Text(
                          'Data: ${_searchResults[i].dataAplicacao.toString().substring(0, 10)}'),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 96,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editById(_searchResults[i].id!),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteById(_searchResults[i].id!),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
