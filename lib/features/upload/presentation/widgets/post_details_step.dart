import 'package:flutter/material.dart';
import 'package:reevo/core/theme/color.dart';
import 'package:reevo/features/upload/presentation/widgets/schedule_picker_widget.dart';

/// Step 2: Post details, privacy settings, and schedule upload
class PostDetailsStep extends StatelessWidget {
  final String description;
  final String visibility;
  final bool allowComments;
  final bool hostWatchTogether;
  final bool isScheduled;
  final DateTime? scheduledDateTime;
  final bool isUploading;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onVisibilityChanged;
  final VoidCallback onToggleComments;
  final VoidCallback onToggleWatchTogether;
  final VoidCallback onToggleSchedule;
  final ValueChanged<DateTime> onScheduleDateTimeChanged;
  final VoidCallback onSubmit;

  const PostDetailsStep({
    super.key,
    required this.description,
    required this.visibility,
    required this.allowComments,
    required this.hostWatchTogether,
    required this.isScheduled,
    this.scheduledDateTime,
    required this.isUploading,
    required this.onDescriptionChanged,
    required this.onVisibilityChanged,
    required this.onToggleComments,
    required this.onToggleWatchTogether,
    required this.onToggleSchedule,
    required this.onScheduleDateTimeChanged,
    required this.onSubmit,
  });

  String _getVisibilityLabel(String value) {
    switch (value) {
      case 'friends':
        return 'Friends';
      case 'only_me':
        return 'Only Me';
      default:
        return 'Everyone';
    }
  }

  void _showVisibilityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Who can watch',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _buildVisibilityOption(
                  context,
                  'everyone',
                  'Everyone',
                  Icons.public_rounded,
                  'Anyone can watch this video',
                ),
                _buildVisibilityOption(
                  context,
                  'friends',
                  'Friends',
                  Icons.people_rounded,
                  'Only your friends can watch',
                ),
                _buildVisibilityOption(
                  context,
                  'only_me',
                  'Only Me',
                  Icons.lock_rounded,
                  'Only you can watch this video',
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisibilityOption(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = visibility == value;
    return GestureDetector(
      onTap: () {
        onVisibilityChanged(value);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.brand.withOpacity(0.1)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: AppColors.brand.withOpacity(0.4), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.brand : AppColors.grey3,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? AppColors.brand : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.grey3,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.brand,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Description + Cover row
          _buildDescriptionAndCover(),

          const SizedBox(height: 8),

          // Divider
          Divider(color: AppColors.grey5, height: 1, indent: 16, endIndent: 16),

          // Add Location
          _buildSettingRow(
            icon: Icons.location_on_outlined,
            title: 'Add Location',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: AppColors.grey3,
              size: 22,
            ),
            onTap: () {},
          ),

          Divider(color: AppColors.grey5, height: 1, indent: 16, endIndent: 16),

          // Who can watch
          _buildSettingRow(
            icon: Icons.public_rounded,
            title: 'Who can watch',
            subtitle: _getVisibilityLabel(visibility),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: AppColors.grey3,
              size: 22,
            ),
            onTap: () => _showVisibilityPicker(context),
          ),

          Divider(color: AppColors.grey5, height: 1, indent: 16, endIndent: 16),

          // Allow comments
          _buildSettingRow(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Allow comments',
            trailing: Switch(
              value: allowComments,
              onChanged: (_) => onToggleComments(),
              activeColor: AppColors.brand,
              activeTrackColor: AppColors.brand.withOpacity(0.3),
              inactiveThumbColor: AppColors.grey3,
              inactiveTrackColor: AppColors.grey5,
            ),
          ),

          Divider(color: AppColors.grey5, height: 1, indent: 16, endIndent: 16),

          // Host Watch Together
          _buildSettingRow(
            icon: Icons.live_tv_rounded,
            title: 'Host Watch Together',
            subtitle: 'Start a live room immediately',
            trailing: Switch(
              value: hostWatchTogether,
              onChanged: (_) => onToggleWatchTogether(),
              activeColor: AppColors.brand,
              activeTrackColor: AppColors.brand.withOpacity(0.3),
              inactiveThumbColor: AppColors.grey3,
              inactiveTrackColor: AppColors.grey5,
            ),
          ),

          Divider(color: AppColors.grey5, height: 1, indent: 16, endIndent: 16),

          // Schedule Upload
          SchedulePickerWidget(
            isScheduled: isScheduled,
            scheduledDateTime: scheduledDateTime,
            onToggle: onToggleSchedule,
            onDateTimeChanged: onScheduleDateTimeChanged,
          ),

          const SizedBox(height: 24),

          // Post / Schedule button
          _buildSubmitButton(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDescriptionAndCover() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description text field
          Expanded(
            child: TextField(
              onChanged: onDescriptionChanged,
              maxLines: 4,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: 'Describe your vibe... #tags @friends',
                hintStyle: TextStyle(
                  color: AppColors.grey3,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Cover image thumbnail
          Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0A2647),
                      Color(0xFF1B2838),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.brand.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brand.withOpacity(0.1),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Mock thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: CustomPaint(
                        size: const Size(100, 100),
                        painter: _CoverThumbnailPainter(),
                      ),
                    ),
                    // Edit Cover overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(11),
                          ),
                        ),
                        child: const Text(
                          'Edit Cover',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey5,
              ),
              child: Icon(icon, color: AppColors.grey2, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.grey3,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final buttonText = isScheduled ? 'Schedule' : 'Post';
    final buttonIcon = isScheduled ? Icons.schedule_rounded : Icons.send_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isUploading ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brand,
            foregroundColor: Colors.black,
            disabledBackgroundColor: AppColors.brand.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: isUploading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.black,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(buttonIcon, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Paints a simple mock cover thumbnail
class _CoverThumbnailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Night sky gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0D1B2A),
          Color(0xFF1B3A5C),
          Color(0xFF0A1628),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Building silhouettes
    final buildingPaint = Paint()
      ..color = const Color(0xFF0A1220)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.5);
    path.lineTo(size.width * 0.12, size.height * 0.5);
    path.lineTo(size.width * 0.12, size.height * 0.35);
    path.lineTo(size.width * 0.25, size.height * 0.35);
    path.lineTo(size.width * 0.25, size.height * 0.55);
    path.lineTo(size.width * 0.38, size.height * 0.55);
    path.lineTo(size.width * 0.38, size.height * 0.25);
    path.lineTo(size.width * 0.52, size.height * 0.25);
    path.lineTo(size.width * 0.52, size.height * 0.45);
    path.lineTo(size.width * 0.65, size.height * 0.45);
    path.lineTo(size.width * 0.65, size.height * 0.3);
    path.lineTo(size.width * 0.78, size.height * 0.3);
    path.lineTo(size.width * 0.78, size.height * 0.5);
    path.lineTo(size.width * 0.9, size.height * 0.5);
    path.lineTo(size.width * 0.9, size.height * 0.4);
    path.lineTo(size.width, size.height * 0.4);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, buildingPaint);

    // Window lights
    final lightPaint = Paint()
      ..color = AppColors.brand.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 8; i++) {
      final x = (i * size.width / 8) + size.width / 16;
      final y = size.height * 0.5 + (i % 3) * 6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: 2, height: 2),
          const Radius.circular(1),
        ),
        lightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
