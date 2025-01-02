import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FilterButton extends StatefulWidget {
  final String label;
  final Function(String) onPressed;
  final double width; // Width of the button
  final double height; // Height of the button

  const FilterButton({
    required this.label,
    required this.onPressed,
    this.width = 100, // Adjusted default width
    this.height = 30, // Adjusted default height
    Key? key,
  }) : super(key: key);

  @override
  _FilterButtonState createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  bool isSelected = false;
  void _toggleSelection() {
    setState(() {
      isSelected = !isSelected;
    });
    widget.onPressed(widget.label);
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: _toggleSelection,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), // Full-rounded corners
            gradient: isSelected
                ? const LinearGradient(
              colors: [Color(0x1D2E26), Color(0x789EB6)],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            )
                : null,
            color: isSelected ? null : Colors.white, // White background when unselected
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey[400]!,
              width: 1, // Border for unselected state
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 2), // Slight shadow for selected state
              ),
            ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[800],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

bool isGuestUser() {
  final user = FirebaseAuth.instance.currentUser;

  // Check if user is null (no logged-in user) or a temporary guest session
  return user == null || user.isAnonymous;
}
