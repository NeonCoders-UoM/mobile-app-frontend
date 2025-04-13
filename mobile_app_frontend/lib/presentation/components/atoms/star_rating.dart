import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  final int starCount;
  final double size;
  final Function(int rating) onRatingChanged;

  const StarRating({
    super.key,
    this.starCount = 5,
    this.size = 32,
    required this.onRatingChanged,
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  int currentRating = 0;

  void _updateRating(int index) {
    setState(() {
      currentRating = index + 1;
    });
    widget.onRatingChanged(currentRating);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(widget.starCount, (index) {
        return IconButton(
          onPressed: () => _updateRating(index),
          icon: Icon(
            index < currentRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: widget.size,
          ),
          splashRadius: 24,
        );
      }),
    );
  }
}
