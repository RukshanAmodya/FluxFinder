enum MaterialType {
  none,
  ferrous,
  acLiveWire,
  electronicInterference,
}

class AIClassifier {
  static const double baseField = 45.0; // Typical earth magnetic field
  
  static MaterialType classify(double intensity, List<double> history) {
    if (intensity < baseField + 5) return MaterialType.none;
    
    // Simple logic for demonstration
    // If intensity is very high and stable-ish, it's likely metal
    // If it's fluctuating wildly, it's interference or AC
    
    double variance = _calculateVariance(history);
    
    if (intensity > 150) {
      return MaterialType.ferrous;
    } else if (variance > 10.0) {
      return MaterialType.acLiveWire;
    } else if (intensity > 60) {
      return MaterialType.electronicInterference;
    }
    
    return MaterialType.none;
  }

  static double _calculateVariance(List<double> data) {
    if (data.isEmpty) return 0.0;
    double mean = data.reduce((a, b) => a + b) / data.length;
    double sumSquaredDiff = data.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b);
    return sumSquaredDiff / data.length;
  }

  static String getMaterialName(MaterialType type) {
    switch (type) {
      case MaterialType.ferrous:
        return 'Ferrous Metal (Iron)';
      case MaterialType.acLiveWire:
        return 'Live Wires (AC)';
      case MaterialType.electronicInterference:
        return 'Electronic Interference';
      default:
        return 'Scanning...';
    }
  }
}
