class CountryCode {
  final String name;
  final String code;
  final String flag;
  final String dialCode;
  final int minLength;
  final int maxLength;

  const CountryCode({
    required this.name,
    required this.code,
    required this.flag,
    required this.dialCode,
    required this.minLength,
    required this.maxLength,
  });
}

class CountryCodeService {
  static const List<CountryCode> countries = [
    // Popular countries first
    CountryCode(
      name: 'Sri Lanka',
      code: 'LK',
      flag: '🇱🇰',
      dialCode: '+94',
      minLength: 9,
      maxLength: 9,
    ),
    CountryCode(
      name: 'United States',
      code: 'US',
      flag: '🇺🇸',
      dialCode: '+1',
      minLength: 10,
      maxLength: 10,
    ),
    CountryCode(
      name: 'United Kingdom',
      code: 'GB',
      flag: '🇬🇧',
      dialCode: '+44',
      minLength: 10,
      maxLength: 11,
    ),
    CountryCode(
      name: 'India',
      code: 'IN',
      flag: '🇮🇳',
      dialCode: '+91',
      minLength: 10,
      maxLength: 10,
    ),
    CountryCode(
      name: 'Australia',
      code: 'AU',
      flag: '🇦🇺',
      dialCode: '+61',
      minLength: 9,
      maxLength: 9,
    ),
    CountryCode(
      name: 'Canada',
      code: 'CA',
      flag: '🇨🇦',
      dialCode: '+1',
      minLength: 10,
      maxLength: 10,
    ),
    // Additional countries alphabetically
    CountryCode(
      name: 'Afghanistan',
      code: 'AF',
      flag: '🇦🇫',
      dialCode: '+93',
      minLength: 8,
      maxLength: 9,
    ),
    CountryCode(
      name: 'Albania',
      code: 'AL',
      flag: '🇦🇱',
      dialCode: '+355',
      minLength: 8,
      maxLength: 9,
    ),
    CountryCode(
      name: 'Algeria',
      code: 'DZ',
      flag: '🇩🇿',
      dialCode: '+213',
      minLength: 8,
      maxLength: 9,
    ),
    CountryCode(
      name: 'Argentina',
      code: 'AR',
      flag: '🇦🇷',
      dialCode: '+54',
      minLength: 10,
      maxLength: 11,
    ),
    CountryCode(
      name: 'Bangladesh',
      code: 'BD',
      flag: '🇧🇩',
      dialCode: '+880',
      minLength: 10,
      maxLength: 10,
    ),
    CountryCode(
      name: 'Brazil',
      code: 'BR',
      flag: '🇧🇷',
      dialCode: '+55',
      minLength: 10,
      maxLength: 11,
    ),
    CountryCode(
      name: 'China',
      code: 'CN',
      flag: '🇨🇳',
      dialCode: '+86',
      minLength: 11,
      maxLength: 11,
    ),
    CountryCode(
      name: 'Egypt',
      code: 'EG',
      flag: '🇪🇬',
      dialCode: '+20',
      minLength: 10,
      maxLength: 10,
    ),
    CountryCode(
      name: 'France',
      code: 'FR',
      flag: '🇫🇷',
      dialCode: '+33',
      minLength: 9,
      maxLength: 9,
    ),
    CountryCode(
      name: 'Germany',
      code: 'DE',
      flag: '🇩🇪',
      dialCode: '+49',
      minLength: 10,
      maxLength: 12,
    ),
    CountryCode(
      name: 'Indonesia',
      code: 'ID',
      flag: '🇮🇩',
      dialCode: '+62',
      minLength: 9,
      maxLength: 12,
    ),
    CountryCode(
      name: 'Italy',
      code: 'IT',
      flag: '🇮🇹',
      dialCode: '+39',
      minLength: 9,
      maxLength: 10,
    ),
    CountryCode(
      name: 'Japan',
      code: 'JP',
      flag: '🇯🇵',
      dialCode: '+81',
      minLength: 10,
      maxLength: 11,
    ),
    CountryCode(
      name: 'Malaysia',
      code: 'MY',
      flag: '🇲🇾',
      dialCode: '+60',
      minLength: 9,
      maxLength: 10,
    ),
    CountryCode(
      name: 'Mexico',
      code: 'MX',
      flag: '🇲🇽',
      dialCode: '+52',
      minLength: 10,
      maxLength: 10,
    ),
    CountryCode(
      name: 'Netherlands',
      code: 'NL',
      flag: '🇳🇱',
      dialCode: '+31',
      minLength: 9,
      maxLength: 9,
    ),
    CountryCode(
      name: 'New Zealand',
      code: 'NZ',
      flag: '🇳🇿',
      dialCode: '+64',
      minLength: 8,
      maxLength: 9,
    ),
    CountryCode(
      name: 'Pakistan',
      code: 'PK',
      flag: '🇵🇰',
      dialCode: '+92',
      minLength: 10,
      maxLength: 10,
    ),
    CountryCode(
      name: 'Philippines',
      code: 'PH',
      flag: '🇵🇭',
      dialCode: '+63',
      minLength: 10,
      maxLength: 10,
    ),
    CountryCode(
      name: 'Russia',
      code: 'RU',
      flag: '🇷🇺',
      dialCode: '+7',
      minLength: 10,
      maxLength: 10,
    ),
    CountryCode(
      name: 'Singapore',
      code: 'SG',
      flag: '🇸🇬',
      dialCode: '+65',
      minLength: 8,
      maxLength: 8,
    ),
    CountryCode(
      name: 'South Africa',
      code: 'ZA',
      flag: '🇿🇦',
      dialCode: '+27',
      minLength: 9,
      maxLength: 9,
    ),
    CountryCode(
      name: 'South Korea',
      code: 'KR',
      flag: '🇰🇷',
      dialCode: '+82',
      minLength: 10,
      maxLength: 11,
    ),
    CountryCode(
      name: 'Spain',
      code: 'ES',
      flag: '🇪🇸',
      dialCode: '+34',
      minLength: 9,
      maxLength: 9,
    ),
    CountryCode(
      name: 'Thailand',
      code: 'TH',
      flag: '🇹🇭',
      dialCode: '+66',
      minLength: 9,
      maxLength: 9,
    ),
    CountryCode(
      name: 'Turkey',
      code: 'TR',
      flag: '🇹🇷',
      dialCode: '+90',
      minLength: 10,
      maxLength: 10,
    ),
    CountryCode(
      name: 'United Arab Emirates',
      code: 'AE',
      flag: '🇦🇪',
      dialCode: '+971',
      minLength: 8,
      maxLength: 9,
    ),
    CountryCode(
      name: 'Vietnam',
      code: 'VN',
      flag: '🇻🇳',
      dialCode: '+84',
      minLength: 9,
      maxLength: 10,
    ),
  ];

  /// Get country by dial code
  static CountryCode? getCountryByDialCode(String dialCode) {
    try {
      return countries.firstWhere((country) => country.dialCode == dialCode);
    } catch (e) {
      return null;
    }
  }

  /// Get default country (Sri Lanka)
  static CountryCode getDefaultCountry() {
    return countries.first; // Sri Lanka
  }

  /// Validate phone number for specific country
  static bool isValidPhoneNumber(String phoneNumber, CountryCode country) {
    // Remove all non-digit characters
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check length
    return cleanNumber.length >= country.minLength && 
           cleanNumber.length <= country.maxLength;
  }

  /// Format phone number with country code
  static String formatPhoneNumber(String phoneNumber, CountryCode country) {
    // Remove all non-digit characters
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Add country dial code
    return '${country.dialCode}$cleanNumber';
  }

  /// Search countries by name
  static List<CountryCode> searchCountries(String query) {
    if (query.isEmpty) return countries;
    
    return countries.where((country) => 
      country.name.toLowerCase().contains(query.toLowerCase()) ||
      country.dialCode.contains(query) ||
      country.code.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
