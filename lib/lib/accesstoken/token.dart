import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<String> getSpotifyAccessToken() async {
  const clientId = '4295237b56614d09b710a17c4b490da5';
  const clientSecret = 'd23b71a06f3c4eba91aa97e87f517ae1';

  final response = await http.post(
    Uri.parse('https://accounts.spotify.com/api/token'),
    headers: {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
      'Content-Type': 'application/x-www-form-urlencoded', // Add Content-Type
    },
    body: {
      'grant_type': 'client_credentials',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['access_token'];
  } else {
    throw Exception('Failed to get access token');
  }
}

void main() async {
  try {
    String accessToken = await getSpotifyAccessToken();
    if (kDebugMode) {
      print('Access Token: $accessToken');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error: $e');
    }
  }
}
