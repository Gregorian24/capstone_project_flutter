import 'package:capstone_project/components/list_item.dart';
import 'package:capstone_project/components/styles.dart';
import 'package:capstone_project/model/account.dart';
import 'package:capstone_project/model/transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListTransaction extends StatefulWidget {
  ListTransaction({super.key});

  @override
  State<ListTransaction> createState() => _ListTransactionState();
}

class _ListTransactionState extends State<ListTransaction> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  Account account = Account(
    uid: '',
    docId: '',
    nama: '',
    noHp: '',
    email: '',
  );

  int balance = 0;

  List<Transfer> listTransaction = [];

  void getAkun() async {
    setState(() {
      _isLoading = true;
    });
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('account')
          .where('uid', isEqualTo: _auth.currentUser!.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data();

        setState(() {
          account = Account(
            uid: userData['uid'],
            nama: userData['nama'],
            noHp: userData['noHP'],
            email: userData['email'],
            docId: userData['docId'],
          );
        });
      }
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

  void getTransaction() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('transaction')
          .where('uid', isEqualTo: account.uid)
          .get();

      setState(() {
        int tempAmount = 0;
        balance = 0;
        listTransaction.clear();
        for (var documents in querySnapshot.docs) {
          listTransaction.add(
            Transfer(
              uid: documents.data()['uid'],
              docId: documents.data()['docId'],
              amount: documents.data()['amount'],
              category: documents.data()['category'],
              title: documents.data()['title'],
              notes: documents.data()['notes'],
              image: documents.data()['image'],
              dates: documents.data()['dates'].toDate(),
            ),
          );
          tempAmount = documents.data()['amount'].toInt();
          balance = balance + tempAmount;
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', ModalRoute.withName('/login'));
  }

  @override
  void initState() {
    super.initState();
    getAkun();
  }

  @override
  Widget build(BuildContext context) {
    getTransaction();
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              title: Text(
                'Money Tracking',
                style: headerStyle(level: 3, dark: false),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Logout'),
                        content: Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Back'),
                          ),
                          TextButton(
                            onPressed: () {
                              logout(context);
                            },
                            child: Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.logout),
                )
              ],
            ),
            backgroundColor: backgroundColorSubtle,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(5), bottom: Radius.circular(5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${account.nama}!',
                          style: headerStyle(level: 3),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text('Your Balance : $balance'),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'History',
                      style: headerStyle(level: 2),
                    ),
                  ),
                  Expanded(
                    child: listTransaction.isEmpty
                        ? Center(
                            child: Text('No Transaction'),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: listTransaction.length,
                            padding: EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            itemBuilder: (context, index) {
                              return ListItem(
                                account: account,
                                transfer: listTransaction[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: primaryColor,
              child: const Icon(
                Icons.add,
                size: 35,
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/add',
                  arguments: {
                    'akun': account,
                  },
                );
              },
            ),
          );
  }
}
