import 'package:flutter/material.dart';

void main() {
  runApp(const EinkaufsApp());
}

// ==========================================
// ROOT WIDGET
// ==========================================
class EinkaufsApp extends StatefulWidget {
  const EinkaufsApp({super.key});

  static _EinkaufsAppState? of(BuildContext context) => context.findAncestorStateOfType<_EinkaufsAppState>();

  @override
  State<EinkaufsApp> createState() => _EinkaufsAppState();
}

class _EinkaufsAppState extends State<EinkaufsApp> {
  void rebuildAll() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MVP 1 EinkaufsApp',
      debugShowCheckedModeBanner: false,
      themeMode: AppState.darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), 
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
// MODELS & GLOBALER STATE
// ==========================================

class ListItem {
  String id;
  String name;
  String category;
  bool checked;

  ListItem({required this.id, required this.name, required this.category, this.checked = false});
}

class ShoppingList {
  String id;
  String title;
  DateTime createdAt;
  DateTime? completedAt;
  bool isCompleted;
  List<ListItem> items;

  ShoppingList({
    required this.id, required this.title, required this.createdAt, 
    this.completedAt, this.isCompleted = false, required this.items
  });
}

// Globaler State für das einfache MVP
class AppState {
  static bool darkMode = false;

  // In-Memory-Speicherung
  static List<ShoppingList> lists = [];

  static const categoriesMap = {
    'Obst & Gemüse': ['apfel', 'banane', 'tomate', 'gurke', 'salat'],
    'Milchprodukte': ['milch', 'käse', 'joghurt', 'quark', 'butter'],
    'Fleisch & Fisch': ['hähnchen', 'rind', 'schwein', 'fisch', 'wurst'],
    'Backwaren': ['brot', 'brötchen', 'toast', 'kuchen'],
    'Getränke': ['wasser', 'saft', 'cola', 'bier', 'wein'],
    'Snacks': ['chips', 'schokolade', 'gummibärchen', 'kekse'],
    'Haushalt': ['seife', 'waschmittel', 'papier'],
  };

  static List<String> get allCategories => [...categoriesMap.keys, 'Sonstiges'];

  static String categorizeItem(String name) {
    final lowerName = name.toLowerCase();
    for (var entry in categoriesMap.entries) {
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), selectedIcon: Icon(Icons.list), label: 'Listen'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Verlauf'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Analyse'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// ==========================================
// DASHBOARD (MVP: Liste anlegen, löschen, Name ändern)
// ==========================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _showListDialog({ShoppingList? listToEdit}) {
    String newTitle = listToEdit?.title ?? '';
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(listToEdit == null ? 'Neue Liste' : 'Liste umbenennen'),
          content: TextField(
            autofocus: true,
            controller: TextEditingController(text: newTitle),
            decoration: const InputDecoration(hintText: 'Z.B. Wocheneinkauf', border: OutlineInputBorder()),
            onChanged: (val) => newTitle = val,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
            FilledButton(
              onPressed: () {
                if (newTitle.trim().isNotEmpty) {
                  setState(() {
                    if (listToEdit == null) {
                      AppState.lists.insert(0, ShoppingList(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: newTitle.trim(),
                        createdAt: DateTime.now(),
                        items: [],
                      ));
                    } else {
                      listToEdit.title = newTitle.trim();
                    }
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      }
    );
  }

  void _deleteList(ShoppingList list) {
    setState(() {
      AppState.lists.remove(list);
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeLists = AppState.lists.where((l) => !l.isCompleted).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktive Listen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: activeLists.isEmpty
        ? const Center(child: Text('Keine aktiven Listen vorhanden.'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeLists.length,
            itemBuilder: (context, index) {
              final list = activeLists[index];
              final total = list.items.length;
              final checked = list.items.where((i) => i.checked).length;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => ListDetailScreen(listId: list.id)));
                    setState((){});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(list.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                  onPressed: () => _showListDialog(listToEdit: list),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                  onPressed: () => _deleteList(list),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('$checked / $total Artikel erledigt', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showListDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ==========================================
// LIST DETAIL (MVP: Artikel verwalten)
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
        category: AppState.categorizeItem(name),
      ));
    });
    _textController.clear();
  }

  void _completeList() {
    setState(() {
      list.isCompleted = true;
      list.completedAt = DateTime.now();
      Navigator.pop(context); // Gehe zurück bei Abschluss
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // Auch bei vergangenen Listen lassen wir die Bearbeitung zu (MVP Anforderung: "vergangene Listen bearbeiten")
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Neuen Artikel hinzufügen...',
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addItem,
                ),
              ),
              onSubmitted: (_) => _addItem(),
            ),
          ),
          Expanded(
            // Nutze ListView.builder für Performance
            child: list.items.isEmpty
                ? const Center(child: Text('Diese Liste ist noch leer.'))
                : ListView.builder(
                    itemCount: list.items.length,
                    itemBuilder: (context, index) {
                      final item = list.items[index];
                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
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
                              color: item.checked ? Colors.lightBlue : Colors.grey,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              decoration: item.checked ? TextDecoration.lineThrough : null,
                              color: item.checked ? Colors.grey : null,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() => list.items.remove(item)),
                          ),
                        ),
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
// HISTORY (MVP: Vergangene Listen ansehen / bearbeiten / löschen)
// ==========================================
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final history = AppState.lists.where((l) => l.isCompleted).toList();
    history.sort((a, b) => (b.completedAt ?? DateTime.now()).compareTo(a.completedAt ?? DateTime.now()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verlauf', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: history.isEmpty
          ? const Center(child: Text('Kein Verlauf vorhanden'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final list = history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.history, color: Colors.green, size: 32),
                    title: Text(list.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text(list.completedAt != null ? formatDate(list.completedAt!) : 'Unbekannt'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          AppState.lists.remove(list);
                        });
                      },
                    ),
                    onTap: () async {
                      // Durch das Öffnen im ListDetailScreen kann die Liste bearbeitet werden
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => ListDetailScreen(listId: list.id)));
                      setState((){});
                    },
                  ),
                );
              },
            ),
    );
  }
}

// ==========================================
// ANALYTICS (MVP: Anzahl Artikel, Listen, Kategorien-Balken)
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
    for (var cat in AppState.allCategories) {
      counts[cat] = 0;
    }
    for (var list in AppState.lists) {
      for (var item in list.items) {
        if(item.checked) {
          counts[item.category] = (counts[item.category] ?? 0) + 1;
        }
      }
    }
    var sortedCategories = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    var topCategories = sortedCategories; // Alle anzeigen
    int maxCount = topCategories.isNotEmpty ? topCategories.first.value : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.shopping_cart, size: 40, color: Colors.blue),
                        const SizedBox(height: 16),
                        Text('$totalItemsBought', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        const Text('Artikel gekauft'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle, size: 40, color: Colors.green),
                        const SizedBox(height: 16),
                        Text('$totalListsCompleted', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        const Text('Listen erledigt'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alle Kategorien', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 32),
                  if (topCategories.isEmpty)
                    const Text('Noch keine Daten vorhanden.')
                  else
                    // Simples Säulendiagramm komplett aus Flutter Standard-Widgets
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
                              Text('${entry.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Container(
                                width: 40,
                                height: 130 * heightFactor,
                                decoration: BoxDecoration(
                                  color: AppState.getCategoryColor(entry.key),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  entry.key, 
                                  style: const TextStyle(fontSize: 10), 
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
// SETTINGS (MVP: Nur Darkmode)
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
        title: const Text('Einstellungen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              secondary: const Icon(Icons.dark_mode),
              value: AppState.darkMode,
              onChanged: (val) {
                setState(() => AppState.darkMode = val);
                EinkaufsApp.of(context)?.rebuildAll();
              },
            ),
          ),
        ],
      ),
    );
  }
}