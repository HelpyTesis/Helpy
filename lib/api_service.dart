import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> sendMessage(String message) async {
  final url = Uri.parse('http://146.148.78.31:5000/chat');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'message': message}),
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['response'];
  } else {
    throw Exception('Error al enviar mensaje');
  }
}
