import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/sky_haven_models.dart';

class EditToolbarWidget extends StatelessWidget {
  final PlacedItem item;
  final VoidCallback? onMove;
  final VoidCallback? onRemove;
  final VoidCallback? onWhisper;
  final VoidCallback? onDone;
  final VoidCallback onScaleUp;
  final VoidCallback onScaleDown;
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final void Function(double)? onRotationChanged;
  final VoidCallback? onDuplicate;
  final VoidCallback? onBringForward;
  final VoidCallback? onSendBackward;
  final VoidCallback? onReset;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final bool isPlacementMode;

  const EditToolbarWidget({
    super.key,
    required this.item,
    required this.onScaleUp,
    required this.onScaleDown,
    required this.onRotateLeft,
    required this.onRotateRight,
    this.onRotationChanged,
    this.onMove,
    this.onRemove,
    this.onWhisper,
    this.onDone,
    this.onDuplicate,
    this.onBringForward,
    this.onSendBackward,
    this.onReset,
    this.onCancel,
    this.onConfirm,
    this.isPlacementMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isPlacementMode && onMove != null) ...[
                    _buildBtn(Icons.open_with_rounded, onMove!, 'Move'),
                    const SizedBox(width: 8),
                  ],
                  _buildBtn(Icons.remove_circle_outline, onScaleDown, 'Scale Down'),
                  _buildBtn(Icons.add_circle_outline, onScaleUp, 'Scale Up'),
                  const SizedBox(width: 8),
                  if (onReset != null) ...[
                    _buildBtn(Icons.settings_backup_restore_rounded, onReset!, 'Reset'),
                    const SizedBox(width: 8),
                  ],
                  if (onBringForward != null) _buildBtn(Icons.flip_to_front_rounded, onBringForward!, 'Bring Forward'),
                  if (onSendBackward != null) _buildBtn(Icons.flip_to_back_rounded, onSendBackward!, 'Send Backward'),
                  const SizedBox(width: 8),
                  _buildBtn(Icons.rotate_left_rounded, onRotateLeft, 'Rotate Left'),
                  _buildBtn(Icons.rotate_right_rounded, onRotateRight, 'Rotate Right'),
                  const SizedBox(width: 8),
                  if (!isPlacementMode) ...[
                    if (onDuplicate != null) ...[
                      _buildBtn(Icons.content_copy_rounded, onDuplicate!, 'Duplicate'),
                      const SizedBox(width: 8),
                    ],
                    if (onWhisper != null) ...[
                      _buildBtn(Icons.chat_bubble_outline_rounded, onWhisper!, 'Whisper'),
                      const SizedBox(width: 8),
                    ],
                    if (onRemove != null) ...[
                      _buildBtn(Icons.delete_outline_rounded, onRemove!, 'Remove', isDestructive: true),
                      const SizedBox(width: 8),
                    ],
                    if (onDone != null)
                      _buildBtn(Icons.check_circle_outline, onDone!, 'Done', colorOverride: Colors.greenAccent),
                  ] else ...[
                    if (onCancel != null) ...[
                      _buildBtn(Icons.close_rounded, onCancel!, 'Cancel', isDestructive: true),
                      const SizedBox(width: 8),
                    ],
                    if (onConfirm != null)
                      _buildBtn(Icons.check_rounded, onConfirm!, 'Confirm Placement', colorOverride: Colors.greenAccent),
                  ],
                ],
              ),
              // Bottom Row: Rotation Slider
              if (onRotationChanged != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.screen_rotation_rounded, color: Colors.white70, size: 16),
                    SizedBox(
                      width: 150,
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white30,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: item.rotation,
                          min: -math.pi,
                          max: math.pi,
                          onChanged: onRotationChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBtn(IconData icon, VoidCallback onTap, String tooltip, {bool isDestructive = false, Color? colorOverride}) {
    final color = colorOverride ?? (isDestructive ? Colors.redAccent : Colors.white);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
      ),
    );
  }
}
