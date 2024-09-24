import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/components/footer.dart';
import 'package:ecom_app/components/my_spacer.dart';
import 'package:ecom_app/constants.dart';
import 'package:ecom_app/helpers/change_screen.dart'; // Ensure this import is here
import 'package:ecom_app/models/item.dart';
import 'package:ecom_app/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    Key? key,
    required this.items,
    required this.page,
  }) : super(key: key);
  final List<Item> items;
  final int page;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  int stepperIndex = 0;
  double totalAmount = 0.0;

  bool isCreditCard = false, isDebitCard = false, isCashOnDel = false;

  getTotalAmount() {
    totalAmount = 0.0; // Reset total amount
    widget.items.forEach((item) {
      totalAmount += double.parse(item.itemAmount) * item.quantity;
    });
  }

  // Solution 1: Name validation - only allows alphabet and spaces
  bool isValidName(String name) {
    final RegExp nameRegex = RegExp(r"^[a-zA-Z\s]+$");
    return nameRegex.hasMatch(name);
  }

  // Solution 2: Phone number validation - valid phone number format
  bool isValidPhoneNumber(String phone) {
    final RegExp phoneRegex =
        RegExp(r'^\+?[0-9]{7,15}$'); // Allows international format
    return phoneRegex.hasMatch(phone);
  }

  // Solution 3: Address sanitization - basic sanitation to remove harmful characters
  String sanitizeAddress(String address) {
    final RegExp addressRegex = RegExp(r'[^a-zA-Z0-9\s,.-]');
    return address.replaceAll(
        addressRegex, ''); // Removes all invalid characters
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appName),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (int i = 0; i < widget.items.length; i++)
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  widget.items[i].imageUrl,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text(widget.items[i].itemName),
                            Text("Amount: \$ ${widget.items[i].itemAmount}"),
                            Text("Qty: ${widget.items[i].quantity}"),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Theme(
                data: ThemeData(
                  textTheme: GoogleFonts.kanitTextTheme(),
                  canvasColor: primaryColor,
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: primaryColor,
                        secondary: primaryColor,
                      ),
                ),
                child: Stepper(
                  steps: [
                    Step(
                      isActive: stepperIndex == 0,
                      title: Text("Billing Address"),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          VerticalSpacer(12),
                          SizedBox(
                            width: 200,
                            child: TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                label: Text("Name"),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (value) {
                                if (!isValidName(value)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Invalid name! Only letters and spaces allowed."),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          VerticalSpacer(12),
                          SizedBox(
                            width: 250,
                            child: TextField(
                              controller: addressController,
                              decoration: InputDecoration(
                                label: Text("Shipping address"),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (value) {
                                addressController.text = sanitizeAddress(value);
                                addressController.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(
                                      offset: addressController.text.length),
                                );
                              },
                            ),
                          ),
                          VerticalSpacer(12),
                          SizedBox(
                            width: 200,
                            child: TextField(
                              controller: phoneNoController,
                              decoration: InputDecoration(
                                label: Text("Phone number"),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (value) {
                                if (!isValidPhoneNumber(value)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("Invalid phone number format!"),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          VerticalSpacer(12),
                        ],
                      ),
                    ),
                    Step(
                      isActive: stepperIndex == 1,
                      title: Text("Payment"),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isCreditCard,
                                onChanged: (value) {
                                  setState(() {
                                    isCreditCard = !isCreditCard;
                                  });
                                },
                              ),
                              Text("Credit Card"),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: isDebitCard,
                                onChanged: (value) {
                                  setState(() {
                                    isDebitCard = !isDebitCard;
                                  });
                                },
                              ),
                              Text("Debit Card"),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: isCashOnDel,
                                onChanged: (value) {
                                  setState(() {
                                    isCashOnDel = !isCashOnDel;
                                  });
                                },
                              ),
                              Text("Cash On Delivery"),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Step(
                      isActive: stepperIndex == 2,
                      title: Text("Order Summary"),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Name: ${nameController.text}"),
                          Text("Address: ${addressController.text}"),
                          Text("Phone Number: ${phoneNoController.text}"),
                          Text("Total item: ${widget.items.length}"),
                          for (int i = 0; i < widget.items.length; i++)
                            Text(
                                "Item ${i + 1}: ${widget.items[i].itemName}; amount: ${widget.items[i].itemAmount}; quantity: ${widget.items[i].quantity}"),
                          Text("Total Amount: \$${totalAmount}"),
                        ],
                      ),
                    ),
                  ],
                  currentStep: stepperIndex,
                  onStepContinue: () async {
                    if (stepperIndex == 0) {
                      if (isValidName(nameController.text) &&
                          addressController.text.isNotEmpty &&
                          isValidPhoneNumber(phoneNoController.text)) {
                        stepperIndex = 1;
                        setState(() {});
                      }
                    } else if (stepperIndex == 1) {
                      if (isCreditCard || isDebitCard || isCashOnDel) {
                        stepperIndex = 2;
                        getTotalAmount();
                        setState(() {});
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Your Order has been placed"),
                        ),
                      );

                      for (int index = 0;
                          index < widget.items.length;
                          index++) {
                        DocumentSnapshot i = await FirebaseFirestore.instance
                            .collection("inventory")
                            .doc(widget.items[index].itemId)
                            .get();
                        await FirebaseFirestore.instance
                            .collection("inventory")
                            .doc(widget.items[index].itemId)
                            .update({
                          "quantity":
                              i.get("quantity") - widget.items[index].quantity,
                        });
                      }

                      await FirebaseFirestore.instance
                          .collection("orders")
                          .add({
                        "userId": FirebaseAuth.instance.currentUser!.uid,
                        "inventory":
                            widget.items.map((item) => item.toMap()).toList(),
                        "address": addressController.text,
                        "phoneNumber": phoneNoController.text,
                        "name": nameController.text,
                        "paymentType": isCashOnDel
                            ? "Cash on delivery"
                            : isCreditCard
                                ? "Credit card"
                                : "Debit card",
                        "status": "Placed",
                        "totalAmount": totalAmount,
                      }).then((value) {
                        changeScreenWithReplacement(context, HomePage());
                      });
                    }
                  },
                  onStepCancel: () {
                    if (stepperIndex > 0) {
                      stepperIndex--;
                      setState(() {});
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Footer(),
    );
  }
}
