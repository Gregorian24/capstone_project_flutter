import 'package:capstone_project/components/input_widget.dart';
import 'package:capstone_project/components/styles.dart';
import 'package:capstone_project/components/validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? nama;
  String? email;
  String? noHp;
  bool obscured = true;
  bool obscured2 = true;

  final TextEditingController _password = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void register() async {
    setState(() {
      _isLoading = true;
    });
    try {
      CollectionReference accountCollection = _db.collection('account');

      final password = _password.text;
      await _auth.createUserWithEmailAndPassword(
          email: email!, password: password);

      final docId = accountCollection.doc().id;
      await accountCollection.doc(docId).set({
        'uid': _auth.currentUser!.uid,
        'nama': nama,
        'email': email,
        'noHP': noHp,
        'docId': docId,
      });

      Navigator.pushNamedAndRemoveUntil(
          context, '/login', ModalRoute.withName('/login'));
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                    SizedBox(
                      height: 80,
                      width: double.infinity,
                    ),
                    Text('Register', style: headerStyle(level: 1)),
                    Container(
                      child: const Text(
                        'Create your profile to start your journey',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 50),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: Form(
                        key: _formKey,
                        child: Column(children: [
                          InputLayout(TextFormField(
                            onChanged: (String value) => setState(() {
                              nama = value;
                            }),
                            validator: notEmptyValidator,
                            decoration: customInputDecoration('Name',
                                prefixIcon: Icon(Icons.person_outline)),
                          )),
                          InputLayout(TextFormField(
                            onChanged: (String value) => setState(() {
                              email = value;
                            }),
                            validator: notEmptyValidator,
                            decoration: customInputDecoration('Email',
                                prefixIcon: Icon(Icons.email_outlined)),
                          )),
                          InputLayout(TextFormField(
                            onChanged: (String value) => setState(() {
                              noHp = value;
                            }),
                            validator: notEmptyValidator,
                            decoration: customInputDecoration('Phone Number',
                                prefixIcon: Icon(Icons.phone_outlined)),
                          )),
                          InputLayout(
                            TextFormField(
                              controller: _password,
                              validator: notEmptyValidator,
                              obscureText: obscured,
                              decoration: customInputDecoration(
                                "Password",
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
                              ),
                            ),
                          ),
                          InputLayout(
                            TextFormField(
                              validator: (value) =>
                                  passConfirmationValidator(value, _password),
                              obscureText: obscured2,
                              decoration: customInputDecoration(
                                "Confirm Password",
                                prefixIcon: Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      obscured2 = !obscured2;
                                    });
                                  },
                                  icon: Icon(obscured2
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            width: double.infinity,
                            child: FilledButton(
                              style: buttonStyle,
                              child: Text('Register',
                                  style: headerStyle(level: 2)),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  register();
                                }
                              },
                            ),
                          )
                        ]),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Have an account already? "),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            'Login here',
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
}
