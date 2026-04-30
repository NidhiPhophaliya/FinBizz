import 'dart:math';

import 'package:alpha/logic/common/interfaces.dart';
import 'package:logging/logging.dart';
import 'package:alpha/logic/data/world_event.dart';

class WorldEventManager implements IManager {
  @override
  Logger log = Logger("WorldEventManager");

  static const kWorldEventDuration = 2;

  final int? seed;
  late final Random _random = Random(seed);

  WorldEvent _currentEvent = WorldEvent.none;
  int _roundsRemaining = 0;

  WorldEvent get currentEvent => _currentEvent;
  int get roundsRemaining => _roundsRemaining;

  WorldEventManager({this.seed});

  void incrementWorldEvent() {
    if (_roundsRemaining > 0) {
      _roundsRemaining--;
    }

    if (_roundsRemaining == 0) {
      _currentEvent = WorldEvent.none;
    }
  }

  WorldEvent triggerEvent() {
    _currentEvent =
        WorldEvent.values[_random.nextInt(WorldEvent.values.length)];
    log.info("Triggered world event: $_currentEvent");

    _roundsRemaining = kWorldEventDuration;

    return _currentEvent;
  }
}
