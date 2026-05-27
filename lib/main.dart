import 'package:flutter/material.dart';

void main() {
  runApp(const EinkaufsApp());
}

// ==========================================
// ROOT WIDGET
// ==========================================
class EinkaufsApp extends StatefulWidget {
  const EinkaufsApp({super.key});

  // Diese statische Methode erlaubt es Kind-Widgets (wie Settings),
  // auf den State der App zuzugreifen und z.B. das Theme neu zu rendern.
  static _EinkaufsAppState? of(BuildContext context) => context.findAncestorStateOfType<_EinkaufsAppState>();

  @override
  State<EinkaufsApp> createState() => _EinkaufsAppState();
}

class _EinkaufsAppState extends State<EinkaufsApp> {
  // Eine Hilfsmethode, um das MaterialApp neu zu bauen (für Dark Mode Wechsel).
  void rebuildAll() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Figma EinkaufsApp',
      debugShowCheckedModeBanner: false,
      themeMode: AppState.settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // slate-50
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// ==========================================
// MODELS & GLOBALER STATE (Mock Data)
// ==========================================

class ListItem {
  String id;
  String name;
  String category;
  bool checked;
  double? price;

  ListItem({required this.id, required this.name, required this.category, this.checked = false, this.price});
}

class ShoppingList {
  String id;
  String title;
  DateTime createdAt;
  DateTime? completedAt;
  bool isCompleted;
  List<ListItem> items;
  double? estimatedBudget;

  ShoppingList({
    required this.id, required this.title, required this.createdAt, 
    this.completedAt, this.isCompleted = false, required this.items, this.estimatedBudget
  });
}

class AppSettings {
  String currency;
  bool smartCategorization;
  bool darkMode;

  AppSettings({required this.currency, required this.smartCategorization, required this.darkMode});
}

// Nutzen eine statische Klasse als simplen globalen State für den Prototyp.
// Erspart uns "Prop-Drilling" (Daten durch jeden Screen durchreichen) und externe Libraries wie Provider.
// Für einen kleinen Uni-Prototyp ist das extrem leicht zu erklären und ausreichend.
class AppState {
  static AppSettings settings = AppSettings(currency: '€', smartCategorization: true, darkMode: false);

  static List<ShoppingList> lists = [
    ShoppingList(
      id: '1', title: 'Wocheneinkauf',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isCompleted: false, estimatedBudget: 50.0,
      items: [
        ListItem(id: 'i1', name: 'Milch 1L', category: 'Milchprodukte', checked: false, price: 1.2),
        ListItem(id: 'i2', name: 'Brot', category: 'Backwaren', checked: true, price: 2.5),
        ListItem(id: 'i3', name: 'Äpfel', category: 'Obst & Gemüse', checked: false, price: 3.0),
      ],
    ),
    ShoppingList(
      id: '2', title: 'Party Snacks',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      completedAt: DateTime.now().subtract(const Duration(days: 9)),
      isCompleted: true, estimatedBudget: 30.0,
      items: [
        ListItem(id: 'i4', name: 'Chips', category: 'Snacks', checked: true, price: 2.0),
        ListItem(id: 'i5', name: 'Cola', category: 'Getränke', checked: true, price: 1.5),
        ListItem(id: 'i6', name: 'Bier', category: 'Getränke', checked: true, price: 10.0),
      ],
    ),
  ];

  static String categorizeItem(String name) {
    final lowerName = name.toLowerCase();
    const categories = {
      'Obst & Gemüse': ['apfel', 'banane', 'tomate', 'gurke', 'salat', 'kartoffel', 'zwiebel'],
      'Milchprodukte': ['milch', 'käse', 'joghurt', 'quark', 'butter', 'sahne'],
      'Fleisch & Fisch': ['hähnchen', 'rind', 'schwein', 'fisch', 'wurst', 'lachs'],
      'Backwaren': ['brot', 'brötchen', 'toast', 'kuchen', 'croissant'],
      'Getränke': ['wasser', 'saft', 'cola', 'bier', 'wein', 'kaffee'],
      'Snacks': ['chips', 'schokolade', 'gummibärchen', 'kekse', 'nüsse'],
      'Haushalt': ['klopapier', 'waschmittel', 'spüli', 'müllbeutel', 'seife'],
    };

    for (var entry in categories.entries) {
      if (entry.value.any((keyword) => lowerName.contains(keyword))) {
        return entry.key;
      }
    }
    return 'Sonstiges';
  }

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Obst & Gemüse': return Colors.green;
      case 'Milchprodukte': return Colors.blue;
      case 'Fleisch & Fisch': return Colors.red;
      case 'Backwaren': return Colors.amber;
      case 'Getränke': return Colors.cyan;
      case 'Snacks': return Colors.purple;
      case 'Haushalt': return Colors.grey;
      default: return Colors.blueGrey;
    }
  }
}

// Hilfsfunktion zur simplen Formatierung, damit wir kein externes "intl" Paket brauchen.
String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}

// ==========================================
// MAIN SCREEN (Navigation Layout)
// ==========================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    DashboardScreen(),
    HistoryScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      // NavigationBar ist die Material 3 Variante für Tabs am unteren Rand.
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Listen'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Verlauf'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Analyse'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// ==========================================
// DASHBOARD
// ==========================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _showAddDialog() {
    String newTitle = '';
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Neue Liste erstellen'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Z.B. Wocheneinkauf', border: OutlineInputBorder()),
            onChanged: (val) => newTitle = val,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
            FilledButton(
              onPressed: () {
                if (newTitle.trim().isNotEmpty) {
                  setState(() {
                    AppState.lists.insert(0, ShoppingList(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: newTitle.trim(),
                      createdAt: DateTime.now(),
                      items: [],
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Erstellen'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeLists = AppState.lists.where((l) => !l.isCompleted).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meine Listen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
            Text('Was brauchst du heute?', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        toolbarHeight: 90,
      ),
      body: activeLists.isEmpty
        ? const Center(child: Text('Keine aktiven Listen vorhanden.', style: TextStyle(color: Colors.grey)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeLists.length,
            itemBuilder: (context, index) {
              final list = activeLists[index];
              final total = list.items.length;
              final checked = list.items.where((i) => i.checked).length;
              final progress = total == 0 ? 0.0 : checked / total;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () async {
                    // Wir warten, bis der User aus der Detailansicht zurückkommt
                    // und rufen dann setState auf, um z.B. den neuen Fortschrittsbalken anzuzeigen.
                    await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ListDetailScreen(listId: list.id)
                    ));
                    setState((){});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(list.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFFF1F5F9), // slate-100
                              child: Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(formatDate(list.createdAt), style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$checked von $total Artikeln', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                            Text('${(progress * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            // Wir nutzen die Primary Color des Themes für den Balken
                            color: Theme.of(context).colorScheme.primary, 
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ==========================================
// LIST DETAIL
// ==========================================
class ListDetailScreen extends StatefulWidget {
  final String listId;
  const ListDetailScreen({super.key, required this.listId});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  final TextEditingController _textController = TextEditingController();

  ShoppingList get list => AppState.lists.firstWhere((l) => l.id == widget.listId);

  void _addItem() {
    final name = _textController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      list.items.add(ListItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        category: AppState.settings.smartCategorization ? AppState.categorizeItem(name) : 'Sonstiges',
      ));
    });
    _textController.clear();
  }

  void _completeList() {
    setState(() {
      list.isCompleted = true;
      list.completedAt = DateTime.now();
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Gruppiere Artikel nach Kategorien, um sie blockweise anzuzeigen.
    final Map<String, List<ListItem>> grouped = {};
    for (var item in list.items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    final categories = grouped.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(list.title),
        actions: [
          if (!list.isCompleted)
            TextButton(
              onPressed: _completeList,
              child: const Text('Abschließen', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          if (!list.isCompleted)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Was möchtest du kaufen?',
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: _addItem,
                    ),
                  ),
                ),
                onSubmitted: (_) => _addItem(),
              ),
            ),
          Expanded(
            // ListView.builder wird verwendet, damit auch Listen mit 
            // hunderten Einträgen absolut flüssig bleiben.
            child: list.items.isEmpty
                ? const Center(child: Text('Diese Liste ist noch leer.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final items = grouped[category]!;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Chip(
                              label: Text(category, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppState.getCategoryColor(category))),
                              backgroundColor: AppState.getCategoryColor(category).withOpacity(0.1),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: Column(
                              children: items.map((item) {
                                return Dismissible(
                                  key: Key(item.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(24)),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                  onDismissed: (_) {
                                    setState(() {
                                      list.items.remove(item);
                                    });
                                  },
                                  child: ListTile(
                                    leading: InkWell(
                                      onTap: () => setState(() => item.checked = !item.checked),
                                      child: Icon(
                                        item.checked ? Icons.check_circle : Icons.radio_button_unchecked,
                                        color: item.checked ? Colors.lightBlue : Colors.grey.shade400,
                                        size: 28,
                                      ),
                                    ),
                                    title: Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        decoration: item.checked ? TextDecoration.lineThrough : null,
                                        color: item.checked ? Colors.grey : null,
                                      ),
                                    ),
                                    // IconButton taucht in der React-App beim Hovern auf, 
                                    // wir zeigen ihn der Einfachheit halber immer als Alternative zum Swipe.
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () => setState(() => list.items.remove(item)),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// HISTORY
// ==========================================
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = AppState.lists.where((l) => l.isCompleted).toList();
    history.sort((a, b) => (b.completedAt ?? DateTime.now()).compareTo(a.completedAt ?? DateTime.now()));

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verlauf', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
            Text('Deine vergangenen Einkäufe.', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        toolbarHeight: 90,
      ),
      body: history.isEmpty
          ? const Center(child: Text('Kein Verlauf vorhanden', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final list = history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.shopping_bag, color: Colors.green),
                    ),
                    title: Text(list.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text(list.completedAt != null ? formatDate(list.completedAt!) : 'Unbekannt', style: const TextStyle(color: Colors.grey)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${list.items.length} Artikel', style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (list.estimatedBudget != null)
                          Text('ca. ${list.estimatedBudget}€', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ListDetailScreen(listId: list.id)));
                    },
                  ),
                );
              },
            ),
    );
  }
}

// ==========================================
// ANALYTICS
// ==========================================
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int totalItemsBought = 0;
    for (var list in AppState.lists) {
      totalItemsBought += list.items.where((i) => i.checked).length;
    }
    int totalListsCompleted = AppState.lists.where((l) => l.isCompleted).length;

    Map<String, int> counts = {};
    for (var list in AppState.lists) {
      for (var item in list.items) {
        counts[item.category] = (counts[item.category] ?? 0) + 1;
      }
    }
    var sortedCategories = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    var topCategories = sortedCategories.take(5).toList();

    int maxCount = topCategories.isNotEmpty ? topCategories.first.value : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analysen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
            Text('Dein Einkaufsverhalten im Blick.', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        toolbarHeight: 90,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.lightBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.trending_up, color: Colors.lightBlue),
                        ),
                        const SizedBox(height: 16),
                        Text('$totalItemsBought', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        const Text('Gekaufte Artikel', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.pie_chart, color: Colors.indigo),
                        ),
                        const SizedBox(height: 16),
                        Text('$totalListsCompleted', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        const Text('Listen erledigt', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Top Kategorien', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text('Nach Anzahl der Artikel', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 32),
                  if (topCategories.isEmpty)
                    const Text('Noch keine Daten vorhanden.', style: TextStyle(color: Colors.grey))
                  else
                    // Wir bauen das Diagramm mit einfachen Standard-Widgets (Row, Column, Container), 
                    // um keine externen Chart-Libraries einbinden zu müssen. Das spart Setup-Zeit für den Prototyp.
                    SizedBox(
                      height: 200,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: topCategories.map((entry) {
                          double heightFactor = entry.value / maxCount;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('${entry.value}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 8),
                              Container(
                                width: 32,
                                height: 130 * heightFactor,
                                decoration: BoxDecoration(
                                  color: AppState.getCategoryColor(entry.key),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  entry.key, 
                                  style: const TextStyle(fontSize: 10, color: Colors.grey), 
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SETTINGS
// ==========================================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Einstellungen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
            Text('Passe die App an deine Bedürfnisse an.', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        toolbarHeight: 90,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: Text('APP EINSTELLUNGEN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.auto_awesome, color: Colors.amber),
                  ),
                  title: const Text('Smartes Einsortieren', style: TextStyle(fontWeight: FontWeight.w500)),
                  value: AppState.settings.smartCategorization,
                  onChanged: (val) {
                    setState(() => AppState.settings.smartCategorization = val);
                  },
                ),
                Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.dark_mode, color: Colors.indigo),
                  ),
                  title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w500)),
                  value: AppState.settings.darkMode,
                  onChanged: (val) {
                    setState(() => AppState.settings.darkMode = val);
                    // Wir rufen eine Funktion auf dem Root-Widget auf, um das Theme global neu zu laden.
                    // Das ist ein einfacher Trick für State Management ohne komplexe Architektur.
                    EinkaufsApp.of(context)?.rebuildAll();
                  },
                ),
                Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.euro, color: Colors.green),
                  ),
                  title: const Text('Währung', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(AppState.settings.currency, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: Text('ACCOUNT & SYNC', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.lightBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.cloud, color: Colors.lightBlue),
                  ),
                  title: const Text('Cloud Sync', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {},
                ),
                Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.notifications, color: Colors.red),
                  ),
                  title: const Text('Benachrichtigungen', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}