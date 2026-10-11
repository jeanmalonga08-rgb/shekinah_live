import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shekinah_live/data/datasources/branham_predications_remote_datasource.dart';
import 'package:shekinah_live/presentation/widgets/content_share_helper.dart';

void main() {
  test('builds a spaced Branham share message without sermon links', () {
    final message = buildBranhamPredicationShareText(
      title: 'La foi est une ferme assurance',
      code: 'FRN 47-0412',
      location: 'Oakland CA',
      appInvitation: 'Téléchargez Shekinah Live : https://store.example/app',
    );

    expect(
      message,
      'La foi est une ferme assurance\n\n'
      'William Branham · FRN 47-0412\n'
      'Oakland CA\n\n'
      'Téléchargez Shekinah Live : https://store.example/app',
    );
    expect(message, isNot(contains('.m4a')));
    expect(message, isNot(contains('branham.org')));
  });

  test('parses Branham result cards and audio links', () {
    const fragment = '''
      <div class="messagebox">
        <div class="prodtext"> FRN 65-0118X </div>
        <span class="prodtexttitle">La semence de discorde</span>
        <div class="prodtext2">Phoenix AZ</div>
        <div class="prodtext2">87 min</div>
        <div class="prodtext2">10/30/2023</div>
        <a href="https://audio.example/sermon.m4a">Audio</a>
        <a href="https://docs.example/sermon.pdf">PDF</a>
        <a href="/fr/messagestream/FRN=65-0118X">Stream</a>
      </div>
    ''';

    final results = parseBranhamPredicationResults(fragment);

    expect(results, hasLength(1));
    expect(results.single.code, 'FRN 65-0118X');
    expect(results.single.title, 'La semence de discorde');
    expect(results.single.location, 'Phoenix AZ');
    expect(results.single.durationMinutes, 87);
    expect(results.single.dateLabel, '10/30/2023');
    expect(results.single.audioUrl, 'https://audio.example/sermon.m4a');
    expect(results.single.pdfUrl, 'https://docs.example/sermon.pdf');
    expect(
      results.single.streamUrl,
      'https://branham.org/fr/messagestream/FRN=65-0118X',
    );
  });

  test('selects the default language before the first search', () async {
    const catalogHtml = '''
      <div id="currentlang">FRN</div>
      <form id="frmcms">
        <select name="ctl00\$main\$ddllanguages">
          <option value="">Choisir</option>
          <option value="FRN">Français</option>
        </select>
        <select name="ctl00\$main\$ddlyears"><option value="">Année</option></select>
        <select name="ctl00\$main\$ddlnarrowlength"><option value="">Durée</option></select>
        <select name="ctl00\$main\$ddlseries"><option value="">Série</option></select>
      </form>
    ''';
    final endpoints = <String>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://branham.org'));
    final dataSource = BranhamPredicationsRemoteDataSource(dio: dio);
    final cookiesByEndpoint = <String, String?>{};
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          endpoints.add(options.uri.path);
          cookiesByEndpoint[options.uri.path] =
              options.headers['cookie'] as String?;
          final Object responseData;
          if (options.uri.path == '/fr/MessageAudio') {
            responseData = catalogHtml;
          } else if (options.uri.path.endsWith('/wmSetLanguage')) {
            responseData = {'d': 'FRN|'};
          } else {
            responseData = {'d': ['', '0', '0', '0']};
          }
          handler.resolve(
            Response(
              requestOptions: options,
              data: responseData,
              headers: options.uri.path == '/fr/MessageAudio'
                  ? Headers.fromMap({
                      'set-cookie': [
                        'ASP.NET_SessionId=test-session; path=/; HttpOnly',
                      ],
                    })
                  : Headers(),
              statusCode: 200,
            ),
            true,
          );
        },
      ),
    );

    final catalog = await dataSource.fetchCatalog();
    await dataSource.fetchPredications(language: catalog.defaultLanguage);

    expect(catalog.defaultLanguage, 'FRN');
    expect(
      endpoints,
      ['/fr/MessageAudio', '/branham/messageaudio.aspx/wmSetLanguage', '/branham/messageaudio.aspx/wmSearch'],
    );
    expect(
      cookiesByEndpoint['/branham/messageaudio.aspx/wmSetLanguage'],
      contains('ASP.NET_SessionId=test-session'),
    );
    expect(
      cookiesByEndpoint['/branham/messageaudio.aspx/wmSearch'],
      contains('ASP.NET_SessionId=test-session'),
    );
  });
}