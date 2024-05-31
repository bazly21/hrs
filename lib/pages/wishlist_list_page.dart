import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/custom_appbar.dart';
import 'package:hrs/components/custom_rental_card.dart';
import 'package:hrs/model/property/property_details.dart';
import 'package:hrs/provider/wishlist_provider.dart';
import 'package:hrs/services/utils/error_message_utils.dart';
import 'package:provider/provider.dart';

class WishlistListPage extends StatefulWidget {
  const WishlistListPage({super.key});

  @override
  State<WishlistListPage> createState() => _WishlistListPageState();
}

class _WishlistListPageState extends State<WishlistListPage> {
  late WishlistProvider _wishlistProvider;
  late Future<List<PropertyFullDetails>> _wishlistFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _wishlistProvider = context.read<WishlistProvider>();
    _wishlistFuture = _wishlistProvider.getWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'My Wishlist'),
      body: _isLoading
          ? _buildLoadingAnimation()
          : _buildMainBody(),
    );
  }

  RefreshIndicator _buildMainBody() {
    return RefreshIndicator(
      onRefresh: refreshData,
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: FutureBuilder(
                future: _wishlistFuture,
                builder: (context, snapshot) {
                  // If the connection is active, show a loading indicator
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingAnimation();
                  } else if (snapshot.hasError) {
                    _buildErrorMessage(snapshot, context);
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    int wishlistCount = snapshot.data!.length;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: wishlistCount,
                      itemBuilder: (context, index) {
                        var propertyData = snapshot.data![index];

                        return RentalCard(
                            propertyData: propertyData,
                            isLastIndex: index == wishlistCount - 1,
                            iconOnPressed: () {
                              _removeWishlist(propertyData.propertyID!);
                            });
                      },
                    );
                  }

                  return const Center(
                    child: Text('There are no properties in your wishlist.'),
                  );
                }),
          ),
        );
      }),
    );
  }

  void _buildErrorMessage(
      AsyncSnapshot<List<PropertyFullDetails>> snapshot, BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String errorMessage;
      if (snapshot.error is FirebaseException) {
        FirebaseException e = snapshot.error as FirebaseException;
        switch (e.code) {
          case 'auth/network-request-failed':
            errorMessage = networkRequestFailedErrorMessage;
            break;
          case 'invalid-access':
            errorMessage = invalidAccessErrorMessage;
            break;
          default:
            errorMessage = genericFutureErrorMessage;
        }
      } else {
        errorMessage = genericFutureErrorMessage;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    });
  }

  Center _buildLoadingAnimation() => const Center(child: CircularProgressIndicator());

  void _removeWishlist(String propertyID) {
    // Show a dialog to confirm the removal of the property from the wishlist
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove from Wishlist'),
          content: const Text(
              'Are you sure you want to remove this property from your wishlist?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                setState(() {
                  _isLoading = true;
                });

                _wishlistProvider
                    .removeFromWishlist(propertyID)
                    .then((_) async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Successfully removed the property from wishlist'),
                      duration: Duration(seconds: 3),
                    ),
                  );

                  // Refresh the wishlist
                  await refreshData();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'An error occurred while removing the property from the wishlist. Please try again.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }).then((_) {
                  setState(() {
                    _isLoading = false;
                  });
                });
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  Future<void> refreshData() async {
    await _wishlistProvider.getWishlist().then((wishlist) {
      setState(() {
        _wishlistFuture = Future.value(wishlist);
      });
    });
  }
}
