import 'package:flutter/material.dart';
import 'package:egg_incubator_app/controllers/arduino_controller.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';

/// Connection panel shared by the incubation screen and hardware console.
class ArduinoConnectionCard extends StatefulWidget {
  const ArduinoConnectionCard({super.key, required this.controller});

  final ArduinoController controller;

  @override
  State<ArduinoConnectionCard> createState() => _ArduinoConnectionCardState();
}

class _ArduinoConnectionCardState extends State<ArduinoConnectionCard> {
  ArduinoController get _arduino => widget.controller;
  String? _selectedPort;

  @override
  void initState() {
    super.initState();
    _arduino.addListener(_onChanged);
    _arduino.refreshPorts();
  }

  @override
  void dispose() {
    _arduino.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _connect() async {
    final port =
        _selectedPort ??
        (_arduino.ports.isNotEmpty ? _arduino.ports.first : null);
    if (port == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No serial port selected.')));
      return;
    }
    try {
      await _arduino.connect(port);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not connect: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final connected = _arduino.isConnected;
    final connecting = _arduino.isConnecting;
    final ports = _arduino.ports;
    if (_selectedPort == null && ports.isNotEmpty) {
      _selectedPort = ports.first;
    }
    final statusColor = connected
        ? const Color(0xFF4CAF50)
        : (connecting ? const Color(0xFFFF9800) : Colors.grey.shade500);
    final statusText = connected
        ? 'Port open${_arduino.portName != null ? ' • ${_arduino.portName}' : ''}'
        : (connecting ? 'Connecting…' : 'Port closed');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.usb, color: statusColor, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'App serial transport',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!connected) ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: ports.contains(_selectedPort)
                            ? _selectedPort
                            : null,
                        hint: const Text('Select serial port'),
                        items: ports
                            .map(
                              (p) => DropdownMenuItem(value: p, child: Text(p)),
                            )
                            .toList(),
                        onChanged: connecting
                            ? null
                            : (v) => setState(() => _selectedPort = v),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Refresh ports',
                  onPressed: connecting ? null : () => _arduino.refreshPorts(),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (ports.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'No serial ports found. Plug in the Arduino over USB.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton.icon(
                onPressed: connecting ? null : _connect,
                icon: connecting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.link),
                label: Text(connecting ? 'Connecting…' : 'Connect'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => _arduino.disconnect(),
                icon: const Icon(Icons.link_off),
                label: const Text('Disconnect'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDarkPressed,
                  side: const BorderSide(color: Color(0xFFE8752A)),
                ),
              ),
            ),
          ],
          if (_arduino.lastError != null) ...[
            const SizedBox(height: 10),
            Text(
              _arduino.lastError!,
              style: const TextStyle(fontSize: 12, color: Color(0xFFD32F2F)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Placeholder shown where a live-reading widget would appear while offline.
class ArduinoPlaceholderCard extends StatelessWidget {
  const ArduinoPlaceholderCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.grey.shade500),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
