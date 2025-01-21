import 'dart:convert';
import 'package:client/core/constants/server_constant.dart';
import 'package:client/features/home/view/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserPreferencesPage extends StatefulWidget {
  final String token; // Add a token field to accept the passed token

  const UserPreferencesPage({super.key, required this.token});

  @override
  UserPreferencesPageState createState() => UserPreferencesPageState();
}

class UserPreferencesPageState extends State<UserPreferencesPage> {
  List<Map<String, String>> genres = [];
  List<String> selectedGenres = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGenres(); // Fetch genres when the page loads
  }

  Future<void> fetchGenres() async {
    final url = '${ServerConstant.serverURL}/song/user/genres/check';

    print('Fetching genres from: $url');
    print('Token: ${widget.token}'); // Use the token passed from the login page

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-auth-token': widget.token, // Pass the token as 'x-auth-token'
        },
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed data: $data');

        if (!data['has_genres']) {
          setState(() {
            genres = (data['available_genres'] as List)
                .map((genre) => {
                      'id': genre['id']
                          .toString(), // Ensure the value is a String
                      'name': genre['name']
                          .toString(), // Ensure the value is a String
                    })
                .toList();
            isLoading = false;
          });
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
            (_) => false,
          );
        }
      } else {
        throw Exception(
            'Failed to fetch genres. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
      showErrorDialog('Error fetching genres: $e');
    }
  }

  Future<void> submitGenres() async {
    final url = '${ServerConstant.serverURL}/song/user/genres/add';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'x-auth-token': widget.token, // Pass the token as 'x-auth-token'
          'Content-Type': 'application/json',
        },
        body: jsonEncode(selectedGenres),
      );

      if (response.statusCode == 201) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
          (_) => false,
        );
      } else {
        final data = jsonDecode(response.body);
        showErrorDialog('Failed to save preferences: ${data['message']}');
      }
    } catch (e) {
      showErrorDialog('Error submitting preferences: $e');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Preferences'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loader while fetching
          : genres.isEmpty
              ? const Center(
                  child: Text('No genres available. Please try again later.'),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: genres.map((genre) {
                              final isSelected =
                                  selectedGenres.contains(genre['name']);
                              return ChoiceChip(
                                label: Text(genre['name'] ?? ''),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedGenres.add(genre['name']!);
                                    } else {
                                      selectedGenres.remove(genre['name']!);
                                    }
                                  });
                                },
                                selectedColor: Colors.blue,
                                backgroundColor: Colors.grey[200],
                                labelStyle: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: selectedGenres.isEmpty
                            ? null
                            : () {
                                submitGenres();
                              },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
