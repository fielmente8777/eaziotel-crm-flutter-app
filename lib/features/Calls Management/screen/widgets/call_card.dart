import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';

import '../../models/call_model.dart';

/// Ek call ka card (web table ki ek row).
class CallCard extends StatelessWidget {
  final int index; // 0 se
  final CallModel call;
  final bool isPlaying;
  final bool isRecordingLoading;
  final bool isWhatsappLoading;
  final VoidCallback onWhatsapp;
  final VoidCallback onCall;
  final VoidCallback onToggleRecording;
  final void Function(CallField field, String value) onFieldChanged;

  const CallCard({
    super.key,
    required this.index,
    required this.call,
    required this.isPlaying,
    this.isRecordingLoading = false,
    this.isWhatsappLoading = false,
    required this.onWhatsapp,
    required this.onCall,
    required this.onToggleRecording,
    required this.onFieldChanged,
  });

  static const Color _incoming = Color(0xFFEF4444);
  static const Color _outgoing = Color(0xFF16B981);

  Color get _statusColor {
    if (call.isSuccessful) return TAppColors.success;
    if (call.isFailed) return TAppColors.error;
    return TAppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? TAppColors.darkCard : TAppColors.lightCard;
    final border = isDark ? TAppColors.darkBorder : TAppColors.lightBorder;
    final text = isDark ? TAppColors.darkText : TAppColors.lightText;
    final subText = isDark
        ? TAppColors.darkSecondaryText
        : TAppColors.lightSecondaryText;

    final directionColor = call.isIncoming ? _incoming : _outgoing;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- #, direction, time ----------
          Row(
            children: [
              Text(
                (index + 1).toString().padLeft(2, '0'),
                style: TextStyle(
                  color: subText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              _chip(
                label: call.directionLabel,
                color: directionColor,
                icon: call.isIncoming ? Icons.call_received : Icons.call_made,
              ),
              const Spacer(),
              Text(
                call.timeAgo,
                style: TextStyle(color: subText, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ---------- From -> To ----------
          Row(
            children: [
              Expanded(
                child: _party(
                  label: 'From',
                  value: call.isIncoming && call.callerName != null
                      ? call.callerName!
                      : call.from,
                  text: text,
                  subText: subText,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 18, color: subText),
              ),
              Expanded(
                child: _party(
                  label: 'To',
                  value: !call.isIncoming && call.callerName != null
                      ? call.callerName!
                      : call.to,
                  text: text,
                  subText: subText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ---------- Status, duration, hotel number ----------
          Wrap(
            spacing: 14,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _info(Icons.circle, call.statusLabel, _statusColor, iconSize: 8),
              _info(Icons.timer_outlined, call.durationLabel, subText),
              if (call.phoneNumber.isNotEmpty)
                _info(Icons.dialpad, call.phoneNumber, subText),
            ],
          ),

          const SizedBox(height: 12),

          // ---------- Segregation / guest type / priority / stage ----------
          Row(
            children: [
              Expanded(
                child: _dropdown(
                  CallField.segregation,
                  cardColor,
                  border,
                  text,
                  subText,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dropdown(
                  CallField.guestType,
                  cardColor,
                  border,
                  text,
                  subText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _dropdown(
                  CallField.priority,
                  cardColor,
                  border,
                  text,
                  subText,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dropdown(
                  CallField.stage,
                  cardColor,
                  border,
                  text,
                  subText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Divider(height: 1, color: border),

          const SizedBox(height: 8),

          // ---------- Actions ----------
          Row(
            children: [
              _action(
                icon: Icons.chat_outlined,
                label: isWhatsappLoading ? 'Opening...' : 'WhatsApp',
                color: TAppColors.whatsappLight,
                onTap: onWhatsapp,
              ),
              _action(
                icon: Icons.call_outlined,
                label: 'Call',
                color: TAppColors.primary,
                onTap: onCall,
              ),
              if (call.hasRecording)
                _action(
                  icon: isRecordingLoading
                      ? Icons.downloading_outlined
                      : isPlaying
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline,
                  label: isRecordingLoading
                      ? 'Loading...'
                      : isPlaying
                      ? 'Stop'
                      : 'Recording',
                  color: TAppColors.info,
                  onTap: onToggleRecording,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PIECES
  // ============================================================

  Widget _chip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _party({
    required String label,
    required String value,
    required Color text,
    required Color subText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: subText, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? '-' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: text,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _info(
    IconData icon,
    String label,
    Color color, {
    double iconSize = 14,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: color),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: color, fontSize: 12.5)),
      ],
    );
  }

  Widget _dropdown(
    CallField field,
    Color cardColor,
    Color border,
    Color text,
    Color subText,
  ) {
    final value = call.valueOf(field);

    // API se koi aisi value aaye jo list me nahi hai to use bhi dikhao
    final options = [
      ...field.options,
      if (value != null && !field.options.contains(value)) value,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label, style: TextStyle(color: subText, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              isDense: true,
              dropdownColor: cardColor,
              borderRadius: BorderRadius.circular(10),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: subText,
              ),
              hint: Text(
                'Select',
                style: TextStyle(color: subText, fontSize: 13),
              ),
              style: TextStyle(
                color: text,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              items: [
                for (final option in options)
                  DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      field.display(option),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (selected) {
                if (selected == null || selected == value) return;

                onFieldChanged(field, selected);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
