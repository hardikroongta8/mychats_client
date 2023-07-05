import 'dart:async';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RequestRetrier{
  final Dio dio;
  final Connectivity connectivity;

  RequestRetrier({
    required this.dio, 
    required this.connectivity
  });

  Future<Response> scheduleRequestRetry(RequestOptions requestOptions)async{
    StreamSubscription? streamSubscription;
    final responseCompleter = Completer<Response>();
    streamSubscription = connectivity.onConnectivityChanged.listen(
      (connectivityResult){
        if(connectivityResult != ConnectivityResult.none){
          streamSubscription!.cancel();
          responseCompleter.complete(
            dio.fetch(requestOptions)
          );
        }
      }
    );

    return responseCompleter.future;
  }
}