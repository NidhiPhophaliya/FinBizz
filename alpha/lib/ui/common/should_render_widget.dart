import 'package:flutter/material.dart';

/// Creates a widget that conditionally render its `child` when
/// the `nullable` value provided is null.
class RenderIfNull<T> extends StatelessWidget {
  final T nullable;
  final Widget child;

  const RenderIfNull({super.key, required this.nullable, required this.child});

  @override
  Widget build(BuildContext context) {
    return (nullable == null) ? child : const SizedBox();
  }
}

/// Creates a widget that conditionally render its `child` when
/// the `nullable` value provided is not null.
class RenderIfNotNull<T> extends StatelessWidget {
  final T nullable;
  final Widget child;

  const RenderIfNotNull(
      {super.key, required this.nullable, required this.child});

  @override
  Widget build(BuildContext context) {
    return (nullable != null) ? child : const SizedBox();
  }
}

/// Creates a widget that conditionally render its `child` when
/// all the values in `nullables` provided are not null.
class RenderIfAllNotNull<T> extends StatelessWidget {
  final List<T> nullables;
  final Widget child;

  const RenderIfAllNotNull(
      {super.key, required this.nullables, required this.child});

  @override
  Widget build(BuildContext context) {
    for (final nullable in nullables) {
      if (nullable == null) return const SizedBox();
    }

    return child;
  }
}

/// Creates a widget that conditionally render its `child` when
/// the `condition` provided is true.
class RenderIfTrue extends StatelessWidget {
  final bool condition;
  final Widget child;
  const RenderIfTrue({super.key, required this.condition, required this.child});

  @override
  Widget build(BuildContext context) => condition ? child : const SizedBox();
}

/// Creates a widget that conditionally render its child when
/// the `condition` provided is false.
class RenderIfFalse extends StatelessWidget {
  final bool condition;
  final Widget child;

  const RenderIfFalse(
      {super.key, required this.condition, required this.child});

  @override
  Widget build(BuildContext context) => !condition ? child : const SizedBox();
}
