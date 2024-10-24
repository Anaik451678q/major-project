import 'package:elaundry/dashboard.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'registration.dart';
import 'home.dart'; 
import 'dashboard-pages/all_users_page.dart';
import 'dashboard-pages/new_order_page.dart';
import 'dashboard-pages/update_order_page.dart';
import 'dashboard-pages/all_orders_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
        '/admin-dashboard': (context) => AdminDashboardPage(),
        '/all-users': (context) => AllUsersPage(),
        '/new-order': (context) => NewOrderPage(),
        '/update-order': (context) => UpdateOrderPage(),
        '/all-orders': (context) => AllOrdersPage(),
      },
    );
  }
}
