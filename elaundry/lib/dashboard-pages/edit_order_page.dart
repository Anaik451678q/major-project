import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/custom_http_client.dart';

class EditOrderPage extends StatefulWidget {
  final Map<String, dynamic> orderDetails;

  EditOrderPage({required this.orderDetails});

  @override
  _EditOrderPageState createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  final CustomHttpClient _httpClient = CustomHttpClient();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _collectionDateController;
  late TextEditingController _deliveryDateController;
  late TextEditingController _amountController;
  late TextEditingController _weightController;
  late bool _paymentStatus;

  @override
  void initState() {
    super.initState();
    _collectionDateController = TextEditingController(text: _formatDate(widget.orderDetails['collectionDate']));
    _deliveryDateController = TextEditingController(text: _formatDate(widget.orderDetails['deliveryDate']));
    _amountController = TextEditingController(text: widget.orderDetails['amount'].toString());
    _weightController = TextEditingController(text: widget.orderDetails['weight'].toString());
    _paymentStatus = widget.orderDetails['paymentStatus'];
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(controller.text),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _updateOrder() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Parse the dates from the text controllers and add one day
        final adjustedCollectionDate = DateTime.parse(_collectionDateController.text).add(Duration(days: 1));
        final adjustedDeliveryDate = DateTime.parse(_deliveryDateController.text).add(Duration(days: 1));

        final response = await _httpClient.post('/admin/update-order', {
          'orderId': widget.orderDetails['orderId'],
          'collectionDate': adjustedCollectionDate.toIso8601String(),
          'deliveryDate': adjustedDeliveryDate.toIso8601String(),
          'amount': double.parse(_amountController.text),
          'weight': double.parse(_weightController.text),
          'paymentStatus': _paymentStatus,
        });

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order updated successfully')),
          );
          Navigator.pop(context, true); // Return true to indicate successful update
        } else {
          throw Exception('Failed to update order');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating order: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Order'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order ID: ${widget.orderDetails['orderId']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextFormField(
                controller: _collectionDateController,
                decoration: InputDecoration(
                  labelText: 'Collection Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _collectionDateController),
                  ),
                ),
                readOnly: true,
                validator: (value) => value!.isEmpty ? 'Please enter collection date' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _deliveryDateController,
                decoration: InputDecoration(
                  labelText: 'Delivery Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _deliveryDateController),
                  ),
                ),
                readOnly: true,
                validator: (value) => value!.isEmpty ? 'Please enter delivery date' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter amount' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter weight' : null,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Payment Status: '),
                  Switch(
                    value: _paymentStatus,
                    onChanged: (bool value) {
                      setState(() {
                        _paymentStatus = value;
                      });
                    },
                  ),
                  Text(_paymentStatus ? 'Paid' : 'Unpaid'),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton(
                child: Text('Update Order'),
                onPressed: _updateOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _collectionDateController.dispose();
    _deliveryDateController.dispose();
    _amountController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
