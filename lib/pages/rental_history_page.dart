import 'package:flutter/material.dart';
import 'package:hrs/components/appbar_shadow.dart';
import 'package:hrs/pages/application_history_list.dart';
import 'package:hrs/pages/rental_history_list.dart';

class RentalHistoryPage extends StatefulWidget {
  const RentalHistoryPage({super.key});

  @override
  State<RentalHistoryPage> createState() => _RentalHistoryPageState();
}

class _RentalHistoryPageState extends State<RentalHistoryPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ApplicationHistoryList(),
    const RentalHistoryList(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental History',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20.0,
          )
        ),
        centerTitle: true,
        toolbarHeight: 70.0,
        flexibleSpace: const AppBarShadow(),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  dropdownColor: Colors.white,
                  value: _selectedIndex,
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedIndex = newValue!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 0,
                      child: Text('Application'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Rental'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}

class ApplicationPage extends StatelessWidget {
  const ApplicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Application Page'),
    );
  }
}
