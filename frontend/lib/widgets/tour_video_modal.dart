import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class TourVideoModal extends StatefulWidget {
  final String videoUrl;

  const TourVideoModal({
    super.key,
    this.videoUrl = 'https://res.cloudinary.com/itzarxmc/video/upload/f_auto,q_auto/v1785392743/Video_Project_1_dlrrlr.mp4',
  });

  @override
  State<TourVideoModal> createState() => _TourVideoModalState();
}

class _TourVideoModalState extends State<TourVideoModal> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _videoController!,
              aspectRatio: 16 / 9,
              autoPlay: false,
              looping: true,
              showControls: true,
              showControlsOnInitialize: false, // Hides playback speed/rewind/fastforward indicators initially
              allowFullScreen: true,
              allowPlaybackSpeedChanging: true, // Playback speed controls
              additionalOptions: (context) => [
                OptionItem(
                  onTap: (context) async {
                    Navigator.pop(context); // Close the option panel sheet
                    try {
                      final Uri url = Uri.parse(widget.videoUrl);
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } catch (e) {
                      debugPrint("Failed to launch video URL: $e");
                    }
                  },
                  iconData: Icons.download_rounded,
                  title: 'Download Video',
                ),
              ],
              materialProgressColors: ChewieProgressColors(
                playedColor: const Color(0xFF8A2E55),
                handleColor: const Color(0xFFCA366C),
                backgroundColor: Colors.white24,
                bufferedColor: Colors.white54,
              ),
              placeholder: Container(
                color: const Color(0xFF090204),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8A2E55)),
                  ),
                ),
              ),
              errorBuilder: (context, errorMessage) {
                return Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            );
            _isInitialized = true;
          });
        }
      }).catchError((error) {
        debugPrint('Video player initialization failed: $error');
      });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _markTourAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_tour', true);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF090204).withOpacity(0.95), // Match app's dark background
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            border: Border.all(
              color: const Color(0xFF8A2E55).withOpacity(0.20), // Matches app CTA theme
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8A2E55).withOpacity(0.08),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Indicator bar
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Immersive Video Area using Chewie Player
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF8A2E55).withOpacity(0.3), // Matches app CTA theme
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8A2E55).withOpacity(0.10),
                        blurRadius: 25,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: _isInitialized && _chewieController != null
                        ? Chewie(controller: _chewieController!)
                        : const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8A2E55)),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title and Subtitle Column (No outer download button)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  // Video Title
                  Text(
                    "Discover Bonding",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE8C6D3), // Elegant theme rose text
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Subtitle without the word "space"
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "A quick video tour showcasing how to build closeness and stay connected.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 13,
                        color: Color(0xFF8B6774), // Cozy theme dark rose
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Got it, Let's go Button matching theme perfectly
              ElevatedButton(
                onPressed: () async {
                  await _markTourAsSeen();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF8A2E55), // Matches your app CTA color exactly
                  shadowColor: const Color(0xFF8A2E55).withOpacity(0.4),
                  elevation: 6,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28), // Rounded button
                  ),
                ),
                child: const Text(
                  "Got it, Let's go!",
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
