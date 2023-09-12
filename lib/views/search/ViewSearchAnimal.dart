import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:floor/floor.dart';
import 'package:test_app/database/AppDatabase.dart';
import 'package:test_app/models/Animal.dart';
import 'package:test_app/views/crud/ViewAnimal.dart';

class ViewSearchAnimal extends StatefulWidget {
  @override
  _ViewSearchAnimal createState() => _ViewSearchAnimal();
}

class _ViewSearchAnimal extends State<ViewSearchAnimal> {
  final TextEditingController _searchController = TextEditingController();
  List<Animal> _searchResults = [];
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
    final dao = database.animalDao;

    List<Animal> results;
    if (query.isEmpty) {
      results = await dao.findAllAnimal();
    } else {
      results = await dao.findAnimalWhereLike("%$query%");
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
    final Animal selectedAnimal = _searchResults[index];
    final screenBack = ViewAnimal(animal: selectedAnimal);
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
    final item = (await database.animalDao.findAnimalById(id)).first;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ViewAnimal(animal: item),
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
                await database.animalDao.deleteAnimal(id);
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
        title: const Text('Animais'),
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
                      builder: (context) => const ViewAnimal(animal: null),
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
                      width: 2.0, //
                    )),
                margin: const EdgeInsets.all(10),
                color: Colors.white,
                child: ListTile(
                  title: Text(
                      '${_searchResults[i].id} - ${_searchResults[i].nome}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Numero: ${_searchResults[i].numero}'),
                      Text('Peso: ${_searchResults[i].peso}'),
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
