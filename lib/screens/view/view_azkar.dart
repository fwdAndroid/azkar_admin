import 'package:azkar_admin/screens/add/add_azkars_page.dart';
import 'package:azkar_admin/widget/arabic_text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewAzkarPage extends StatelessWidget {
  final String azkarType;
  const ViewAzkarPage({super.key, required this.azkarType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) => AddAzkarPage(azkarType: azkarType),
            ),
          );
        },
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: ArabicText("View", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(azkarType)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: ArabicText("No Azkar found."));
            }

            final azkarList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: azkarList.length,
              itemBuilder: (context, index) {
                return AzkarCard(
                  azkar: azkarList[index].data() as Map<String, dynamic>,
                  docId: azkarList[index].id,
                  azkarType: azkarType,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AzkarCard extends StatefulWidget {
  final Map<String, dynamic> azkar;
  final String docId;
  final String azkarType;

  const AzkarCard({
    super.key,
    required this.azkar,
    required this.docId,
    required this.azkarType,
  });

  @override
  State<AzkarCard> createState() => _AzkarCardState();
}

class _AzkarCardState extends State<AzkarCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ArabicText(
                widget.azkar['dua'] ?? '',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Confirm Delete"),
                        content: Text(
                          "Are you sure you want to delete this Azkar?",
                        ),
                        actions: [
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          TextButton(
                            child: Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await FirebaseFirestore.instance
                          .collection(widget.azkarType)
                          .doc(widget.docId)
                          .delete();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Azkar deleted successfully."),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
