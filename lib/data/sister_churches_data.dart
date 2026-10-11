class SisterChurch {
  const SisterChurch({
    required this.pastors,
    required this.address,
    this.countryCode,
    this.emails = const [],
    this.phones = const [],
  });

  final String pastors;
  final String address;
  final String? countryCode;
  final List<String> emails;
  final List<String> phones;
}

/// Églises sœurs — source : shekinahgospel.org/assemblee/other-churches
const List<SisterChurch> sisterChurches = [
  SisterChurch(
    pastors: 'Fr ADO',
    address: 'Brazzaville / Republic Of Congo',
    countryCode: 'cg',
  ),
  SisterChurch(
    pastors: 'Fr Theo Somue',
    address: 'Congo Central (Kwilu Ngongo) / Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr MICHEL',
    address: 'Congo Central (Matadi) / Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr Martin Mbelu',
    address: 'Nord Kivu (Goma) / Republic Democratic Of Congo',
    countryCode: 'cd',
    emails: ['mbelumartin2@gmail.com', 'marcmamingi1@gmail.com'],
    phones: ['+243822265174'],
  ),
  SisterChurch(
    pastors: 'Fr Obed Diyoka, Minga Makashi & Samuel',
    address: 'Johannesburg / RSA',
    countryCode: 'za',
  ),
  SisterChurch(
    pastors: 'Fr Christian Bosila & Pathy Waba',
    address: 'Durban / RSA',
    countryCode: 'za',
  ),
  SisterChurch(
    pastors: 'Fr Jules Tshibe',
    address: 'Luanda / Angola',
    countryCode: 'ao',
    emails: [
      'malembajulio@yahoo.fr',
      'anselmongoma76@gmail.com',
      'natanielnkosi7@mail.com',
    ],
    phones: ['+244922996350'],
  ),
  SisterChurch(
    pastors: 'Fr Ghyslain Kabeya',
    address: 'Kabinda / Angola',
    countryCode: 'ao',
  ),
  SisterChurch(
    pastors: 'Fr Justino',
    address: 'Soyo / Angola',
    countryCode: 'ao',
  ),
  SisterChurch(
    pastors: 'Fr Guillaume Mputu',
    address: 'Lubumbashi / Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr Pierre Nikongo & Seth BakunzI',
    address: 'Congo Central / Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr Timothee Kalenga',
    address: 'Bandundu (Popokabaka) / Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr Timothee Kalenga',
    address: 'Bandundu (Kalamba) / Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr Sylas Emery',
    address: 'Bandundu / Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr Clement Kalambayi & Aurelien Zimvuama',
    address: 'Bruxelle / Belgique',
    countryCode: 'be',
    emails: [
      'clement.mbala.kalambay@gmail.com',
      'aurelienzimvuama@gmail.com',
    ],
    phones: ['+32479680340'],
  ),
  SisterChurch(
    pastors: 'Fr Elie Pambi & Divin Kipiti',
    address: 'Kisangani / Republic Democratic Of Congo',
    countryCode: 'cd',
    emails: ['eliempambi@gmail.com', 'divinkipiti@gmail.com'],
    phones: ['+243814913750'],
  ),
  SisterChurch(
    pastors: 'Fr Kamil',
    address: 'Sud Kivu (Bukavu) / Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr',
    address: 'Connecticut / USA',
    countryCode: 'us',
  ),
  SisterChurch(
    pastors: 'Fr Robert Bohumu & Caleb Katumbayi',
    address: 'Paris / France',
    countryCode: 'fr',
  ),
  SisterChurch(
    pastors: 'Fr Agapao Dinanga',
    address: 'Congo Central (Kolo Fuma) / Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr Agapao Dinanga',
    address: 'Congo Central (Mvuazi) / Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr Louis Ananini & Pascal & Pierre & Patrick',
    address: 'Lodja / Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr Grace Ipama',
    address: 'Equateur (Bakandjo) / Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr Grace Ipama',
    address: 'Mbandaka / Equateur Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr Grace Ipama',
    address: 'Bandundu (Bangumi) / Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr Elie',
    address: 'Bandundu (Manzasay) / Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr Lazare Bakongela',
    address: 'Bandundu (Inongo) / Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr Lazare Bakongela',
    address: 'Bandundu (Ibenga) / Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr Grace Ipama',
    address: 'Equateur (Djombo) / Republic Democratic Of Congo',
    countryCode: 'cd',
  ),
  SisterChurch(
    pastors: 'Fr Aime Muanza',
    address: 'Dakar / Senegal',
    countryCode: 'sn',
    emails: ['aimemuanza7@gmail.com'],
    phones: ['+221776977687'],
  ),
];

String? sisterChurchFlagUrl(String? countryCode) {
  if (countryCode == null || countryCode.isEmpty) return null;
  return 'https://flagcdn.com/w80/$countryCode.png';
}
