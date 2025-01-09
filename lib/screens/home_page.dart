import 'package:flutter/material.dart';
import 'detail_page.dart';
import "package:http/http.dart" as http;
import 'dart:convert';

class User {
  final String name;
  final String gender;
  final String city;
  final String email;
  final String phone;
  final String imageUrl;

  User({
    required this.name,
    required this.gender,
    required this.city,
    required this.email,
    required this.phone,
    required this.imageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // ignore: prefer_interpolation_to_compose_strings
    final name = json['name']['first'] + ' ' + json['name']['last'];
    return User(
      name: name,
      gender: json['gender'],
      city: json['location']['city'],
      email: json['email'],
      phone: json['phone'],
      imageUrl: json['picture']['large'],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  bool _hasError = false;

  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse('https://randomuser.me/api/?results=200'));

    if (response.statusCode == 200) {
      setState(() {
        var data = json.decode(response.body);
        _users = (data['results'] as List).map((userJson) {
          return User.fromJson(userJson);
        }).toList();
        _filteredUsers = _users;
        _isLoading = false;
        _hasError = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _users.where((user) {
        return user.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by Name',
                hintText: 'Enter name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterUsers,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(child: Text('Failed to load data. Please try again.'))
          : _filteredUsers.isEmpty
          ? Center(child: Text('No users found'))
          : ListView.builder(
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage:
              NetworkImage(_filteredUsers[index].imageUrl),
            ),
            title: Text(_filteredUsers[index].name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetailPage(user: _filteredUsers[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
