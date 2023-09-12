import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../database/AppDatabase.dart';
import '../../models/Producao.dart';

class ViewProducao extends StatelessWidget {
  final Producao? producao;

  const ViewProducao({Key? key, this.producao}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Producao'),
        centerTitle: true,
      ),
      body: FormWidget(
        producao: producao,
      ),
    );
  }
}

class FormWidget extends StatefulWidget {
  final Producao? producao;

  const FormWidget({Key? key, this.producao}) : super(key: key);

  @override
  State<FormWidget> createState() => _FormWidgetState(producao: producao);
}

class _FormWidgetState extends State<FormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Producao? producao;

  _FormWidgetState({this.producao});

  // Other necessary variables and methods

  TextEditingController dataProdController = TextEditingController();
  TextEditingController quantidadeController = TextEditingController();
  TextEditingController periodoController = TextEditingController();

  Future<AppDatabase> connect() async {
    return await $FloorAppDatabase.databaseBuilder('database_test.db').build();
  }

  static bool isNullOrEmpty(String? value) => value == null || value.isEmpty;

  String? validatorDataProd(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe a data de produção';
    }
    return null;
  }

  String? validatorQuantidade(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe a quantidade';
    }
    double? parsedValue = double.tryParse(value ?? '');
    if (parsedValue == null || parsedValue <= 0) {
      return 'Informe uma quantidade válida';
    }
    return null;
  }

  String? validatorPeriodo(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe o período';
    }
    return null;
  }

  @override
  void initState() {
    if (producao != null) {
      setState(() {
        dataProdController.text = producao!.dataProd ?? '';
        quantidadeController.text = producao!.quantidade?.toString() ?? '';
        periodoController.text = producao!.periodo ?? '';
      });
    }
    super.initState();
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
                'Dados de Produção',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: dataProdController,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    dataProdController.text =
                        pickedDate.toLocal().toString().split(' ')[0];
                  }
                },
                readOnly: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: validatorDataProd,
                decoration: InputDecoration(
                  hintText: 'Data de Produção',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
              TextFormField(
                controller: quantidadeController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: validatorQuantidade,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Quantidade',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
              TextFormField(
                controller: periodoController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: validatorPeriodo,
                decoration: InputDecoration(
                  hintText: 'Período',
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
                          if (producao == null) {
                            await database.producaoDao.insertProducao(
                              Producao(
                                null,
                                dataProdController.text,
                                double.parse(quantidadeController.text),
                                periodoController.text,
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
                            await database.producaoDao.updateProducao(
                              Producao(
                                producao?.id,
                                dataProdController.text,
                                double.parse(quantidadeController.text),
                                periodoController.text,
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
