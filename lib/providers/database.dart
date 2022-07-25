import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Database extends ChangeNotifier {
  static const String boxName = "my_words";
  static var box = Hive.box(boxName);

  late List<MapEntry<dynamic, dynamic>> allWords;

  Database() {
    updateAllWords();
  }

  void updateAllWords({isSort = true}) {
    allWords = _getAllWords(isSort);
    notifyListeners();
  }

  void addNewWord(String key, Map<dynamic, dynamic> value) async {
    await box.put(key, value);
    updateAllWords();
  }

  Future<void> incrementCount(key) async {
    var item = box.get(key);
    var count = item["count"] + 1;
    await box.put(key,
        {"tr": item["tr"], "isLearned": item["isLearned"], "count": count});
    updateAllWords();
  }

  static Map<dynamic, dynamic> getWordByKey(String key) {
    return box.get(key);
  }

  Future<void> deleteWord(key) async {
    await box.delete(key);
    updateAllWords();
  }

  List<MapEntry<dynamic, dynamic>> _getAllWords(isSort) {
    var items = box.toMap().entries.toList();
    if (isSort) {
      items.sort((a, b) => a.value['count'].compareTo(b.value['count']));
    }
    return items;
  }
}
