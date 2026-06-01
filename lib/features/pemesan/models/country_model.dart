class CountryModel {
  final String name;
  final String code; // cca2
  final String dialCode;
  final String flagUrl;

  CountryModel({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flagUrl,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    final nameMap = json['name'] as Map<String, dynamic>?;
    final commonName = nameMap?['common'] as String? ?? '';
    final cca2 = json['cca2'] as String? ?? '';

    final idd = json['idd'] as Map<String, dynamic>?;
    final root = idd?['root'] as String? ?? '';
    final suffixes = idd?['suffixes'] as List<dynamic>? ?? [];
    String dialCode = root;
    if (root == '+1') {
      dialCode = '+1';
    } else if (suffixes.isNotEmpty) {
      dialCode = '$root${suffixes[0]}';
    }

    final flags = json['flags'] as Map<String, dynamic>?;
    final flagUrl = flags?['png'] as String? ?? '';

    return CountryModel(
      name: commonName,
      code: cca2,
      dialCode: dialCode,
      flagUrl: flagUrl,
    );
  }

  static final List<CountryModel> defaultCountries = [
    CountryModel(
      name: 'Indonesia',
      code: 'ID',
      dialCode: '+62',
      flagUrl: 'https://flagcdn.com/w320/id.png',
    ),
    CountryModel(
      name: 'Malaysia',
      code: 'MY',
      dialCode: '+60',
      flagUrl: 'https://flagcdn.com/w320/my.png',
    ),
    CountryModel(
      name: 'Singapore',
      code: 'SG',
      dialCode: '+65',
      flagUrl: 'https://flagcdn.com/w320/sg.png',
    ),
    CountryModel(
      name: 'United States',
      code: 'US',
      dialCode: '+1',
      flagUrl: 'https://flagcdn.com/w320/us.png',
    ),
    CountryModel(
      name: 'United Kingdom',
      code: 'GB',
      dialCode: '+44',
      flagUrl: 'https://flagcdn.com/w320/gb.png',
    ),
    CountryModel(
      name: 'Australia',
      code: 'AU',
      dialCode: '+61',
      flagUrl: 'https://flagcdn.com/w320/au.png',
    ),
    CountryModel(
      name: 'Japan',
      code: 'JP',
      dialCode: '+81',
      flagUrl: 'https://flagcdn.com/w320/jp.png',
    ),
    CountryModel(
      name: 'South Korea',
      code: 'KR',
      dialCode: '+82',
      flagUrl: 'https://flagcdn.com/w320/kr.png',
    ),
    CountryModel(
      name: 'Saudi Arabia',
      code: 'SA',
      dialCode: '+966',
      flagUrl: 'https://flagcdn.com/w320/sa.png',
    ),
    CountryModel(
      name: 'United Arab Emirates',
      code: 'AE',
      dialCode: '+971',
      flagUrl: 'https://flagcdn.com/w320/ae.png',
    ),
    CountryModel(
      name: 'Brunei',
      code: 'BN',
      dialCode: '+673',
      flagUrl: 'https://flagcdn.com/w320/bn.png',
    ),
    CountryModel(
      name: 'Timor-Leste',
      code: 'TL',
      dialCode: '+670',
      flagUrl: 'https://flagcdn.com/w320/tl.png',
    ),
    CountryModel(
      name: 'Canada',
      code: 'CA',
      dialCode: '+1',
      flagUrl: 'https://flagcdn.com/w320/ca.png',
    ),
    CountryModel(
      name: 'Germany',
      code: 'DE',
      dialCode: '+49',
      flagUrl: 'https://flagcdn.com/w320/de.png',
    ),
    CountryModel(
      name: 'France',
      code: 'FR',
      dialCode: '+33',
      flagUrl: 'https://flagcdn.com/w320/fr.png',
    ),
    CountryModel(
      name: 'Netherlands',
      code: 'NL',
      dialCode: '+31',
      flagUrl: 'https://flagcdn.com/w320/nl.png',
    ),
    CountryModel(
      name: 'China',
      code: 'CN',
      dialCode: '+86',
      flagUrl: 'https://flagcdn.com/w320/cn.png',
    ),
    CountryModel(
      name: 'India',
      code: 'IN',
      dialCode: '+91',
      flagUrl: 'https://flagcdn.com/w320/in.png',
    ),
    CountryModel(
      name: 'New Zealand',
      code: 'NZ',
      dialCode: '+64',
      flagUrl: 'https://flagcdn.com/w320/nz.png',
    ),
    CountryModel(
      name: 'Turkey',
      code: 'TR',
      dialCode: '+90',
      flagUrl: 'https://flagcdn.com/w320/tr.png',
    ),
    CountryModel(
      name: 'Egypt',
      code: 'EG',
      dialCode: '+20',
      flagUrl: 'https://flagcdn.com/w320/eg.png',
    ),
    CountryModel(
      name: 'South Africa',
      code: 'ZA',
      dialCode: '+27',
      flagUrl: 'https://flagcdn.com/w320/za.png',
    ),
    CountryModel(
      name: 'Brazil',
      code: 'BR',
      dialCode: '+55',
      flagUrl: 'https://flagcdn.com/w320/br.png',
    ),
    CountryModel(
      name: 'Russia',
      code: 'RU',
      dialCode: '+7',
      flagUrl: 'https://flagcdn.com/w320/ru.png',
    ),
  ];
}
