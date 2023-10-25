import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String stockSymbol = "M"; // Ganti dengan kode saham Anda
  List<FlSpot> stockData = []; // Data harga saham

  // Fungsi untuk mengambil data harga saham dari API
  Future<void> fetchData() async {
    final apiKey = "LL2_wl5YE4SvVA6Sq_HKS4HXmZdP8yEX";
    final response = await http.get(Uri.parse(
        'https://api.polygon.io/v2/aggs/ticker/M/range/1/day/2023-01-09/2023-02-09?adjusted=true&sort=asc&limit=120&apiKey=$apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];

      List<FlSpot> prices = [];

      for (var result in results) {
        double price = double.parse(result['l'].toString());
        prices.add(FlSpot(prices.length.toDouble(), price));
      }

      setState(() {
        stockData = prices;
      });
    } else {
      print("Gagal mengambil data: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    fetchData(); // Panggil fungsi fetchData saat halaman diinisialisasi
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pergerakan Harga Saham'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Kode Saham: $stockSymbol',
            style: TextStyle(fontSize: 20),
          ),
          ElevatedButton(
            onPressed: () {
              fetchData(); // Ketika tombol ditekan, panggil fungsi fetchData
            },
            child: Text('Refresh Data'),
          ),
          Container(
            height: 300,
            padding: EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: true),
                gridData: FlGridData(show: false),
                minX: 0,
                maxX: stockData.length.toDouble() - 1,
                minY: stockData.isEmpty
                    ? 0
                    : stockData.reduce((a, b) => a.y < b.y ? a : b).y,
                maxY: stockData.isEmpty
                    ? 0
                    : stockData.reduce((a, b) => a.y > b.y ? a : b).y,
                lineBarsData: [
                  LineChartBarData(
                    spots: stockData,
                    isCurved: true,
                    dotData: FlDotData(
                        show:
                            true), // Menampilkan bulatan pada titik-titik data
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
