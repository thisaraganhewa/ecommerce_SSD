import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/components/footer.dart';
import 'package:ecom_app/components/my_button.dart';
import 'package:ecom_app/components/my_spacer.dart';
import 'package:ecom_app/constants.dart';
import 'package:ecom_app/helpers/change_screen.dart';
import 'package:ecom_app/models/item.dart';
import 'package:ecom_app/pages/checkout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool showLoading = false;

  bool _isValidId(String input) {
    final RegExp idRegExp = RegExp(r'^[a-zA-Z0-9-_]+$');
    return idRegExp.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("cart")
              .where("user-id",
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, d) {
            if (!d.hasData) {
              return CircularProgressIndicator(color: primaryColor);
            }

            if (d.data!.docs.any((doc) => !_isValidId(doc.id))) {
              return Center(child: Text("Invalid data detected."));
            }

            return Stack(
              alignment: (d.data!.size == 0)
                  ? Alignment.topCenter
                  : Alignment.bottomRight,
              children: [
                SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          (d.data!.size == 0)
                              ? "No items in cart!"
                              : "Your cart items",
                          style: TextStyle(fontSize: 28),
                        ),
                        VerticalSpacer(32),
                        for (int i = 0; i < d.data!.size; i++)
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("inventory")
                                    .doc(d.data!.docs[i].get("inventory-id"))
                                    .snapshots(),
                                builder: (context, inventory) {
                                  if (!inventory.hasData) {
                                    return CircularProgressIndicator(color: primaryColor);
                                  }

                                  Map item = inventory.data!.data() as Map;

                                  if (!_isValidId(d.data!.docs[i].get("inventory-id"))) {
                                    return Text("Invalid inventory item.");
                                  }

                                  return MyCard(
                                    itemName: item["name"],
                                    imageUrl: item["imageUrl"][0],
                                    itemAmount: item["amount"],
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection("cart")
                                          .doc(d.data!.docs[i].id)
                                          .delete();
                                    },
                                    quantity: null,
                                  );
                                }),
                          ),
                      ],
                    ),
                  ),
                ),
                (d.data!.size == 0)
                    ? Container()
                    : showLoading
                        ? CircularProgressIndicator(color: primaryColor)
                        : Padding(
                            padding: const EdgeInsets.all(25),
                            child: MyButton(
                                text: "Checkout",
                                onPressed: () async {
                                  showLoading = true;
                                  setState(() {});

                                  List<Item> items = [];
                                  QuerySnapshot cart = await FirebaseFirestore
                                      .instance
                                      .collection("cart")
                                      .where("user-id",
                                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                                      .get();

                                  for (int i = 0; i < cart.size; i++) {
                                    DocumentSnapshot inventory =
                                        await FirebaseFirestore.instance
                                            .collection("inventory")
                                            .doc(cart.docs[i].get("inventory-id"))
                                            .get();

                                    if (!_isValidId(inventory.id)) {
                                      Fluttertoast.showToast(
                                          msg: "Invalid cart item detected.",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                      continue;
                                    }

                                    items.add(
                                      Item(
                                        inventory.id,
                                        inventory.get("amount").toString(),
                                        inventory.get("name"),
                                        inventory.get("imageUrl")[0],
                                        1, itemId: '', itemAmount: '', itemName: '', imageUrl: '', quantity: 0,
                                      ),
                                    );
                                  }

                                  print(items);
                                  showLoading = false;
                                  setState(() {});
                                  changeScreen(
                                    context,
                                    CheckoutPage(
                                      items: items,
                                      page: 2,
                                    ),
                                  );
                                }),
                          ),
              ],
            );
          }),
      bottomNavigationBar: Footer(),
    );
  }
}

// MyCard widget remains unchanged
class MyCard extends StatelessWidget {
  const MyCard({
    Key? key,
    required this.imageUrl,
    required this.itemName,
    required this.itemAmount,
    required this.onPressed,
    required quantity,
  }) : super(key: key);

  final String imageUrl;
  final String itemName;
  final double itemAmount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          height: 80 + 2,
          width: width / 3 + 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        Container(
          height: 80,
          width: width / 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrl,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                itemName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              Text(
                "\$ ${itemAmount}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: onPressed,
                icon: Icon(
                  Icons.delete,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
