import 'dart:developer';

import 'package:auth/auth.dart';
import 'package:common/common.dart';
import 'package:design_system/design_system.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:student/student.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:teacher/teacher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EquatableConfig.stringify = true;

  await Supabase.initialize(
    url: 'https://azwzokekmicmhdnafhfh.supabase.co',
    anonKey: 'sb_publishable_l9YiN7ot9wNIWoVmTCAY0g_DRsJkvox',
  );

  final allModules = [
    CommonModule(),
    AuthModule(),
    StudentModule(),
    TeacherModule(),
    DesignSystemModule(),
  ];

  for (var module in allModules) {
    await module.init();
  }

  final allRoutes = allModules
      .whereType<RoutedModule>()
      .map((module) => module.routes)
      .fold(
        <String, WidgetBuilder>{},
        (previousValue, element) => {...previousValue, ...element},
      );

  runApp(MyApp(routes: allRoutes));
}

class MyApp extends StatelessWidget {
  final Map<String, WidgetBuilder> routes;

  const MyApp({super.key, this.routes = const {}});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: kDesignSystemTheme,
      routes: routes,
      home: const LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
