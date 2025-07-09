import 'package:azkar_admin/widget/arabic_text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AddAzkarPage extends StatefulWidget {
  final String azkarType; // e.g., 'morning', 'evening', etc.
  const AddAzkarPage({super.key, required this.azkarType});

  @override
  State<AddAzkarPage> createState() => _AddAzkarPageState();
}

class _AddAzkarPageState extends State<AddAzkarPage> {
  final TextEditingController _duaController = TextEditingController();
  bool _isLoading = false;
  var uuid = Uuid().v4();

  Future<void> _addAzkar() async {
    final text = _duaController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection(widget.azkarType)
          .doc(uuid)
          .set({"dua": text, "timestamp": Timestamp.now(), "uuid": uuid});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: ArabicText("Added to ${widget.azkarType}")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: ArabicText("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ArabicText("Add ${widget.azkarType} Azkar"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _duaController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Enter azkar text...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _addAzkar,
                    icon: Icon(Icons.save),
                    label: ArabicText("Save"),
                  ),
          ],
        ),
      ),
    );
  }
}
