import 'package:flutter/material.dart';

class InstanceToggleCard extends StatelessWidget {
  const InstanceToggleCard({
    super.key,
    required this.instanceOn,
    required this.baseGreen,
    required this.accentGreen,
    required this.borderGreen,
    required this.onChanged,
  });

  final bool instanceOn;
  final Color baseGreen;
  final Color accentGreen;
  final Color borderGreen;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
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
          Switch.adaptive(
            value: instanceOn,
            activeColor: Colors.white,
            activeTrackColor: baseGreen,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
