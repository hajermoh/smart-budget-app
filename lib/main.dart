import 'package:flutter/material.dart';

void main() {
  runApp(const SmartBudgetApp());
}

const darkBlue = Color(0xFF071A3D);
const softBlue = Color(0xFFEAF2FF);
const gold = Color(0xFFF4B400);

class SmartBudgetApp extends StatelessWidget {
  const SmartBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Budget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        colorScheme: ColorScheme.fromSeed(seedColor: darkBlue),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBlue,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class Expense {
  final String title;
  final String category;
  final double amount;

  Expense({
    required this.title,
    required this.category,
    required this.amount,
  });
}

class SavingGoal {
  final String name;
  final double target;
  double saved;

  SavingGoal({
    required this.name,
    required this.target,
    required this.saved,
  });
}

class AppData {
  static List<Expense> expenses = [
    Expense(title: 'Groceries', category: 'Food', amount: 25),
    Expense(title: 'Shell Station', category: 'Gas', amount: 10),
    Expense(title: 'Ooredoo Bill', category: 'Bills', amount: 18),
  ];

  static List<SavingGoal> goals = [
    SavingGoal(name: 'Emergency Fund', target: 500, saved: 220),
    SavingGoal(name: 'Travel', target: 800, saved: 300),
  ];

  static double get totalExpenses =>
      expenses.fold(0, (sum, item) => sum + item.amount);

  static double get totalSavings =>
      goals.fold(0, (sum, item) => sum + item.saved);
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: softBlue,
                  child: Icon(
                    Icons.attach_money,
                    color: darkBlue,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Smart Budget',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your smart money assistant',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 28),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int pageIndex = 0;

  final pages = const [
    DashboardScreen(),
    ExpensesScreen(),
    SavingsScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[pageIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: pageIndex,
        backgroundColor: Colors.white,
        indicatorColor: softBlue,
        onDestinationSelected: (index) {
          setState(() {
            pageIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Goals'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Map<String, double> categoryTotals() {
    final Map<String, double> result = {};
    for (final expense in AppData.expenses) {
      result[expense.category] = (result[expense.category] ?? 0) + expense.amount;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final categories = categoryTotals();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            premiumBalanceCard(),
            const SizedBox(height: 18),
            quickActions(),
            const SizedBox(height: 22),
            const Text(
              'Spending Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkBlue),
            ),
            const SizedBox(height: 12),
            ...categories.entries.map((entry) {
              final total = AppData.totalExpenses == 0 ? 1 : AppData.totalExpenses;
              return categoryBar(entry.key, entry.value, entry.value / total);
            }),
            const SizedBox(height: 22),
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkBlue),
            ),
            const SizedBox(height: 10),
            ...AppData.expenses.take(4).map(
              (expense) => premiumTransactionTile(expense),
            ),
          ],
        ),
      ),
    );
  }

  Widget premiumBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkBlue, Color(0xFF123D7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Available Balance', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          const Text(
            'OMR 750.000',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: smallWhiteInfo(
                  'Expenses',
                  'OMR ${AppData.totalExpenses.toStringAsFixed(2)}',
                  Icons.trending_down,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: smallWhiteInfo(
                  'Savings',
                  'OMR ${AppData.totalSavings.toStringAsFixed(2)}',
                  Icons.attach_money,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget smallWhiteInfo(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget quickActions() {
    return Row(
      children: const [
        Expanded(child: ActionCard(icon: Icons.add_card, title: 'Add Expense')),
        SizedBox(width: 10),
        Expanded(child: ActionCard(icon: Icons.savings, title: 'Save Money')),
        SizedBox(width: 10),
        Expanded(child: ActionCard(icon: Icons.notifications_active, title: 'Alerts')),
      ],
    );
  }

  Widget categoryBar(String category, double amount, double percent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$category  •  OMR ${amount.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent.clamp(0, 1),
            minHeight: 10,
            backgroundColor: softBlue,
            color: darkBlue,
            borderRadius: BorderRadius.circular(20),
          ),
        ],
      ),
    );
  }

  Widget premiumTransactionTile(Expense expense) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: softBlue,
          child: Icon(Icons.payments, color: darkBlue),
        ),
        title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(expense.category),
        trailing: Text(
          '- OMR ${expense.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: darkBlue),
        ),
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const ActionCard({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: darkBlue),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  String selectedCategory = 'Food';

  final categories = ['Food', 'Gas', 'Bills', 'Travel', 'Gifts', 'Health', 'Shopping', 'Emergency', 'Other'];

  void addExpense() {
    if (titleController.text.trim().isEmpty || amountController.text.trim().isEmpty) return;

    setState(() {
      AppData.expenses.add(
        Expense(
          title: titleController.text.trim(),
          category: selectedCategory,
          amount: double.tryParse(amountController.text.trim()) ?? 0,
        ),
      );
    });

    titleController.clear();
    amountController.clear();
    Navigator.pop(context);
  }

  void openAddExpenseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (context, modalSetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Add Expense', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Expense title', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount in OMR', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (value) => modalSetState(() => selectedCategory = value!),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: darkBlue, foregroundColor: Colors.white),
                    onPressed: addExpense,
                    child: const Text('Save Expense'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void deleteExpense(int index) {
    setState(() {
      AppData.expenses.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(onPressed: openAddExpenseSheet, icon: const Icon(Icons.add)),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AppData.expenses.length,
        itemBuilder: (context, index) {
          final e = AppData.expenses[index];
          return Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: softBlue, child: Icon(Icons.payments, color: darkBlue)),
              title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(e.category),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => deleteExpense(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        onPressed: openAddExpenseSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  void addMoneyToGoal(int index) {
    setState(() {
      AppData.goals[index].saved += 20;
      if (AppData.goals[index].saved > AppData.goals[index].target) {
        AppData.goals[index].saved = AppData.goals[index].target;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AppData.goals.length,
        itemBuilder: (context, index) {
          final g = AppData.goals[index];
          final progress = g.target == 0 ? 0.0 : g.saved / g.target;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: softBlue,
                      child: Icon(Icons.attach_money, color: darkBlue),
                    ),
                    const SizedBox(width: 12),
                    Text(g.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('OMR ${g.saved.toStringAsFixed(2)} / OMR ${g.target.toStringAsFixed(2)}'),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress.clamp(0, 1),
                  minHeight: 12,
                  color: darkBlue,
                  backgroundColor: softBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: darkBlue, foregroundColor: Colors.white),
                  onPressed: () => addMoneyToGoal(index),
                  child: const Text('Add OMR 20'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Map<String, double> categoryTotals() {
    final Map<String, double> result = {};
    for (final expense in AppData.expenses) {
      result[expense.category] = (result[expense.category] ?? 0) + expense.amount;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final categories = categoryTotals();

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            reportCard('Total Spending', 'OMR ${AppData.totalExpenses.toStringAsFixed(2)}', Icons.payments),
            reportCard('Total Savings', 'OMR ${AppData.totalSavings.toStringAsFixed(2)}', Icons.attach_money),
            const SizedBox(height: 18),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Category Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkBlue)),
            ),
            const SizedBox(height: 10),
            ...categories.entries.map(
              (entry) => Card(
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.pie_chart, color: darkBlue),
                  title: Text(entry.key),
                  trailing: Text('OMR ${entry.value.toStringAsFixed(2)}'),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(20)),
              child: const Text(
                'Insight: Food and bills are usually the highest spending areas. Reducing small repeated expenses can improve monthly savings.',
                textAlign: TextAlign.center,
                style: TextStyle(color: darkBlue, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget reportCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: softBlue, child: Icon(icon, color: darkBlue)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkBlue)),
            ],
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: const [
          CircleAvatar(
            radius: 48,
            backgroundColor: darkBlue,
            child: Icon(Icons.person, color: Colors.white, size: 54),
          ),
          SizedBox(height: 14),
          Center(child: Text('Hajer Alabalushi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          Center(child: Text('Currency: OMR')),
          SizedBox(height: 24),
          PremiumSettingTile(icon: Icons.security, title: 'Security', subtitle: 'Password and privacy settings'),
          PremiumSettingTile(icon: Icons.notifications_active, title: 'Notifications', subtitle: 'Spending alerts and reminders'),
          PremiumSettingTile(icon: Icons.currency_exchange, title: 'Currency', subtitle: 'Omani Rial - OMR'),
          PremiumSettingTile(icon: Icons.info_outline, title: 'About App', subtitle: 'Smart finance assistant prototype'),
        ],
      ),
    );
  }
}

class PremiumSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const PremiumSettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: softBlue, child: Icon(icon, color: darkBlue)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}