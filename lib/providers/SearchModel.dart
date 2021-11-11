import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import '../utils/Utility.dart';
import '../utils/ApiUrl.dart';
import '../models/Media.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchModel with ChangeNotifier {
  List<Media> _items = [];
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  bool isError = false;
  bool isLoading = false;
  bool isIdle = true;
  String query = "";

  SearchModel();

  List<Media> get items {
    return _items;
  }

  void cancelSearch() {
    isError = false;
    isLoading = false;
    isIdle = true;
    notifyListeners();
  }

  void setSearchResult(List<Media> item) {
    _items = item;
    refreshController.refreshCompleted();
    isError = false;
    isLoading = false;
    notifyListeners();
  }

  void setMoreSearchResults(List<Media> item) {
    _items.addAll(item);
    refreshController.loadComplete();
    notifyListeners();
  }

  Future<void> searchArticles(String query) async {
    try {
      this.query = query;
      isIdle = false;
      isLoading = true;
      notifyListeners();
      final response = await Utility.getDio().post(
        ApiUrl.SEARCH,
        data: jsonEncode({
          "data": {"offset": 0, "query": query, "version": "v2"}
        }),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic res = jsonDecode(response.data);
        List<Media> articles = await compute(parseMedia, res);
        setSearchResult(articles);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        setArticleFetchError();
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      setArticleFetchError();
    }
  }

  setArticleFetchError() {
    _items = [];
    refreshController.refreshFailed();
    isError = true;
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMoreSearch() async {
    try {
      final response = await Utility.getDio().post(
        ApiUrl.SEARCH,
        data: jsonEncode({
          "data": {"offset": items.length + 1, "query": query, "version": "v2"}
        }),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic res = jsonDecode(response.data);
        List<Media> articles = await compute(parseMedia, res);
        setMoreSearchResults(articles);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        refreshController.refreshFailed();
        notifyListeners();
      }
    } catch (exception) {
      print(exception);
      refreshController.loadFailed();
      notifyListeners();
    }
  }

  static List<Media> parseMedia(dynamic res) {
    final parsed = res["search"].cast<Map<String, dynamic>>();
    return parsed.map<Media>((json) => Media.fromJson(json)).toList();
  }
}
