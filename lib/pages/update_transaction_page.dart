import 'dart:io';

import 'package:capstone_project/components/input_widget.dart';
import 'package:capstone_project/components/styles.dart';
import 'package:capstone_project/components/validator.dart';
import 'package:capstone_project/components/vars.dart';
import 'package:capstone_project/model/account.dart';
import 'package:capstone_project/model/transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UpdateTransaction extends StatefulWidget {
  const UpdateTransaction({super.key});

  @override
  State<UpdateTransaction> createState() => _UpdateTransactionState();
}

class _UpdateTransactionState extends State<UpdateTransaction> {
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

  Image imagePreview(String? img) {
    if (file != null) {
      return Image.file(File(file!.path), width: 180, height: 180);
    } else if (img != null && img != '') {
      return Image.network(img, width: 180, height: 180);
    } else {
      return Image.asset('assets/istock-default.png', width: 180, height: 180);
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

  Future<String> uploadImage(String? image) async {
    if (file == null) return image ?? '';

    String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      if (file != null) {
        Reference dirUpload =
            _storage.ref().child('upload/${_auth.currentUser!.uid}');
        Reference storedDir = dirUpload.child(uniqueFilename);

        await storedDir.putFile(File(file!.path));

        return await storedDir.getDownloadURL();
      } else {
        return image ?? '';
      }
    } catch (e) {
      return '';
    }
  }

  void addTransaksi(Account akun, Transfer transaction) async {
    setState(() {
      _isLoading = true;
    });
    try {
      CollectionReference transactionCollection =
          _firestore.collection('transaction');

      DateFormat pickerFormat = DateFormat('yyyy-MM-dd');
      DateTime dateTime =
          pickerFormat.parse(date ?? transaction.dates.toString());
      Timestamp timestamp = Timestamp.fromDate(dateTime);

      if (file != null &&
          transaction.image != null &&
          transaction.image != '') {
        await _storage.refFromURL(transaction.image!).delete();
      }

      String url = await uploadImage(transaction.image);

      int? amountInt = int.tryParse(amount ?? transaction.amount.toString());

      await transactionCollection.doc(transaction.docId).update({
        'uid': _auth.currentUser!.uid,
        'title': title ?? transaction.title,
        'category': category ?? transaction.category,
        'amount': amountInt ?? transaction.amount,
        'notes': notes ?? transaction.notes,
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
    final Transfer transaction = arguments['transaction'];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Edit Transaksi',
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
                                  initialValue: transaction.title,
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
                                  initialValue: transaction.dates.toString(),
                                  initialDate: transaction.dates,
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
                                  initialValue: transaction.amount.toString(),
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
                                    value: transaction.category,
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
                                child: imagePreview(transaction.image),
                              ),
                              InputLayout(
                                TextFormField(
                                  initialValue: transaction.notes,
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
                                      'Update',
                                      style: headerStyle(level: 3, dark: false),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        addTransaksi(akun, transaction);
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
