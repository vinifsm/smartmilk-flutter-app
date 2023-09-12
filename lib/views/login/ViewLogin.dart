import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:test_app/database/AppDatabase.dart';
import 'package:test_app/views/main/home.dart';
import 'ViewCadastro.dart';

class ViewLogin extends StatefulWidget {
  @override
  State<ViewLogin> createState() => ViewLoginState();
}

class ViewLoginState extends State<ViewLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  bool _obscurePassword = true;

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

  String? validatorSenha(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Informe uma senha';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.black.withAlpha(600), width: 3),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withAlpha(200),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Container(
                          color: Colors.transparent,
                          child: Image(
                            image: AssetImage('assets/images/logo.png'),
                            width: 200,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(width: 55),
                          Text(
                            'Smart',
                            style: TextStyle(
                              fontSize: 37,
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .blue, // Set your desired text color here
                            ),
                          ),
                          Text(
                            'Milk',
                            style: TextStyle(
                              fontSize: 37,
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .white, // Set your desired text color here
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        children: [
                          SizedBox(width: 5),
                          Text(
                            'Bem vindo de volta',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .black45, // Set your desired text color here
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        controller: nomeController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: validatorNome,
                        decoration: InputDecoration(
                          hintText: 'Usuário',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        controller: senhaController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: validatorSenha,
                        decoration: InputDecoration(
                          hintText: 'Senha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(140, 30),
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final userDao = (await connect()).usuarioDao;
                            final userFromDb =
                                (await userDao.findUsuarioByCredentials(
                                    nomeController.text, senhaController.text));
                            if (userFromDb.length == 1) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      HomePageWidget(userFromDb.first.id)));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Login inválido!'),
                                ),
                              );
                            }
                          }
                        },
                        child: Text('Entrar'),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStatePropertyAll(Colors.blue),
                          backgroundColor: MaterialStatePropertyAll(
                            Colors.white.withAlpha(990),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewCadastro()),
                          );
                        },
                        child: Text('Criar uma conta'),
                      ),
                    ],
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
