import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/strings.dart';
import 'features/match/domain/usecases/update_commander_damage_usecase.dart';
import 'features/match/domain/usecases/update_life_usecase.dart';
import 'features/match/domain/usecases/update_poison_usecase.dart';
import 'features/match/presentation/cubit/match_cubit.dart';
import 'features/match/presentation/pages/match_screen.dart';

void main() {
  // Ensures Flutter bindings are initialized before hiding the status bar
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  ); // Fullscreen mode

  runApp(const MTGCounterApp());
}

class MTGCounterApp extends StatelessWidget {
  const MTGCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: BlocProvider(
        create: (context) => MatchCubit(
          updateLife: UpdateLifeUseCase(),
          updatePoison: UpdatePoisonUseCase(),
          updateCommanderDamage: UpdateCommanderDamageUseCase(),
        ),
        child: const MatchScreen(),
      ),
    );
  }
}
