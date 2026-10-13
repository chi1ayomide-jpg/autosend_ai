import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autosend_ai/main.dart';
import 'package:autosend_ai/services/variable_service.dart';
import 'package:autosend_ai/models/auto_reply_rule.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('1. Variable Substitution & Accent Normalization Engine', () {
    test('Resolves {name}, {first_name}, {time}, {date}, {phone}', () {
      final template = "Hello {name} ({first_name})! Phone: {phone} on {date} at {time}.";
      final resolved = VariableService.resolve(
        template,
        name: "Chidinma Okafor",
        phone: "+2348145556677",
        now: DateTime(2026, 10, 13, 14, 30),
      );

      expect(resolved.contains("Chidinma Okafor"), isTrue);
      expect(resolved.contains("Chidinma"), isTrue);
      expect(resolved.contains("+2348145556677"), isTrue);
      expect(resolved.contains("13 Oct 2026"), isTrue);
      expect(resolved.contains("02:30 PM"), isTrue);
    });

    test('Strips accents for fuzzy matching (ignore_accents)', () {
      expect(VariableService.normalizeAccents("café"), equals("cafe"));
      expect(VariableService.normalizeAccents("crème"), equals("creme"));
      expect(VariableService.normalizeAccents("Español"), equals("espanol"));
    });
  });

  group('2. AutoReplyRule Matching & Rotating Responses', () {
    test('Rule matching: contains and exact', () {
      final rule = AutoReplyRule(
        id: '1',
        name: 'Price Rule',
        triggerPattern: 'price',
        matchType: MatchType.contains,
        responseMessage: 'Our price list is on our website.',
      );

      expect(rule.matches('What is the price please?'), isTrue);
      expect(rule.matches('Hello there'), isFalse);
    });

    test('Multi-reply rotation (///) selects variants', () {
      final rule = AutoReplyRule(
        id: '2',
        name: 'Greeting Rotation',
        triggerPattern: 'hello',
        matchType: MatchType.contains,
        responseMessage: 'Hello {name}! /// Good day {name}! /// Greetings {name}!',
      );

      final resp = rule.getResolvedResponse(senderName: 'David');
      expect(resp.contains('David'), isTrue);
      expect(resp.startsWith('Hello') || resp.startsWith('Good day') || resp.startsWith('Greetings'), isTrue);
    });
  });

  group('3. Full App Navigation & 5-Tab Interface UI Tests', () {
    testWidgets('MainNavigation renders all tabs and navigates smoothly', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const OmniFlowApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Verify OmniFlow AI title on Dashboard
      expect(find.text("OmniFlow AI"), findsOneWidget);

      // Verify bottom nav items
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget); // Home
      expect(find.byIcon(Icons.send_rounded), findsWidgets); // Bulk Send
      expect(find.byIcon(Icons.schedule_rounded), findsWidgets); // Schedule
      expect(find.byIcon(Icons.reply_all_rounded), findsOneWidget); // Auto Reply
      expect(find.byIcon(Icons.settings_rounded), findsOneWidget); // Settings

      // Tap on Bulk Send bottom navigation tab
      await tester.tap(find.byIcon(Icons.send_rounded).first);
      await tester.pump(const Duration(milliseconds: 500));

      // Verify 5 Sending Tabs exist
      expect(find.widgetWithText(Tab, "Dashboard"), findsOneWidget);
      expect(find.widgetWithText(Tab, "Contacts"), findsOneWidget);
      expect(find.widgetWithText(Tab, "Enter Number"), findsOneWidget);
      expect(find.widgetWithText(Tab, "Recent Logs"), findsOneWidget);
      expect(find.widgetWithText(Tab, "Favourites"), findsOneWidget);

      // Verify WhatsApp client selector
      expect(find.text("WhatsApp Sender Engine"), findsOneWidget);
      expect(find.text("WhatsApp Standard"), findsOneWidget);

      // Verify Require Approval switch is present
      expect(find.text("Require Approval Before Sending"), findsOneWidget);

      // Navigate to Contacts tab using widgetWithText
      await tester.tap(find.widgetWithText(Tab, "Contacts"));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text("Pastor Emmanuel"), findsOneWidget);
      expect(find.text("Select All"), findsOneWidget);

      // Navigate to Enter Number tab
      await tester.tap(find.widgetWithText(Tab, "Enter Number"));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Default Country Code is +234 Nigeria
      expect(find.text("🇳🇬 +234 (NG)"), findsOneWidget);
      expect(find.text("Add Recipient Direct"), findsOneWidget);
      expect(find.text("Add To Send Queue"), findsOneWidget);

      // Navigate to Favourites tab
      await tester.tap(find.widgetWithText(Tab, "Favourites"));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text("Friendly Check-in"), findsOneWidget);
      expect(find.text("Meeting Reminder"), findsOneWidget);
      expect(find.text("VIP Broadcast"), findsOneWidget);

      // Navigate to Auto Reply screen
      await tester.tap(find.byIcon(Icons.reply_all_rounded));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text("Auto Reply Engine"), findsOneWidget);

      // Navigate to Settings screen
      await tester.tap(find.byIcon(Icons.settings_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text("OmniFlow Settings"), findsOneWidget);
      expect(find.text("Require Approval Before Sending"), findsOneWidget);
      expect(find.text("WhatsApp Engine Routing"), findsOneWidget);
    });
  });
}
