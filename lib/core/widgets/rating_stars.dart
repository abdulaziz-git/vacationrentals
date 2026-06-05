import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A row of 5 stars rendering a fractional [rating].
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 16});
  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating - i;
        IconData icon;
        if (filled >= 1) {
          icon = Icons.star;
        } else if (filled >= 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, size: size, color: AppTheme.sun);
      }),
    );
  }
}
