import 'package:flutter/material.dart';
import 'package:hrs/components/custom_appbar.dart';
import 'package:hrs/components/custom_rental_card.dart';
import 'package:hrs/model/property/property_details.dart';
import 'package:hrs/pages/login_page.dart';
import 'package:hrs/provider/refresh_provider.dart';
import 'package:hrs/provider/wishlist_provider.dart';
import 'package:hrs/services/auth/auth_service.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:hrs/services/property/property_service.dart';
import 'package:provider/provider.dart';

class RentalListPage extends StatefulWidget {
  const RentalListPage({super.key});

  @override
  State<RentalListPage> createState() => _RentalListPageState();
}

class _RentalListPageState extends State<RentalListPage> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<PropertyFullDetails>?> rentalListFuture;
  String? role;
  bool refresh = false;

  // Initialize state
  // Execute fetchRentalDetails function and store it
  // in the rentalDetailsFuture within initState to
  // improve the app's performance
  @override
  void initState() {
    super.initState();
    rentalListFuture = PropertyService.fetchAvailableProperties(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    role = context.watch<AuthService>().userRole;
    refresh = context.watch<RefreshProvider>().isRefresh;

    if (refresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleRefresh().then((_) {
          context.read<RefreshProvider>().setRefresh(false);
        });
      });
    }

    return Scaffold(
      appBar: SearchAppBar(
        hintText: "Enter location or property type",
        controller: _searchController,
        onChanged: _handleSearch,
      ),
      body: RefreshIndicator(
        onRefresh: handleRefresh,
        child: FutureBuilder(
            future: rentalListFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a loading indicator while waiting for the data
                return const Center(child: CircularProgressIndicator());
              }
              // If there's an error fetching the data
              else if (snapshot.hasError) {
                // Show an error message if there's an error fetching the data
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${snapshot.error}')),
                  );
                });
              }
              // If there is data and the data is empty
              else if (snapshot.hasData && snapshot.data != null) {
                int propertyCount = snapshot.data!.length;

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: propertyCount,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    // Return the rental list
                    // return rentalList(
                    //     context, snapshot.data![index], index, propertyCount);
                    var propertyData = snapshot.data![index];

                    return RentalCard(
                        propertyData: propertyData,
                        isLastIndex: index == propertyCount - 1,
                        requiresConsumer: true,
                        iconOnPressed: () {
                          toggleWishlist(propertyData.propertyID!);
                        });
                  },
                );
              }

              // When there is no data
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No rental properties found'),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
      ),
    );
  }

  Future<void> handleRefresh() async {
    await PropertyService.fetchAvailableProperties(context).then((properties) {
      setState(() {
        rentalListFuture = Future.value(properties);
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Unable to refresh. Please try again."),
            duration: Duration(seconds: 3)),
      );
    });
  }

  void toggleWishlist(String propertyID) {
    if (role != null && role == "Tenant") {
      bool isWishlisted = context
          .read<WishlistProvider>()
          .wishlistPropertyIDs
          .contains(propertyID);

      if (isWishlisted) {
        context
            .read<WishlistProvider>()
            .removeFromWishlist(propertyID)
            .then((_) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Property removed from wishlist'),
                    duration: Duration(seconds: 2))))
            .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Error removing property from wishlist'))));
      } else {
        context
            .read<WishlistProvider>()
            .addToWishlist(propertyID)
            .then((_) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Property added to wishlist'),
                    duration: Duration(seconds: 2),
                  ),
                ))
            .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error adding property to wishlist'),
                  ),
                ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'You must login first to add the property to your wishlist.'),
          action: SnackBarAction(
            label: 'Login',
            onPressed: () {
              NavigationUtils.pushPage(context, const LoginPage(role: "Tenant"),
                  SlideDirection.left);
            },
          ),
        ),
      );
    }
  }

  void _handleSearch(searchQuery) {
    setState(() {
      rentalListFuture = PropertyService.fetchAvailableProperties(context,
          searchQuery: searchQuery);
    });
  }
}
