import 'package:flutter/material.dart';
import '../services/aqi_api_service.dart';

class ConnectionTestWidget extends StatefulWidget {
  const ConnectionTestWidget({Key? key}) : super(key: key);

  @override
  State<ConnectionTestWidget> createState() => _ConnectionTestWidgetState();
}

class _ConnectionTestWidgetState extends State<ConnectionTestWidget> {
  bool _isLoading = false;
  bool? _connectionStatus;
  String _statusMessage = '';

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = null;
      _statusMessage = 'Testing connection...';
    });

    try {
      final isConnected = await AQIApiService.testConnection();
      setState(() {
        _connectionStatus = isConnected;
        _statusMessage = isConnected 
            ? '✅ Connected to API server at ${AQIApiService.baseUrl}'
            : '❌ Cannot connect to API server at ${AQIApiService.baseUrl}';
      });
    } catch (e) {
      setState(() {
        _connectionStatus = false;
        _statusMessage = '❌ Connection error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wifi, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'API Connection Test',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testConnection,
                  child: _isLoading 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Test'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'API URL: ${AQIApiService.baseUrl}',
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _connectionStatus == true 
                      ? Colors.green.withOpacity(0.1)
                      : _connectionStatus == false
                          ? Colors.red.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _connectionStatus == true 
                        ? Colors.green
                        : _connectionStatus == false
                            ? Colors.red
                            : Colors.grey,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _connectionStatus == true 
                          ? Icons.check_circle
                          : _connectionStatus == false
                              ? Icons.error
                              : Icons.info,
                      color: _connectionStatus == true 
                          ? Colors.green
                          : _connectionStatus == false
                              ? Colors.red
                              : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          color: _connectionStatus == true 
                              ? Colors.green.shade700
                              : _connectionStatus == false
                                  ? Colors.red.shade700
                                  : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_connectionStatus == false) ...[
              const SizedBox(height: 12),
              const Text(
                '💡 Troubleshooting Steps:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Make sure FastAPI server is running:\n'
                '   cd aqi_prediction_api && python main.py\n\n'
                '2. Check if server is accessible:\n'
                '   Open http://localhost:8000/docs in browser\n\n'
                '3. For real devices, update IP address in code:\n'
                '   Replace 192.168.1.XXX with your computer\'s IP',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
