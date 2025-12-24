import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game.dart';

// Star model for the animated background
class Star {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class LeaderboardScreen extends StatefulWidget {
  final List<PlayerScore> leaderboard;
  final String? roomId;
  final bool showBackToLobby;

  const LeaderboardScreen({
    super.key,
    required this.leaderboard,
    this.roomId,
    this.showBackToLobby = true,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<Star> _stars;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _stars = _generateStars(50);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _animController.addListener(_updateStars);
  }

  List<Star> _generateStars(int count) {
    return List.generate(count, (_) => _createStar(randomY: true));
  }

  Star _createStar({bool randomY = false}) {
    return Star(
      x: _random.nextDouble(),
      y: randomY ? _random.nextDouble() : 0,
      size: _random.nextDouble() * 3 + 1,
      speed: _random.nextDouble() * 0.003 + 0.001,
      opacity: _random.nextDouble() * 0.6 + 0.4,
    );
  }

  void _updateStars() {
    setState(() {
      for (var star in _stars) {
        star.y += star.speed;
        star.x += (sin(star.y * 10) * 0.0005);
        if (star.y > 1) {
          star.y = 0;
          star.x = _random.nextDouble();
          star.opacity = _random.nextDouble() * 0.6 + 0.4;
        }
        if (star.x < 0) star.x = 1;
        if (star.x > 1) star.x = 0;
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF05396B), Color(0xFF0E5F88)],
              ),
            ),
          ),
          // Animated stars
          CustomPaint(
            painter: StarsPainter(stars: _stars),
            size: Size.infinite,
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Podium for top 3
                  if (widget.leaderboard.isNotEmpty) _buildPodium(),

                  const SizedBox(height: 24),

                  // Full leaderboard
                  Expanded(child: _buildLeaderboardList()),

                  const SizedBox(height: 16),

                  // Back button
                  if (widget.showBackToLobby) _buildBackButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Trophy animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: const Text('🏆', style: TextStyle(fontSize: 64)),
        ),
        const SizedBox(height: 8),
        Text(
          'Final Results',
          style: GoogleFonts.comicNeue(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Congratulations to all players!',
          style: GoogleFonts.comicNeue(
            color: const Color(0xFFB0B0B0),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildPodium() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place
        if (widget.leaderboard.length > 1)
          _buildPodiumPlace(widget.leaderboard[1], 2, 90)
        else
          const SizedBox(width: 100),

        const SizedBox(width: 8),

        // 1st place
        if (widget.leaderboard.isNotEmpty)
          _buildPodiumPlace(widget.leaderboard[0], 1, 120),

        const SizedBox(width: 8),

        // 3rd place
        if (widget.leaderboard.length > 2)
          _buildPodiumPlace(widget.leaderboard[2], 3, 70)
        else
          const SizedBox(width: 100),
      ],
    );
  }

  Widget _buildPodiumPlace(PlayerScore player, int place, double height) {
    final colors = {
      1: const Color(0xFFFFD700), // Gold
      2: const Color(0xFFC0C0C0), // Silver
      3: const Color(0xFFCD7F32), // Bronze
    };

    final crownEmoji = place == 1 ? '👑' : '';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (place * 200)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          alignment: Alignment.bottomCenter,
          child: child,
        );
      },
      child: Column(
        children: [
          // Crown for 1st place
          if (place == 1)
            Text(crownEmoji, style: const TextStyle(fontSize: 24)),

          // Avatar
          Container(
            width: place == 1 ? 70 : 55,
            height: place == 1 ? 70 : 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors[place]!, width: 4),
              color: const Color(0xFF0E5F88),
              boxShadow: [
                BoxShadow(
                  color: colors[place]!.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: player.avatar != null
                ? ClipOval(
                    child: Image.asset(
                      'lib/assets/${player.avatar}',
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      player.name.isNotEmpty
                          ? player.name[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.comicNeue(
                        color: Colors.white,
                        fontSize: place == 1 ? 28 : 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),

          // Name
          SizedBox(
            width: 100,
            child: Text(
              player.name,
              style: GoogleFonts.comicNeue(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),

          // Podium block
          Container(
            width: 100,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors[place]!, colors[place]!.withOpacity(0.7)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border.all(
                color: colors[place]!.withOpacity(0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors[place]!.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$place',
                  style: GoogleFonts.comicNeue(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${player.score} pts',
                    style: GoogleFonts.comicNeue(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A4A6F).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF22D3EE).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: widget.leaderboard.length,
          separatorBuilder: (_, __) => Divider(
            color: const Color(0xFF22D3EE).withOpacity(0.2),
            height: 1,
          ),
          itemBuilder: (context, index) {
            final player = widget.leaderboard[index];
            return _buildLeaderboardRow(player, index + 1);
          },
        ),
      ),
    );
  }

  Widget _buildLeaderboardRow(PlayerScore player, int rank) {
    final isTopThree = rank <= 3;
    final rankColors = {
      1: const Color(0xFFFFD700),
      2: const Color(0xFFC0C0C0),
      3: const Color(0xFFCD7F32),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Rank
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTopThree
                  ? rankColors[rank]!.withOpacity(0.2)
                  : const Color(0xFF0E5F88),
              border: isTopThree
                  ? Border.all(color: rankColors[rank]!, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: GoogleFonts.comicNeue(
                  color: isTopThree ? rankColors[rank]! : Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0E5F88),
              border: Border.all(
                color: const Color(0xFF22D3EE).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: player.avatar != null
                ? ClipOval(
                    child: Image.asset(
                      'lib/assets/${player.avatar}',
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      player.name.isNotEmpty
                          ? player.name[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.comicNeue(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(
              player.name,
              style: GoogleFonts.comicNeue(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2DD4BF), Color(0xFF6366F1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${player.score} pts',
                  style: GoogleFonts.comicNeue(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${player.correctAnswers}/${player.totalAnswered} correct',
                style: GoogleFonts.comicNeue(
                  color: const Color(0xFFB0B0B0),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD9A223), Color(0xFFB8891D)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD9A223), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD9A223).withOpacity(0.4),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.home_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Text(
                  'BACK TO LOBBY',
                  style: GoogleFonts.comicNeue(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for rendering animated stars
class StarsPainter extends CustomPainter {
  final List<Star> stars;

  StarsPainter({required this.stars});

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(star.opacity)
        ..style = PaintingStyle.fill;

      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(star.opacity * 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      final x = star.x * size.width;
      final y = star.y * size.height;

      canvas.drawCircle(Offset(x, y), star.size * 2, glowPaint);
      canvas.drawCircle(Offset(x, y), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarsPainter oldDelegate) => true;
}
