import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
// ONLY the public barrel — proves showPrismDialog is consumer-reachable.
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  test('showPrismDialog is part of public API', () {
    final Future<dynamic> Function({
      required BuildContext context,
      required WidgetBuilder builder,
      bool barrierDismissible,
      Color? barrierColor,
      String barrierLabel,
      bool useRootNavigator,
      RouteSettings? routeSettings,
    }) alias = showPrismDialog;
    expect(alias, isNotNull);
  });

  test('PrismDialog public symbols resolve', () {
    const dialog = PrismDialog(
      title: 'Probe',
      actions: [PrismDialogAction(label: 'OK')],
    );
    expect(dialog.title, 'Probe');
    expect(PrismDialogSize.md, PrismDialogSize.md);
  });
}
