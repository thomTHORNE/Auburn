// The basics from Spec/Visual Design.md, as Dart constants. Every screen reads
// its values from here, the way its screen.html reads CSS variables.

import 'package:flutter/material.dart';

const tube = Color(0xFF1A1D1A);
const obsidian = Color(0xFF121215);
const ember = Color(0xFFD9573B);
const cyanWhite = Color(0xFFDDF7F5);

/// The tube's settings, from the CRT and glass Lab verdicts.
const tubeStrength = 0.6;
const tubeGlass = 0.6;
const tubeTravel = 0.35;
