import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationInitial());

  int selectedIndex = 0;

  void updateSelectedIndex(int index) {
    selectedIndex = index;
    emit(NavigationTabChanged(index));
  }
}
