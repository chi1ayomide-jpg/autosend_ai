import 'package:intl/intl.dart';

/// Variable resolution engine inspired by AutoResponder WA's AnswerReplacements
/// Resolves placeholders like {name}, {first_name}, {time}, {date}, {phone}
class VariableService {
  static const List<String> availableVariables = [
    '{name}',
    '{first_name}',
    '{time}',
    '{date}',
    '{phone}',
  ];

  /// Replaces all supported variable tags with real-time values
  static String resolve(
    String template, {
    String name = 'Friend',
    String phone = '',
    DateTime? now,
  }) {
    final dt = now ?? DateTime.now();
    final timeStr = DateFormat('hh:mm a').format(dt);
    final dateStr = DateFormat('dd MMM yyyy').format(dt);

    final cleanName = name.trim().isEmpty ? 'Friend' : name.trim();
    final firstName = cleanName.split(' ').first;

    var result = template;
    result = result.replaceAll('{name}', cleanName);
    result = result.replaceAll('{first_name}', firstName);
    result = result.replaceAll('{time}', timeStr);
    result = result.replaceAll('{date}', dateStr);
    result = result.replaceAll('{phone}', phone.trim());

    return result;
  }

  /// Normalizes accent marks for fuzzy matching (like AutoResponder WA ignore_accents)
  static String normalizeAccents(String input) {
    const accents = 'àáâãäåèéêëìíîïòóôõöùúûüýÿñç';
    const regular = 'aaaaaaeeeeiiiiooooouuuuyync';

    var output = input.toLowerCase();
    for (int i = 0; i < accents.length; i++) {
      output = output.replaceAll(accents[i], regular[i]);
    }
    return output;
  }
}
