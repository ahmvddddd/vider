// import 'dart:convert';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;

// class Coin {
//   final String id;
//   final String name;
//   final String symbol;
//   final double price;

//   Coin({
//     required this.id,
//     required this.name,
//     required this.symbol,
//     required this.price,
//   });

//   factory Coin.fromJson(Map<String, dynamic> json) {
//     return Coin(
//       id: json['id'],
//       name: json['name'],
//       symbol: json['symbol'],
//       price: (json['current_price'] as num).toDouble(),
//     );
//   }
// }

// class CoinService {
//   static Future<List<Coin>> fetchCoins() async {
//     final response = await http.get(
//       Uri.parse(
//         'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd',
//       ),
//     );
//     final List data = jsonDecode(response.body);
//     return data.map((json) => Coin.fromJson(json)).toList();
//   }

//   static Future<List<List<num>>> fetchCoinChart(String coinId) async {
//   final response = await http.get(
//     Uri.parse(
//       'https://api.coingecko.com/api/v3/coins/$coinId/market_chart?vs_currency=usd&days=1',
//     ),
//   );

//   if (response.statusCode != 200) {
//     throw Exception('Failed to load chart data: ${response.body}');
//   }

//   final data = jsonDecode(response.body);

//   if (data == null || data['prices'] == null) {
//     throw Exception('Chart data is missing');
//   }

//   final prices = data['prices'];

//   if (prices is! List) {
//     throw Exception('Invalid chart data format');
//   }

//   return List<List<num>>.from(
//     prices.map<List<num>>(
//       (item) => List<num>.from(item),
//     ),
//   );
// }

// }

// final coinListProvider = FutureProvider<List<Coin>>((ref) async {
//   return CoinService.fetchCoins();
// });

// final coinChartProvider = FutureProvider.family<List<List<num>>, String>((
//   ref,
//   coinId,
// ) async {
//   return CoinService.fetchCoinChart(coinId);
// });

// class CoinListPage extends ConsumerWidget {
//   const CoinListPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final coinsAsync = ref.watch(coinListProvider);

//     return Scaffold(
//       appBar: AppBar(title: Text('Crypto Coins')),
//       body: coinsAsync.when(
//         data:
//             (coins) => ListView.builder(
//               itemCount: coins.length,
//               itemBuilder: (_, index) {
//                 final coin = coins[index];
//                 return ListTile(
//                   title: Text('${coin.name} (${coin.symbol.toUpperCase()})'),
//                   subtitle: Text('\$${coin.price.toStringAsFixed(2)}'),
//                   onTap:
//                       () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder:
//                               (_) => CoinChartPage(
//                                 coinId: coin.id,
//                                 coinName: coin.name,
//                               ),
//                         ),
//                       ),
//                 );
//               },
//             ),
//         loading: () => Center(child: CircularProgressIndicator()),
//         error: (e, _) => Center(child: Text('Error: $e')),
//       ),
//     );
//   }
// }

// class CoinChartPage extends ConsumerWidget {
//   final String coinId;
//   final String coinName;

//   const CoinChartPage({
//     super.key,
//     required this.coinId,
//     required this.coinName,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final chartAsync = ref.watch(coinChartProvider(coinId));

//     return Scaffold(
//       appBar: AppBar(title: Text('$coinName Chart')),
//       body: chartAsync.when(
//         data: (data) {
//           final spots =
//               data
//                   .asMap()
//                   .entries
//                   .map(
//                     (entry) =>
//                         FlSpot(entry.key.toDouble(), entry.value[1].toDouble()),
//                   )
//                   .toList();

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: LineChart(
//               LineChartData(
//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: spots,
//                     isCurved: true,
//                     color: Colors.blue,
//                     belowBarData: BarAreaData(
//                       show: true,
//                       color: Colors.blue.withOpacity(0.3),
//                     ),
//                   ),
//                 ],
//                 titlesData: FlTitlesData(show: false),
//                 gridData: FlGridData(show: false),
//                 borderData: FlBorderData(show: false),
//               ),
//             ),
//           );
//         },
//         loading: () => Center(child: CircularProgressIndicator()),
//         error: (e, _) {
//           debugPrint('Error: $e');
//           return Center(child: Text('Error: $e'));
//         },
//       ),
//     );
//   }
// }



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:graphic/graphic.dart' as graphic;
// import 'package:http/http.dart' as http;

// // --- CoinService (updated to get OHLC data) ---
// class CoinService {
//   static Future<List<CandleData>> fetchCoinCandles(String coinId) async {
//     final response = await http.get(
//       Uri.parse(
//         'https://api.coingecko.com/api/v3/coins/$coinId/ohlc?vs_currency=usd&days=1',
//       ),
//     );

//     if (response.statusCode != 200) {
//       throw Exception('Failed to fetch OHLC: ${response.body}');
//     }

//     final List data = jsonDecode(response.body);

//     // Each item format: [timestamp, open, high, low, close]
//     return data.map((e) {
//       return CandleData(
//         time: DateTime.fromMillisecondsSinceEpoch(e[0]),
//         open: e[1].toDouble(),
//         high: e[2].toDouble(),
//         low: e[3].toDouble(),
//         close: e[4].toDouble(),
//       );
//     }).toList();
//   }
// }

// class CandleData {
//   final DateTime time;
//   final double open;
//   final double high;
//   final double low;
//   final double close;

//   CandleData({
//     required this.time,
//     required this.open,
//     required this.high,
//     required this.low,
//     required this.close,
//   });

//   String get label => '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

//   bool get isRise => close >= open;
// }

// // --- Riverpod Provider ---
// final coinCandleProvider = FutureProvider.family<List<CandleData>, String>((ref, coinId) async {
//   return CoinService.fetchCoinCandles(coinId);
// });

// // --- CoinChartPage ---
// class CoinChartPage extends ConsumerWidget {
//   final String coinId;
//   final String coinName;

//   const CoinChartPage({
//     super.key,
//     required this.coinId,
//     required this.coinName,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final candleAsync = ref.watch(coinCandleProvider(coinId));

//     return Scaffold(
//       appBar: AppBar(title: Text('$coinName Chart')),
//       body: candleAsync.when(
//         data: (candles) {
//           final data = candles.map((e) {
//             return {
//               'time': e.label,
//               'open': e.open,
//               'high': e.high,
//               'low': e.low,
//               'close': e.close,
//               'rise': e.isRise,
//             };
//           }).toList();

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: graphic.Chart(
//   data: data,
//   variables: {
//     'time': graphic.Variable(accessor: (row) => row['time']),
//     'open': graphic.Variable(accessor: (row) => row['open']),
//     'high': graphic.Variable(accessor: (row) => row['high']),
//     'low': graphic.Variable(accessor: (row) => row['low']),
//     'close': graphic.Variable(accessor: (row) => row['close']),
//     'rise': graphic.Variable(accessor: (row) => row['rise']),
//   },
//   marks: [
//     // Candle body (open-close)
//     graphic.IntervalMark(
//       position: graphic.Varset('time') * graphic.Varset('open' / 'close'),
//       color: graphic.ColorEncode(
//         variable: 'rise',
//         values: [Colors.red, Colors.green],
//       ),
//     ),

//     // Candle wick (low-high)
//     graphic.IntervalMark(
//       position: graphic.Varset('time') * graphic.Varset('low' / 'high'),
//       color: graphic.ColorEncode(
//         variable: 'rise',
//         values: [Colors.red, Colors.green],
//       ),
//       size: graphic.SizeEncode(value: 1), // thinner wick
//     ),
//   ],
//   axes: {
//     'time': graphic.Defaults.horizontalAxis,
//     'close': graphic.Defaults.verticalAxis,
//   },
// )

//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, _) => Center(child: Text('Error: $e')),
//       ),
//     );
//   }
// }
