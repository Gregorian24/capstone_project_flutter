import 'package:capstone_project/components/styles.dart';
import 'package:capstone_project/model/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailTransaction extends StatefulWidget {
  const DetailTransaction({super.key});

  @override
  State<DetailTransaction> createState() => _DetailTransactionState();
}

class _DetailTransactionState extends State<DetailTransaction> {
  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final Transfer transaction = arguments['transaction'];
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(
            'Transaction Detail',
            style: headerStyle(level: 3, dark: false),
          ),
          centerTitle: true,
        ),
        backgroundColor: backgroundColorSubtle,
        body: SafeArea(
            child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                transaction.image != ''
                    ? Image.network(transaction.image!)
                    : Image.asset('assets/istock-default.png'),
                SizedBox(
                  height: 20,
                ),
                Divider(
                  thickness: 2.0,
                  color: Colors.grey,
                ),
                Center(
                  child: Text(
                    'Rp. ${transaction.amount.toString()}',
                    style: transactionStyleBig(transaction.amount.toInt()),
                  ),
                ),
                Divider(
                  thickness: 2.0,
                  color: Colors.grey,
                ),
                Center(
                  child: Text(
                    transaction.title,
                    style: headerStyle(level: 2),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Icons.category,
                              )),
                          SizedBox(width: 5),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  border: Border.all(width: 1),
                                  borderRadius: BorderRadius.circular(100),
                                  color: transaction.category == 'Top Up'
                                      ? Colors.green
                                      : transaction.category == 'Tagihan'
                                          ? Colors.red
                                          : transaction.category == 'Transaksi'
                                              ? Colors.amber
                                              : Colors.orange),
                              child: Text(
                                transaction.category,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                              padding: EdgeInsets.all(5),
                              child: Icon(Icons.calendar_today_outlined)),
                          SizedBox(width: 5),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(width: 1),
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.white,
                              ),
                              child: Text(
                                DateFormat('dd/MM/yyyy')
                                    .format(transaction.dates),
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  thickness: 2,
                  color: Colors.grey,
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Icon(Icons.notes),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Notes',
                      style: headerStyle(level: 3),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: Text(transaction.notes ?? 'Empty notes'),
                ),
              ],
            ),
          ),
        )));
  }
}
