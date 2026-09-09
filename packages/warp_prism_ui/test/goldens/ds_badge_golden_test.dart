@Tags(['golden'])
library;

// Golden tests for DSBadge — renders badge variants, sizes, and
// operational state badges.
//
// Run from packages/warp_prism_ui/:
//   flutter test --update-goldens test/goldens/ds_badge_golden_test.dart
//   flutter test test/goldens/ds_badge_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

Widget _inApp(Widget child) {
  return MaterialApp(
    theme: PrismTheme.dark(),
    home: Scaffold(
      backgroundColor: DSColors.obsidianBase,
      body: Center(child: child),
    ),
  );
}

void main() {
  group('DSBadge golden — semantic constructors', () {
    testWidgets('renders success badge with label', (tester) async {
      await tester.pumpWidget(_inApp(const DSBadge.success(label: 'Verified')));
      await expectLater(
        find.byType(DSBadge),
        matchesGoldenFile('goldens/badge_success_label.png'),
      );
    });

    testWidgets('renders warning badge with count', (tester) async {
      await tester.pumpWidget(_inApp(const DSBadge.warning(count: 3)));
      await expectLater(
        find.byType(DSBadge),
        matchesGoldenFile('goldens/badge_warning_count.png'),
      );
    });

    testWidgets('renders error badge with label', (tester) async {
      await tester.pumpWidget(_inApp(const DSBadge.error(label: 'Blocked')));
      await expectLater(
        find.byType(DSBadge),
        matchesGoldenFile('goldens/badge_error_label.png'),
      );
    });

    testWidgets('renders info badge with label', (tester) async {
      await tester.pumpWidget(_inApp(const DSBadge.info(label: 'Notice')));
      await expectLater(
        find.byType(DSBadge),
        matchesGoldenFile('goldens/badge_info_label.png'),
      );
    });
  });

  group('DSBadge golden — variants', () {
    testWidgets('renders filled variant', (tester) async {
      await tester.pumpWidget(
        _inApp(
          const DSBadge(
            label: 'Filled',
            color: DSColors.accentCyan,
            variant: DSBadgeVariant.filled,
          ),
        ),
      );
      await expectLater(
        find.byType(DSBadge),
        matchesGoldenFile('goldens/badge_variant_filled.png'),
      );
    });

    testWidgets('renders outlined variant', (tester) async {
      await tester.pumpWidget(
        _inApp(
          const DSBadge(
            label: 'Outlined',
            color: DSColors.accentViolet,
            variant: DSBadgeVariant.outlined,
          ),
        ),
      );
      await expectLater(
        find.byType(DSBadge),
        matchesGoldenFile('goldens/badge_variant_outlined.png'),
      );
    });

    testWidgets('renders dot variant', (tester) async {
      await tester.pumpWidget(
        _inApp(const DSBadge.dot(color: DSColors.statusSuccess)),
      );
      await expectLater(
        find.byType(DSBadge),
        matchesGoldenFile('goldens/badge_variant_dot.png'),
      );
    });
  });

  group('DSBadge golden — sizes', () {
    testWidgets('renders small size', (tester) async {
      await tester.pumpWidget(
        _inApp(
          const DSBadge(
            label: 'S',
            color: DSColors.accentCyan,
            size: DSBadgeSize.small,
          ),
        ),
      );
      await expectLater(
        find.byType(DSBadge),
        matchesGoldenFile('goldens/badge_size_small.png'),
      );
    });

    testWidgets('renders medium size', (tester) async {
      await tester.pumpWidget(
        _inApp(
          const DSBadge(
            label: 'M',
            color: DSColors.accentCyan,
            size: DSBadgeSize.medium,
          ),
        ),
      );
      await expectLater(
        find.byType(DSBadge),
        matchesGoldenFile('goldens/badge_size_medium.png'),
      );
    });

    testWidgets('renders large size', (tester) async {
      await tester.pumpWidget(
        _inApp(
          const DSBadge(
            label: 'L',
            color: DSColors.accentCyan,
            size: DSBadgeSize.large,
          ),
        ),
      );
      await expectLater(
        find.byType(DSBadge),
        matchesGoldenFile('goldens/badge_size_large.png'),
      );
    });
  });

  group('DSBadge golden — count overflow', () {
    testWidgets('renders 99+ for count over 99', (tester) async {
      await tester.pumpWidget(_inApp(const DSBadge.count(150)));
      await expectLater(
        find.byType(DSBadge),
        matchesGoldenFile('goldens/badge_count_overflow.png'),
      );
    });
  });

  group('DSBadge golden — operational state badges', () {
    testWidgets('renders all operational state badges in a row', (
      tester,
    ) async {
      await tester.pumpWidget(
        _inApp(
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DSOperationalState.values
                .map((state) => DSBadge.operational(state))
                .toList(),
          ),
        ),
      );
      await expectLater(
        find.byType(Wrap),
        matchesGoldenFile('goldens/badge_all_operational_states.png'),
      );
    });
  });
}
