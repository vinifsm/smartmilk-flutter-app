import 'package:flutter/material.dart';
import 'package:test_app/database/AppDatabase.dart';
import 'package:test_app/models/Medicacao.dart';
import 'package:test_app/models/Animal.dart';
import 'package:test_app/models/Aplicacao.dart';

class ViewAplicacaoSimples extends StatelessWidget {
  final Aplicacao? aplicacao;

  const ViewAplicacaoSimples({Key? key, this.aplicacao}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Aplicação'),
        centerTitle: true,
      ),
      body: FormWidget(
        aplicacao: aplicacao,
      ),
    );
  }
}

class FormWidget extends StatefulWidget {
  final Aplicacao? aplicacao;

  const FormWidget({Key? key, this.aplicacao}) : super(key: key);

  @override
  State<FormWidget> createState() => _FormWidgetState(aplicacao: aplicacao);
}

class _FormWidgetState extends State<FormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Aplicacao? aplicacao;

  _FormWidgetState({this.aplicacao});

  static bool isNullOrEmpty(String? value) => value == null || value.isEmpty;

  int? selectedAnimal;

  int? selectedMedicacao;

  Future<AppDatabase> connect() async {
    return await $FloorAppDatabase.databaseBuilder('database_test.db').build();
  }

  String? validatorMedicacao(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe a medicação';
    }
    return null;
  }

  String? validatorDataAplicacao(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe a data de aplicação';
    }
    return null;
  }

  TextEditingController dataAplicacaoController = TextEditingController();

  Map<String, dynamic> _getFormData() {
    Map<String, dynamic> formData = {};

    formData['dataAplicacao'] = dataAplicacaoController.text;

    return formData;
  }

  List<Medicacao> medicacoes = [];
  List<Animal> animais = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadLists();
  }

  Future<void> _loadData() async {
    final database = await connect();
    final medicacoesList = (await database.medicacaoDao.findAllMedicacao());
    final animaisList = (await database.animalDao.findAllAnimal());
    setState(() {
      medicacoes = medicacoesList;
      animais = animaisList;
    });
  }

  void _loadLists() {
    if (aplicacao != null) {
      setState(() {
        selectedAnimal = aplicacao!.animal;
        selectedMedicacao = aplicacao!.medicacao;
        dataAplicacaoController.text = aplicacao!.dataAplicacao;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Dados da Aplicação',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<int>(
                value: aplicacao?.medicacao,
                items: medicacoes.map((medicacao) {
                  return DropdownMenuItem<int>(
                    value: medicacao.id,
                    child: Text(medicacao.nome),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMedicacao = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Medicação',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
              DropdownButtonFormField<int>(
                value: aplicacao?.animal,
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
                readOnly: true,
                controller: dataAplicacaoController,
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (selectedDate != null) {
                    setState(() {
                      dataAplicacaoController.text =
                          selectedDate.toLocal().toString().split(' ')[0];
                    });
                  }
                },
                validator: validatorDataAplicacao,
                decoration: InputDecoration(
                  hintText: 'Data de Aplicação',
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
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(100, 30),
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final database = await connect();
                          print("a");
                          print(aplicacao);
                          if (aplicacao == null) {
                            database.aplicacaoDao.insertAplicacao(
                              Aplicacao(
                                null,
                                selectedMedicacao,
                                selectedAnimal,
                                null,
                                dataAplicacaoController.text,
                              ),
                            );
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
                            database.aplicacaoDao.updateAplicacao(
                              Aplicacao(
                                aplicacao!.id,
                                aplicacao!
                                    .medicacao, // You might need to adjust this part
                                aplicacao!
                                    .animal, // You might need to adjust this part
                                aplicacao!.lote,
                                dataAplicacaoController.text,
                              ),
                            );
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
                      child: const Text('Confirmar'),
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
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
            ]
                .map((widget) => Padding(
                      padding: const EdgeInsets.only(top: 30.0, right: 30.0),
                      child: widget,
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
