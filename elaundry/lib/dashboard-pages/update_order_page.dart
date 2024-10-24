import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/custom_http_client.dart';
import 'dart:convert';
import 'edit_order_page.dart';

class UpdateOrderPage extends StatefulWidget {
  @override
  _UpdateOrderPageState createState() => _UpdateOrderPageState();
}

class _UpdateOrderPageState extends State<UpdateOrderPage> {
  final CustomHttpClient _httpClient = CustomHttpClient();
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _orderDetails;
  bool _isLoading = false;

  Future<void> _searchOrder() async {
    setState(() {
      _isLoading = true;
      _orderDetails = null;
    });

    try {
      final response = await _httpClient.post('/admin/get-order', {
        'orderId': _searchController.text,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _orderDetails = data['order'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching order: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Order'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter Order ID',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchOrder,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_orderDetails != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ID: ${_orderDetails!['orderId']}',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          _buildInfoRow('Customer', '${_orderDetails!['name']}'),
                          _buildInfoRow('Phone', '${_orderDetails!['phoneNumber']}'),
                          _buildInfoRow('Collection Date', _formatDate(_orderDetails!['collectionDate'])),
                          _buildInfoRow('Delivery Date', _formatDate(_orderDetails!['deliveryDate'])),
                          _buildInfoRow('Amount', '\$${_orderDetails!['amount'].toStringAsFixed(2)}'),
                          _buildInfoRow('Weight', '${_orderDetails!['weight']} kg'),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Payment Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Chip(
                                label: Text(
                                  _orderDetails!['paymentStatus'] ? 'Paid' : 'Unpaid',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: _orderDetails!['paymentStatus'] ? Colors.green : Colors.red,
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            child: Text('Update Order'),
                            onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOrderPage(orderDetails: _orderDetails!),
      ),
    );
    if (result == true) {
      // If the order was updated successfully, refresh the order details
      _searchOrder();
    }
  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
