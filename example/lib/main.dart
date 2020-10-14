import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radar Chart Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool fillPolygons = false;
  bool hasCircularBorder = false;
  double numberOfFeatures = 3;
  double axisRadius = 20.0;

  List<int> shuffledData() {
    final data = [15, 1, 4, 14, 23, 10, 6, 19];
    data.shuffle();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    const ticks = [7, 14, 21, 28, 35];
    var features = ["AA", "BB", "CC", "DD", "EE", "FF", "GG", "HH"];
    var data = [
      [10, 20, 28, 5, 16, 15, 17, 6],
      [15, 1, 4, 14, 23, 10, 6, 19],
      shuffledData(),
    ];

    features = features.sublist(0, numberOfFeatures.floor());
    data = data.map((graph) => graph.sublist(0, numberOfFeatures.floor())).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Radar Chart Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Fill polygons',
                  style: TextStyle(color: Colors.black),
                ),
                Switch(
                  value: this.fillPolygons,
                  onChanged: (value) {
                    setState(() {
                      fillPolygons = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                hasCircularBorder
                    ? Text(
                        'Polygon border',
                        style: TextStyle(color: Colors.black),
                      )
                    : Text(
                        'Circular border',
                        style: TextStyle(color: Colors.black),
                      ),
                Switch(
                  value: this.hasCircularBorder,
                  onChanged: (value) {
                    setState(() {
                      hasCircularBorder = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Number of features',
                  style: TextStyle(color: Colors.black),
                ),
                Expanded(
                  child: Slider(
                    value: this.numberOfFeatures,
                    min: 3,
                    max: 8,
                    divisions: 5,
                    onChanged: (value) {
                      setState(() {
                        numberOfFeatures = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RadarChart(
              axisRadius: axisRadius,
              ticks: ticks,
              features: features,
              data: data,
              hasCircularBorder: hasCircularBorder,
              outlineColor: Colors.grey,
              fillPolygons: fillPolygons,
            ),
          ),
        ],
      ),
    );
  }
}
