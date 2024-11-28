// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_screen_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SplashScreenStore on _SplashScreenStore, Store {
  late final _$newsLoadedAtom =
      Atom(name: '_SplashScreenStore.newsLoaded', context: context);

  @override
  bool get newsLoaded {
    _$newsLoadedAtom.reportRead();
    return super.newsLoaded;
  }

  @override
  set newsLoaded(bool value) {
    _$newsLoadedAtom.reportWrite(value, super.newsLoaded, () {
      super.newsLoaded = value;
    });
  }

  late final _$hasErrorAtom =
      Atom(name: '_SplashScreenStore.hasError', context: context);

  @override
  bool get hasError {
    _$hasErrorAtom.reportRead();
    return super.hasError;
  }

  @override
  set hasError(bool value) {
    _$hasErrorAtom.reportWrite(value, super.hasError, () {
      super.hasError = value;
    });
  }

  late final _$newsArticlesAtom =
      Atom(name: '_SplashScreenStore.newsArticles', context: context);

  @override
  List<NewsModel> get newsArticles {
    _$newsArticlesAtom.reportRead();
    return super.newsArticles;
  }

  @override
  set newsArticles(List<NewsModel> value) {
    _$newsArticlesAtom.reportWrite(value, super.newsArticles, () {
      super.newsArticles = value;
    });
  }

  late final _$fetchNewsAsyncAction =
      AsyncAction('_SplashScreenStore.fetchNews', context: context);

  @override
  Future<void> fetchNews() {
    return _$fetchNewsAsyncAction.run(() => super.fetchNews());
  }

  late final _$_SplashScreenStoreActionController =
      ActionController(name: '_SplashScreenStore', context: context);

  @override
  void reload() {
    final _$actionInfo = _$_SplashScreenStoreActionController.startAction(
        name: '_SplashScreenStore.reload');
    try {
      return super.reload();
    } finally {
      _$_SplashScreenStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
newsLoaded: ${newsLoaded},
hasError: ${hasError},
newsArticles: ${newsArticles}
    ''';
  }
}
