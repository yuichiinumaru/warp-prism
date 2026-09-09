import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  final color = PrismOperationalState.running.color;
  final label = PrismOperationalState.running.label;
  final icon = PrismOperationalState.running.icon;
  print('Color: $color, Label: $label, Icon: $icon');
}
