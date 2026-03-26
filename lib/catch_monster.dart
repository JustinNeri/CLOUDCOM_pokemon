import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class CatchMonsterScreen extends StatefulWidget {
  const CatchMonsterScreen({super.key});

  @override
  State<CatchMonsterScreen> createState() => _CatchMonsterScreenState();
}

class _CatchMonsterScreenState extends State<CatchMonsterScreen> {
  // Replace with your API base (FastAPI/PHPScript over VPN)
  final String apiBase = "http://15.224.51.87";

  String latitude = "";
  String longitude = "";
  String detectMessage = "";
  String catchMessage = "";
  String error = "";
  List<Map<String, dynamic>> nearby = [];
  final Set<int> caughtIds = {};
  bool detecting = false;
  bool catching = false;

  int? detectedMonsterId;
  String? detectedMonsterName;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  Future<void> getLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => error = "Location services are disabled. Enable GPS.");
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      setState(() => error = "Location permission denied.");
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
      error = "";
    });
  }

  Future<void> detectMonster() async {
    if (latitude.isEmpty || longitude.isEmpty) {
      await getLocation();
      if (latitude.isEmpty || longitude.isEmpty) return;
    }

    setState(() {
      detecting = true;
      catchMessage = "";
      detectMessage = "";
      error = "";
      detectedMonsterId = null;
      detectedMonsterName = null;
      nearby = [];
    });

    final url = Uri.parse(
      "$apiBase/detect_monsters_api.php?lat=$latitude&lon=$longitude",
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          setState(() => detectMessage = "No monster found nearby.");
        } else {
          try {
            final data = json.decode(response.body);
            List<Map<String, dynamic>> items = [];
            if (data is List) {
              for (final item in data) {
                if (item is Map) {
                  items.add(Map<String, dynamic>.from(item));
                }
              }
            } else if (data is Map<String, dynamic>) {
              items.add(data);
            }

            // Filter out already-caught monsters client-side
            items = items
                .where((m) {
                  final id = int.tryParse(m["monster_id"].toString());
                  return id == null || !caughtIds.contains(id);
                })
                .toList();

            if (items.isNotEmpty) {
              nearby = items;
              final first = items.first;
              detectedMonsterId = int.tryParse(first["monster_id"].toString());
              detectedMonsterName = first["monster_name"]?.toString();
              final distance = first["distance"]?.toString() ?? "";
              final type = first["monster_type"]?.toString();
              setState(() => detectMessage =
                  "Detected: ${detectedMonsterName ?? "monster"}${type != null ? " (" + type + ")" : ""}${distance.isNotEmpty ? " - " + distance + " m away" : ""}");
            } else {
              setState(() => detectMessage = response.body);
            }
          } catch (_) {
            setState(() => detectMessage = response.body);
          }
        }
      } else {
        setState(() => error = "Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => error = "Request failed: $e");
    } finally {
      setState(() => detecting = false);
    }
  }

  Future<void> catchMonster() async {
    if (detectedMonsterId == null) {
      setState(() => catchMessage = "Detect first, then catch.");
      return;
    }
    if (latitude.isEmpty || longitude.isEmpty) {
      await getLocation();
      if (latitude.isEmpty || longitude.isEmpty) return;
    }

    setState(() {
      catching = true;
      catchMessage = "";
      error = "";
    });

    // Adjust player_id/location_id fields to match your API contract.
    final url = Uri.parse("$apiBase/catch_monster_api.php");
    final body = {
      "player_id": "1",
      "monster_id": detectedMonsterId.toString(),
      "lat": latitude,
      "lon": longitude,
    };

    try {
      final response = await http
          .post(url, body: body)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        setState(() {
          catchMessage =
              response.body.isEmpty ? "Catch recorded." : response.body;

          // Remove the caught monster from the nearby list
          nearby.removeWhere((m) =>
              int.tryParse(m["monster_id"].toString()) == detectedMonsterId);

          if (detectedMonsterId != null) {
            caughtIds.add(detectedMonsterId!);
          }

          // Reset selection to next available, or clear if none
          if (nearby.isNotEmpty) {
            final first = nearby.first;
            detectedMonsterId = int.tryParse(first["monster_id"].toString());
            detectedMonsterName = first["monster_name"]?.toString();
            final distance = first["distance"]?.toString() ?? "";
            final type = first["monster_type"]?.toString();
            detectMessage =
                "Detected: ${detectedMonsterName ?? "monster"}${type != null ? " (" + type + ")" : ""}${distance.isNotEmpty ? " - " + distance + " m away" : ""}";
          } else {
            detectedMonsterId = null;
            detectedMonsterName = null;
            detectMessage = "No monster selected";
          }
        });
      } else {
        setState(() => error = "Catch failed: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => error = "Request failed: $e");
    } finally {
      setState(() => catching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text('Catch Monsters')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                buildField("Your Latitude", latitude),
                buildField("Your Longitude", longitude),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: detecting ? null : detectMonster,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: detecting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Detect Monsters"),
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: catching ? null : catchMonster,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: catching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Catch Monster"),
                ),

                const SizedBox(height: 20),

                if (error.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(error, textAlign: TextAlign.center),
                  ),

                if (detectMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      detectMessage,
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (catchMessage.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      catchMessage,
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (nearby.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Nearby Monsters (${nearby.length})",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: nearby.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final m = nearby[index];
                      final name = m["monster_name"]?.toString() ?? "Monster";
                      final type = m["monster_type"]?.toString();
                      final distance = m["distance"]?.toString();
                      final id = int.tryParse(m["monster_id"].toString());
                      final selected = detectedMonsterId != null && id == detectedMonsterId;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            detectedMonsterId = id;
                            detectedMonsterName = name;
                            catchMessage = "";
                            error = "";
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selected ? Colors.blue[50] : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? Colors.blue : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${type ?? "Unknown"} - ${distance ?? "?"} m",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selected)
                                const Icon(Icons.check_circle, color: Colors.blue),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(value.isEmpty ? "Loading..." : value),
        ),
      ],
    );
  }
}
