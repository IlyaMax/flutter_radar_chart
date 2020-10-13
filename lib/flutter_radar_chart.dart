library flutter_radar_chart;

import 'dart:math' as math;
import 'dart:math' show pi, cos, sin;
import 'dart:ui';

import 'package:flutter/material.dart';

const defaultGraphColors = [
  Colors.green,
  Colors.blue,
  Colors.red,
  Colors.orange,
];

class RadarChart extends StatefulWidget {
  final List<int> ticks;
  final List<String> features;
  final List<List<int>> data;
  final bool reverseAxis;
  final TextStyle ticksTextStyle;
  final TextStyle featuresTextStyle;
  final Color outlineColor;
  final double outlineWidth;
  final Color axisColor;
  final double axisRadius;
  final List<Color> graphColors;
  final bool hasCircularBorder;
  final bool fillPolygons;
  final double dotRadius;

  const RadarChart({
    Key key,
    @required this.ticks,
    @required this.features,
    @required this.data,
    this.reverseAxis = false,
    this.hasCircularBorder = true,
    this.fillPolygons = true,
    this.ticksTextStyle = const TextStyle(color: Colors.grey, fontSize: 12),
    this.featuresTextStyle = const TextStyle(color: Colors.black, fontSize: 16),
    this.outlineColor = Colors.black,
    this.outlineWidth = 1.0,
    this.axisColor = Colors.grey,
    this.axisRadius = 0.0,
    this.graphColors = defaultGraphColors,
    this.dotRadius = 5.0,
  }) : super(key: key);

  @override
  _RadarChartState createState() => _RadarChartState();
}

class _RadarChartState extends State<RadarChart> with SingleTickerProviderStateMixin {
  double fraction = 0;
  Animation<double> animation;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(duration: Duration(milliseconds: 1000), vsync: this);

    animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: animationController,
    ))
      ..addListener(() {
        setState(() {
          fraction = animation.value;
        });
      });

    animationController.forward();
  }

  @override
  void didUpdateWidget(RadarChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    animationController.reset();
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, double.infinity),
      painter: RadarChartPainter(widget, this.fraction),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class RadarChartPainter extends CustomPainter {
  final RadarChart chart;
  final double fraction;

  RadarChartPainter(this.chart, this.fraction);

  Path variablePath(Size size, double radius) {
    var path = Path();

    if (chart.hasCircularBorder) {
      path.addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: radius,
      ));
      return path;
    } else {
      // Draw a polygon
      final sides = chart.features.length;
      var angle = (math.pi * 2) / sides;
      Offset center = Offset(size.width / 2, size.height / 2);
      Offset startPoint = Offset(radius * cos(-pi / 2), radius * sin(-pi / 2));

      path.moveTo(startPoint.dx + center.dx, startPoint.dy + center.dy);

      for (int i = 1; i <= sides; i++) {
        double x = radius * cos(angle * i - pi / 2) + center.dx;
        double y = radius * sin(angle * i - pi / 2) + center.dy;
        path.lineTo(x, y);
      }
      path.close();
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2.0;
    final centerY = size.height / 2.0;
    final centerOffset = Offset(centerX, centerY);
    final radius = math.min(centerX, centerY) * 0.8;
    final scale = radius / chart.ticks.last;

    // Painting the chart outline
    var outlinePaint = Paint()
      ..color = chart.outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = chart.outlineWidth
      ..isAntiAlias = true;

    var ticksPaint = Paint()
      ..color = chart.axisColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    canvas.drawPath(variablePath(size, radius), outlinePaint);
    // Painting the circles and labels for the given ticks (could be auto-generated)
    // The last tick is ignored, since it overlaps with the feature label
    var tickDistance = radius / (chart.ticks.length);
    var tickLabels = chart.reverseAxis ? chart.ticks.reversed.toList() : chart.ticks;

    if (chart.reverseAxis) {
      TextPainter(
        text: TextSpan(text: tickLabels[0].toString(), style: chart.ticksTextStyle),
        textDirection: TextDirection.ltr,
      )
        ..layout(minWidth: 0, maxWidth: size.width)
        ..paint(canvas, Offset(centerX, centerY - chart.ticksTextStyle.fontSize));
    }

    tickLabels
        .sublist(chart.reverseAxis ? 1 : 0, chart.reverseAxis ? chart.ticks.length : chart.ticks.length - 1)
        .asMap()
        .forEach((index, tick) {
      var tickRadius = tickDistance * (index + 1);

      canvas.drawPath(variablePath(size, tickRadius), ticksPaint);

      TextPainter(
        text: TextSpan(text: tick.toString(), style: chart.ticksTextStyle),
        textDirection: TextDirection.ltr,
      )
        ..layout(minWidth: 0, maxWidth: size.width)
        ..paint(canvas, Offset(centerX, centerY - tickRadius - chart.ticksTextStyle.fontSize));
    });

    // Painting the axis for each given feature
    var angle = (2 * pi) / chart.features.length;

    chart.features.asMap().forEach((index, feature) {
      var xAngle = cos(angle * index - pi / 2);
      var yAngle = sin(angle * index - pi / 2);

      var featureOffset = Offset(
        centerX + (radius + chart.axisRadius.abs()) * xAngle,
        centerY + (radius + chart.axisRadius.abs()) * yAngle,
      );

      canvas.drawLine(centerOffset, featureOffset, ticksPaint);

      var featureLabelFontHeight = chart.featuresTextStyle.fontSize;
      var featureLabelFontWidth = chart.featuresTextStyle.fontSize - 5;
      var labelYOffset = yAngle < 0 ? -featureLabelFontHeight : 0;
      var labelXOffset = xAngle < 0 ? -featureLabelFontWidth * feature.length : 0;

      TextPainter(
        text: TextSpan(text: feature, style: chart.featuresTextStyle),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      )
        ..layout(minWidth: 0, maxWidth: size.width)
        ..paint(canvas, Offset(featureOffset.dx + labelXOffset, featureOffset.dy + labelYOffset));
    });

    // Painting each graph
    chart.data.asMap().forEach((index, graph) {
      final graphPaint = Paint()
        ..color = chart.graphColors[index % chart.graphColors.length].withOpacity(0.3)
        ..style = PaintingStyle.fill;

      final graphOutlinePaint = Paint()
        ..color = chart.graphColors[index % chart.graphColors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..isAntiAlias = true;

      final dotPaint = Paint()
        ..color = chart.graphColors[index % chart.graphColors.length]
        ..style = PaintingStyle.fill;

      // Start the graph on the initial point
      var scaledPoint = scale * graph[0] * fraction;
      var path = Path();

      if (chart.reverseAxis) {
        path.moveTo(centerX, centerY - (radius * fraction - scaledPoint));
      } else {
        path.moveTo(centerX, centerY - scaledPoint);
      }
      canvas.drawCircle(Offset(centerX, centerY - scaledPoint), chart.dotRadius, dotPaint);
      graph.asMap().forEach((index, point) {
        if (index == 0) return;

        var xAngle = cos(angle * index - pi / 2);
        var yAngle = sin(angle * index - pi / 2);
        var scaledPoint = scale * point * fraction;

        final destX = centerX + ((chart.reverseAxis) ? radius * fraction - scaledPoint : scaledPoint) * xAngle;
        final destY = centerY + ((chart.reverseAxis) ? radius * fraction - scaledPoint : scaledPoint) * yAngle;
        path.lineTo(destX, destY);
        canvas.drawCircle(Offset(destX, destY), chart.dotRadius, dotPaint);
      });

      path.close();
      if (chart.fillPolygons) canvas.drawPath(path, graphPaint);
      canvas.drawPath(path, graphOutlinePaint);
    });
  }
  
  @override
  bool shouldRepaint(RadarChartPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}
