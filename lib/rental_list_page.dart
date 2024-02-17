import 'package:flutter/material.dart';
import 'components/my_appbar.dart';
// import 'components/my_label.dart';

class RentalListPage extends StatelessWidget {
  const RentalListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MyAppBar(
          text: "Enter location or property type", appBarContent: "Search"),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 19), // Adjust the height as needed
            Expanded(
              // Use Expanded to make the ListView take the remaining space
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: 6,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: InkWell(
                      onTap: () {}, // Go to property details page
                      child: Container(
                        height: 189,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 108,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10)),
                                  image: DecorationImage(
                                      image: AssetImage(
                                          "lib/images/city${index + 1}.jpg"),
                                      fit: BoxFit.cover,
                                      opacity: 0.8)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // Align text to the left
                                children: [
                                  const Text(
                                    "Modern Wood Cabin in Bangi",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Text(
                                    "Seksyen 9, Bangi",
                                    style: TextStyle(
                                        fontSize: 13, color: Color(0xFF7D7F88)),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // Profile picture
                                      InkWell(
                                        onTap: () {},
                                        child: ClipOval(
                                          child: Image.network(
                                            'https://via.placeholder.com/150', // Replace with your profile picture URL
                                            width:
                                                19, // Width for the profile picture
                                            height:
                                                19, // Height for the profile picture
                                            fit: BoxFit
                                                .cover, // Cover the bounds of the parent widget (ClipOval)
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5), // Add space between elements
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
