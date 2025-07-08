class HttpService {
  //final baseUrl = "http://10.0.2.2:3000/api";
  static const String host = "http://192.168.0.113:3000/api";

  static Uri buildUri(String path, { Map<String, dynamic>? queryParameters}) => Uri.parse('$host$path');
  static Uri buildUriGet(String path, Map<String, String> map) => Uri.parse('$host$path');
}
