import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SmartBudgetApp());
}

const darkBlue = Color(0xFF071A3D);
const softBlue = Color(0xFFEAF2FF);

class SmartBudgetApp extends StatelessWidget {
  const SmartBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Smart Budget",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        colorScheme: ColorScheme.fromSeed(seedColor: darkBlue),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBlue,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? const LoginScreen()
          : const HomeScreen(),
    );
  }
}

class DB {
  static String get uid => FirebaseAuth.instance.currentUser!.uid;

  static CollectionReference get expenses =>
      FirebaseFirestore.instance.collection("users").doc(uid).collection("expenses");

  static CollectionReference get goals =>
      FirebaseFirestore.instance.collection("users").doc(uid).collection("goals");

  static DocumentReference get profile =>
      FirebaseFirestore.instance.collection("users").doc(uid);

  static Future<void> addExpense(String title, String category, double amount) {
    return expenses.add({
      "title": title,
      "category": category,
      "amount": amount,
      "createdAt": Timestamp.now(),
    });
  }

  static Future<void> deleteExpense(String id) {
    return expenses.doc(id).delete();
  }

  static Future<void> addGoal(String name, double target, double saved) {
    return goals.add({
      "name": name,
      "target": target,
      "saved": saved,
      "createdAt": Timestamp.now(),
    });
  }

  static Future<void> updateGoal(String id, double saved) {
    return goals.doc(id).update({"saved": saved});
  }

  static Future<void> deleteGoal(String id) {
    return goals.doc(id).delete();
  }

  static Future<void> updateName(String name) {
    return profile.set({"name": name}, SetOptions(merge: true));
  }
}

/* AUTH */

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final user = FirebaseAuth.instance.currentUser!;
      if (!user.emailVerified) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifyEmailScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      showMessage("Login failed. Check email and password.");
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Smart Budget",
      subtitle: "Your smart money assistant",
      children: [
        TextField(controller: email, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder())),
        const SizedBox(height: 18),
        PrimaryButton(text: "Login", onPressed: login),
        TextButton(
          child: const Text("Create new account"),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
        ),
        TextButton(
          child: const Text("Forgot password?"),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
        ),
      ],
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  Future<void> signUp() async {
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      await cred.user!.sendEmailVerification();

      await FirebaseFirestore.instance.collection("users").doc(cred.user!.uid).set({
        "name": name.text.trim(),
        "email": email.text.trim(),
        "createdAt": Timestamp.now(),
      });

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const VerifyEmailScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sign up failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Create Account",
      subtitle: "Register to start",
      children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: email, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder())),
        const SizedBox(height: 18),
        PrimaryButton(text: "Sign Up", onPressed: signUp),
      ],
    );
  }
}

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  Future<void> checkVerification(BuildContext context) async {
    await FirebaseAuth.instance.currentUser!.reload();
    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please verify your email first")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Verify Email",
      subtitle: "Security check",
      children: [
        const Icon(Icons.mark_email_read, size: 70, color: darkBlue),
        const SizedBox(height: 16),
        const Text("A verification email was sent. Open your email, verify, then press the button below.", textAlign: TextAlign.center),
        const SizedBox(height: 18),
        PrimaryButton(text: "I Verified My Email", onPressed: () => checkVerification(context)),
      ],
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final email = TextEditingController();

  Future<void> resetPassword() async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reset email sent")));
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Reset Password",
      subtitle: "Send reset link",
      children: [
        TextField(controller: email, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder())),
        const SizedBox(height: 18),
        PrimaryButton(text: "Send Reset Link", onPressed: resetPassword),
      ],
    );
  }
}

/* HOME */

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int page = 0;
  void goTo(int index) => setState(() => page = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(onNavigate: goTo),
      const ExpensesScreen(),
      const GoalsScreen(),
      const ReportsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[page],
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        indicatorColor: softBlue,
        onDestinationSelected: goTo,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home"),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: "Expenses"),
          NavigationDestination(icon: Icon(Icons.flag_outlined), label: "Goals"),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: "Reports"),
          NavigationDestination(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}

/* DASHBOARD */

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: StreamBuilder<QuerySnapshot>(
        stream: DB.expenses.orderBy("createdAt", descending: true).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          final total = docs.fold(0.0, (sum, d) => sum + (d["amount"] as num).toDouble());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [darkBlue, Color(0xFF123D7A)]),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("Total Balance", style: TextStyle(color: Colors.white70)),
                    const Text("OMR 750.000", style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    Text("Total Expenses: OMR ${total.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white)),
                  ]),
                ),
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(child: ActionCard(icon: Icons.add_card, title: "Add Expense", onTap: () => onNavigate(1))),
                  Expanded(child: ActionCard(icon: Icons.flag, title: "Goals", onTap: () => onNavigate(2))),
                  Expanded(child: ActionCard(icon: Icons.bar_chart, title: "Reports", onTap: () => onNavigate(3))),
                ]),
                const SizedBox(height: 20),
                const Align(alignment: Alignment.centerLeft, child: Text("Recent Expenses", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
                ...docs.take(5).map((d) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.payments, color: darkBlue),
                    title: Text(d["title"]),
                    subtitle: Text(d["category"]),
                    trailing: Text("OMR ${(d["amount"] as num).toString()}"),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}

/* EXPENSES */

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});
  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final title = TextEditingController();
  final amount = TextEditingController();
  String category = "Food";
  final categories = ["Food", "Gas", "Bills", "Travel", "Gifts", "Health", "Shopping", "Emergency", "Other"];

  void openAddExpense() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: StatefulBuilder(builder: (context, modalSetState) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("Add Expense", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            TextField(controller: title, decoration: const InputDecoration(labelText: "Expense title")),
            TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount")),
            DropdownButtonFormField(
              value: category,
              items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => modalSetState(() => category = v!),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              text: "Save",
              onPressed: () async {
                await DB.addExpense(title.text, category, double.tryParse(amount.text) ?? 0);
                title.clear();
                amount.clear();
                Navigator.pop(context);
              },
            )
          ]);
        }),
      ),
    );
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text("Are you sure you want to delete this expense?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await DB.deleteExpense(id);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expenses"), actions: [IconButton(onPressed: openAddExpense, icon: const Icon(Icons.add))]),
      body: StreamBuilder<QuerySnapshot>(
        stream: DB.expenses.orderBy("createdAt", descending: true).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.payments, color: darkBlue),
                  title: Text(d["title"]),
                  subtitle: Text(d["category"]),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => confirmDelete(d.id)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: darkBlue, foregroundColor: Colors.white, onPressed: openAddExpense, child: const Icon(Icons.add)),
    );
  }
}

/* GOALS */

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});
  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final name = TextEditingController();
  final target = TextEditingController();
  final saved = TextEditingController();

  void openAddGoal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("Add Goal", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          TextField(controller: name, decoration: const InputDecoration(labelText: "Goal name")),
          TextField(controller: target, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Target")),
          TextField(controller: saved, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Saved")),
          const SizedBox(height: 14),
          PrimaryButton(
            text: "Save Goal",
            onPressed: () async {
              await DB.addGoal(name.text, double.tryParse(target.text) ?? 0, double.tryParse(saved.text) ?? 0);
              name.clear(); target.clear(); saved.clear();
              Navigator.pop(context);
            },
          )
        ]),
      ),
    );
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Goal"),
        content: const Text("Are you sure you want to delete this goal?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () async { await DB.deleteGoal(id); Navigator.pop(context); }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Future<void> changeGoal(String id, double current, double target, double value) async {
    double newValue = current + value;
    if (newValue < 0) newValue = 0;
    if (newValue > target) newValue = target;
    await DB.updateGoal(id, newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Savings Goals"), actions: [IconButton(onPressed: openAddGoal, icon: const Icon(Icons.add))]),
      body: StreamBuilder<QuerySnapshot>(
        stream: DB.goals.orderBy("createdAt", descending: true).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              final current = (d["saved"] as num).toDouble();
              final target = (d["target"] as num).toDouble();
              final progress = target == 0 ? 0.0 : current / target;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.attach_money, color: darkBlue),
                      Expanded(child: Text(d["name"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => confirmDelete(d.id)),
                    ]),
                    Text("OMR ${current.toStringAsFixed(2)} / OMR ${target.toStringAsFixed(2)}"),
                    LinearProgressIndicator(value: progress.clamp(0, 1)),
                    Row(children: [
                      Expanded(child: OutlinedButton(onPressed: () => changeGoal(d.id, current, target, -20), child: const Text("Deduct 20"))),
                      Expanded(child: ElevatedButton(onPressed: () => changeGoal(d.id, current, target, 20), child: const Text("Add 20"))),
                    ])
                  ]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: darkBlue, foregroundColor: Colors.white, onPressed: openAddGoal, child: const Icon(Icons.add)),
    );
  }
}

/* REPORTS */

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Map<String, double> getCategories(List<QueryDocumentSnapshot> docs) {
    final Map<String, double> data = {};
    for (final d in docs) {
      data[d["category"]] = (data[d["category"]] ?? 0) + (d["amount"] as num).toDouble();
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: StreamBuilder<QuerySnapshot>(
        stream: DB.expenses.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final data = getCategories(snap.data!.docs);
          final total = data.values.fold(0.0, (a, b) => a + b);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Card(child: ListTile(title: const Text("Total Spending"), subtitle: Text("OMR ${total.toStringAsFixed(2)}"))),
              SizedBox(height: 250, child: CustomPaint(painter: PieChartPainter(data), child: Container())),
              ...data.entries.map((e) => ListTile(title: Text(e.key), trailing: Text("OMR ${e.value.toStringAsFixed(2)}"))),
            ]),
          );
        },
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;
    final colors = [darkBlue, Colors.blue, Colors.orange, Colors.green, Colors.purple, Colors.red];
    final paint = Paint()..style = PaintingStyle.fill;
    final rect = Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: 100);
    double start = -pi / 2;
    int i = 0;
    for (final value in data.values) {
      final sweep = (value / total) * 2 * pi;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect, start, sweep, true, paint);
      start += sweep;
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/* PROFILE */

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final name = TextEditingController();

  void editName(String current) {
    name.text = current;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(controller: name),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () async { await DB.updateName(name.text); Navigator.pop(context); }, child: const Text("Save")),
        ],
      ),
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile & Settings")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: DB.profile.snapshots(),
        builder: (context, snap) {
          final currentName = snap.hasData && snap.data!.exists ? (snap.data!["name"] ?? "User") : "User";
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const CircleAvatar(radius: 48, backgroundColor: darkBlue, child: Icon(Icons.add_a_photo, color: Colors.white, size: 42)),
              const SizedBox(height: 14),
              Center(child: Text(currentName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
              const Center(child: Text("Currency: OMR")),
              SettingTile(icon: Icons.edit, title: "Edit Name", subtitle: "Change profile name", onTap: () => editName(currentName)),
              SettingTile(icon: Icons.security, title: "Security", subtitle: "Firebase Authentication enabled", onTap: () {}),
              SettingTile(icon: Icons.logout, title: "Logout", subtitle: "Return to login", onTap: logout),
            ],
          );
        },
      ),
    );
  }
}

/* WIDGETS */

class AuthLayout extends StatelessWidget {
  final String title, subtitle;
  final List<Widget> children;
  const AuthLayout({super.key, required this.title, required this.subtitle, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const CircleAvatar(radius: 42, backgroundColor: softBlue, child: Icon(Icons.attach_money, color: darkBlue, size: 48)),
              Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkBlue)),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 22),
              ...children,
            ]),
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const PrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: onPressed, child: Text(text)));
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const ActionCard({super.key, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, child: Card(child: SizedBox(height: 90, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: darkBlue), Text(title)]))));
  }
}

class SettingTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const SettingTile({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(leading: Icon(icon, color: darkBlue), title: Text(title), subtitle: Text(subtitle), onTap: onTap));
  }
}