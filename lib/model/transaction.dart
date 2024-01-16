class Transfer {
  final String uid;
  final String docId;

  final String title;
  final num amount;
  final String category;
  String? notes;
  String? image;
  final DateTime dates;

  Transfer(
      {required this.uid,
      required this.docId,
      required this.amount,
      required this.category,
      required this.title,
      this.notes,
      this.image,
      required this.dates});
}
