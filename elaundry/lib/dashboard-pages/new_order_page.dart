import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/custom_http_client.dart';

class NewOrderPage extends StatefulWidget {
  @override
  _NewOrderPageState createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final CustomHttpClient _httpClient = CustomHttpClient();

  DateTime? _collectionDate;
  DateTime? _deliveryDate;
  TextEditingController _amountController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();

  TimeOfDay? _collectionTime;
  TimeOfDay? _deliveryTime;

  Future<void> _selectDate(BuildContext context, bool isCollectionDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isCollectionDate) {
          _collectionDate = picked;
        } else {
          _deliveryDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isCollectionTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isCollectionTime) {
          _collectionTime = picked;
        } else {
          _deliveryTime = picked;
        }
      });
    }
  }

  Future<void> _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      if (_collectionDate == null || _collectionTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select collection date and time')),
        );
        return;
      }
      if (_deliveryDate == null || _deliveryTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select delivery date and time')),
        );
        return;
      }

      try {
        final adjustedCollectionDate = _collectionDate?.add(Duration(days: 1));
        final adjustedDeliveryDate = _deliveryDate?.add(Duration(days: 1));

        final response = await _httpClient.post('/admin/new-order', {
          'collectionDate': adjustedCollectionDate?.toIso8601String(),
          'collectionTime': _collectionTime?.format(context),
          'deliveryDate': adjustedDeliveryDate?.toIso8601String(),
          'deliveryTime': _deliveryTime?.format(context),
          'amount': double.parse(_amountController.text),
          'weight': double.parse(_weightController.text),
          'phoneNumber': _phoneNumberController.text,
        });

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order created successfully')),
          );
          Navigator.pop(context); // Go back to previous screen
        } else {
          throw Exception('Failed to create order: ${response.body}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating order: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Order'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 10,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => _selectDate(context, true),
                          child: Text(_collectionDate == null
                              ? 'Select Collection Date'
                              : 'Collection Date: ${DateFormat('yyyy-MM-dd').format(_collectionDate!)}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton(
                          onPressed: () => _selectTime(context, true),
                          child: Text(_collectionTime == null
                              ? 'Select Collection Time'
                              : 'Collection Time: ${_collectionTime!.format(context)}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => _selectDate(context, false),
                          child: Text(_deliveryDate == null
                              ? 'Select Delivery Date'
                              : 'Delivery Date: ${DateFormat('yyyy-MM-dd').format(_deliveryDate!)}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton(
                          onPressed: () => _selectTime(context, false),
                          child: Text(_deliveryTime == null
                              ? 'Select Delivery Time'
                              : 'Delivery Time: ${_deliveryTime!.format(context)}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      labelStyle: TextStyle(color: Colors.blue),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a weight';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      labelStyle: TextStyle(color: Colors.blue),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitOrder,
                    child: const Text('Create Order', style: TextStyle(color: Colors.white, fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
