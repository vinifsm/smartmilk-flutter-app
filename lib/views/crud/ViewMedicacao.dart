import 'package:flutter/material.dart';
import 'package:test_app/database/AppDatabase.dart';
import 'package:test_app/models/Medicacao.dart';
import 'package:test_app/util/enumFormater.dart';
import 'package:test_app/views/search/ViewSearchMedicacao.dart';

class ViewMedicacao extends StatelessWidget {
  final Medicacao? medicacao;

  const ViewMedicacao({Key? key, this.medicacao}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Medicação'),
        centerTitle: true,
      ),
      body: FormWidget(
        medicacao: medicacao,
      ),
    );
  }
}

class FormWidget extends StatefulWidget {
  final Medicacao? medicacao;

  const FormWidget({Key? key, this.medicacao}) : super(key: key);

  @override
  State<FormWidget> createState() => _FormWidgetState(medicacao: medicacao);
}

class _FormWidgetState extends State<FormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Medicacao? medicacao;

  _FormWidgetState({this.medicacao});

  static bool isNullOrEmpty(String? value) => value == null || value.isEmpty;

  Future<AppDatabase> connect() async {
    return await $FloorAppDatabase.databaseBuilder('database_test.db').build();
  }

  String? validatorNome(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe um nome';
    }
    return null;
  }

  String? validatorDescricao(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe uma descrição';
    }
    return null;
  }

  TipoMedicacao _selectedTipo = TipoMedicacao.AntiInflamatorios;

  final List<DropdownMenuItem<TipoMedicacao>> _dropdownItemsTipo =
      TipoMedicacao.values.map((TipoMedicacao tipoMedicacao) {
    return DropdownMenuItem<TipoMedicacao>(
      value: tipoMedicacao,
      child: Text(enumFormater()
          .formatWithSpace(tipoMedicacao.toString().split('.').last)),
    );
  }).toList();

  TextEditingController nomeController = TextEditingController();
  TextEditingController descricaoController = TextEditingController();

  Map<String, dynamic> _getFormData() {
    Map<String, dynamic> formData = {};

    formData['nome'] = nomeController.text;
    formData['descricao'] = descricaoController.text;
    formData['tipo'] = _selectedTipo;

    return formData;
  }

  @override
  void initState() {
    if (medicacao != null) {
      setState(() {
        nomeController.text = medicacao!.nome;
        descricaoController.text = medicacao!.descricao;
        _selectedTipo = medicacao!.tipo;
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
                'Dados da Medicação',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              TextFormField(
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
              TextFormField(
                controller: descricaoController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: validatorDescricao,
                decoration: InputDecoration(
                  hintText: 'Descrição',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
              const Text(
                'Tipos de Medicação',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<TipoMedicacao>(
                items: _dropdownItemsTipo,
                value: _selectedTipo,
                onChanged: (TipoMedicacao? tipoMedicacao) {
                  setState(() {
                    _selectedTipo = tipoMedicacao!;
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
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final database = await connect();
                            if (medicacao == null) {
                              database.medicacaoDao.insertMedicacao(
                                Medicacao(
                                  null,
                                  nomeController.text,
                                  descricaoController.text,
                                  _selectedTipo,
                                ),
                              );
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
                                        Text('Cadastro realizado com sucesso'),
                                      ],
                                    )),
                              );
                            } else {
                              database.medicacaoDao.updateMedicacao(
                                Medicacao(
                                  medicacao?.id,
                                  nomeController.text,
                                  descricaoController.text,
                                  _selectedTipo,
                                ),
                              );
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
                                        Text('Alteração realizada com sucesso'),
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
                          backgroundColor: Colors.black87,
                        ),
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
