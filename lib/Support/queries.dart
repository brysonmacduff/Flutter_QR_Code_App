import 'package:ceg4912_project/Models/customer.dart';
import 'package:ceg4912_project/Models/item.dart';
import 'package:ceg4912_project/Models/merchant.dart';
import 'package:ceg4912_project/Models/receipt_item.dart';
import 'package:flutter/foundation.dart';
import 'package:mysql1/mysql1.dart';
import 'package:ceg4912_project/Models/user.dart';
import 'package:ceg4912_project/Models/receipt.dart';

// a public class of sql queries
class Queries {
  // returns an sql connection object
  static getConnection() async {
    var settings = ConnectionSettings(
        host: 'us-cdbr-east-05.cleardb.net',
        port: 3306,
        user: 'b4c34f510a627f',
        password: '51fb516c',
        db: 'heroku_3eb2baaa59ea134');

    var conn = await MySqlConnection.connect(settings);
    return conn;
  }

  // returns a user by email and password
  static getUser(MySqlConnection conn, String email, String password) async {
    String query = "select * from user where uEmail = '" +
        email +
        "' and uPassword = '" +
        password +
        "'";

    // result rows are in JSON format
    try {
      var results = await conn.query(query);
      int uId = results.first["uId"];
      String uEmail = results.first["uEmail"];
      String uPassword = results.first["uPassword"];
      String uRole = results.first["uRole"];

      if (uRole == "C") {
        return Customer.credentials(uId, uEmail, uPassword);
      } else {
        return Merchant.credentials(uId, uEmail, uPassword);
      }
    } catch (e) {
      return null;
    }
  }

  // checks if a user account exists for a given email
  static userExists(MySqlConnection conn, String email) async {
    String query = "select * from user where uEmail = '" + email + "'";

    // result rows are in JSON format
    try {
      var results = await conn.query(query);
      return results.isNotEmpty;
    } catch (e) {
      print("error occured while checking if user exists");
      return null;
    }
  }

  // gets the highest user id primary key
  static _getMaxUserId(MySqlConnection conn) async {
    String query = "select max(uId) as maxId from user";
    return await conn.query(query);
  }

  // inserts a new customer to the database
  static insertCustomer(
    MySqlConnection conn,
    String email,
    String password,
  ) async {
    try {
      // check if this user already has an account
      var exists = await userExists(conn, email);
      if (exists) {
        print("account already exists");
        return false;
      }

      var result = await _getMaxUserId(conn);
      int maxId = result.first["maxId"];
      String nextId = (maxId + 1).toString();

      // insert user
      String uQuery = "insert into user values (" +
          nextId +
          ",'" +
          email +
          "','" +
          password +
          "','C')";

      await conn.query(uQuery);

      // insert customer
      String cQuery = "insert into customer values (" +
          nextId +
          ",'" +
          email+
          "','"+
          password+
          "','')";
      await conn.query(cQuery);

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // inserts a new merchant into the database
  static insertMerchant(
      MySqlConnection conn,
      String email,
      String password,
      String firstName,
      String lastName,
      String ssn,
      String businessWebsite,
      String businessName,
      String businessType,
      String businessPhone,
      String psCompletionDelay,
      String billingFrequency,
      String industry,
      String financialInstitution,
      String csEmail,
      String csPhone,
      String streetAddress,
      String postalCode,
      String psDescription,
      DateTime merchantBirthDate) async {
    try {
      // check if this user already has an account
      var exists = await userExists(conn, email);
      if (exists) {
        print("account already exists");
        return false;
      }

      var result = await _getMaxUserId(conn);
      int maxId = result.first["maxId"];
      String nextId = (maxId + 1).toString();

      // insert user
      String uQuery = "insert into user values (" +
          nextId +
          ",'" +
          email +
          "','" +
          password +
          "','M')";

      await conn.query(uQuery);

      // insert merchant
      String mQuery = "insert into merchant values(" +
          nextId +
          ",'" +
          firstName +
          "','" +
          lastName +
          "','" +
          merchantBirthDate.toString() +
          "','" +
          ssn +
          "','" +
          businessPhone +
          "','" +
          streetAddress +
          "','" +
          postalCode +
          "','" +
          industry +
          "','" +
          businessType +
          "','" +
          psDescription +
          "','" +
          psCompletionDelay +
          "','" +
          billingFrequency +
          "','" +
          businessName +
          "','" +
          businessWebsite +
          "','" +
          csPhone +
          "','" +
          csEmail +
          "','" +
          financialInstitution +
          "');";

      await conn.query(mQuery);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // gets the business items that pertain to a merchant identified by mId
  static getMerchantItems(MySqlConnection conn, int mId) async {
    String query = "select * from item where mId = '" + mId.toString() + "'";

    // result rows are in JSON format
    try {
      List<Item> items = <Item>[];
      var results = await conn.query(query);
      var iterator = results.iterator;

      while (iterator.moveNext()) {
        var result = iterator.current;

        int iId = result["iId"];
        int mId = result["mId"];
        String iName = result["iName"];
        String iCode = result["iCode"];
        String iDetails = result["iDetails"].toString();
        String iCategory = result["iCategory"];
        double iPrice = result["iPrice"];
        int iTaxable = result["iTaxable"];

        bool taxable = false;
        // mysql stores booleans as integers but only lets them be 1 or 0.
        if (iTaxable == 1) {
          taxable = true;
        }

        Categories category = Categories.none;

        // this looks redundant now but will be extended as more categories are included
        if (iCategory == "none") {
          category = Categories.none;
        }

        items.add(Item.all(
            iId, mId, iName, iCode, iDetails, category, iPrice, taxable));
      }

      return items;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // gets the business items that pertain to a merchant identified by mId
  static getCustomerScannedReceiptItems(MySqlConnection conn, int receiptId) async {
    // String query = "select * from receiptitem where rid = '" + receiptId.toString() + "'";
    String query = "select * from receiptitem join item on item.iId = receiptitem.iId where rid = '" + receiptId.toString() + "'";
    // result rows are in JSON format
    try {
      List<Item> items = <Item>[];
      var results = await conn.query(query);
      var iterator = results.iterator;

      while (iterator.moveNext()) {
        var result = iterator.current;

        int iId = result["iId"];
        int mId = result["mId"];
        String iName = result["iName"];
        String iCode = result["iCode"];
        String iDetails = result["iDetails"].toString();
        String iCategory = result["iCategory"];
        double iPrice = result["iPrice"];
        int iTaxable = result["iTaxable"];

        bool taxable = false;
        // mysql stores booleans as integers but only lets them be 1 or 0.
        if (iTaxable == 1) {
          taxable = true;
        }

        Categories category = Categories.none;

        // this looks redundant now but will be extended as more categories are included
        if (iCategory == "none") {
          category = Categories.none;
        }

        items.add(Item.all(
            iId, mId, iName, iCode, iDetails, category, iPrice, taxable));
      }

      return items;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // gets the largest primary key id of the item table
  static _getMaxItemId(MySqlConnection conn) async {
    String query = "select max(iId) as maxId from item";
    return await conn.query(query);
  }

  // inserts a new item into the database
  static insertItem(
      MySqlConnection conn,
      int merchantId,
      String name,
      String details,
      String code,
      Categories category,
      String price,
      bool taxable) async {
    try {
      var result = await _getMaxItemId(conn);
      int maxId = result.first["maxId"];
      String nextId = (maxId + 1).toString();

      int nTaxable = 1;
      if (!taxable) {
        nTaxable = 0;
      }

      String query = "insert into item values ('" +
          nextId +
          "','" +
          merchantId.toString() +
          "','" +
          name +
          "','" +
          code +
          "','" +
          details +
          "','" +
          Item.getFormattedCategoryByParameter(category) +
          "','" +
          price +
          "','" +
          nTaxable.toString() +
          "')";

      await conn.query(query);
      return true;
    } catch (e) {
      print("insertItem(): " + e.toString());
      return false;
    }
  }

  // edits an item in the database
  static editItem(MySqlConnection conn, Item item) async {
    try {
      int nTaxable = 1;
      if (!item.isTaxable()) {
        nTaxable = 0;
      }

      String query = "update item set iName='" +
          item.getName() +
          "', iCode='" +
          item.getCode() +
          "', iDetails='" +
          item.getDetails() +
          "', iCategory='" +
          item.getCategoryFormatted() +
          "', iPrice=" +
          item.getPrice().toString() +
          ", iTaxable=" +
          nTaxable.toString() +
          " where iId=" +
          item.getItemId().toString();

      await conn.query(query);
      return true;
    } catch (e) {
      print("editItem(): " + e.toString());
      return false;
    }
  }
  //Updates the customer Id column in the receipt table
  static editReceiptCid(MySqlConnection conn, int rId, int cId) async {
    try {
      String query = "update receipt set cid='" +
          cId.toString() + "'"
          " where rId='" +
          rId.toString() + "';";

      await conn.query(query);
      return true;
    } catch (e) {
      print("editReceiptCid(): " + e.toString());
      return false;
    }
  }

  // deletes an item by specifying its primary key id
  static deleteItem(MySqlConnection conn, int itemId) async {
    try {
      String query = "delete from item where iId = " + itemId.toString() + "";
      await conn.query(query);

      return true;
    } catch (e) {
      print("deleteItem(): " + e.toString());
      return false;
    }
  }

  static getMerchantReceipts(MySqlConnection conn, int mId) async {
    String query = "select * from receipt where mid = '" + mId.toString() + "'";

    // result rows are in JSON format
    try {
      List<Receipt> receipts = <Receipt>[];
      var results = await conn.query(query);
      var iterator = results.iterator;

      while (iterator.moveNext()) {
        var result = iterator.current;

        int rId = result["rid"];
        DateTime dateTime = result["rDateTime"];
        double cost = double.parse(result["rCost"]);
        int mId = result["mid"];
        int cId = result["cid"];

        receipts.add(Receipt.no_items(rId, dateTime, cost, mId, cId));
      }

      return receipts;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static getMaxReceiptId(MySqlConnection conn) async {
    String query = "select max(rId) as maxId from receipt";
    return await conn.query(query);
  }

  static _getMaxReceiptItemId(MySqlConnection conn) async {
    String query = "select max(riid) as maxId from ReceiptItem";
    return await conn.query(query);
  }

  // Inserts a receipt and its associated receipt items to the database.
  // Receipt item has a database dependency with receipt, and receipt points to a merchant id.
  // A customer will associate themselves to a receipt after it is created by the merchant.
  static insertReceipt(MySqlConnection conn, Receipt receipt) async {
    try {
      // insert receipt tuple---------------------------------------------------
      String query = "insert into receipt values('" +
          receipt.getId().toString() +
          "','" +
          receipt.getDateTime().toString() +
          "','" +
          receipt.getCost().toString() +
          "','" +
          receipt.getMerchantId().toString() +
          "','" +
          receipt.getCustomerId().toString() +
          "')";
      await conn.query(query);

      // insert receipt item tuples--------------------------------------------------
      List<ReceiptItem> riList = receipt.getReceiptItems();
      for (int i = 0; i < riList.length; i++) {
        // get next receipt item id
        ReceiptItem ri = riList[i];
        var result = await _getMaxReceiptItemId(conn);
        int receiptItemId = result.first["maxId"] + 1;
        query = "insert into ReceiptItem values('" +
            receiptItemId.toString() +
            "','" +
            ri.getQuanity().toString() +
            "','" +
            receipt.getId().toString() +
            "','" +
            ri.getItem().getItemId().toString() +
            "')";
        await conn.query(query);
      }
      return true;
    } catch (e) {
      print(
          "Queries.insertReceipt(): Failed to insert receipt into the database. Error: " +
              e.toString());
      return false;
    }
  }

  static getCustomerReceipts(MySqlConnection conn, int cId) async {
    String query = "select * from receipt where cid = '" + cId.toString() + "'";

    // result rows are in JSON format
    try {
      List<Receipt> receipts = <Receipt>[];
      var results = await conn.query(query);
      var iterator = results.iterator;

      while (iterator.moveNext()) {
        var result = iterator.current;

        int rId = result["rid"];
        DateTime dateTime = result["rDateTime"];
        double cost = double.parse(result["rCost"]);
        int mId = result["mid"];
        int cId = result["cid"];

        receipts.add(Receipt.no_items(rId, dateTime, cost, mId, cId));
      }

      return receipts;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
