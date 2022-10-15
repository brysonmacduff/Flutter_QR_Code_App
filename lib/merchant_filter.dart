import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MerchantFilter extends StatefulWidget {
  const MerchantFilter({Key? key}) : super(key: key);

  @override
  State<MerchantFilter> createState() => _MerchantFilterPageState();
}

class _MerchantFilterPageState extends State<MerchantFilter> {
  // This holds a list of fiction users
  // You can use data fetched from a database or a server as well
  final List<String> _allUsers = [
  ];

  // This list holds the data for the list view
  List<String> _foundUsers = [];
  @override
  initState() {
    // at the beginning, all users are shown
    _foundUsers = _allUsers;
    super.initState();
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<String> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _allUsers;
    } else {
      results = _allUsers
          .where((_allUsers) =>
          _allUsers.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Email Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            TextField(
              onChanged: (value) => _runFilter(value),
              decoration: const InputDecoration(
                  labelText: 'Search', suffixIcon: Icon(Icons.search)),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: _foundUsers.isNotEmpty
                  ? ListView.builder(
                itemCount: _foundUsers.length,
                itemBuilder: (context, index) => Card(
                  key: ValueKey(_foundUsers[index]),
                  color: Colors.blueAccent,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                ),
              )
                  : const Text(
                'No results found',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}