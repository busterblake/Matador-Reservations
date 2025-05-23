import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return const Text('Firebase Auth');
  }

Widget _entryField(
  String title,
  TextEditingController controller,
){
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: title,
    ),
  );
}
Widget _errorMessage() {
  return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
}

Widget _submitButton(){
  return ElevatedButton(
    onPressed: 
    isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
    child: Text(isLogin ? 'Login' : 'Register'),
    );
}

Widget _loginOrRegisterButton() {
  return TextButton(
  onPressed: () {
    setState((){
      isLogin = !isLogin;
    });
  },
  child: Text(isLogin ? 'Register instead' : 'Login instead'),
  );
}

@override
Widget build(BuildContext context) {
  print('Rendering LoginPage');


  return Scaffold(
    appBar: AppBar(
      title: _title(),
    ),
    body: Container(
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _entryField('Email', emailController),
          _entryField('Password', passwordController),
          _errorMessage(),
          _submitButton(),
          _loginOrRegisterButton(),
        ],
      ),
    ),
  );
}

}
