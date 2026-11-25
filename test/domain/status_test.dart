import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/domain/enums.dart';

void main() {
  test('«finito» e «completato» sono gli unici stati portati a termine', () {
    expect(GameStatus.finito.isCompleted, isTrue);
    expect(GameStatus.completato.isCompleted, isTrue);
    for (final GameStatus stato in GameStatus.values) {
      if (stato == GameStatus.finito || stato == GameStatus.completato) continue;
      expect(stato.isCompleted, isFalse, reason: '${stato.name} non è una partita portata a termine');
    }
  });

  test('solo gli arcade non si possono finire', () {
    // Decide sia la riga «x su y finiti o completati» dei giochi contenuti in
    // una collection, sia la percentuale nelle statistiche: un cabinato non ha
    // un finale, quindi non sta nemmeno al denominatore.
    expect(GameStatus.arcade.isCompletable, isFalse);
    for (final GameStatus stato in GameStatus.values) {
      if (stato == GameStatus.arcade) continue;
      expect(stato.isCompletable, isTrue, reason: '${stato.name} deve contare nel «su quanti»');
    }
  });
}
