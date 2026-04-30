import 'dart:async';

import 'package:alpha/ui/common/alpha_container.dart';
import 'package:alpha/utils.dart';
import 'package:flutter/material.dart';

enum StockUnitChangeDirection { increase, decrease }

class StockUnitController extends ChangeNotifier {
  int _units = 10;
  int get units => _units;

  Timer? _timer;
  int _tickCount = 0;
  int _lastIncrementTick = 0;
  int _ticksPerIncrement = 30;

  static const int maxUnits = 9999;

  void start(StockUnitChangeDirection direction) {
    _tickCount = 0;
    _lastIncrementTick = 0;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(milliseconds: 5), (timer) {
      _tickCount++;

      if (_tickCount - _lastIncrementTick >= _ticksPerIncrement) {
        _lastIncrementTick = _tickCount;
        _ticksPerIncrement = roundDown(10000 / _tickCount, 1).clamp(1, 30);

        if (direction == StockUnitChangeDirection.increase) {
          _units = (_units + 1).clamp(0, maxUnits);
        } else {
          _units = (_units - 1).clamp(0, maxUnits);
        }

        notifyListeners();
      }
    });
  }

  void stop(StockUnitChangeDirection direction) {
    _timer?.cancel();
    _timer = null;
    _tickCount = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void setUnits(int units) {
    _units = units.clamp(0, maxUnits);
    notifyListeners();
  }
}

class StockUnitSelector extends StatelessWidget {
  final StockUnitController controller;
  final void Function() onTapEdit;

  const StockUnitSelector(
      {super.key, required this.controller, required this.onTapEdit});

  @override
  Widget build(BuildContext context) {
    return AlphaContainer(
      width: 225.0,
      height: 70.0,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      shadowOffset: const Offset(0.5, 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => controller.setUnits(controller.units - 1),
            onTapDown: (_) =>
                controller.start(StockUnitChangeDirection.decrease),
            onTapUp: (_) => controller.stop(StockUnitChangeDirection.decrease),
            onTapCancel: () =>
                controller.stop(StockUnitChangeDirection.decrease),
            child: const SizedBox(
                width: 40.0, height: 40.0, child: Icon(Icons.remove)),
          ),
          GestureDetector(
            onTap: onTapEdit,
            behavior: HitTestBehavior.opaque,
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) => Text(
                controller.units.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 38.0,
                  height: 1.80,
                ),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => controller.setUnits(controller.units + 1),
            onTapDown: (_) =>
                controller.start(StockUnitChangeDirection.increase),
            onTapUp: (_) => controller.stop(StockUnitChangeDirection.increase),
            onTapCancel: () =>
                controller.stop(StockUnitChangeDirection.increase),
            child: const SizedBox(
                width: 40.0, height: 40.0, child: Icon(Icons.add)),
          ),
        ],
      ),
    );
  }
}
