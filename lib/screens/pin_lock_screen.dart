import 'package:flutter/material.dart';

class PinLockScreen extends StatefulWidget {
  final Future<String?> Function() getPin;
  final VoidCallback onUnlock;
  const PinLockScreen({super.key, required this.getPin, required this.onUnlock});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final _controller = TextEditingController();
  String? _error;
  bool _isChecking = false;

  Future<void> _checkPin() async {
    setState(() {
      _isChecking = true;
      _error = null;
    });
    final savedPin = await widget.getPin();
    if (_controller.text == savedPin) {
      widget.onUnlock();
    } else {
      setState(() {
        _error = 'Code incorrect';
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 48, color: color),
                  const SizedBox(height: 16),
                  const Text('Entrez votre code PIN', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: 'Code PIN',
                      errorText: _error,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _checkPin(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isChecking ? null : _checkPin,
                    child: _isChecking
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Déverrouiller'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 