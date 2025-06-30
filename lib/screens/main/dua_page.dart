import 'package:azkar_admin/screens/add/add_dua.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class DuaPage extends StatefulWidget {
  const DuaPage({super.key});

  @override
  State<DuaPage> createState() => _DuaPageState();
}

class _DuaPageState extends State<DuaPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingUrl;

  Stream<DurationState> get _durationState =>
      Rx.combineLatest2<Duration, Duration, DurationState>(
        _audioPlayer.positionStream,
        _audioPlayer.durationStream.map((d) => d ?? Duration.zero),
        (position, duration) =>
            DurationState(position: position, total: duration),
      );

  Future<void> togglePlayPause(String url) async {
    if (_currentlyPlayingUrl == url && _audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      if (_currentlyPlayingUrl != url) {
        await _audioPlayer.setUrl(url);
        _currentlyPlayingUrl = url;
      }
      await _audioPlayer.play();
    }
    setState(() {}); // update play/pause icon
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildAudioControls(String audioUrl) {
    bool isCurrent = _currentlyPlayingUrl == audioUrl;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _audioPlayer.playing && isCurrent
                    ? Icons.pause_circle
                    : Icons.play_circle,
                size: 36,
                color: Colors.green,
              ),
              onPressed: () => togglePlayPause(audioUrl),
            ),
          ],
        ),
        if (isCurrent)
          StreamBuilder<DurationState>(
            stream: _durationState,
            builder: (context, snapshot) {
              final durationState = snapshot.data;
              final position = durationState?.position ?? Duration.zero;
              final total = durationState?.total ?? Duration.zero;

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
                      _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                    },
                  ),
                  Text(
                    "${_formatDuration(position)} / ${_formatDuration(total)}",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

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
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
              return const Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.podcasts_outlined, size: 40),
                    SizedBox(height: 8),
                    Text("No posts available"),
                  ],
                ),
              );
            }

            var posts = snapshot.data!.docs;

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                var post = posts[index].data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 280,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Today's Dua",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              post['dua'] ?? '',
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12),
                            if (post['audio'] != null &&
                                post['audio'].toString().isNotEmpty)
                              _buildAudioControls(post['audio']),
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Confirm Delete"),
                                    content: Text(
                                      "Are you sure you want to delete this dua?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await FirebaseFirestore.instance
                                              .collection('dua')
                                              .doc(posts[index].id)
                                              .delete();
                                        },
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
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
