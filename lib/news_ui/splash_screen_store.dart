import 'package:mobx/mobx.dart';
import 'package:news_app/news_api/news_service.dart';
import 'package:news_app/news-schema/news_model.dart';

part 'splash_screen_store.g.dart';

class SplashScreenStore = _SplashScreenStore with _$SplashScreenStore;

abstract class _SplashScreenStore with Store {
  final NewsService newsService = NewsService();

  @observable
  bool newsLoaded = false;

  @observable
  bool hasError = false;

  @observable
  List<NewsModel> newsArticles = [];

  @action
  Future<void> fetchNews() async {
    try {
      newsArticles = await newsService.fetchNews();
      newsLoaded = true;
    } catch (e) {
      hasError = true;
      newsLoaded = true;
    }
  }

  @action
  void reload() {
    hasError = false;
    newsLoaded = false;
    fetchNews();
  }
}
