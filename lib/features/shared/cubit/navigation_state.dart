abstract class NavigationState {}

class NavigationInitial extends NavigationState {}

class NavigationTabChanged extends NavigationState {
  final int selectedIndex;
  NavigationTabChanged(this.selectedIndex);
}
