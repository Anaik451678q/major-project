import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2, // Display 2 buttons per row
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildDashboardButton(
              context,
              'All Users',
              Icons.people,
              Colors.blue,
              '/all-users',
            ),
            _buildDashboardButton(
              context,
              'New Order',
              Icons.add_shopping_cart,
              Colors.green,
              '/new-order',
            ),
            _buildDashboardButton(
              context,
              'Update Order',
              Icons.update,
              Colors.orange,
              '/update-order',
            ),
            _buildDashboardButton(
              context,
              'All Orders',
              Icons.list_alt,
              Colors.purple,
              '/all-orders',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
      BuildContext context, String label, IconData icon, Color color, String route) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, route); // Navigate to the respective page
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        padding: EdgeInsets.all(20.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.white),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
