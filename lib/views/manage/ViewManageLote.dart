import 'package:flutter/material.dart';
import 'package:test_app/database/AppDatabase.dart';
import 'package:test_app/models/Animal.dart';
import 'package:test_app/models/Lote.dart';

class ViewManageLote extends StatefulWidget {
  @override
  _ViewManageLoteState createState() => _ViewManageLoteState();
}

class _ViewManageLoteState extends State<ViewManageLote> {
  final _formKey = GlobalKey<FormState>();

  List<Animal> availableAnimals = [];

  List<Animal> selectedAnimals = [];

  List<Lote> _lotes = [];

  Lote? selectedLote = Lote(null, "Selecione um Lote");

  bool isButtonVisible = false;

  static bool isNullOrEmpty(String? value) => value == null || value.isEmpty;

  String? validatorNome(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe um nome';
    }
    return null;
  }

  void _makeTransaction() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('database_test.db').build();
    final dao = database.animalDao;
    selectedAnimals.forEach((element) async {
      element.lote = selectedLote?.id;
      dao.updateAnimal(element);
    });
    availableAnimals.forEach((element) {
      element.lote = null;
      dao.updateAnimal(element);
    });
  }

  void _showDialog() {
    TextEditingController nomeController = TextEditingController();
    if (selectedLote?.id != null) {
      nomeController.text = selectedLote?.nome;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Dados do Lote'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: nomeController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: validatorNome,
              decoration: InputDecoration(
                hintText: 'Nome',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(100, 30),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final database = await $FloorAppDatabase
                          .databaseBuilder('database_test.db')
                          .build();
                      final dao = database.loteDao;
                      if (selectedLote?.id == null) {
                        dao.insertLote(Lote(null, nomeController.text));
                        Navigator.of(context).pop(_loadLotes());
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              backgroundColor: Colors.black,
                              behavior: SnackBarBehavior.floating,
                              dismissDirection: DismissDirection.startToEnd,
                              content: const Row(
                                children: [
                                  Icon(
                                    Icons.info,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('Cadastro realizado com sucesso'),
                                ],
                              )),
                        );
                      } else {
                        dao.updateLote(
                            Lote(selectedLote?.id, nomeController.text));
                        Navigator.of(context).pop(_loadLotes());
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              backgroundColor: Colors.black,
                              behavior: SnackBarBehavior.floating,
                              dismissDirection: DismissDirection.startToEnd,
                              content: const Row(
                                children: [
                                  Icon(
                                    Icons.info,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('Alteração realizada com sucesso'),
                                ],
                              )),
                        );
                      }
                    }
                  },
                  child: Text('Confirmar'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(100, 30),
                    backgroundColor: Colors.black87,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(_loadLotes());
                  },
                  child: Text('Cancelar'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showDialogDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deseja mesmo excluir?'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(100, 30),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () async {
                    final database = await $FloorAppDatabase
                        .databaseBuilder('database_test.db')
                        .build();
                    final dao = database.loteDao;
                    print(selectedLote?.id);
                    await dao.deleteLote(selectedLote?.id);
                    Navigator.of(context).pop(_loadLotes());
                  },
                  child: Text('Confirmar'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(100, 30),
                    backgroundColor: Colors.black87,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadLotes() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('database_test.db').build();
    final daoLote = database.loteDao;
    final daoAnimal = database.animalDao;
    List<Lote> lots = await daoLote.findAllLote();
    List<Animal> animals = await daoAnimal.findAnimalWithNullLote();
    selectedLote = Lote(null, "Selecione um Lote");
    setState(() {
      _lotes = lots;
      availableAnimals = animals;
    });
  }

  void _loadLists() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('database_test.db').build();
    final daoAnimal = database.animalDao;
    List<Animal> animalsFromLot =
        await daoAnimal.findAnimalByLote(selectedLote?.id);
    List<Animal> animals = await daoAnimal.findAnimalWithNullLote();
    setState(() {
      selectedAnimals = animalsFromLot;
      availableAnimals = animals;
    });
  }

  void _showConfirmDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Deseja confirmar está transação?'),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey, // Change button color
                    ),
                    child: Text('Não'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      _makeTransaction();
                      Navigator.pop(context);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            backgroundColor: Colors.black,
                            behavior: SnackBarBehavior.floating,
                            dismissDirection: DismissDirection.startToEnd,
                            content: const Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Movimentação realizada com sucesso'),
                              ],
                            )),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // Use the original button color
                    ),
                    child: Text('Sim'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _loadLotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lotes'),
        backgroundColor: Colors.black,
        actions: [
          PopupMenuButton<Lote>(
            onSelected: (Lote selectedLote) {
              setState(() {
                this.selectedLote = selectedLote;
                isButtonVisible = false;
                _loadLists();
              });
            },
            itemBuilder: (BuildContext context) {
              return _lotes.map((Lote lote) {
                return PopupMenuItem<Lote>(
                  value: lote,
                  child: Text(lote.nome),
                );
              }).toList();
            },
          ),
          IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: () {
                _showDialog();
              }),
          IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                if (selectedLote?.id != null) {
                  _showDialog();
                }
              }),
          IconButton(
              icon: const Icon(Icons.remove_circle),
              onPressed: () {
                if (selectedLote?.id != null) {
                  _showDialogDelete();
                }
              }),
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildList(
              'Sem Lote/Área de Transferência', availableAnimals, moveToLeft),
          Container(
            color: Colors.grey, // Cor da linha vertical
            width: 2, // Largura da linha vertical
            height:
                double.infinity, // Altura da linha igual ao tamanho da coluna
          ),
          _buildList(selectedLote?.nome, selectedAnimals, moveToRight),
        ],
      ),
      persistentFooterButtons: isButtonVisible
          ? [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _showConfirmDialog,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text('Realizar Transação'),
                    ),
                  ),
                ],
              ),
            ]
          : [],
    );
  }

  Widget _buildList(
      String title, List<Animal> animals, Function(Animal) onTap) {
    return Expanded(
      child: Card(
        elevation: 4, // Add some shadow to the card
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(8), // Rounded corners for the card
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 100), // Animation duration
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: ListView.builder(
                  key: ValueKey<int>(
                      animals.length), // Used for the animated switcher
                  itemCount: animals.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => onTap(animals[index]),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                              color: Colors.grey), // Border color for the card
                        ),
                        child: ListTile(
                          title: Text(animals[index].nome),
                          subtitle: Text('Numero: ${animals[index].numero}'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void moveToLeft(Animal animal) {
    if (selectedLote?.id != null) {
      setState(() {
        isButtonVisible = true;
        selectedAnimals.add(animal);
        availableAnimals.remove(animal);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            dismissDirection: DismissDirection.startToEnd,
            content: const Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 10,
                ),
                Text('Selecione um lote para movimentar'),
              ],
            )),
      );
    }
  }

  void moveToRight(Animal animal) {
    setState(() {
      isButtonVisible = true;
      availableAnimals.add(animal);
      selectedAnimals.remove(animal);
    });
  }
}
