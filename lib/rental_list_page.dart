import 'package:flutter/material.dart';
import 'components/my_appbar.dart';

class RentalListPage extends StatelessWidget {
  const RentalListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBar(
        text: "Enter location or property type", 
        appBarContent: "Search"
      ),
      body: Center(
        child: Text('My App Content'),
      ),
    ); 
  }
}
