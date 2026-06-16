import sys

# read old sanctuary
with open('old_sanctuary_utf8.dart', 'r', encoding='utf-8') as f:
    old_lines = f.readlines()

# extract classes
classes = ''.join(old_lines[134:338])

# read current sanctuary
with open('frontend/lib/widgets/living_sanctuary_section.dart', 'r', encoding='utf-8') as f:
    current_content = f.read()

# Append classes
current_content += '\n' + classes

# Update class declaration
current_content = current_content.replace(
    '  final bool isActiveSeparation;\n  const LivingSanctuarySection({super.key, required this.isActiveSeparation});',
    '  final bool isActiveSeparation;\n  final bool hasPartner;\n  const LivingSanctuarySection({super.key, required this.isActiveSeparation, this.hasPartner = false});'
)

# Also need to import JoinWithCodeScreen if it was removed
if "import '../screens/join_with_code_screen.dart';" not in current_content:
    current_content = current_content.replace(
        "import '../screens/history_screen.dart';",
        "import '../screens/history_screen.dart';\nimport '../screens/join_with_code_screen.dart';"
    )

# Update build method to include the buttons
new_build = """            // ── TOP BUTTONS ──
            Row(
              children: [
                Expanded(
                  child: _FloatingPillButton(
                    title: "Begin a New Journey",
                    icon: Icons.add,
                    isPrimary: true,
                    breathingController: _breathingController,
                    onTap: () {
                      if (widget.isActiveSeparation) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("You are already in an active separation journey."),
                            backgroundColor: const Color(0xFF911746),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SeparationStep1IntentionScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FloatingPillButton(
                    title: "Shared Memories",
                    icon: Icons.history,
                    isPrimary: false,
                    breathingController: _breathingController,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── CONNECTION PORTAL (Join) ──
            if (!widget.hasPartner) ...[
              _ConnectionPortalBar(
                driftController: _ambientDriftController,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JoinWithCodeScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // ── THE QUOTE CARD SANCTUARY ──"""

current_content = current_content.replace('            // ── THE QUOTE CARD SANCTUARY ──', new_build)

with open('frontend/lib/widgets/living_sanctuary_section.dart', 'w', encoding='utf-8') as f:
    f.write(current_content)

print('Done')
