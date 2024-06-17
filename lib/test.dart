import 'package:flutter/material.dart';
import 'package:hrs/components/custom_circleavatar.dart';
import 'package:hrs/components/custom_rating_bar.dart';
import 'package:hrs/components/custom_richtext.dart';

class SubTestPage extends StatefulWidget {
  const SubTestPage({super.key});

  @override
  State<SubTestPage> createState() => _SubTestPageState();
}

class _SubTestPageState extends State<SubTestPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("John Doe"),
          centerTitle: true,
        ),
        body: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              delegate: _ProfileInfoHeader(
                height: 140,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomCircleAvatar(
                      radius: 40,
                      name: "John Doe",
                      imageURL: null,
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("John Doe", style: TextStyle(fontSize: 20)),
                        SizedBox(height: 10),
                        CustomRatingBar(rating: 4.5),
                      ],
                    ),
                  ],
                ),
              ),
              pinned: false,
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                Column(
                  children: <Widget>[
                    TabBar(
                      tabs: [
                        Tab(icon: Icon(Icons.directions_car), text: "Car"),
                        Tab(
                            icon: Icon(Icons.directions_transit),
                            text: "Transit"),
                        Tab(icon: Icon(Icons.directions_bike), text: "Bike"),
                      ],
                      indicatorColor:
                          Colors.blue, // You can customize the indicator color
                      labelColor:
                          Colors.black, // You can customize the label color
                      unselectedLabelColor: Colors
                          .grey, // You can customize the unselected label color
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          ListView.builder(
                            itemCount: 30,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text("Car $index"),
                              );
                            },
                          ),
                          Container(
                            color: Colors.white,
                            child: Center(
                              child: Text("Transit"),
                            ),
                          ),
                          Container(
                            color: Colors.white,
                            child: Center(
                              child: Text("Bike"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                context,
              ),
              pinned: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this._context);

  final Column _tabBar;
  final BuildContext _context;

  @override
  double get minExtent => kToolbarHeight;
  @override
  double get maxExtent => MediaQuery.of(_context).size.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Page"),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SubTestPage()));
            },
            child: const Text("Go to SubTestPage")),
      ),
    );
  }
}

class _ProfileInfoHeader extends SliverPersistentHeaderDelegate {
  _ProfileInfoHeader({
    required double height,
    required Widget child,
  })  : _height = height,
        _child = child;

  final double _height;
  final Widget _child;

  @override
  double get minExtent => kToolbarHeight;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(child: _child);
  }

  @override
  bool shouldRebuild(_ProfileInfoHeader oldDelegate) {
    return true;
  }
}
