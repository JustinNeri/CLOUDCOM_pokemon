import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'instance_toggle.dart';

class InstanceScreen extends StatefulWidget {
  const InstanceScreen({super.key, required this.initialStatus});

  final bool initialStatus;

  @override
  State<InstanceScreen> createState() => _InstanceScreenState();
}

class _InstanceScreenState extends State<InstanceScreen> {
  late bool instanceOn;
  bool isLoading = false;
  String? error;
  bool initialFetchDone = false;

  static const _endpoint =
      'https://xfnttovxp5.execute-api.eu-west-3.amazonaws.com/default/STOP_AND_START';

  @override
  void initState() {
    super.initState();
    instanceOn = widget.initialStatus;
    _refreshStatus();
  }

  @override
  Widget build(BuildContext context) {
    const baseGreen = Color(0xFF3F6F4F);
    const accentGreen = Color(0xFF6AA972);
    const borderGreen = Color(0xFFCADBC5);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: baseGreen,
        elevation: 0,
        title: const Text('Instance Control', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5FAF4), Color(0xFFE8F1E6)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Toggle the instance to enable or pause catching and detection flows.',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 16),
                if (!initialFetchDone && isLoading)
                  Row(
                    children: const [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Loading instance status...'),
                    ],
                  ),
                if (initialFetchDone)
                InstanceToggleCard(
                  instanceOn: instanceOn,
                  baseGreen: baseGreen,
                  accentGreen: accentGreen,
                  borderGreen: borderGreen,
                  onChanged: (val) => _updateInstance(val, baseGreen),
                ),
                if (isLoading && initialFetchDone)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Updating instance...'),
                      ],
                    ),
                  ),
                if (error != null && !isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: baseGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.of(context).pop(instanceOn),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Save status'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshStatus() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final resp = await _callApi('status');
      final body = resp.body.toLowerCase();
      final running = body.contains('running') || body.contains('online') || body.contains('started');
      final stopping = body.contains('stopping') || body.contains('shutting');
      final stopped = body.contains('stopped') || body.contains('offline');
      final newState = running || stopping ? true : stopped ? false : instanceOn;
      setState(() {
        instanceOn = newState;
        initialFetchDone = true;
      });
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        initialFetchDone = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateInstance(bool targetState, Color baseGreen) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
      error = null;
    });

    final action = targetState ? 'start' : 'stop';
    try {
      final resp = await _callApi(action);

      setState(() {
        instanceOn = targetState;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Instance ${action == 'start' ? 'started' : 'stopped'}'),
            backgroundColor: baseGreen,
          ),
        );
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<http.Response> _callApi(String action) async {
    final uri = Uri.parse(_endpoint).replace(queryParameters: {'action': action});
    http.Response? lastResponse;

    // Try POST first (include action in both body and query to handle non-proxy integrations)
    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': action}),
      );
      if (resp.statusCode == 200) return resp;
      lastResponse = resp;
    } catch (e) {
      // swallow and attempt GET below
      lastResponse = null;
    }

    // Fallback to GET with query param
    final getResp = await http.get(uri);
    if (getResp.statusCode == 200) return getResp;

    final msg = lastResponse != null
      ? 'POST failed: ${lastResponse.statusCode} ${lastResponse.body} | GET failed: ${getResp.statusCode} ${getResp.body}'
      : 'POST error then GET failed: ${getResp.statusCode} ${getResp.body}';
    throw Exception(msg);
  }
}
