import 'dart:io';
import 'package:capstone_project/components/input_widget.dart';
import 'package:capstone_project/components/styles.dart';
import 'package:capstone_project/components/validator.dart';
import 'package:capstone_project/components/vars.dart';
import 'package:capstone_project/model/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({super.key});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final _formKey = GlobalKey<FormState>();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  bool _isLoading = false;

  String? title;
  String? date;
  String? notes;
  String? amount;
  String? category;

  ImagePicker picker = ImagePicker();
  XFile? file;

  Image imagePreview() {
    if (file == null) {
      return Image.asset('assets/istock-default.png', width: 180, height: 180);
    } else {
      return Image.file(File(file!.path), width: 180, height: 180);
    }
  }

  Future<dynamic> uploadDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (buildContext) {
          return AlertDialog(
            title: const Text('Pick source'),
            actions: [
              TextButton(
                onPressed: () async {
                  XFile? upload =
                      await picker.pickImage(source: ImageSource.camera);

                  setState(() {
                    file = upload;
                  });

                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.camera_alt),
              ),
              TextButton(
                onPressed: () async {
                  XFile? upload =
                      await picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    file = upload;
                  });

                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.photo_library),
              ),
            ],
          );
        });
  }

  Future<String> uploadImage() async {
    if (file == null) return '';

    String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      Reference dirUpload =
          _storage.ref().child('upload/${_auth.currentUser!.uid}');
      Reference storedDir = dirUpload.child(uniqueFilename);

      await storedDir.putFile(File(file!.path));

      return await storedDir.getDownloadURL();
    } catch (e) {
      return '';
    }
  }

  void addTransaksi(Account akun) async {
    setState(() {
      _isLoading = true;
    });
    try {
      CollectionReference transactionCollection =
          _firestore.collection('transaction');

      // Convert DateTime to Firestore Timestamp
      DateFormat pickerFormat = DateFormat('yyyy-MM-dd');
      DateTime dateTime = pickerFormat.parse(date!);
      Timestamp timestamp = Timestamp.fromDate(dateTime);

      String url = await uploadImage();

      int? amountInt = int.tryParse(amount!);

      final id = transactionCollection.doc().id;

      await transactionCollection.doc(id).set({
        'uid': _auth.currentUser!.uid,
        'docId': id,
        'title': title,
        'category': category,
        'amount': amountInt ?? 0,
        'notes': notes,
        'image': url,
        'dates': timestamp,
      }).catchError((e) {
        throw e;
      });
      Navigator.popAndPushNamed(context, '/dashboard');
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final Account akun = arguments['akun'];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Add Transaksi',
          style: headerStyle(level: 3, dark: false),
        ),
      ),
      backgroundColor: backgroundColorSubtle,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              InputLayout(
                                TextFormField(
                                  onChanged: (String value) => setState(() {
                                    title = value;
                                  }),
                                  validator: notEmptyValidator,
                                  decoration: customInputDecoration('Title',
                                      prefixIcon: const Icon(Icons.edit_note)),
                                ),
                              ),
                              InputLayout(
                                DateTimePicker(
                                  type: DateTimePickerType.date,
                                  dateMask: 'dd/MMM/yyyy',
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  onChanged: (String value) => setState(() {
                                    date = value;
                                  }),
                                  onSaved: (val) => date = val,
                                  validator: notEmptyValidator,
                                  decoration: customInputDecoration('Date',
                                      prefixIcon: Icon(Icons.event)),
                                ),
                              ),
                              InputLayout(
                                TextFormField(
                                  onChanged: (String value) => setState(() {
                                    amount = value;
                                  }),
                                  keyboardType: TextInputType.number,
                                  validator: notEmptyValidator,
                                  decoration: customInputDecoration('Amount',
                                      prefixIcon:
                                          const Icon(Icons.attach_money)),
                                ),
                              ),
                              InputLayout(
                                DropdownButtonFormField<String>(
                                    validator: notEmptyValidator,
                                    decoration: customInputDecoration(
                                        'Category',
                                        prefixIcon: Icon(Icons.category)),
                                    items: dataTransaksi.map((e) {
                                      return DropdownMenuItem<String>(
                                          value: e, child: Text(e));
                                    }).toList(),
                                    onChanged: (selected) {
                                      setState(() {
                                        category = selected;
                                      });
                                    }),
                              ),
                              InputLayout(
                                TextFormField(
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: file == null ? '' : file!.path),
                                    decoration: customInputDecoration(
                                      'Image',
                                      prefixIcon: const Icon(Icons.image),
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            uploadDialog(context);
                                          },
                                          icon: Icon(Icons.upload)),
                                    )),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: imagePreview(),
                              ),
                              InputLayout(
                                TextFormField(
                                  onChanged: (String value) => setState(() {
                                    notes = value;
                                  }),
                                  maxLines: 3,
                                  decoration: notesInputDecoration('Notes'),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 20),
                                width: double.infinity,
                                child: FilledButton(
                                    style: buttonStyle,
                                    child: Text(
                                      'Add',
                                      style: headerStyle(level: 3, dark: false),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        addTransaksi(akun);
                                      }
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
