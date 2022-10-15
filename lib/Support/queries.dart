import 'dart:ffi';

import 'package:ceg4912_project/Models/customer.dart';
import 'package:ceg4912_project/Models/item.dart';
import 'package:ceg4912_project/Models/merchant.dart';
import 'package:flutter/foundation.dart';
import 'package:mysql1/mysql1.dart';
import 'package:ceg4912_project/Models/user.dart';
import 'package:ceg4912_project/Models/receipt.dart';
import 'package:ceg4912_project/Models/receipt_item.dart';

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
      String cQuery = "insert into customer values (" + nextId + ")";
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

  // deletes an item by specifying its primary key id
  static deleteItem(MySqlConnection conn, int itemId) async {
    try {
      String query = "delete from item where iId = " + itemId.toString() + "";
      await conn.query(query);

      return true;
    } catch (e) {
      print("delteItem(): " + e.toString());
      return false;
    }
  }

  static getMerchantReceipts(MySqlConnection conn, int mId, int cId) async {
    String query =
        "select * from receipt AS r JOIN receiptitem AS ri ON r.rid = ri.rid JOIN item as i ON ri.iId = i.iId where r.mId = '" +
            mId.toString() +
            "' and r.cid = '" +
            cId.toString() +
            "'";
    // result rows are in JSON format
    try {
      List<Receipt> receipts = <Receipt>[];
      List<ReceiptItem> receiptItems = <ReceiptItem>[];
      List<Item> items = <Item>[];

      var results = await conn.query(query);
      var iterator = results.iterator;

      while (iterator.moveNext()) {
        var result = iterator.current;

        int itemId = result["iId"];
        int mId = result["mid"];
        String itemName = result["iName"];
        String itemCode = result["iCode"];
        String itemDetails = result["iDetails"];
        Categories itemCategory = result["iCategory"];
        double itemPrice = result["iPrice"];
        bool itemTaxable = result["iTaxable"];

        items.add(Item.all(itemId, mId, itemName, itemCode, itemDetails, itemCategory, itemPrice, itemTaxable));

        for (Item i in items) {
          receiptItems.add(ReceiptItem.create(i));
        }

        int rId = result["rid"];
        DateTime dateTime = result["rDateTime"];
        double cost = double.parse(result["rCost"]);
        int cId = result["cid"];

        receipts.add(Receipt.all(rId, dateTime, cost, mId, cId, receiptItems));
      }

      return receipts;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // returns all customers that have a receipt at a given merchant
  static getCustomerEmails(MySqlConnection conn, int mid) async {
    String query =
        "select cEmail from customer AS c JOIN receipt As r ON c.cid = r.cid JOIN merchant as m ON m.mid = r.mid where m.mId = '" +
            mid.toString() +
            "'";
    try {
      List<String> emails = <String>[];

      var results = await conn.query(query);
      var iterator = results.iterator;
      while (iterator.moveNext()) {
        var result = iterator.current;
        String email = result["cEmail"];
        emails.add(email);
      }
      return emails;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
