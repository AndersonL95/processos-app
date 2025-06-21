class HttpService {
  //final baseUrl = "http://10.0.2.2:3000/api";
  static const String host = "http://192.168.0.112:3000/api";

  static Uri buildUri(String path) => Uri.parse('$host$path');
}
