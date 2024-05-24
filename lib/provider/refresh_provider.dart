import 'package:flutter/material.dart';

class RefreshProvider extends ChangeNotifier {
  bool _isRefreshing = false;

  bool get isRefresh => _isRefreshing;

  void setRefresh(bool value) {
    _isRefreshing = value;
    notifyListeners();
  }
}