import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/item_page.dart';
import 'package:ceg4912_project/Support/session.dart';
import 'package:ceg4912_project/Support/utility.dart';
import 'package:ceg4912_project/merchant_receipt_history.dart';
import 'package:ceg4912_project/merchant_receipt_page.dart';
import 'package:flutter/material.dart';
import 'Models/user.dart';

class MerchantHomePage extends StatefulWidget {
  const MerchantHomePage({Key? key}) : super(key: key);

  @override
  State<MerchantHomePage> createState() => _MerchantHomePageState();
}

class _MerchantHomePageState extends State<MerchantHomePage> {
  User user = Session.getSessionUser();

  // loads the item page
  void loadItemPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ItemPage(),
      ),
    );
  }

  void loadReceiptPage() async {
    int mId = Session.getSessionUser().getId();

    var conn;
    var mItems;
    try {
      conn = await Queries.getConnection();
      mItems = await Queries.getMerchantItems(conn, mId);
    } catch (e) {
      Utility.displayAlertMessage(context, "Failed to Retrieve Data",
          "Please check your network connection.");
    }

    // exit if something went wrong
    if (mItems == null) {
      return;
    }

    // send the merchant's business items to the receipt page
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MerchantReceiptPage(),
        settings: RouteSettings(
          arguments: {"merchantItems": mItems},
        ),
      ),
    );

    // clear the static receipt item list upon returning from the receipt page
    MerchantReceiptPage.receiptItems.clear();
  }

  void loadReceiptHistoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MerchantReceiptHistoryPage(),
      ),
    );
  }

  void loadSettings() {
    // Does nothing right now. WIP.
    // The pop is needed since this function's button is inside another BuildContext. This closes the PopupMenu.
    Navigator.pop(context);
  }

  // clears the session user and returns to the sign in page
  void signOut() {
    Session.clearSessionUser();
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Merchant Home Page"),
        backgroundColor: Utility.getBackGroundColor(),
        actions: <Widget>[
          PopupMenuButton(
            offset: Offset.zero,
            color: Utility.getBackGroundColor(),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: InkWell(
                    splashColor: Colors.grey,
                    child: IconButton(
                      icon: const Icon(Icons.settings),
                      color: Colors.white,
                      onPressed: loadSettings,
                    ),
                  ),
                ),
                PopupMenuItem(
                  child: InkWell(
                    splashColor: Colors.grey, // splash color
                    child: IconButton(
                      icon: const Icon(Icons.logout_rounded),
                      color: Colors.red,
                      onPressed: signOut,
                    ),
                  ),
                ),
              ];
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.blue,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                Session.getSessionUser().getEmail(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 4.5,
                  color: Utility.getBackGroundColor(),
                  child: TextButton(
                    onPressed: loadItemPage,
                    child: const Text(
                      "Business Items",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 4.5,
                  color: Utility.getBackGroundColor(),
                  child: TextButton(
                    onPressed: loadReceiptPage,
                    child: const Text(
                      "Create Receipt",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 4.5,
                  color: Utility.getBackGroundColor(),
                  child: TextButton(
                    onPressed: loadReceiptHistoryPage,
                    child: const Text(
                      "Receipt History",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
