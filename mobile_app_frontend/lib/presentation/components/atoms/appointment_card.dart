import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/custom_button.dart';

class AppointmentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0x302e31), // Background color of the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners
      ),
      elevation: 4, // Adds a slight shadow effect
      child: Container(
        width: 360, // Set a fixed width for the card
        padding: EdgeInsets.all(16), // Padding inside the card
        decoration: BoxDecoration(
          color: const Color.fromARGB(
              144, 120, 120, 117), // Background color of the card
          borderRadius: BorderRadius.circular(15), // Rounded corners
          border: Border.all(
              color: const Color.fromARGB(144, 120, 120, 117)
                  .withOpacity(0.5)), // Light border
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align items to the left
          mainAxisSize:
              MainAxisSize.min, // Wrap content without taking extra space
          children: [
            // Row for "Janaka Motors" with Home Icon
            Row(
              children: [
                Icon(Icons.home, color: Colors.white, size: 18), // Home icon
                SizedBox(width: 8), // Space between icon and text
                Text(
                  "Janaka Motors",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8), // Space between rows

            // Row for Date with Clock Icon
            Row(
              children: [
                Icon(Icons.access_time,
                    color: Colors.white, size: 18), // Clock icon
                SizedBox(width: 8),
                Text(
                  "Sat, Feb, 2025",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 12), // Space before button

            // Placeholder for the button component
            Align(
              alignment: Alignment.centerRight, // Align button to the right
              child: CustomButton(), // Calling the separate button component
            ),
          ],
        ),
      ),
    );
  }
}
