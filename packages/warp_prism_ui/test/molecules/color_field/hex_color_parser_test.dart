import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/color_field/hex_color_parser.dart';

int _a(Color c) => (c.a * 255).round().clamp(0, 255);
int _r(Color c) => (c.r * 255).round().clamp(0, 255);
int _g(Color c) => (c.g * 255).round().clamp(0, 255);
int _b(Color c) => (c.b * 255).round().clamp(0, 255);

void main() {
  group('HexColorParser', () {
    group('tryParseHexColor', () {
      test('parses 3-digit hex #RGB', () {
        final color = HexColorParser.tryParseHexColor('#F0A');
        expect(color, isNotNull);
        expect(_a(color!), equals(255));
        expect(_r(color), equals(0xFF));
        expect(_g(color), equals(0x00));
        expect(_b(color), equals(0xAA));
      });

      test('parses 3-digit hex RGB without leading hash', () {
        final color = HexColorParser.tryParseHexColor('123');
        expect(color, isNotNull);
        expect(_r(color!), equals(0x11));
        expect(_g(color), equals(0x22));
        expect(_b(color), equals(0x33));
      });

      test('parses 6-digit hex #RRGGBB', () {
        final color = HexColorParser.tryParseHexColor('#2F81FF');
        expect(color, isNotNull);
        expect(_a(color!), equals(255));
        expect(_r(color), equals(0x2F));
        expect(_g(color), equals(0x81));
        expect(_b(color), equals(0xFF));
      });

      test('parses 6-digit hex RRGGBB lowercase without hash', () {
        final color = HexColorParser.tryParseHexColor('00d4ff');
        expect(color, isNotNull);
        expect(_r(color!), equals(0x00));
        expect(_g(color), equals(0xD4));
        expect(_b(color), equals(0xFF));
      });

      test('parses 8-digit hex #AARRGGBB', () {
        final color = HexColorParser.tryParseHexColor('#80FF0000');
        expect(color, isNotNull);
        expect(_a(color!), equals(0x80));
        expect(_r(color), equals(0xFF));
        expect(_g(color), equals(0x00));
        expect(_b(color), equals(0x00));
      });

      test('rejects invalid hex strings', () {
        expect(HexColorParser.tryParseHexColor(null), isNull);
        expect(HexColorParser.tryParseHexColor(''), isNull);
        expect(HexColorParser.tryParseHexColor('   '), isNull);
        expect(HexColorParser.tryParseHexColor('#'), isNull);
        expect(HexColorParser.tryParseHexColor('#12'), isNull);
        expect(HexColorParser.tryParseHexColor('#1234'), isNull);
        expect(HexColorParser.tryParseHexColor('1234'), isNull);
        expect(HexColorParser.tryParseHexColor('#12345'), isNull);
        expect(HexColorParser.tryParseHexColor('#1234567'), isNull);
        expect(HexColorParser.tryParseHexColor('#GGHHII'), isNull);
        expect(HexColorParser.tryParseHexColor('#XYZ'), isNull);
      });
    });

    group('formatHexColor', () {
      test('formats color to #RRGGBB by default', () {
        const color = Color(0xFF2F81FF);
        expect(HexColorParser.formatHexColor(color), equals('#2F81FF'));
      });

      test('formats color to #AARRGGBB when includeAlpha is true', () {
        const color = Color(0x802F81FF);
        expect(
          HexColorParser.formatHexColor(color, includeAlpha: true),
          equals('#802F81FF'),
        );
      });

      test('formats color without leading hash when leadingHash is false', () {
        const color = Color(0xFF00D4FF);
        expect(
          HexColorParser.formatHexColor(color, leadingHash: false),
          equals('00D4FF'),
        );
      });
    });
  });
}
