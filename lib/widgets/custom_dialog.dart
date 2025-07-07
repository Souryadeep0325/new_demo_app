import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final double maxWidth;
  final bool showCloseButton;
  final EdgeInsets? contentPadding;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.maxWidth = 600,
    this.showCloseButton = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  if (showCloseButton)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: contentPadding ?? const EdgeInsets.all(24),
                  child: content,
                ),
              ),
            ),
            // Actions
            if (actions != null) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Reusable dialog button styles
class DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDestructive;
  final bool isLoading;
  final IconData? icon;

  const DialogButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final buttonStyle = isPrimary
        ? ElevatedButton.styleFrom(
            backgroundColor: isDestructive
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          )
        : TextButton.styleFrom(
            foregroundColor: isDestructive
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          );

    Widget buttonChild = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(label),
            ],
          )
        : Text(label);

    final button = isPrimary
        ? ElevatedButton(
            style: buttonStyle,
            onPressed: isLoading ? null : onPressed,
            child: buttonChild,
          )
        : TextButton(
            style: buttonStyle,
            onPressed: isLoading ? null : onPressed,
            child: buttonChild,
          );

    return isLoading
        ? Stack(
            alignment: Alignment.center,
            children: [
              button,
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          )
        : button;
  }
}

// Info Section Widget for displaying grouped information
class InfoSection extends StatelessWidget {
  final String title;
  final List<InfoRow> rows;
  final bool hasDivider;

  const InfoSection({
    super.key,
    required this.title,
    required this.rows,
    this.hasDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...rows,
        if (hasDivider) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

// Info Row Widget for displaying label-value pairs
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;
  final bool copyable;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isHighlighted = false,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isHighlighted ? FontWeight.bold : null,
                      color: isHighlighted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onBackground,
                    ),
                  ),
                ),
                if (copyable)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$label copied!')),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 