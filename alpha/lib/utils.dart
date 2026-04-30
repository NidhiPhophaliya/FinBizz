import 'dart:convert';
import 'dart:typed_data';

bool isVowel(String char) =>
    ["A", "E", "I", "O", "U"].contains(char.toUpperCase());

String singularArticle(String subject, {bool capitalize = false}) {
  String article;

  if (isVowel(subject.substring(0, 1))) {
    article = "an";
  } else {
    article = "a";
  }

  if (capitalize) {
    article = article.substring(0, 1).toUpperCase() + article.substring(1);
  }

  return "$article $subject";
}

int roundDown(double value, int nearest) => (value / nearest).floor() * nearest;

int roundUp(double value, int nearest) => (value / nearest).ceil() * nearest;

T sum<T extends num>(Iterable<T> items) {
  if (items.isEmpty) return 0 as T;

  return items.reduce((T value, T acc) => value + acc as T);
}

String getOrdinalSuffix(int number) {
  if (number >= 11 && number <= 13) {
    return 'th';
  }

  switch (number % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

String toOrdinal(int number) {
  return '$number${getOrdinalSuffix(number)}';
}

/// Generates a deterministic but seemingly "random" factor based on the [str] and [seed].
/// This function always yield the same factor for the same inputs.
double generateRandomFactor(String str, int seed) {
  Uint8List bytes = utf8.encode(str);

  int hash = seed;

  for (int byte in bytes) {
    hash = ((hash * 33) + byte) & 0xFFFFFFFF;
  }

  hash = ((hash >> 16) ^ hash) * 0x45d9f3b;
  hash = ((hash >> 16) ^ hash) * 0x45d9f3b;
  hash = (hash >> 16) ^ hash;

  double result = (hash & 0xFFFFFFFF) / 0xFFFFFFFF;

  return result;
}
