import 'package:flutter/material.dart';

class LevelingSystem {
  int experience = 0;
  
  String get rank {
    if (experience > 1000) return 'Master Archaeologist';
    if (experience > 500) return 'Relic Hunter';
    if (experience > 100) return 'Flux Tracker';
    return 'Rookie Finder';
  }

  double get progress {
    if (experience > 1000) return 1.0;
    return (experience % 500) / 500.0;
  }

  void addExperience(double intensity) {
    if (intensity > 60) {
      experience += (intensity / 10).toInt();
    }
  }
}
