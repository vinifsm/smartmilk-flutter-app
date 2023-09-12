import 'package:flutter/material.dart';
import 'package:test_app/database/AppDatabase.dart';
import 'package:test_app/models/Animal.dart';
import 'package:test_app/models/Aplicacao.dart';
import 'package:test_app/models/Lote.dart';
import '../../models/Medicacao.dart';

class ViewAplicacaoAvancado extends StatefulWidget {
  final Medicacao? medicacao;

  final Lote? lote;

  const ViewAplicacaoAvancado({Key? key, this.medicacao, this.lote})
      : super(key: key);

  @override
  _ViewAplicacaoAvancadoState createState() =>
      _ViewAplicacaoAvancadoState(medicacao: medicacao, lote: lote);
}

class _ViewAplicacaoAvancadoState extends State<ViewAplicacaoAvancado> {
  List<Animal> pendingAnimals = [];

  List<Animal> doneAnimals = [];

  Medicacao? medicacao;

  Lote? lote;

  _ViewAplicacaoAvancadoState({this.lote, this.medicacao});

  bool isButtonVisible = false;

  void _isAllDone() {
    if (pendingAnimals.length <= 0) {
      isButtonVisible = true;
    } else {
      isButtonVisible = false;
    }
  }

  void _confirmApplication() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('database_test.db').build();
    final dao = database.aplicacaoDao;
    doneAnimals.forEach((element) async {
      dao.insertAplicacao(Aplicacao(null, medicacao?.id, element.id,
          element.lote, DateTime.now().toString()));
    });
    Navigator.pop(context);
  }

  void _loadList() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('database_test.db').build();
    final daoAnimal = database.animalDao;
    List<Animal> animalsFromLot = await daoAnimal.findAnimalByLote(lote?.id);
    setState(() {
      pendingAnimals = animalsFromLot;
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
              Text('Deseja confirmar está aplicação?'),
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
                      _confirmApplication();
                      Navigator.pop(context);
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
    _loadList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplicação em Lotes'),
        backgroundColor: Colors.black,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildList('Pendentes de Aplicar', pendingAnimals, moveToLeft),
          Container(
            color: Colors.grey,
            width: 2,
            height: double.infinity,
          ),
          _buildList('Aplicações Concluídas', doneAnimals, moveToRight),
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
                      child: Text('Finalizar Aplicação'),
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
                          subtitle: Text('Nº:${animals[index].numero}'),
                          trailing: SizedBox(
                            width: 50,
                            child: Row(
                              children: [
                                IconButton(
                                    icon: title == 'Aplicações Concluídas'
                                        ? const Icon(Icons.check,
                                            color: Colors.blue)
                                        : const Icon(Icons.pending),
                                    onPressed: () {
                                      onTap(animals[index]);
                                    }),
                              ],
                            ),
                          ),
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
    setState(() {
      doneAnimals.add(animal);
      pendingAnimals.remove(animal);
      _isAllDone();
    });
  }

  void moveToRight(Animal animal) {
    setState(() {
      pendingAnimals.add(animal);
      doneAnimals.remove(animal);
      _isAllDone();
    });
  }
}
