import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  test('PrismDialog public symbol resolves', () {
    const dialog = PrismDialog(
      title: 'Public Alias Probe',
      actions: [PrismDialogAction(label: 'OK')],
    );
    expect(dialog.title, 'Public Alias Probe');
  });
}
