import 'package:alpha/logic/data/personal_life.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:flutter/material.dart';

class PersonalLifeCard extends StatelessWidget {
  final PersonalLifeStatus status;

  const PersonalLifeCard(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlphaContainer(
      width: 360.0,
      height: 480.0,
      padding: const EdgeInsets.only(top: 10.0, left: 25.0, right: 25.0),
      color: mapStatusToColor(status),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 240.0,
                height: 240.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xfffcf7e8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xff000000),
                        offset: Offset(0, 4),
                      )
                    ],
                    border:
                        Border.all(color: const Color(0xff383838), width: 3.0)),
              ),
              Container(
                width: 220.0,
                height: 220.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xfffcf7e8),
                    border:
                        Border.all(color: const Color(0xff383838), width: 3.0)),
              ),
              SizedBox(
                width: 290.0,
                height: 290.0,
                child: Image.asset(status.image.path),
              )
            ],
          ),
          Text(status.title, style: TextStyles.bold30),
          const SizedBox(height: 5.0),
          Text(status.description,
              textAlign: TextAlign.center,
              style: TextStyles.medium17.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}

Color mapStatusToColor(PersonalLifeStatus status) {
  switch (status) {
    case PersonalLifeStatus.single:
      return const Color(0xFFE7FBFF);
    case PersonalLifeStatus.dating:
      return const Color(0xFFFFE0F0);
    case PersonalLifeStatus.marriage:
      return const Color(0xFFFFF4D1);
    case PersonalLifeStatus.family:
      return const Color(0xFFE7D9FF);
  }
}
