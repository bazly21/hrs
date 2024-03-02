import 'package:flutter/material.dart';
import 'package:hrs/components/my_appbar.dart';
import 'package:hrs/components/my_rentallist.dart';

class RentalListPage extends StatelessWidget {
  const RentalListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(text: "Enter location or property type", appBarType: "Search",),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 19),
            Expanded(
              child: MyRentalList(),
            ),
          ],
        ),
      ),
    );
  }
}
