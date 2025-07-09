import 'package:azkar_admin/screens/main/main_dashboard.dart';
import 'package:azkar_admin/screens/utils/show_message.dart';
import 'package:azkar_admin/widget/arabic_text_widget.dart';
import 'package:azkar_admin/widget/save_button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AddDua extends StatefulWidget {
  const AddDua({super.key});

  @override
  State<AddDua> createState() => _AddDuaState();
}

class _AddDuaState extends State<AddDua> {
  TextEditingController nameController = TextEditingController();
  bool _isLoading = false;
  var uuid = Uuid().v4();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _saveDua() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection("dua").doc(uuid).set({
        "uuid": uuid,
        "dua": nameController.text.trim(),
      });

      showMessageBar("Dua Added", context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainDashboard()),
      );
    } catch (e) {
      showMessageBar("Failed to add Dua", context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          title: ArabicText("Add Dua", style: TextStyle(color: Colors.white)),
        ),
        body: Stack(
          children: [
            Image.asset(
              "assets/bg.png",
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
            ),
            SingleChildScrollView(
              padding: EdgeInsets.only(top: kToolbarHeight + 32),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset("assets/logo.png", height: 200),
                  ),
                  // Dua Input Field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Add Today's Dua",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  // Audio Selector
                ],
              ),
            ),

            // Save Button
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1D3B2A),
                        ),
                      )
                    : SaveButton(title: "Add Dua", onTap: _saveDua),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
