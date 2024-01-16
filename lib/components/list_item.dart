import 'package:capstone_project/components/styles.dart';
import 'package:capstone_project/model/account.dart';
import 'package:capstone_project/model/transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ListItem extends StatefulWidget {
  final Account account;
  final Transfer transfer;
  ListItem({
    super.key,
    required this.account,
    required this.transfer,
  });

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  void editTransfer() {
    Navigator.pushNamed(context, '/update', arguments: {
      'akun': widget.account,
      "transaction": widget.transfer,
    });
  }

  void deleteTransfer() async {
    try {
      CollectionReference transferCollection = _db.collection('transaction');

      if (widget.transfer.image != '') {
        await _storage.refFromURL(widget.transfer.image!).delete();
      }

      await transferCollection.doc(widget.transfer.docId).delete();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detail',
          arguments: {
            "transaction": widget.transfer,
          },
        );
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(widget.transfer.title),
            content: Text('What do you want to do?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deleteTransfer();
                },
                child: Text('Delete'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  editTransfer();
                },
                child: Text('Edit'),
              )
            ],
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1),
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(5), bottom: Radius.circular(5)),
        ),
        child: Container(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              Icon(
                Icons.image,
                size: 48,
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.transfer.title,
                    style: headerStyle(level: 3),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Rp. ${widget.transfer.amount.toString()}',
                    style: transactionStyle(widget.transfer.amount.toInt()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
