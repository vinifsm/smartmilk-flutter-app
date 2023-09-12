import 'package:flutter/material.dart';
import 'package:test_app/database/AppDatabase.dart';
import 'package:test_app/models/Animal.dart';
import 'package:test_app/models/Gestacao.dart';
import 'package:test_app/util/enumFormater.dart';
import 'package:test_app/util/statusGest.dart';
import 'package:test_app/views/crud/ViewGestacao.dart';
import 'package:test_app/views/manage/ViewManageGestacao.dart';

class ViewSearchGestacao extends StatefulWidget {
  @override
  _ViewSearchGestacaoState createState() => _ViewSearchGestacaoState();
}

class _ViewSearchGestacaoState extends State<ViewSearchGestacao> {
  final TextEditingController _searchController = TextEditingController();
  List<Gestacao> _searchResults = [];

  late Map<int?, Animal> _animalMap;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _onSearchChanged();
    _loadLists();
  }

  void _loadLists() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('database_test.db').build();
    List<Animal> _animais = await database.animalDao.findAllAnimal();

    setState(() {
      _animalMap = Map.fromIterable(
        _animais,
        key: (animal) => animal.id,
        value: (animal) => animal,
      );
    });
  }

  void _onSearchChanged() async {
    final query = _searchController.text;
    final database =
        await $FloorAppDatabase.databaseBuilder('database_test.db').build();
    final dao = database.gestacaoDao;
    List<Gestacao> results;
    if (query.isEmpty) {
      results = await dao.findAllGestacao();
    } else {
      results = await dao.findGestacaoWhereLike("%$query%");
    }
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestação'),
        backgroundColor: Colors.black,
        centerTitle: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                _onSearchChanged();
              }),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                    builder: (context) => const ViewGestacao(),
                  ))
                  .then((_) => _onSearchChanged());
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
              itemBuilder: (context, index) {
                final gestacao = _searchResults[index];
                return GestureDetector(
                  onTap: () {},
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(
                        color: Colors.black12,
                        width: 2.0,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                          '${gestacao.id} - ${_animalMap[_searchResults[index].animalGestante]?.nome}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Semên: ${gestacao.animalSemen}'),
                          Text('Data Inicial: ${gestacao.dataInicial}'),
                          Text(
                              'Status: ${enumFormater().formatWithSpace(getStatus(gestacao.statusGest).name) ?? "N/A"}'),
                        ],
                      ),
                      trailing: SizedBox(
                        width: 96,
                        child: Row(
                          children: [
                            IconButton(
                                icon: const Icon(Icons.timeline),
                                onPressed: () => Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => ViewManageGestacao(
                                          gestacao: gestacao),
                                    ))),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
