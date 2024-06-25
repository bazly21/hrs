import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hrs/components/my_propertydescription.dart';
import 'package:hrs/components/my_rentaldetails.dart';
import 'package:hrs/model/property/property_details.dart';
import 'package:hrs/pages/landord_pages/landlord_edit_property_details_page.dart';
import 'package:hrs/services/navigation/navigation_utils.dart';
import 'package:hrs/services/property/property_service.dart';

class PropertyDetailsSection extends StatefulWidget {
  final String propertyID;

  const PropertyDetailsSection({super.key, required this.propertyID});

  @override
  State<PropertyDetailsSection> createState() => _PropertyDetailsSectionState();
}

class _PropertyDetailsSectionState extends State<PropertyDetailsSection> {
  late Future<PropertyDetails> propertyApplicationsFuture;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    propertyApplicationsFuture =
        PropertyService.getPropertyFullDetails(widget.propertyID, null);
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: () => refreshData(),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: FutureBuilder<PropertyDetails>(
                future: propertyApplicationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: constraints.maxHeight,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    // Display error message through snackbar
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(snapshot.error.toString()),
                        ),
                      );
                    });
                  } else if (snapshot.hasData && snapshot.data != null) {
                    // Check if the snapshot has data
                    final PropertyDetails propertyData = snapshot.data!;
                    return _buildPropertyDetails(
                        propertyData, context, height, width);
                  }
                  // Act as placeholder
                  return const Center(child: Text('No property found'));
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Column _buildPropertyDetails(PropertyDetails propertyData,
      BuildContext context, double height, double width) {
    return Column(
      children: [
        // Image container
        Stack(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 250,
                viewportFraction: 1.0,
                enableInfiniteScroll:
                    propertyData.image!.length > 1 ? true : false,
                autoPlay: false,
                onPageChanged: (index, _) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: propertyData.image!
                  .map((item) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(item),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            if (propertyData.image!.length > 1)
              Positioned(
                bottom: 16.0,
                left: 0,
                right: 0,
                child: Center(
                  child: CarouselIndicator(
                    count: propertyData.image!.length,
                    index: _currentIndex,
                    color: Colors.white,
                    activeColor: const Color(0xFF8568F3),
                    space: 6.0,
                    width: 11.0,
                    height: 11.0,
                    cornerRadius: 6.0,
                  ),
                ),
              ),
          ],
        ),

        // ********* Property Details Section (Start) *********
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ********* Property Name, Property Location & Edit Button (Start) *********
              PropertyDetailsInfo(
                propertyName: propertyData.propertyName!,
                propertyLocation: propertyData.address!,
                icon: const Icon(Icons.edit, size: 21),
                showIcon: true, // Set this to false to hide the icon button
                onIconPressed: () {
                  NavigationUtils.pushPage(
                    context,
                    EditPropertyDetailsPage(
                      propertyID: widget.propertyID,
                    ),
                    SlideDirection.up,
                  ).then((status) {
                    if (status != null && status['success']) {
                      // Refresh data
                      setState(() {
                        propertyApplicationsFuture =
                            Future.value(status['updatedData']);
                      });

                      // Show success message
                      Future.delayed(const Duration(milliseconds: 500), () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(status['message']),
                            duration: const Duration(seconds: 3),
                            backgroundColor: Colors.green[700],
                          ),
                        );
                      });
                    }
                  });
                },
              ),
              // ********* Property Name, Property Location & Edit Button (End) *********

              // Add space between elements
              SizedBox(height: height * 0.025),

              // ********* Property Main Details (Start)  *********
              Row(
                children: [
                  // ********* Property Size Information (Start) *********
                  // Property Size Icon
                  const Icon(
                    Icons.house_rounded,
                    size: 16.0,
                    color: Color(0xFF7D7F88),
                  ),

                  // Add space between elements
                  SizedBox(width: width * 0.015),

                  // Property Size Text **Database Required**
                  Text(
                    "${propertyData.size!} m\u00B2",
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF7D7F88)),
                  ),
                  // ********* Property Size Information (End) *********

                  // Add space between elements
                  SizedBox(width: width * 0.04),

                  // ********* Bed Information (Start) *********
                  // House's Size Icon
                  const Icon(
                    Icons.bed,
                    size: 16.0,
                    color: Color(0xFF7D7F88),
                  ),

                  // Add space between elements
                  SizedBox(width: width * 0.015),

                  // Propery's Size Text **Database Required**
                  Text(
                    "${propertyData.bedrooms!} Rooms",
                    style: const TextStyle(
                        fontSize: 14.0, color: Color(0xFF7D7F88)),
                  ),
                  // ********* Bed Information (End) *********

                  // Add space between elements
                  SizedBox(width: width * 0.04),

                  // ********* Number of Bathroom Information (Start) *********
                  // Bathroom Icon
                  const Icon(
                    Icons.bathroom_rounded,
                    size: 16.0,
                    color: Color(0xFF7D7F88),
                  ),

                  // Add space between elements
                  SizedBox(width: width * 0.015),

                  // Number of Bathroom Text **Database Required**
                  Text(
                    "${propertyData.bathrooms!} Bathrooms",
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF7D7F88)),
                  ),
                  // ********* Number of Bed Information (End) *********
                ],
              ),
              // ********* Property Main Details (End)  *********

              // Add space between elements
              SizedBox(height: height * 0.01),

              const Divider(),

              // Add space between elements
              SizedBox(height: height * 0.01),

              // ********* Property Description Section (Start) *********
              // Property Description Label
              PropertyDescription(
                title: "Description",
                content: propertyData.description!,
              ),

              // Furnishing Description Label
              PropertyDescription(
                title: "Furnishing",
                content: propertyData.furnishing!,
              ),

              // Facilities Description Label
              PropertyDescription(
                title: "Facilities",
                content: propertyData.facilities!,
              ),

              // Accessibility Description Label
              PropertyDescription(
                title: "Accessibility",
                content: propertyData.accessibilities!,
              ),
              // ********* Property Description Section (End) *********
            ],
          ),
        )
        // ********* Property Details Section (End) *********
      ],
    );
  }

  Future<void> refreshData() async {
    await PropertyService.getPropertyFullDetails(widget.propertyID, null)
        .then((newData) {
      setState(() {
        propertyApplicationsFuture = Future.value(newData);
      });
    });
  }
}
