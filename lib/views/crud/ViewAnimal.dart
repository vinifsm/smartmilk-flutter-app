import 'package:flutter/material.dart';
import 'package:test_app/database/AppDatabase.dart';
import 'package:test_app/models/Animal.dart';
import 'package:test_app/util/enumFormater.dart';

class ViewAnimal extends StatelessWidget {
  final Animal? animal;

  const ViewAnimal({Key? key, this.animal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Animal'),
        centerTitle: true,
      ),
      body: FormWidget(
        animal: animal,
      ),
    );
  }
}

class FormWidget extends StatefulWidget {
  final Animal? animal;

  const FormWidget({Key? key, this.animal}) : super(key: key);

  @override
  State<FormWidget> createState() => _FormWidgetState(animal: animal);
}

class _FormWidgetState extends State<FormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Animal? animal;

  _FormWidgetState({this.animal});

  static bool isNullOrEmpty(String? value) => value == null || value.isEmpty;

  Future<AppDatabase> connect() async {
    return await $FloorAppDatabase.databaseBuilder('database_test.db').build();
  }

  String? validatorNumero(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe um número';
    }
    return null;
  }

  String? validatorNome(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe um nome';
    }
    return null;
  }

  String? validatorPeso(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe um peso';
    }
    return null;
  }

  String? validatorCor(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe uma cor';
    }
    return null;
  }

  final List<DropdownMenuItem<Raca>> _dropdownItemsRaca =
      Raca.values.map((Raca raca) {
    return DropdownMenuItem<Raca>(
      value: raca,
      child:
          Text(enumFormater().formatWithSpace(raca.toString().split('.').last)),
    );
  }).toList();

  Raca? _selectedRaca = Raca.NaoEspecificada;
  bool _produzLeite = false;

  TextEditingController numeroController = TextEditingController();
  TextEditingController nomeController = TextEditingController();
  TextEditingController pesoController = TextEditingController();
  TextEditingController corController = TextEditingController();

  Map<String, dynamic> _getFormData() {
    Map<String, dynamic> formData = {};

    formData['numero'] = numeroController.text;
    formData['nome'] = nomeController.text;
    formData['peso'] = pesoController.text;
    formData['cor'] = corController.text;

    formData['raca'] = _selectedRaca;
    return formData;
  }

  @override
  void initState() {
    if (animal != null) {
      setState(() {
        numeroController.text = animal!.numero.toString();
        nomeController.text = animal!.nome;
        pesoController.text = animal!.peso.toString();
        corController.text = animal!.cor;
        _selectedRaca = animal!.raca;
        _produzLeite = animal!.produzLeite;
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
                  'Dados do Animal',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                    controller: numeroController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    validator: validatorNumero,
                    decoration: InputDecoration(
                      hintText: 'Número',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                    )),
                TextFormField(
                  controller: nomeController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validatorNome,
                  decoration: InputDecoration(
                    hintText: 'Nome',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                  ),
                ),
                TextFormField(
                  controller: pesoController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: validatorPeso,
                  decoration: InputDecoration(
                    hintText: 'Peso',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                  ),
                ),
                TextFormField(
                  controller: corController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validatorCor,
                  decoration: InputDecoration(
                    hintText: 'Cor',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                  ),
                ),
                const Text(
                  'Raças',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                DropdownButtonFormField<Raca>(
                  focusColor: Colors.white,
                  dropdownColor: Colors.white,
                  items: _dropdownItemsRaca,
                  value: _selectedRaca,
                  onChanged: (Raca? raca) {
                    setState(() {
                      _selectedRaca = raca;
                    });
                  },
                ),
                CheckboxListTile(
                  value: _produzLeite,
                  title: const Text('Produz Leite'),
                  subtitle: const Text(
                      'Se ativado indica que o animal está produzindo leite'),
                  secondary: const Icon(Icons.water_drop),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) {
                    setState(() {
                      _produzLeite = value!;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: true,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(100, 30),
                              backgroundColor: Colors.blue),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final database = await connect();
                              if (animal == null) {
                                database.animalDao.insertAnimal(Animal(
                                    null,
                                    int.parse(numeroController.text),
                                    nomeController.text,
                                    double.tryParse(pesoController.text),
                                    corController.text,
                                    _selectedRaca,
                                    _produzLeite,
                                    null));
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor: Colors.black,
                                      behavior: SnackBarBehavior.floating,
                                      dismissDirection:
                                          DismissDirection.startToEnd,
                                      content: const Row(
                                        children: [
                                          Icon(
                                            Icons.info,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                              'Cadastro realizado com sucesso'),
                                        ],
                                      )),
                                );
                              } else {
                                database.animalDao.updateAnimal(Animal(
                                    animal?.id,
                                    int.parse(numeroController.text),
                                    nomeController.text,
                                    double.tryParse(pesoController.text),
                                    corController.text,
                                    _selectedRaca,
                                    _produzLeite,
                                    animal?.lote));
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor: Colors.black,
                                      behavior: SnackBarBehavior.floating,
                                      dismissDirection:
                                          DismissDirection.startToEnd,
                                      content: const Row(
                                        children: [
                                          Icon(
                                            Icons.info,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                              'Alteração realizada com sucesso'),
                                        ],
                                      )),
                                );
                              }
                            }
                          },
                          child: const Text('Confirmar'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Visibility(
                        visible: true,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(100, 30),
                              backgroundColor: Colors.black87),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancelar'),
                        ),
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
          )),
    );
  }
}
