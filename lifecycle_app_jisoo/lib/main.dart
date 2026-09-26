import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LifecycleScreen(),
    );
  }
}

class LifecycleScreen extends StatefulWidget {
  const LifecycleScreen({super.key});

  @override
  State<LifecycleScreen> createState() => _LifecycleScreenState();
}

class _LifecycleScreenState extends State<LifecycleScreen>
    with WidgetsBindingObserver {
  String appStatus = "App Started";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      appStatus = state.toString();
    });

    print("App Status Changed: $state");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lifecycle App"),
      ),
      body: Center(
        child: Text(
          appStatus,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}