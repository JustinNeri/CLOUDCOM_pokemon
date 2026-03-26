import 'package:flutter/material.dart';
import 'add_monster.dart';
import 'catch_monster.dart';
import 'instance_toggle.dart';
import 'instance_screen.dart';
import 'edit_monster.dart';
import 'delete_monster.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monster Control Center',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F6F4F)),
        scaffoldBackgroundColor: const Color(0xFFEFF5EC),
        useMaterial3: false,
      ),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  bool instanceOn = true;

  @override
  Widget build(BuildContext context) {
    const baseGreen = Color(0xFF3F6F4F);
    const accentGreen = Color(0xFF6AA972);
    const lightGreen = Color(0xFFDDECDC);
    const cardGreen = Color(0xFFF7FAF6);
    const borderGreen = Color(0xFFCADBC5);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: baseGreen,
        elevation: 0,
        title: const Text('Monster Control Center',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _AppDrawer(baseGreen: baseGreen),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5FAF4), Color(0xFFE8F1E6)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3F6F4F), Color(0xFF6AA972)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.14),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -30,
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 54,
                                width: 54,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white.withOpacity(0.8)),
                                ),
                                child: const Icon(Icons.shield_moon_outlined,
                                    color: baseGreen, size: 30),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Monster Control Center',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Operate, monitor, and secure your creatures',
                                    style: TextStyle(
                                      color: Color(0xFFEAF5EA),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: const [
                              _Pill(text: 'Control Center', icon: Icons.dashboard_customize),
                              _Pill(text: '6 actions', icon: Icons.grid_view),
                              _Pill(text: 'Live telemetry', icon: Icons.insights_outlined),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => InstanceScreen(initialStatus: instanceOn),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        instanceOn = result;
                      });
                    }
                  },
                  child: _InstancePreviewCard(
                    instanceOn: instanceOn,
                    baseGreen: baseGreen,
                    accentGreen: accentGreen,
                    borderGreen: borderGreen,
                  ),
                ),
                const SizedBox(height: 18),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _MenuCard(
                      title: 'Add Monsters',
                      subtitle: 'Create new entries',
                      icon: Icons.add_circle_outline,
                      color: baseGreen,
                      accent: accentGreen,
                      background: cardGreen,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddMonsterScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuCard(
                      title: 'Catch Monsters',
                      subtitle: 'Find nearby spawns',
                      icon: Icons.catching_pokemon,
                      color: baseGreen,
                      accent: accentGreen,
                      background: cardGreen,
                      highlight: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CatchMonsterScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuCard(
                      title: 'Edit Monsters',
                      subtitle: 'Update details',
                      icon: Icons.edit_outlined,
                      color: baseGreen,
                      accent: accentGreen,
                      background: cardGreen,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EditMonsterScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuCard(
                      title: 'Delete Monsters',
                      subtitle: 'Clean old data',
                      icon: Icons.delete_outline,
                      color: baseGreen,
                      accent: accentGreen,
                      background: cardGreen,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DeleteMonsterScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuCard(
                      title: 'View Top Monster Hunters',
                      subtitle: 'Leaderboard',
                      icon: Icons.emoji_events_outlined,
                      color: baseGreen,
                      accent: accentGreen,
                      background: cardGreen,
                      onTap: () => _comingSoon(context),
                    ),
                    _MenuCard(
                      title: 'Show Monster Map',
                      subtitle: 'See hotspots',
                      icon: Icons.map_outlined,
                      color: baseGreen,
                      accent: accentGreen,
                      background: cardGreen,
                      onTap: () => _comingSoon(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.accent,
    required this.background,
    required this.onTap,
    this.highlight = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color accent;
  final Color background;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: background,
          border: Border.all(color: Colors.black.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withOpacity(0.15),
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  if (highlight)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Focus',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.65),
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstancePreviewCard extends StatelessWidget {
  const _InstancePreviewCard({
    required this.instanceOn,
    required this.baseGreen,
    required this.accentGreen,
    required this.borderGreen,
  });

  final bool instanceOn;
  final Color baseGreen;
  final Color accentGreen;
  final Color borderGreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: instanceOn ? Colors.white : const Color(0xFFFFF3F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGreen.withOpacity(0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (instanceOn ? accentGreen : Colors.redAccent).withOpacity(0.12),
            ),
            child: Icon(
              instanceOn ? Icons.power : Icons.power_off,
              color: instanceOn ? baseGreen : Colors.redAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Instance status',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (instanceOn ? accentGreen : Colors.redAccent).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          instanceOn ? 'Online' : 'Offline',
                          key: ValueKey(instanceOn),
                          style: TextStyle(
                            color: instanceOn ? baseGreen : Colors.redAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  instanceOn
                      ? 'All systems nominal. Catch flows and monitoring are active.'
                      : 'Paused for maintenance. Reactivate to resume catch and detect.',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black45),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF3F6F4F)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3F6F4F),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.baseGreen});

  final Color baseGreen;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: baseGreen),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black87),
            ),
            accountName: const Text('Monster Admin'),
            accountEmail: const Text('monster@app.local'),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ExpansionTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Manage Monsters'),
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add Monster'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddMonsterScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Monsters'),
                onTap: () => _showComingSoon(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete Monsters'),
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events_outlined),
            title: const Text('View Top Monster Hunters'),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: const Icon(Icons.catching_pokemon),
            title: const Text('Catch Monsters'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CatchMonsterScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('Show Monster Map'),
            onTap: () => _showComingSoon(context),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }
}
