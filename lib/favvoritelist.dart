import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Favoritelist {
  List<String> favoritelistData = [];

  // Save the list to local storage
  Future<void> saveToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the list to JSON and save it
    prefs.setString('favoritelist', jsonEncode(favoritelistData));
  }

  // Load the list from local storage
  Future<void> loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the list as a JSON string and decode it
    String? jsonString = prefs.getString('favoritelist');
    if (jsonString != null) {
      favoritelistData = List<String>.from(jsonDecode(jsonString));
    }
  }

  // Add an item and save the updated list
  Future<void> addItem(String item) async {
    if (!favoritelistData.contains(item)) {
      favoritelistData.add(item);
      await saveToLocalStorage();
    }
  }

  // Remove an item and save the updated list
  Future<void> removeItem(String item) async {
    if (favoritelistData.contains(item)) {
      favoritelistData.remove(item);
      await saveToLocalStorage();
    }
  }

  // Check if an item exists
  bool containsItem(String item) {
    return favoritelistData.contains(item);
  }

  // Getter for the list
  List<String> get items => favoritelistData;
}
