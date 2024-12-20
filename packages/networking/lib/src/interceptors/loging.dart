
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';


class LoggingInterceptor extends InterceptorsWrapper with Interceptor {
  int maxCharactersPerLine = 200;

  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers["accept"] = "application/json";
            
    debugPrint("--> START onRequest");
    debugPrint("--> Method: ${options.method} PATH:${options.path} REQUESTDATA: ${options.data}");
    debugPrint("<-- END onRequest");

    return super.onRequest(options, handler);
  }

  @override
  Future onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    debugPrint("--> START onResponse");
    debugPrint("--> CODE:  ${response.statusCode}");
    String responseAsString = response.data.toString();

    if (responseAsString.length > maxCharactersPerLine) {
      int iterations = (responseAsString.length / maxCharactersPerLine).floor();
      for (int i = 0; i <= iterations; i++) {
        int endingIndex = i * maxCharactersPerLine + maxCharactersPerLine;
        if (endingIndex > responseAsString.length) {
          endingIndex = responseAsString.length;
        }
        // debugPrint("${responseAsString.substring(i * maxCharactersPerLine, endingIndex)}");
      }
    } else {
      // debugPrint("${response.data}");
    }

    debugPrint("<-- END onResponse");
    return super.onResponse(response, handler);
  }

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    debugPrint("--> START onError");
    debugPrint("--> START ${err.response!.data}");
    switch (err.type) {
      case DioErrorType.connectTimeout:
        err.error = "Connection to  server timed out";
        break;
      case DioErrorType.sendTimeout:
        err.error = "Send timeout in connection with  server";
        break;
      case DioErrorType.receiveTimeout:
        err.error = "Receive timeout in connection with  server";
        break;
      case DioErrorType.response:
        if (err.response!.data != null) {
          if (err.response!.data is String) {
            err.error = "${err.response!.statusCode}: ${err.response!.data}";
          } else
            err.error = err.response!.data['message'];
          if (err.response!.statusCode == 404 && err.response!.data is String) {
            err.error = "${err.response!.statusCode} Page not found.";
          }
          if (err.response!.statusCode == 500 && err.response!.data is String) {
            err.error = "${err.response!.statusCode} Internal server error.";
          }

          if (err.response!.statusCode == 401 ||
              err.response!.statusCode == 403) {
            err.error = "Unauthorized";
          }
        } else {
          err.error =
              "Received invalid status code: ${err.response!.statusCode}";
        }
        break;
      case DioErrorType.cancel:
        err.error = "Request to  server was cancelled";
        break;
      case DioErrorType.other:
        err.error = "Connection to Server failed,try again later .";
        break;
    }

    debugPrint("<-- END onError");
    return super.onError(err, handler);
  }
}
