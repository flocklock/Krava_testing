import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/widgets.dart';
import 'utils.dart';

class Chart extends StatelessWidget {
  final List<SensorValue> _data;
  DateTime initTime;

  Chart(this._data, this.initTime);

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart([
      charts.Series<SensorValue, DateTime>(
        id: 'Values',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (SensorValue values, _) =>
            initTime.add(Duration(milliseconds: values.time ?? 0)),
        measureFn: (SensorValue values, _) => values.x,
        data: _data,
      )
    ],
        animate: false,
        primaryMeasureAxis: const charts.NumericAxisSpec(
          tickProviderSpec:
              charts.BasicNumericTickProviderSpec(zeroBound: false),
          renderSpec: charts.NoneRenderSpec(),
        ),
        domainAxis:
            const charts.DateTimeAxisSpec(renderSpec: charts.NoneRenderSpec()));
  }
}
