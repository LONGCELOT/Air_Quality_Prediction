// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/aqi_provider.dart';
// import '../services/aqi_api_services.dart';

// class PredictionCard extends StatelessWidget {
//   const PredictionCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<AQIProvider>(context);

//     if (provider.isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (provider.error != null) {
//       return Card(
//         color: Colors.red[100],
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Text("❌ ${provider.error}"),
//         ),
//       );
//     }

//     // final predictions = provider.predictions;
//     // if (predictions == null || predictions.isEmpty) {
//     //   return const Center(child: Text("No prediction data available"));
//     // }

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "AQI Predictions",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             _buildPredictionRow("8 Hours", prediction.aqi8h),
//             _buildPredictionRow("12 Hours", prediction.aqi12h),
//             _buildPredictionRow("24 Hours", prediction.aqi24h),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPredictionRow(String label, double value) {
//     final level = AQIApiService.getAQILevel(value);
//     final color = AQIApiService.getAQIColor(value);

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
//           Text(
//             "${value.toStringAsFixed(0)} ($level)",
//             style: TextStyle(color: Color(color), fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
// }
