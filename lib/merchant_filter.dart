import 'package:ceg4912_project/merchant_receipt_history.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Support/queries.dart';
import 'Support/session.dart';
import 'Support/utility.dart';

class MerchantFilter extends StatefulWidget {
  const MerchantFilter({Key? key}) : super(key: key);

  @override
  State<MerchantFilter> createState() => _MerchantFilterPageState();
}

class _MerchantFilterPageState extends State<MerchantFilter> {
  // This holds a list of fiction users
  // You can use data fetched from a database or a server as well
  final List<String> _allUsers = [];

  // the color of event messages that are displayed to the user
  Color eventMessageColor = Colors.white;
  // the message that is displayed to the user to inform them of events
  String eventMessage = "";

  // This list holds the data for the list view
  List<String> _foundUsers = [];

  // Contains selected emails
  List<String> _selectedEmails = [];

  List<int> _selectedCid = [];

  @override
  initState() {
    // at the beginning, all users are shown
    _getCustomerList();
    _foundUsers = _allUsers;
    super.initState();
  }

  // triggered when a checkbox is selected/unselected
  void _selected(String option, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedEmails.add(option);
      } else {
        _selectedEmails.remove(option);
      }
    });
  }

   dynamic getCustomerId(List<String> emails) async {
    List<int> cidlist = [];
    var cid;
    for (String email in emails) {
      try {
        var conn = await Queries.getConnection();
        cid = await Queries.getCustomerIdByEmail(conn, email);

        if (cid == null) {
          Utility.displayAlertMessage(context, "Item Retrieval Failed", "");
          return;
        }
        cidlist.add(cid);
      } catch (e) {
        print(e);
        if (mounted) {
          Utility.displayAlertMessage(
              context, "Connection Error", "Please check your network connection.");
          return;
        }
      }
    } return cidlist;
  }

  //passes the list of customer emails to the merchant receipt history page
  Future<void> _passCustomerIds() async {
    // Contains all selected cid
    List<int> localCid = await getCustomerId(_selectedEmails);

    Navigator.pop(
      context,
      localCid
      );
  }

  void _getCustomerList() async {
    int mId = Session.getSessionUser().getId();

    var conn = await Queries.getConnection();
    var mCustomers = await Queries.getCustomerEmails(conn, mId);
    // if the query went wrong then it would return null
    if (mCustomers == null) {
      setState(() {
        eventMessage = "Receipt Retrieval Failed.";
        eventMessageColor = Colors.red;
      });

      // clears the event message after 2 seconds have passed
      clearEventMessage(2000);
      return;
    }
    for (int i = 0; i < mCustomers.length; i++) {
      _allUsers.add(mCustomers[i]);
    }
  }

  // clears the event message after some time has passed
  void clearEventMessage(int delay) {
    Future.delayed(Duration(milliseconds: delay), () {
      setState(() {
        eventMessage = "";
        eventMessageColor = Colors.white;
      });
    });
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

  //Widget for list item
  Widget listItem(int i) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        color: const Color.fromARGB(255, 46, 73, 107),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    "Customer Email: " + _foundUsers[i],
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 20,
                    ),
                  ),
                ),
                Checkbox(
                    value: _selectedEmails.contains(_foundUsers[i]),
                    onChanged: (isChecked) => _selected(_foundUsers[i], isChecked!),
                )
              ],
            ),
          ],
        ),
      ),
    );
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
                      itemBuilder: (context, index) => listItem(index)
                    )
                  : const Text(
                      'No results found',
                      style: TextStyle(fontSize: 24),
                    ),
            ),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: _passCustomerIds,
            ),
          ],
        ),
      ),
    );
  }
}
