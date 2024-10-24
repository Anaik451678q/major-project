import 'dart:convert';
import 'package:elaundry/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/custom_http_client.dart'; // Your custom HTTP client
import 'package:intl/intl.dart'; // For date formatting

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _userName;
  String? _phoneNumber;
  String? _userId;
  bool _isLoading = true;
  bool _isAdmin = false;
  final CustomHttpClient httpClient = CustomHttpClient();
  List<dynamic> _userOrders = [];
  bool _isLoadingOrders = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final response = await httpClient.get('/user/get-user');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _userName = data['user']['name'];
          _phoneNumber = data['user']['phoneNumber'];
          _isAdmin = data['user']['isAdmin'];
          _userId = data['user']['_id'];
          _isLoading = false;
        });

        if (!_isAdmin) _fetchUserOrders();
      } else if (data['authStatus'] == false) {
        logout(context);
      } else {
        _showSnackbar(data['authStatus']);
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  Future<void> _fetchUserOrders() async {
    setState(() {
      _isLoadingOrders = true;
    });
    try {
      final response = await httpClient.get('/user/all-orders');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _userOrders = data['orders'];
        });
      } else {
        _showSnackbar('Failed to load orders');
      }
    } catch (e) {
      _showSnackbar('Error loading orders');
    } finally {
      setState(() {
        _isLoadingOrders = false;
      });
    }
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Laundry'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserInfoCard(),
                    const SizedBox(height: 20),
                    _isAdmin
                        ? _buildAdminButton()
                        : _buildOrderList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $_userName!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.blue),
                const SizedBox(width: 8),
                Text('$_phoneNumber', style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.account_circle, color: Colors.blue),
                const SizedBox(width: 8),
                Text('User ID: $_userId', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/admin-dashboard');
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.blueAccent,
        ),
        child: const Text('Go to Admin Dashboard'),
      ),
    );
  }

  Widget _buildOrderList() {
    return _isLoadingOrders
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _userOrders.length,
            itemBuilder: (context, index) {
              final order = _userOrders[index];
              return OrderCard(order: order);
            },
          );
  }
}

class OrderCard extends StatelessWidget {
  final dynamic order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${order['orderId']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildRichText('Total:', '₹${order['amount']}'),
            const SizedBox(height: 4),
            _buildRichText(
              'Collection Date:',
              DateFormat('dd-MM-yyyy').format(
                DateTime.parse(order['collectionDate']),
              ),
            ),
            const SizedBox(height: 4),
            _buildRichText(
              'Delivery Date:',
              DateFormat('dd-MM-yyyy').format(
                DateTime.parse(order['deliveryDate']),
              ),
            ),
            const SizedBox(height: 8),
            _buildPaymentStatus(order['paymentStatus']),
          ],
        ),
      ),
    );
  }

  Widget _buildRichText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black),
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatus(bool status) {
    return Row(
      children: [
        const Text('Payment Status: ', style: TextStyle(fontSize: 16)),
        Chip(
          label: Text(
            status ? 'Paid' : 'Pending',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: status ? Colors.green : Colors.red,
        ),
      ],
    );
  }
}
