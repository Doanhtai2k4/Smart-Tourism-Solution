enum Currency {
  vnd,
  usd,
  eur,
  gbp,
  jpy,
  cad,
  aud,
  inr;

  String get symbol {
    switch (this) {
      case Currency.vnd:
        return '₫';
      case Currency.usd:
        return '\$';
      case Currency.eur:
        return '€';
      case Currency.gbp:
        return '£';
      case Currency.jpy:
        return '¥';
      case Currency.cad:
        return 'C\$';
      case Currency.aud:
        return 'A\$';
      case Currency.inr:
        return '₹';
    }
  }

  String get label {
    switch (this) {
      case Currency.vnd:
        return 'VNĐ';
      case Currency.usd:
        return 'USD';
      case Currency.eur:
        return 'EUR';
      case Currency.gbp:
        return 'GBP';
      case Currency.jpy:
        return 'JPY';
      case Currency.cad:
        return 'CAD';
      case Currency.aud:
        return 'AUD';
      case Currency.inr:
        return 'INR';
    }
  }
}