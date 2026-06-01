import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/warehouse_state.dart';
import 'screens/login_screen.dart';
import 'screens/product_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WarehouseApp());
}

class WarehouseApp extends StatelessWidget {
  const WarehouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WarehouseState()..initialize(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Складской учет',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF276EF1),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF6F8FB),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Color(0xFFF6F8FB),
            foregroundColor: Color(0xFF172033),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFE1E6EF)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD4DAE5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD4DAE5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF276EF1), width: 2),
            ),
          ),
          useMaterial3: true,
        ),
        home: const AppRoot(),
      ),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WarehouseState>();

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.currentUser == null) {
      return const LoginScreen();
    }

    return const ProductListScreen();
  }
}
