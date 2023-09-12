import 'package:flutter/material.dart';
import 'package:test_app/models/Animal.dart';
import '../../database/AppDatabase.dart';
import '../../models/Gestacao.dart';

class ViewGestacao extends StatelessWidget {
  final Gestacao? gestacao;

  const ViewGestacao({Key? key, this.gestacao}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Gestacao'),
        centerTitle: true,
      ),
      body: FormWidget(
        gestacao: gestacao,
      ),
    );
  }
}

class FormWidget extends StatefulWidget {
  final Gestacao? gestacao;

  const FormWidget({Key? key, this.gestacao}) : super(key: key);

  @override
  State<FormWidget> createState() => _FormWidgetState(gestacao: gestacao);
}

class _FormWidgetState extends State<FormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Gestacao? gestacao;
  int? selectedAnimal;
  TextEditingController animalGestanteController = TextEditingController();
  TextEditingController animalSemenController = TextEditingController();
  TextEditingController dataInicialController = TextEditingController();

  List<Animal> animais = [];

  _FormWidgetState({this.gestacao});

  Future<AppDatabase> connect() async {
    return await $FloorAppDatabase.databaseBuilder('database_test.db').build();
  }

  static bool isNullOrEmpty(String? value) => value == null || value.isEmpty;

  String? validatorAnimalGestante(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe o animal gestante';
    }
    return null;
  }

  String? validatorDataInicial(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe a data inicial';
    }
    return null;
  }

  @override
  void initState() {
    if (gestacao != null) {
      setState(() {
        animalGestanteController.text =
            gestacao!.animalGestante?.toString() ?? '';
        animalSemenController.text = gestacao!.animalSemen;
        dataInicialController.text = gestacao!.dataInicial;
      });
    }
    loadList();
    super.initState();
  }

  Future<void> loadList() async {
    final database = await connect();
    final animaisList = (await database.animalDao.findAllAnimal());
    setState(() {
      animais = animaisList;
    });
  }

  @override
  Widget build(BuildContext context) {
    loadList();
    return Container(
      margin: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Dados de Gestação',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<int>(
                value: gestacao?.animalGestante,
                items: animais.map((animal) {
                  return DropdownMenuItem<int>(
                    value: animal.id,
                    child: Text(animal.nome),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAnimal = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Animal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
              TextFormField(
                controller: animalSemenController,
                decoration: InputDecoration(
                  hintText: 'Animal Semen',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
              TextFormField(
                controller: dataInicialController,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    dataInicialController.text =
                        pickedDate.toLocal().toString().split(' ')[0];
                  }
                },
                readOnly: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: validatorDataInicial,
                decoration: InputDecoration(
                  hintText: 'Data Inicial',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final database = await connect();
                          if (gestacao == null) {
                            await database.gestacaoDao.insertGestacao(
                              Gestacao(
                                null,
                                selectedAnimal,
                                animalSemenController.text,
                                dataInicialController.text,
                                null,
                                "0",
                              ),
                            );
                          }
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
                        }
                      },
                      child: const Text('Confirmar'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.black)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
            ]
                .map(
                  (widget) => Padding(
                    padding: const EdgeInsets.only(top: 30.0, right: 30.0),
                    child: widget,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
