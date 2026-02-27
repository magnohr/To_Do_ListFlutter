class AdsIds {
  static const bool _isTest = false;

  // TESTE (oficial Google)
  static const bannerTest = 'ca-app-pub-3940256099942544/6300978111';

  // PRODUÇÃO (SEU ID REAL)
  static const bannerProd = 'ca-app-pub-3338710274300696/2457393204';

  static String get banner => _isTest ? bannerTest : bannerProd;
}

//ID do app na AdMob
// TaskBookca-app-pub-3338710274300696~7358366093
//
// ID do bloco de anúncios da AdMob
// bannerca-app-pub-3338710274300696/2457393204