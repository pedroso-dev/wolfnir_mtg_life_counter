import '../../../../core/constants/strings.dart';

enum GameFormat { commander, duelCommander, tinyLeaders }

extension GameFormatExtension on GameFormat {
  int get startingLife {
    switch (this) {
      case GameFormat.commander:
        return 40;
      case GameFormat.tinyLeaders:
        return 25;
      case GameFormat.duelCommander:
        return 20;
    }
  }

  bool get hasCommanderDamage {
    return this == GameFormat.commander;
  }

  String get displayName {
    switch (this) {
      case GameFormat.commander:
        return AppStrings.commander;
      case GameFormat.tinyLeaders:
        return AppStrings.tinyLeaders;
      case GameFormat.duelCommander:
        return AppStrings.duelCommander;
    }
  }
}
