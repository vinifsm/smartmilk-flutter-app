import 'package:flutter/material.dart';
import 'package:floor/floor.dart';
import 'package:test_app/database/AppDatabase.dart';
import 'package:test_app/models/Medicacao.dart';
import 'package:test_app/util/enumFormater.dart';
import 'package:test_app/views/crud/ViewMedicacao.dart';

class ViewSearchMedicacao extends StatefulWidget {
  @override
  _ViewSearchMedicacaoState createState() => _ViewSearchMedicacaoState();
}

class _ViewSearchMedicacaoState extends State<ViewSearchMedicacao> {
  final TextEditingController _searchController = TextEditingController();
  List<Medicacao> _searchResults = [];
  int _selectedRowIndex = -1;

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
    final dao = database.medicacaoDao;

    List<Medicacao> results;
    if (query.isEmpty) {
      results = await dao.findAllMedicacao();
    } else {
      results = await dao.findAllMedicacaoWhereLikeNome("%$query%");
    }
    setState(() {
      _searchResults = results;
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
    final Medicacao selectedMedicacao = _searchResults[index];
    final screenBack = ViewMedicacao(medicacao: selectedMedicacao);
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
    final item = (await database.medicacaoDao.findMedicacaoById(id)).first;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ViewMedicacao(medicacao: item),
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
                await database.medicacaoDao.deleteMedicacao(id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicações'),
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
                      builder: (context) =>
                          const ViewMedicacao(medicacao: null),
                    ))
                    .then((_) => _onSearchChanged());
              }),
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
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
                      '${_searchResults[i].id} - ${_searchResults[i].nome}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Descrição: ${_searchResults[i].descricao}'),
                      Text(
                          'Tipo: ${enumFormater().formatWithSpace(_searchResults[i].tipo.toString().split('.').last)}'),
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
