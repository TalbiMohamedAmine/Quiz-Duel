import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_screen.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  void _openAuth(BuildContext context) {
    Navigator.of(context).pushNamed(AuthScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF05396B), Color(0xFF0E5F88)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with profile button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9A223),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFB8891D),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFD9A223,
                            ).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _openAuth(context),
                          borderRadius: BorderRadius.circular(16),
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Logo and title section
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Logo - sized appropriately
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'lib/assets/quizzly_logo.png',
                        height: 520,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback if logo is not found
                          return Container(
                            height: 220,
                            width: 220,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4BA4FF),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.quiz_rounded,
                              size: 110,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      'Challenge your friends!',
                      style: GoogleFonts.comicNeue(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE0E0E0),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Menu buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Column(
                        children: [
                          _buildMenuButton(
                            context,
                            icon: Icons.add_circle_rounded,
                            label: 'Create Game',
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushNamed(CreateRoomScreen.routeName);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildMenuButton(
                            context,
                            icon: Icons.group_add_rounded,
                            label: 'Join Game',
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushNamed(JoinRoomScreen.routeName);
                            },
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),
                  ],
                ),
              ),

              // Footer with accent yellow
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFD9A223),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Text(
                  '🎄 Happy Holidays! 🎄',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.comicNeue(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 200,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF262B35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF111319), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: const Color(0xFF4BA4FF), size: 24),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: GoogleFonts.comicNeue(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
