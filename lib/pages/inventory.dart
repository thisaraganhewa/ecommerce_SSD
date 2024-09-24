import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/components/my_button.dart';
import 'package:ecom_app/components/my_spacer.dart';
import 'package:ecom_app/pages/cart.dart';
import 'package:flutter/material.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory"),
        backgroundColor: Colors.blue, // Use your primary color here
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("inventory").snapshots(),
        builder: (context, inventory) {
          if (!inventory.hasData) {
            return CircularProgressIndicator(
              color: Colors.blue, // Use your primary color here
            );
          }

          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (int i = 0; i < inventory.data!.size; i++)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: InkWell(
                      onTap: () {
                        TextEditingController amountController =
                            TextEditingController();
                        TextEditingController qtyController =
                            TextEditingController();

                        amountController.text =
                            inventory.data!.docs[i].get("amount").toString();
                        qtyController.text =
                            inventory.data!.docs[i].get("quantity").toString();

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            title: Text(
                                "Edit item: ${inventory.data!.docs[i].get("name")}"),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: amountController,
                                    decoration: InputDecoration(
                                      label: Text("Amount"),
                                    ),
                                  ),
                                  VerticalSpacer(12),
                                  TextField(
                                    controller: qtyController,
                                    decoration: InputDecoration(
                                      label: Text("Quantity"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              MyButton(
                                text: "Update",
                                onPressed: () async {
                                  final double? amount = parseAmount(amountController.text);
                                  final int? quantity = parseQuantity(qtyController.text);

                                  if (amount != null && quantity != null) {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection("inventory")
                                          .doc(inventory.data!.docs[i].id)
                                          .update({
                                        "amount": amount,
                                        "quantity": quantity,
                                      });
                                      Navigator.pop(context);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text('Failed to update item: $e')),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Invalid input.')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: MyCard(
                        itemName: inventory.data!.docs[i].get("name"),
                        imageUrl: inventory.data!.docs[i].get("imageUrl")[0],
                        itemAmount: inventory.data!.docs[i].get("amount"),
                        quantity: inventory.data!.docs[i].get("quantity"),
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection("inventory")
                                .doc(inventory.data!.docs[i].id)
                                .delete();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed to delete item: $e')),
                            );
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController amountController = TextEditingController();
          TextEditingController qtyController = TextEditingController();
          TextEditingController nameController = TextEditingController();
          TextEditingController imageUrlController = TextEditingController();
          TextEditingController descController = TextEditingController();

          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => AlertDialog(
              title: Text("New Item"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        label: Text("Name"),
                      ),
                      maxLength: 50,
                    ),
                    VerticalSpacer(12),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        label: Text("Description"),
                      ),
                      maxLength: 250,
                    ),
                    VerticalSpacer(12),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        label: Text("Amount"),
                      ),
                    ),
                    VerticalSpacer(12),
                    TextField(
                      controller: qtyController,
                      decoration: InputDecoration(
                        label: Text("Quantity"),
                      ),
                    ),
                    VerticalSpacer(12),
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: imageUrlController,
                        decoration: InputDecoration(
                          label: Text("Image"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                MyButton(
                  text: "Add",
                  onPressed: () async {
                    final double? amount = parseAmount(amountController.text);
                    final int? quantity = parseQuantity(qtyController.text);
                    final String imageUrl = imageUrlController.text;

                    if (amount != null && quantity != null && isValidUrl(imageUrl)) {
                      try {
                        await FirebaseFirestore.instance.collection("inventory").add({
                          "amount": amount,
                          "quantity": quantity,
                          "name": nameController.text,
                          "description": descController.text,
                          "imageUrl": [imageUrl],
                        });
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add new item: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid input or URL.')),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
        child: Text("Add"),
      ),
    );
  }

  // Input validation helpers
  double? parseAmount(String input) {
    try {
      return double.parse(input);
    } catch (e) {
      return null;
    }
  }

  int? parseQuantity(String input) {
    try {
      return int.parse(input);
    } catch (e) {
      return null;
    }
  }

  bool isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }
}
