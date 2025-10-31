import 'package:flutter/material.dart';

/// Common input field widget for adding thoughts
/// Follows Single Responsibility Principle - only handles thought input
/// Matches the original TextField design from editing_phase_widget
class ThoughtInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Color color;
  final VoidCallback onSubmit;
  final bool isLoading;
  final bool isSmallScreen;

  const ThoughtInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.color,
    required this.onSubmit,
    this.isLoading = false,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: !isLoading,
      minLines: 1,
      maxLines: 5,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: isSmallScreen ? 13 : 14,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: 12,
        ),
        suffixIcon: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isLoading ? Colors.grey : color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isLoading
              ? SizedBox(
                  width: isSmallScreen ? 20 : 24,
                  height: isSmallScreen ? 20 : 24,
                  child: Center(
                    child: SizedBox(
                      width: isSmallScreen ? 14 : 16,
                      height: isSmallScreen ? 14 : 16,
                      child: const CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: isSmallScreen ? 18 : 20,
                  ),
                  onPressed: onSubmit,
                ),
        ),
      ),
    );
  }
}
