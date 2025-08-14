import 'dart:convert';
import 'package:http/http.dart' as http;

const String API_KEY = '45516266-bb8ba5d7de5c577f94232c870'; // Replace with your Pixabay API key
const String baseUrl = 'https://pixabay.com/api/';

Future<List<dynamic>> fetchWallpapers(String query) async {
  final url = Uri.parse(
      '$baseUrl?key=$API_KEY&q=${Uri.encodeComponent(query)}&image_type=photo&orientation=vertical&per_page=50');
  print('Requesting: $url');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['hits'];
  } else {
    print('Error: ${response.statusCode}, ${response.body}');
    throw Exception('Failed to load wallpapers. Status code: ${response.statusCode}');
  }
}