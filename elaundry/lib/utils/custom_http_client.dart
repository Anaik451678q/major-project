import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CustomHttpClient {
  final String baseUrl = 'https://elaundry-project.vercel.app/api';
  // final String baseUrl = 'http://192.168.195.222:5000/api';
  final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken'); // Retrieve the saved token

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token', // Include the token if available
    };
  }

  CustomHttpClient();

  Future<void> registerUser(String name, String phoneNumber, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {
          ...headers,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );

      // Check the response status code
      if (response.statusCode == 201) {
        // User registered successfully
        print('User registered successfully: ${response.body}');
      } else {
        // Handle error
        print('Failed to register user: ${response.statusCode} ${response.body}');
        throw Exception('Failed to register user');
      }
    } catch (error) {
      print('Error occurred: $error');
      throw error; // Propagate the error
    }
  }

  Future<Map<String, dynamic>> loginUser(String phone, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Return the response data
      } else {
        throw Exception('Failed to login');
      }
    } catch (error) {
      print('Error occurred: $error');
      throw error;
    }
  }

Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(); // Get headers with token
    return await http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(); // Get headers with token
    return await http.post(url, headers: headers, body: jsonEncode(body));
  }

}
