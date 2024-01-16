import "package:capstone_project/components/input_widget.dart";
import "package:capstone_project/components/styles.dart";
import "package:capstone_project/components/validator.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  String? email;
  String? password;
  bool obscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    Center(
                      child: Text(
                        'Welcome Back!',
                        style: headerStyle(level: 1),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            InputLayout(
                              TextFormField(
                                onChanged: (String value) => setState(() {
                                  email = value;
                                }),
                                validator: notEmptyValidator,
                                decoration: customInputDecoration('Email',
                                    prefixIcon:
                                        const Icon(Icons.person_outline)),
                              ),
                            ),
                            InputLayout(
                              TextFormField(
                                  onChanged: (String value) => setState(() {
                                        password = value;
                                      }),
                                  validator: notEmptyValidator,
                                  obscureText: obscured,
                                  decoration: customInputDecoration(
                                    'Password',
                                    prefixIcon: Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          obscured = !obscured;
                                        });
                                      },
                                      icon: Icon(obscured
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      color: Colors.black,
                                    ),
                                  )),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              width: double.infinity,
                              child: FilledButton(
                                  style: buttonStyle,
                                  child: Text(
                                    'Login',
                                    style: headerStyle(level: 3, dark: false),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      login();
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Didn't have an account yet? "),
                        InkWell(
                          onTap: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: const Text(
                            'Register here!',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }

  void login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
          email: email!, password: password!);

      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', ModalRoute.withName('/dashboard'));
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
