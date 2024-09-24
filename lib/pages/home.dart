import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/components/footer.dart';
import 'package:ecom_app/components/my_card.dart';
import 'package:ecom_app/constants.dart';
import 'package:ecom_app/helpers/change_screen.dart';
import 'package:ecom_app/pages/cart.dart';
import 'package:ecom_app/pages/details.dart';
import 'package:ecom_app/pages/wishlist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // Function to validate string inputs
  bool _isValidString(String? input) {
    return input != null && input.isNotEmpty && input.length <= 100;
  }

  // Function to validate number inputs
  bool _isValidNumber(dynamic amount) {
    return amount != null && amount is num;
  }

  // Function to validate URL
  bool _isValidUrl(String? url) {
    if (url == null) return false;
    final Uri? uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appName),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              changeScreen(context, WishlistPage());
            },
            icon: Icon(
              Icons.favorite_rounded,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              changeScreen(context, CartPage());
            },
            icon: Icon(
              Icons.shopping_cart_rounded,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.logout_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 1440,
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("inventory")
                  .snapshots(),
              builder: (context, d) {
                if (!d.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                if (d.data!.size == 0) {
                  return Center(child: Text("No items to show!"));
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 30,
                    crossAxisSpacing: 30,
                    childAspectRatio: 3 / 4,
                  ),
                  padding: EdgeInsets.all(30),
                  itemCount: d.data!.size,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    String userId = FirebaseAuth.instance.currentUser!.uid;
                    String itemId = d.data!.docs[index].id;
                    Map item = d.data!.docs[index].data() as Map;

                    // Validate item fields
                    String? itemName = _isValidString(item["name"]) ? item["name"] : "Unknown Item";
                    double itemAmount = _isValidNumber(item["amount"]) ? (item["amount"] as num).toDouble() : 0.0;
                    List<String> images = item["imageUrl"] is List && item["imageUrl"].every(_isValidUrl)
                        ? List<String>.from(item["imageUrl"])
                        : ["https://example.com/default_image.jpg"]; // default image if invalid

                    return InkWell(
                      onTap: () {
                        changeScreen(
                            context,
                            ItemDetailsPage(
                              itemName: itemName!,
                              itemAmount: itemAmount,
                              description: _isValidString(item["description"]) ? item["description"] : "No description available.",
                              images: images,
                              mainImageUrl: images[0], // first valid image
                              userId: userId,
                              itemId: itemId,
                            ));
                      },
                      child: MyItemCard(
                        imageUrl: images[0],
                        itemAmount: itemAmount,
                        itemName: itemName!,
                        itemId: itemId,
                        userId: userId,
                      ),
                    );
                  },
                );
              }),
        ),
      ),
      bottomNavigationBar: Footer(),
    );
  }
}
