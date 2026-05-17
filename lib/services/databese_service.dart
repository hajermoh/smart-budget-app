import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference expenses =
      FirebaseFirestore.instance.collection('expenses');

  Future<void> addExpense({
    required String title,
    required String category,
    required double amount,
  }) {
    return expenses.add({
      'title': title,
      'category': category,
      'amount': amount,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getExpenses() {
    return expenses.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> deleteExpense(String id) {
    return expenses.doc(id).delete();
  }
}