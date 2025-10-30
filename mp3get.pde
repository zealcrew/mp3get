import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import java.util.Date;

PrintWriter _log;
int currentTrack = 0;
String _baseURL = "https://www.italo-disco.net";
String _dirURL = "/MP3 Player/2. 80s MOB MP3/";
int delayBetweenDownloads = 5000;
String _basePath = "data/";
String _trackPath = "80s/"; // ItaloDisco
String _listURL = "https://www.italo-disco.net/MP3%20Player/2.%2080s%20MOB%20MP3/";
String userAgentString = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36 Edg/129.0.0.0";
Elements _block;
Element _track;

void setup () {
  size(50, 50);
  _log = createWriter(_basePath + "dowmloads.log");
  try {
    println(_listURL);
    Document doc = Jsoup.connect(_listURL).userAgent(userAgentString).get();
    _block = doc.select("body > table > tbody > tr > td > a");
  }
  catch (Exception e) {
    println("Ошибка: " + e.getMessage());
    e.printStackTrace();
  }
}

void draw () {

  for (int i = 1; i < _block.size(); i++) {
    _track = _block.get(i);
    try {
      if (_track != null) {
        String _URL =  _track.attr("href");
        String _decodedURL = java.net.URLDecoder.decode(_URL, "UTF-8");
        String _name = _decodedURL.substring(_decodedURL.lastIndexOf('/') + 1);
        String _encodedQuery = _baseURL + _dirURL.replace(" ", "%20") + _decodedURL.replace(" ", "%20");
        println(i + ". " + _name + " ===> " + _encodedQuery);
        downloadMP3(_encodedQuery, _name);
        println("Пауза " + delayBetweenDownloads/1000 + " секунд...");
        delay(delayBetweenDownloads);
      } else {
        println("Элемент не найден");
      }
    }

    catch (Exception e) {
      println("Ошибка: " + e.getMessage());
      e.printStackTrace();
    }
  }
  noLoop();
  println("------------ конец ------------");
}


void downloadMP3(String url, String filename) {

  InputStream input = createInput(sketchPath(_basePath) + _trackPath + filename);

  if (input != null) {
    log("-- skip -- Файл " + filename + " уже существует...");
    delayBetweenDownloads = 0;
  } else {
    delayBetweenDownloads = 5;
    try {
      log("==>> Скачиваем: " + filename);
      byte[] data = loadBytes(url);
      if (data != null && data.length > 0) {
        saveBytes(sketchPath(_basePath) + _trackPath + filename, data);
        log("++ Успешно: " + filename + " (" + data.length/1024 + " KB)");
      } else {
        log("! Ошибка загрузки: " + filename);
      }
    }

    catch (Exception e) {
      log("! Ошибка скачивания '" + filename + "': " + e.getMessage());
    }
  }
}

String normalizeFilename(String filename) {
  return filename.toLowerCase().replace(" ", "_");
}

void log(String message) {
  println(message);
  if (_log != null) {
    _log.println("[" + new Date() + "] " + message);
    _log.flush();
  }
}
