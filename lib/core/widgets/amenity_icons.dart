import 'package:flutter/material.dart';

/// Maps amenity icon keys (and common labels) to Material icons.
IconData amenityIcon(String? key, String label) {
  switch (key) {
    case 'ac':
      return Icons.ac_unit;
    case 'pool':
      return Icons.pool;
    case 'wifi':
      return Icons.wifi;
    case 'laundry':
      return Icons.local_laundry_service;
    case 'deck':
      return Icons.deck;
    case 'ev':
      return Icons.ev_station;
  }
  final l = label.toLowerCase();
  if (l.contains('grill')) return Icons.outdoor_grill;
  if (l.contains('coffee') || l.contains('keurig')) return Icons.coffee;
  if (l.contains('dishwasher')) return Icons.countertops;
  if (l.contains('microwave')) return Icons.microwave;
  if (l.contains('fan')) return Icons.mode_fan_off;
  if (l.contains('internet')) return Icons.router;
  if (l.contains('balcony') || l.contains('deck')) return Icons.balcony;
  if (l.contains('shower')) return Icons.shower;
  if (l.contains('crib') || l.contains('pack')) return Icons.child_friendly;
  if (l.contains('living')) return Icons.weekend;
  return Icons.check_circle_outline;
}
