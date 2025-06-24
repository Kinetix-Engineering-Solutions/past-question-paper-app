import 'package:liver_port/liver_port.dart';

class QuizStore extends Store {
  QuizStore() : super({'currentScreen': 'home'});

  void goTo(String screen) => set('currentScreen', screen);
}