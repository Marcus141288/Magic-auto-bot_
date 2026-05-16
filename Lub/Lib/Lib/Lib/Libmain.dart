import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MagicAutoBotApp());
}

class MagicAutoBotApp extends StatelessWidget {
  const MagicAutoBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic Auto Bot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFFFF3333),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String apiUrl = "http://192.168.1.100:8000";
  Map<String, dynamic> status = {};

  @override
  void initState() {
    super.initState();
    fetchStatus();
  }

  Future<void> fetchStatus() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/status'));
      if (response.statusCode == 200) {
        setState(() {
          status = json.decode(response.body);
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> sendCommand(String command) async {
    try {
      await http.post(
        Uri.parse('$apiUrl/command'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'command': command}),
      );
      fetchStatus();
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset('assets/bot.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'MAGIC AUTO BOT',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D11),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionBtn(Icons.refresh, 'QUOTES', () => sendCommand('quotes')),
                    _buildActionBtn(Icons.play_arrow, 'TRADE', () => sendCommand('trade')),
                    _buildActionBtn(Icons.delete_outline, 'REMOVE', () => sendCommand('remove')),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildStatsCard(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF3333),
        onPressed: () => sendCommand('chat'),
        child: const Icon(Icons.smart_toy),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFF3333), size: 28),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D11),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('SYMBOLS', status['symbols']?.toString() ?? '0'),
          _buildStat('STATUS', status['status'] ?? 'OFFLINE', 
            color: status['status'] == 'ONLINE' ? Colors.green : Colors.red),
          _buildStat('SIGNALS', status['signals']?.toString() ?? '0'),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(
          color: color ?? Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        )),
      ],
    );
  }
}
