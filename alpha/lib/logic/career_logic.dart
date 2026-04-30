import 'package:alpha/logic/accounts_logic.dart';
import 'package:alpha/logic/common/interfaces.dart';
import 'package:alpha/logic/data/careers.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:alpha/services.dart';
import 'package:logging/logging.dart';

class CareerEmployment {
  final Job job;
  final int startRound;

  CareerEmployment({
    required this.job,
    required this.startRound,
  });
}

class CareerManager implements IManager {
  @override
  final Logger log = Logger("CareerManager");

  static const kCPFContributionRate = 0.055;
  static const kCareerProgressionHappinessBonus = 5;

  final Map<Player, CareerEmployment> _employments = {};

  bool isEmployed(Player player) => _employments.containsKey(player);

  bool isQualified(Player player, Job job) {
    final skillLevel = skillManager.getPlayerSkill(player).level;
    final requiredSkill = job.levelRequirement;

    return skillLevel >= requiredSkill;
  }

  void initialisePlayerCareers(List<Player> players) {
    for (final player in players) {
      employ(player, player.startingCareer, 1);
    }
  }

  Job getPlayerJob(Player player) {
    final employment = _employments[player];

    if (employment == null) {
      return Job.unemployed;
    }

    return employment.job;
  }

  Job getNextTierJob(Job job) {
    return Job.values.firstWhere(
        (j) => (j.tier == job.tier + 1) && job.career == j.career,
        orElse: () => Job.unemployed);
  }

  bool hasNextTierJob(Player player) {
    final Job job = getPlayerJob(player);
    return getNextTierJob(job) != Job.unemployed;
  }

  bool canPromote(Player player) {
    Job nextJob = getNextTierJob(getPlayerJob(player));

    return skillManager.getPlayerSkill(player).level >=
        nextJob.levelRequirement;
  }

  void employ(Player player, Job job, int round) {
    if (isEmployed(player)) {
      log.info(
          "Resigning ${player.name} from current job before employing as ${job.name}");
      resign(player);
    }

    if (!isQualified(player, job)) {
      log.warning(
          "Called employ on Player ${player.name} who is not qualified for $job");
      return;
    }

    _employments[player] = CareerEmployment(
      job: job,
      startRound: round,
    );

    log.info("Employed ${player.name} as ${job.name}");
  }

  bool resign(Player player) {
    final employment = _employments[player];

    if (employment == null) {
      log.warning("Called resign on Player ${player.name} who is not employed");
      return false;
    }

    _employments.remove(player);
    return true;
  }

  Job promote(Player player) {
    final employment = _employments[player];

    if (employment == null) {
      log.warning(
          "Called promote on Player ${player.name} who is not employed");
      return Job.unemployed;
    }

    final currentJob = employment.job;
    final nextJob = getNextTierJob(currentJob);

    if (nextJob == Job.unemployed) {
      log.warning("Called promote on Player ${player.name} who is at max tier");

      return employment.job;
    }

    _employments[player] = CareerEmployment(
      job: nextJob,
      startRound: employment.startRound,
    );

    statsManager.addHappiness(player, kCareerProgressionHappinessBonus);

    return nextJob;
  }

  void creditSalary() {
    log.info("Crediting salaries to employed players");

    for (final player in _employments.keys) {
      final employment = _employments[player];
      if (employment == null) {
        log.warning("Employment record missing for ${player.name}");
        continue;
      }

      final double salary = employment.job.salary;
      final double cpf = salary * kCPFContributionRate;

      final double netSalary = salary - cpf;

      final PlayerAccount account = accountsManager.getPlayerAccount(player);

      accountsManager.creditToSavingsUnbudgeted(player, netSalary);
      account.cpf.add(cpf);

      log.info(
          "Credited salary of $netSalary to ${player.name} after CPF, current Savings: ${account.savings.balance}, current CPF: ${account.cpf.balance}");
    }
  }
}
