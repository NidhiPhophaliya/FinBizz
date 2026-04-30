import 'package:logging/logging.dart';

/// The interface to be implemented by all [Manager] related classes
abstract interface class IManager {
  /// To ensure that the manager performs logging
  Logger get log;
}
