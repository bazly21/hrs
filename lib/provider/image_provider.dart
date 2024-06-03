import 'package:flutter/material.dart';

class ImageService with ChangeNotifier {
  List<String> _images = [];

  List<String> get images => _images;
  int get imageCount => _images.length;
  bool get hasImages => _images.isNotEmpty;

  set images(List<String> images) {
    _images = images;
    notifyListeners();
  }

  void addImage(String image) {
    _images.add(image);
    notifyListeners();
  }

  void removeImage(int index) {
    _images.removeAt(index);
    notifyListeners();
  }

  void clearImage() {
    _images.clear();
    notifyListeners();
  }
}
