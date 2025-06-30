import 'package:azkar_admin/screens/add/add_dua.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

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
              return const Center(child: Text("No Duas Available"));
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
  late AudioPlayer _player;
  bool _isPlaying = false;

  Stream<DurationState> get _durationState =>
      Rx.combineLatest2<Duration, Duration, DurationState>(
        _player.positionStream,
        _player.durationStream.map((d) => d ?? Duration.zero),
        (position, duration) =>
            DurationState(position: position, total: duration ?? Duration.zero),
      );

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    if (widget.post['audio'] != null &&
        widget.post['audio'].toString().isNotEmpty) {
      try {
        await _player.setUrl(widget.post['audio']);
      } catch (e) {
        print("Audio error: $e");
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }

    setState(() {
      _isPlaying = _player.playing;
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }

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
            Text(
              "Today's Dua",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              widget.post['dua'] ?? '',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (widget.post['audio'] != null &&
                widget.post['audio'].toString().isNotEmpty)
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause_circle : Icons.play_circle,
                      size: 36,
                      color: Colors.green,
                    ),
                    onPressed: _togglePlay,
                  ),
                  StreamBuilder<DurationState>(
                    stream: _durationState,
                    builder: (context, snapshot) {
                      final data = snapshot.data;
                      final position = data?.position ?? Duration.zero;
                      final total = data?.total ?? Duration.zero;

                      return Column(
                        children: [
                          Slider(
                            activeColor: Colors.green,
                            inactiveColor: Colors.grey,
                            min: 0.0,
                            max: total.inMilliseconds.toDouble(),
                            value: position.inMilliseconds
                                .clamp(0, total.inMilliseconds)
                                .toDouble(),
                            onChanged: (value) {
                              _player.seek(
                                Duration(milliseconds: value.toInt()),
                              );
                            },
                          ),
                          Text(
                            "${_formatDuration(position)} / ${_formatDuration(total)}",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('dua')
                    .doc(widget.docId)
                    .delete();
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
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
