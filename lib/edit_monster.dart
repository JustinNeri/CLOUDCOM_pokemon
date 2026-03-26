import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditMonsterScreen extends StatefulWidget {
  const EditMonsterScreen({super.key});

  @override
  State<EditMonsterScreen> createState() => _EditMonsterScreenState();
}

class _EditMonsterScreenState extends State<EditMonsterScreen> {
  final _playerController = TextEditingController(text: '1');

  bool submitting = false;
  bool loadingList = false;
  String loadError = '';
  List<_Monster> caughtMonsters = [];

  // Elastic IP base for the PHP APIs
  final String apiBase = 'http://15.224.51.87';
  // If your PHP file lives in a subfolder, update this path accordingly.
  String get listEndpoint => '$apiBase/get_caught_monsters_api.php';

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCaughtMonsters();
  }

  Future<void> _loadCaughtMonsters() async {
    final playerId = _playerController.text.trim().isEmpty
        ? '1'
        : _playerController.text.trim();

    setState(() {
      loadingList = true;
      loadError = '';
    });

    final url = Uri.parse('$listEndpoint?player_id=$playerId');

    try {
      final resp = await http.get(url).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final parsed = _parseList(resp.body);
        final serverMsg = _extractServerMessage(resp.body);
        if (parsed.isEmpty && serverMsg != null && serverMsg.isNotEmpty) {
          setState(() => loadError = 'Server message: $serverMsg');
          return;
        }
        setState(() {
          caughtMonsters = parsed;
        });
      } else {
        setState(() => loadError = 'Server error: ${resp.statusCode}\n${_shortBody(resp.body)}');
      }
    } catch (e) {
      setState(() => loadError = 'Request failed: $e');
    } finally {
      if (mounted) {
        setState(() => loadingList = false);
      }
    }
  }

  Future<void> _editMonster(_Monster monster, String newName, String newType) async {
    final id = monster.id;
    if (id.isEmpty) {
      _show('Monster ID missing.');
      return;
    }

    setState(() {
      submitting = true;
    });

    final url = Uri.parse('$apiBase/edit_monster_api.php');
    final body = {
      'monster_id': id,
      if (newName.trim().isNotEmpty) 'name': newName.trim(),
      if (newType.trim().isNotEmpty) 'type': newType.trim(),
    };

    try {
      final resp = await http.post(url, body: body).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        const feedback = 'Edit Succesfully';
        _show(feedback);

        // Update list locally for quick feedback
        setState(() {
          caughtMonsters = caughtMonsters.map((m) {
            if (m.id == monster.id) {
              return m.copyWith(name: newName.trim().isEmpty ? m.name : newName.trim(), type: newType.trim().isEmpty ? m.type : newType.trim());
            }
            return m;
          }).toList();
        });
      } else {
        _show('Server error: ${resp.statusCode}\n${_shortBody(resp.body)}');
      }
    } catch (e) {
      _show('Request failed: $e');
    } finally {
      if (mounted) {
        setState(() => submitting = false);
      }
    }
  }

  void _openEditSheet(_Monster monster) {
    final nameCtrl = TextEditingController(text: monster.name ?? '');
    final typeCtrl = TextEditingController(text: monster.type ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit ${monster.name ?? 'Monster'} (#${monster.id})',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              _Field(label: 'Monster Name', controller: nameCtrl),
              const SizedBox(height: 10),
              _Field(label: 'Monster Type', controller: typeCtrl),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: submitting
                      ? null
                      : () async {
                          Navigator.of(ctx).pop();
                          await _editMonster(monster, nameCtrl.text, typeCtrl.text);
                        },
                  icon: submitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Save Changes'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F6F4F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _show(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    const baseGreen = Color(0xFF3F6F4F);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: baseGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Edit Monsters', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Caught monsters for this player. Tap edit to change name or type.'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Field(
                      label: 'Player ID',
                      controller: _playerController,
                      keyboard: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: loadingList ? null : _loadCaughtMonsters,
                    icon: loadingList
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: baseGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (loadError.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(loadError),
                ),
              if (loadingList)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!loadingList && loadError.isEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Caught Monsters (${caughtMonsters.length})',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    if (caughtMonsters.isEmpty)
                      const Text('No caught monsters yet.'),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: caughtMonsters.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final m = caughtMonsters[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.name ?? 'Monster ${m.id}',
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(m.type ?? 'Unknown type', style: const TextStyle(color: Colors.black87)),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: submitting ? null : () => _openEditSheet(m),
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Edit'),
                                style: TextButton.styleFrom(
                                  foregroundColor: baseGreen,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

String _shortBody(String body) {
  final clean = body.trim();
  if (clean.isEmpty) return '(empty response body)';
  if (clean.length <= 240) return clean;
  return '${clean.substring(0, 240)}...';
}

String? _extractServerMessage(String body) {
  try {
    final data = json.decode(body);
    if (data is Map<String, dynamic>) {
      final err = data['error']?.toString();
      if (err != null && err.trim().isNotEmpty) return err;
      final msg = data['message']?.toString();
      if (msg != null && msg.trim().isNotEmpty) return msg;
    }
  } catch (_) {
    // Ignore parse errors and fallback to generic handling.
  }
  return null;
}

class _Monster {
  _Monster({
    required this.id,
    this.name,
    this.type,
    this.lat,
    this.lon,
    this.radius,
    this.caughtAt,
  });

  final String id;
  final String? name;
  final String? type;
  final String? lat;
  final String? lon;
  final String? radius;
  final String? caughtAt;

  _Monster copyWith({String? name, String? type}) {
    return _Monster(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      lat: lat,
      lon: lon,
      radius: radius,
      caughtAt: caughtAt,
    );
  }

  factory _Monster.fromMap(Map<String, dynamic> map) {
    return _Monster(
      id: map['monster_id']?.toString() ?? '',
      name: map['monster_name']?.toString(),
      type: map['monster_type']?.toString(),
      lat: map['lat']?.toString() ?? map['latitude']?.toString(),
      lon: map['lon']?.toString() ?? map['longitude']?.toString(),
      radius: map['radius']?.toString(),
      caughtAt: map['caught_at']?.toString(),
    );
  }
}

List<_Monster> _parseList(String body) {
  try {
    final data = json.decode(body);
    List list;
    if (data is List) {
      list = data;
    } else if (data is Map && data['data'] is List) {
      list = data['data'];
    } else {
      return [];
    }
    return list
        .whereType<Map>()
        .map((m) => _Monster.fromMap(Map<String, dynamic>.from(m)))
        .where((m) => m.id.isNotEmpty)
        .toList();
  } catch (_) {
    return [];
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.keyboard,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFCBD8C9);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          decoration: InputDecoration(
            hintText: label,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3F6F4F)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
