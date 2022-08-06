import 'package:ceg4912_project/item_page.dart';
import 'package:ceg4912_project/Support/session.dart';
import 'package:ceg4912_project/Support/utility.dart';
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

  void loadReceiptPage() {
    // Does nothing right now. WIP.
    // The pop is needed since this function's button is inside another BuildContext. This closes the PopupMenu.
    Navigator.pop(context);
  }

  void loadReceiptHistoryPage() {
    // Does nothing right now. WIP.
    // The pop is needed since this function's button is inside another BuildContext. This closes the PopupMenu.
    Navigator.pop(context);
  }

  void loadMerchantAccountPage() {
    // Does nothing right now. WIP.
    // The pop is needed since this function's button is inside another BuildContext. This closes the PopupMenu.
    Navigator.pop(context);
  }

  // clears the session user and returns to the sign in page
  void signOut() {
    Session.clearSessionUser();
    // two pops are needed since the signOut button is inside another BuildContext
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
                      icon: const Icon(Icons.account_circle),
                      color: Colors.white,
                      onPressed: loadMerchantAccountPage,
                    ),
                  ),
                ),
                PopupMenuItem(
                  child: InkWell(
                    splashColor: Colors.grey,
                    child: IconButton(
                      icon: const Icon(Icons.shop_2_rounded),
                      color: Colors.white,
                      onPressed: loadItemPage,
                    ),
                  ),
                ),
                PopupMenuItem(
                  child: InkWell(
                    splashColor: Colors.grey,
                    child: IconButton(
                      icon: const Icon(Icons.receipt_rounded),
                      color: Colors.white,
                      onPressed: loadReceiptPage,
                    ),
                  ),
                ),
                PopupMenuItem(
                  child: InkWell(
                    splashColor: Colors.grey,
                    child: IconButton(
                      icon: const Icon(Icons.history_rounded),
                      color: Colors.white,
                      onPressed: loadReceiptHistoryPage,
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
    );
  }
}
