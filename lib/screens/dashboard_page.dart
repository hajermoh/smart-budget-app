import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user logged in');
    }

    final docRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'email': user.email ?? '',
        'monthlyIncome': 0,
        'totalSavings': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return await docRef.get();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Budget Dashboard'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data?.data() ?? {};

          final monthlyIncome = data['monthlyIncome'] ?? 0;
          final totalSavings = data['totalSavings'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user?.email ?? 'User'}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                Card(
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(
                      Icons.payments,
                      color: Colors.indigo,
                    ),
                    title: const Text('Monthly Income'),
                    subtitle: Text('$monthlyIncome OMR'),
                  ),
                ),

                Card(
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(
                      Icons.savings,
                      color: Colors.green,
                    ),
                    title: const Text('Total Savings'),
                    subtitle: Text('$totalSavings OMR'),
                  ),
                ),

                Card(
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(
                      Icons.pie_chart,
                      color: Colors.orange,
                    ),
                    title: const Text('Expenses'),
                    subtitle: const Text('No expenses added yet'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}