import 'package:flutter/material.dart';
import 'package:projeto_smartmilk/models/Animal.dart';
import 'dart:developer' as dev;

const String LOGGER_NAME = 'mobile.fema';

class ViewAnimal extends StatelessWidget {
  const ViewAnimal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Formulários'),
        centerTitle: true,
      ),
      body: FormWidget(),
    );
  }
}

class FormWidget extends StatefulWidget {
  const FormWidget({
    super.key,
  });

  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static bool isNullOrEmpty(String? value) => value == null || value.isEmpty;

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

  List<DropdownMenuItem<Raca>> _dropdownItemsRaca =
      Raca.values.map((Raca raca) {
    return DropdownMenuItem<Raca>(
      value: raca,
      child: Text(raca.toString().split('.').last),
    );
  }).toList();

  Raca? _selectedRaca = Raca.NAO_ESPECIFICADA;
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20.0),
      child: Form(
          key: _formKey,
          // autovalidateMode: AutovalidateMode.onUserInteraction,
          // onChanged: () {
          //   Form.of(primaryFocus!.context!).save();
          // },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Dados',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: numeroController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.number,
                  validator: validatorNumero,
                  decoration: const InputDecoration(
                    hintText: 'Número',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  controller: nomeController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validatorNome,
                  decoration: const InputDecoration(
                    hintText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  controller: pesoController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: validatorPeso,
                  decoration: const InputDecoration(
                    hintText: 'Peso',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  controller: corController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validatorCor,
                  decoration: const InputDecoration(
                    hintText: 'Cor',
                    border: OutlineInputBorder(),
                  ),
                ),
                const Text(
                  'Raças',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(130, 30),
                            backgroundColor: Colors.blue),
                        onPressed: () {
                          dev.log('button.confirmar', name: LOGGER_NAME);

                          if (_formKey.currentState!.validate()) {
                            var formData = _getFormData();

                            print(formData);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  backgroundColor: Colors.black,
                                  behavior: SnackBarBehavior.floating,
                                  dismissDirection: DismissDirection.startToEnd,
                                  duration: const Duration(seconds: 3),
                                  action: SnackBarAction(
                                    label: 'Confirmar',
                                    textColor: Colors.green,
                                    onPressed: () {
                                      dev.log('snackBar.action',
                                          name: LOGGER_NAME);
                                    },
                                  ),
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.info,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text('Dados em processamento...'),
                                    ],
                                  )),
                            );
                          }
                        },
                        child: const Text('Confirmar'),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(100, 30),
                            backgroundColor: Colors.black54),
                        onPressed: () {
                          dev.log('button.limpar', name: LOGGER_NAME);

                          _formKey.currentState!.reset();
                        },
                        child: const Text('Limpar'),
                      ),
                    ],
                  ),
                ),
              ]
                  .map((widget) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: widget,
                      ))
                  .toList(),
            ),
          )),
    );
  }
}
