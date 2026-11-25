import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/domain/normalizer.dart';

void main() {
  test('i titoli in alfabeti non latini non si riducono a stringa vuota', () {
    expect(normalize('ドラゴンクエスト'), isNotEmpty);
    expect(normalize('Тетрис'), 'тетрис');
    expect(normalize('ドラゴンクエスト'), isNot(normalize('ファイナルファンタジー')));
  });

  test('due nomi fatti di soli simboli restano distinti', () {
    expect(normalize('★'), isNotEmpty);
    expect(normalize('★'), isNot(normalize('♥')));
    expect(normalize('★  ★'), normalize('★ ★'));
  });
}
