class Endpoints{
  static const String baseUrl = 'http://192.168.1.8:8080';
  // static const String baseUrl = 'https://mychats-1.onrender.com';

  static getHeader(){
    return {'Content-Type': 'application/json'};
  }
}