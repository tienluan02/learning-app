import 'package:flutter/material.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/containers/primary_container.dart';

class MessageField extends StatefulWidget {
  const MessageField({
    required this.onSend,
    super.key,
  });

  final Future<void> Function(String message) onSend;

  @override
  State<MessageField> createState() => _MessageFieldState();
}

class _MessageFieldState extends State<MessageField> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      await widget.onSend(text);
      if (mounted) {
        _controller.clear();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.twentyVertical),
      decoration: BoxDecoration(
        color: AppColors.kPrimary.withValues(
          alpha: (0.41 * 255).round().toDouble(),
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusThirty),
        ),
      ),
      child: PrimaryContainer(
        child: TextFormField(
          controller: _controller,
          textInputAction: TextInputAction.send,
          onFieldSubmitted: (_) {
            _handleSend();
          },
          decoration: InputDecoration(
            hintText: 'Type a message',
            suffixIcon: IconButton(
              onPressed: _isSending ? null : _handleSend,
              icon: Icon(
                _isSending ? Icons.hourglass_top : Icons.send,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
