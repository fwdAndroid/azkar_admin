import 'package:azkar_admin/screens/add/add_dua.dart';
import 'package:azkar_admin/widget/arabic_text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DuaPage extends StatelessWidget {
  const DuaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (builder) => AddDua()),
          );
        },
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('dua').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: ArabicText("No Duas Available"));
            }

            var posts = snapshot.data!.docs;

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                var post = posts[index].data() as Map<String, dynamic>;
                var docId = posts[index].id;

                return DuaCard(post: post, docId: docId);
              },
            );
          },
        ),
      ),
    );
  }
}

class DuaCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final String docId;

  const DuaCard({super.key, required this.post, required this.docId});

  @override
  State<DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<DuaCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ArabicText(
              "Today's Dua",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ArabicText(
              widget.post['dua'] ?? '',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),

            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('dua')
                    .doc(widget.docId)
                    .delete();
              },
              child: ArabicText("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

class DurationState {
  final Duration position;
  final Duration total;

  DurationState({required this.position, required this.total});
}
