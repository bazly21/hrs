import 'package:flutter/material.dart';

class RefreshProvider extends ChangeNotifier {
  bool _isRefreshing = false;
  bool _profileRefresh = false;
  bool _propertyRefresh = false;

  bool get isRefresh => _isRefreshing;
  bool get profileRefresh => _profileRefresh;
  bool get propertyRefresh => _propertyRefresh;

  void setRefresh(bool value) {
    _isRefreshing = value;
    notifyListeners();
  }

  set profileRefresh(bool value) {
    _profileRefresh = value;
    notifyListeners();
  }

  set propertyRefresh(bool value) {
    _propertyRefresh = value;
    notifyListeners();
  }
}