class GreetingUtil {
  static String getGreeting() {
    final hora = DateTime.now().hour;

    if (hora >= 5 && hora < 12) {
      return 'BUENOS DÍAS';
    } else if (hora >= 12 && hora < 18) {
      return 'BUENAS TARDES';
    } else {
      return 'BUENAS NOCHES';
    }
  }
}
