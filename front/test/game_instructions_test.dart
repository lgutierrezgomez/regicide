import 'package:flutter_test/flutter_test.dart';
import 'package:front/core/rules/game_instructions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads paginated instruction pages from bundled asset', () async {
    final pages = await GameInstructions.load();
    expect(pages.length, greaterThanOrEqualTo(6));
    expect(pages.first.title, isNotEmpty);
    expect(pages.first.body, isNotEmpty);
  });
}
