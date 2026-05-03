enum MagneticMaterialType {
  none,
  ferrous,
  acLiveWire,
  electronicInterference,
}

class AIClassifier {
  static const double baseField = 45.0; // Typical earth magnetic field
  
  static MagneticMaterialType classify(double intensity, List<double> history) {
    if (intensity < baseField + 5) return MagneticMaterialType.none;
    
    // Simple logic for demonstration
    // If intensity is very high and stable-ish, it's likely metal
    // If it's fluctuating wildly, it's interference or AC
    
    double variance = _calculateVariance(history);
    
    if (intensity > 150) {
      return MagneticMaterialType.ferrous;
    } else if (variance > 10.0) {
      return MagneticMaterialType.acLiveWire;
    } else if (intensity > 60) {
      return MagneticMaterialType.electronicInterference;
    }
    
    return MagneticMaterialType.none;
  }

  static double _calculateVariance(List<double> data) {
    if (data.isEmpty) return 0.0;
    double mean = data.reduce((a, b) => a + b) / data.length;
    double sumSquaredDiff = data.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b);
    return sumSquaredDiff / data.length;
  }

  static String getMaterialName(MagneticMaterialType type) {
    switch (type) {
      case MagneticMaterialType.ferrous:
        return 'Ferrous Metal (Iron)';
      case MagneticMaterialType.acLiveWire:
        return 'Live Wires (AC)';
      case MagneticMaterialType.electronicInterference:
        return 'Electronic Interference';
      default:
        return 'Scanning...';
    }
  }
}
