part of 'regex_labels.dart';

String _cap(String text) =>
    text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';

String _joinWith(List<String> words, String and) => words.length == 1
    ? words.first
    : '${words.sublist(0, words.length - 1).join(', ')} $and ${words.last}';

// Türkçe
String _trMin(int n) => 'En az $n karakter';
String _trMax(int n) => 'En fazla $n karakter';
String _trBetween(int a, int b) => '$a–$b karakter';
String _trExact(int n) => 'Tam $n karakter';
String _trUpper(int n) => n == 1 ? 'Bir büyük harf' : 'En az $n büyük harf';
String _trLower(int n) => n == 1 ? 'Bir küçük harf' : 'En az $n küçük harf';
String _trDigit(int n) => n == 1 ? 'Bir rakam' : 'En az $n rakam';
String _trSpecial(int n) =>
    n == 1 ? 'Bir özel karakter' : 'En az $n özel karakter';
String _trRepeat(int n) => 'Aynı karakter art arda $n kez olmasın';
String _trStarts(String t) => '"$t" ile başlasın';
String _trNotStarts(String t) => '"$t" ile başlamasın';
String _trEnds(String t) => '"$t" ile bitsin';
String _trContains(String t) => '"$t" içersin';
String _trOnly(String l) => 'Sadece $l';
String _trNone(String l) => '${l[0].toUpperCase()}${l.substring(1)} olmasın';
String _trJoin(List<String> w) => _joinWith(w, 've');

const _tr = RegexLabels(
  minLength: _trMin,
  maxLength: _trMax,
  lengthBetween: _trBetween,
  exactLength: _trExact,
  uppercase: _trUpper,
  lowercase: _trLower,
  digit: _trDigit,
  special: _trSpecial,
  noRepeating: _trRepeat,
  startsWith: _trStarts,
  notStartsWith: _trNotStarts,
  endsWith: _trEnds,
  contains: _trContains,
  only: _trOnly,
  none: _trNone,
  join: _trJoin,
  chars: {
    RegexChar.letters: 'harfler',
    RegexChar.englishLetters: 'İngilizce harfler (a–z)',
    RegexChar.uppercase: 'büyük harfler',
    RegexChar.lowercase: 'küçük harfler',
    RegexChar.digits: 'rakamlar',
    RegexChar.whitespace: 'boşluk',
    RegexChar.special: 'özel karakterler',
  },
  space: 'boşluk',
  noSpaces: 'Boşluk olmasın',
  email: 'Geçerli e-posta adresi',
  phone: 'Geçerli telefon numarası',
  url: 'Geçerli web adresi',
  iban: 'Geçerli IBAN',
  sameAs: 'Şifreler aynı olmalı',
  required: 'Bu alan zorunlu',
  notContains: 'Adınızı içermesin',
  met: 'tamam',
  unmet: 'eksik',
  strength: ['Çok zayıf', 'Zayıf', 'Orta', 'İyi', 'Güçlü'],
  show: 'Şifreyi göster',
  hide: 'Şifreyi gizle',
  passwordField: 'Şifre',
  emailField: 'E-posta',
  userNameField: 'Kullanıcı adı',
);

// Deutsch
String _deMin(int n) => 'Mindestens $n Zeichen';
String _deMax(int n) => 'Höchstens $n Zeichen';
String _deBetween(int a, int b) => '$a bis $b Zeichen';
String _deExact(int n) => 'Genau $n Zeichen';
String _deUpper(int n) =>
    n == 1 ? 'Ein Großbuchstabe' : 'Mindestens $n Großbuchstaben';
String _deLower(int n) =>
    n == 1 ? 'Ein Kleinbuchstabe' : 'Mindestens $n Kleinbuchstaben';
String _deDigit(int n) => n == 1 ? 'Eine Ziffer' : 'Mindestens $n Ziffern';
String _deSpecial(int n) =>
    n == 1 ? 'Ein Sonderzeichen' : 'Mindestens $n Sonderzeichen';
String _deRepeat(int n) => 'Kein Zeichen $n-mal hintereinander';
String _deStarts(String t) => 'Beginnt mit „$t“';
String _deNotStarts(String t) => 'Beginnt nicht mit „$t“';
String _deEnds(String t) => 'Endet mit „$t“';
String _deContains(String t) => 'Enthält „$t“';
String _deOnly(String l) => 'Nur $l';
String _deNone(String l) => 'Keine $l';
String _deJoin(List<String> w) => _joinWith(w, 'und');

const _de = RegexLabels(
  minLength: _deMin,
  maxLength: _deMax,
  lengthBetween: _deBetween,
  exactLength: _deExact,
  uppercase: _deUpper,
  lowercase: _deLower,
  digit: _deDigit,
  special: _deSpecial,
  noRepeating: _deRepeat,
  startsWith: _deStarts,
  notStartsWith: _deNotStarts,
  endsWith: _deEnds,
  contains: _deContains,
  only: _deOnly,
  none: _deNone,
  join: _deJoin,
  chars: {
    RegexChar.letters: 'Buchstaben',
    RegexChar.englishLetters: 'Buchstaben ohne Umlaute (a–z)',
    RegexChar.uppercase: 'Großbuchstaben',
    RegexChar.lowercase: 'Kleinbuchstaben',
    RegexChar.digits: 'Ziffern',
    RegexChar.whitespace: 'Leerzeichen',
    RegexChar.special: 'Sonderzeichen',
  },
  space: 'Leerzeichen',
  noSpaces: 'Keine Leerzeichen',
  email: 'Gültige E-Mail-Adresse',
  phone: 'Gültige Telefonnummer',
  url: 'Gültige Webadresse',
  iban: 'Gültige IBAN',
  sameAs: 'Passwörter müssen übereinstimmen',
  required: 'Pflichtfeld',
  notContains: 'Enthält nicht deinen Namen',
  met: 'erfüllt',
  unmet: 'nicht erfüllt',
  strength: ['Sehr schwach', 'Schwach', 'Mittel', 'Gut', 'Stark'],
  show: 'Passwort anzeigen',
  hide: 'Passwort ausblenden',
  passwordField: 'Passwort',
  emailField: 'E-Mail',
  userNameField: 'Benutzername',
);

// Español
String _esMin(int n) => 'Al menos $n caracteres';
String _esMax(int n) => 'Como máximo $n caracteres';
String _esBetween(int a, int b) => 'De $a a $b caracteres';
String _esExact(int n) => 'Exactamente $n caracteres';
String _esUpper(int n) =>
    n == 1 ? 'Una letra mayúscula' : 'Al menos $n letras mayúsculas';
String _esLower(int n) =>
    n == 1 ? 'Una letra minúscula' : 'Al menos $n letras minúsculas';
String _esDigit(int n) => n == 1 ? 'Un número' : 'Al menos $n números';
String _esSpecial(int n) =>
    n == 1 ? 'Un carácter especial' : 'Al menos $n caracteres especiales';
String _esRepeat(int n) => 'Sin repetir un carácter $n veces seguidas';
String _esStarts(String t) => 'Comienza con "$t"';
String _esNotStarts(String t) => 'No comienza con "$t"';
String _esEnds(String t) => 'Termina con "$t"';
String _esContains(String t) => 'Contiene "$t"';
String _esOnly(String l) => 'Solo $l';
String _esNone(String l) => 'Sin $l';
String _esJoin(List<String> w) => _joinWith(w, 'y');

const _es = RegexLabels(
  minLength: _esMin,
  maxLength: _esMax,
  lengthBetween: _esBetween,
  exactLength: _esExact,
  uppercase: _esUpper,
  lowercase: _esLower,
  digit: _esDigit,
  special: _esSpecial,
  noRepeating: _esRepeat,
  startsWith: _esStarts,
  notStartsWith: _esNotStarts,
  endsWith: _esEnds,
  contains: _esContains,
  only: _esOnly,
  none: _esNone,
  join: _esJoin,
  chars: {
    RegexChar.letters: 'letras',
    RegexChar.englishLetters: 'letras sin acentos (a–z)',
    RegexChar.uppercase: 'letras mayúsculas',
    RegexChar.lowercase: 'letras minúsculas',
    RegexChar.digits: 'números',
    RegexChar.whitespace: 'espacios',
    RegexChar.special: 'caracteres especiales',
  },
  space: 'espacios',
  noSpaces: 'Sin espacios',
  email: 'Correo electrónico válido',
  phone: 'Número de teléfono válido',
  url: 'Dirección web válida',
  iban: 'IBAN válido',
  sameAs: 'Las contraseñas deben coincidir',
  required: 'Campo obligatorio',
  notContains: 'No contiene tu nombre',
  met: 'cumplido',
  unmet: 'no cumplido',
  strength: ['Muy débil', 'Débil', 'Aceptable', 'Buena', 'Fuerte'],
  show: 'Mostrar contraseña',
  hide: 'Ocultar contraseña',
  passwordField: 'Contraseña',
  emailField: 'Correo electrónico',
  userNameField: 'Nombre de usuario',
);

// Français
String _frMin(int n) => 'Au moins $n caractères';
String _frMax(int n) => 'Au maximum $n caractères';
String _frBetween(int a, int b) => 'De $a à $b caractères';
String _frExact(int n) => 'Exactement $n caractères';
String _frUpper(int n) => n == 1 ? 'Une majuscule' : 'Au moins $n majuscules';
String _frLower(int n) => n == 1 ? 'Une minuscule' : 'Au moins $n minuscules';
String _frDigit(int n) => n == 1 ? 'Un chiffre' : 'Au moins $n chiffres';
String _frSpecial(int n) =>
    n == 1 ? 'Un caractère spécial' : 'Au moins $n caractères spéciaux';
String _frRepeat(int n) => 'Pas le même caractère $n fois de suite';
String _frStarts(String t) => 'Commence par « $t »';
String _frNotStarts(String t) => 'Ne commence pas par « $t »';
String _frEnds(String t) => 'Se termine par « $t »';
String _frContains(String t) => 'Contient « $t »';
String _frOnly(String l) => '${_cap(l)} uniquement';
// "de" becomes "d'" before a vowel or a mute h: "Pas d'espaces".
String _frNone(String l) =>
    RegExp('^[aeiouyhàâéèêîôû]', caseSensitive: false).hasMatch(l)
    ? "Pas d'$l"
    : 'Pas de $l';
String _frJoin(List<String> w) => _joinWith(w, 'et');

const _fr = RegexLabels(
  minLength: _frMin,
  maxLength: _frMax,
  lengthBetween: _frBetween,
  exactLength: _frExact,
  uppercase: _frUpper,
  lowercase: _frLower,
  digit: _frDigit,
  special: _frSpecial,
  noRepeating: _frRepeat,
  startsWith: _frStarts,
  notStartsWith: _frNotStarts,
  endsWith: _frEnds,
  contains: _frContains,
  only: _frOnly,
  none: _frNone,
  join: _frJoin,
  chars: {
    RegexChar.letters: 'lettres',
    RegexChar.englishLetters: 'lettres sans accents (a–z)',
    RegexChar.uppercase: 'majuscules',
    RegexChar.lowercase: 'minuscules',
    RegexChar.digits: 'chiffres',
    RegexChar.whitespace: 'espaces',
    RegexChar.special: 'caractères spéciaux',
  },
  space: 'espaces',
  noSpaces: "Pas d'espaces",
  email: 'Adresse e-mail valide',
  phone: 'Numéro de téléphone valide',
  url: 'Adresse web valide',
  iban: 'IBAN valide',
  sameAs: 'Les mots de passe doivent correspondre',
  required: 'Champ obligatoire',
  notContains: 'Ne contient pas votre nom',
  met: 'respecté',
  unmet: 'non respecté',
  strength: ['Très faible', 'Faible', 'Moyen', 'Bon', 'Fort'],
  show: 'Afficher le mot de passe',
  hide: 'Masquer le mot de passe',
  passwordField: 'Mot de passe',
  emailField: 'E-mail',
  userNameField: "Nom d'utilisateur",
);

// Italiano
String _itMin(int n) => 'Almeno $n caratteri';
String _itMax(int n) => 'Al massimo $n caratteri';
String _itBetween(int a, int b) => 'Da $a a $b caratteri';
String _itExact(int n) => 'Esattamente $n caratteri';
String _itUpper(int n) =>
    n == 1 ? 'Una lettera maiuscola' : 'Almeno $n lettere maiuscole';
String _itLower(int n) =>
    n == 1 ? 'Una lettera minuscola' : 'Almeno $n lettere minuscole';
String _itDigit(int n) => n == 1 ? 'Un numero' : 'Almeno $n numeri';
String _itSpecial(int n) =>
    n == 1 ? 'Un carattere speciale' : 'Almeno $n caratteri speciali';
String _itRepeat(int n) => 'Nessun carattere ripetuto $n volte di fila';
String _itStarts(String t) => 'Inizia con "$t"';
String _itNotStarts(String t) => 'Non inizia con "$t"';
String _itEnds(String t) => 'Termina con "$t"';
String _itContains(String t) => 'Contiene "$t"';
String _itOnly(String l) => 'Solo $l';
String _itNone(String l) => 'Senza $l';
String _itJoin(List<String> w) => _joinWith(w, 'e');

const _it = RegexLabels(
  minLength: _itMin,
  maxLength: _itMax,
  lengthBetween: _itBetween,
  exactLength: _itExact,
  uppercase: _itUpper,
  lowercase: _itLower,
  digit: _itDigit,
  special: _itSpecial,
  noRepeating: _itRepeat,
  startsWith: _itStarts,
  notStartsWith: _itNotStarts,
  endsWith: _itEnds,
  contains: _itContains,
  only: _itOnly,
  none: _itNone,
  join: _itJoin,
  chars: {
    RegexChar.letters: 'lettere',
    RegexChar.englishLetters: 'lettere senza accenti (a–z)',
    RegexChar.uppercase: 'lettere maiuscole',
    RegexChar.lowercase: 'lettere minuscole',
    RegexChar.digits: 'numeri',
    RegexChar.whitespace: 'spazi',
    RegexChar.special: 'caratteri speciali',
  },
  space: 'spazi',
  noSpaces: 'Nessuno spazio',
  email: 'Indirizzo e-mail valido',
  phone: 'Numero di telefono valido',
  url: 'Indirizzo web valido',
  iban: 'IBAN valido',
  sameAs: 'Le password devono coincidere',
  required: 'Campo obbligatorio',
  notContains: 'Non contiene il tuo nome',
  met: 'soddisfatto',
  unmet: 'non soddisfatto',
  strength: ['Molto debole', 'Debole', 'Discreta', 'Buona', 'Forte'],
  show: 'Mostra password',
  hide: 'Nascondi password',
  passwordField: 'Password',
  emailField: 'E-mail',
  userNameField: 'Nome utente',
);

// Português
String _ptMin(int n) => 'Pelo menos $n caracteres';
String _ptMax(int n) => 'No máximo $n caracteres';
String _ptBetween(int a, int b) => 'De $a a $b caracteres';
String _ptExact(int n) => 'Exatamente $n caracteres';
String _ptUpper(int n) =>
    n == 1 ? 'Uma letra maiúscula' : 'Pelo menos $n letras maiúsculas';
String _ptLower(int n) =>
    n == 1 ? 'Uma letra minúscula' : 'Pelo menos $n letras minúsculas';
String _ptDigit(int n) => n == 1 ? 'Um número' : 'Pelo menos $n números';
String _ptSpecial(int n) =>
    n == 1 ? 'Um caractere especial' : 'Pelo menos $n caracteres especiais';
String _ptRepeat(int n) => 'Sem repetir um caractere $n vezes seguidas';
String _ptStarts(String t) => 'Começa com "$t"';
String _ptNotStarts(String t) => 'Não começa com "$t"';
String _ptEnds(String t) => 'Termina com "$t"';
String _ptContains(String t) => 'Contém "$t"';
String _ptOnly(String l) => 'Apenas $l';
String _ptNone(String l) => 'Sem $l';
String _ptJoin(List<String> w) => _joinWith(w, 'e');

const _pt = RegexLabels(
  minLength: _ptMin,
  maxLength: _ptMax,
  lengthBetween: _ptBetween,
  exactLength: _ptExact,
  uppercase: _ptUpper,
  lowercase: _ptLower,
  digit: _ptDigit,
  special: _ptSpecial,
  noRepeating: _ptRepeat,
  startsWith: _ptStarts,
  notStartsWith: _ptNotStarts,
  endsWith: _ptEnds,
  contains: _ptContains,
  only: _ptOnly,
  none: _ptNone,
  join: _ptJoin,
  chars: {
    RegexChar.letters: 'letras',
    RegexChar.englishLetters: 'letras sem acento (a–z)',
    RegexChar.uppercase: 'letras maiúsculas',
    RegexChar.lowercase: 'letras minúsculas',
    RegexChar.digits: 'números',
    RegexChar.whitespace: 'espaços',
    RegexChar.special: 'caracteres especiais',
  },
  space: 'espaços',
  noSpaces: 'Sem espaços',
  email: 'E-mail válido',
  phone: 'Número de telefone válido',
  url: 'Endereço web válido',
  iban: 'IBAN válido',
  sameAs: 'As senhas devem coincidir',
  required: 'Campo obrigatório',
  notContains: 'Não contém seu nome',
  met: 'atendido',
  unmet: 'não atendido',
  strength: ['Muito fraca', 'Fraca', 'Razoável', 'Boa', 'Forte'],
  show: 'Mostrar senha',
  hide: 'Ocultar senha',
  passwordField: 'Senha',
  emailField: 'E-mail',
  userNameField: 'Nome de usuário',
);

// 日本語
String _jaMin(int n) => '$n文字以上';
String _jaMax(int n) => '$n文字以内';
String _jaBetween(int a, int b) => '$a〜$b文字';
String _jaExact(int n) => 'ちょうど$n文字';
String _jaUpper(int n) => '英大文字を$n文字以上含む';
String _jaLower(int n) => '英小文字を$n文字以上含む';
String _jaDigit(int n) => '数字を$n文字以上含む';
String _jaSpecial(int n) => '記号を$n文字以上含む';
String _jaRepeat(int n) => '同じ文字を$n回以上続けない';
String _jaStarts(String t) => '「$t」で始まる';
String _jaNotStarts(String t) => '「$t」で始まらない';
String _jaEnds(String t) => '「$t」で終わる';
String _jaContains(String t) => '「$t」を含む';
String _jaOnly(String l) => '$lのみ';
String _jaNone(String l) => '$lを含まない';
String _jaJoin(List<String> w) => w.join('、');

const _ja = RegexLabels(
  minLength: _jaMin,
  maxLength: _jaMax,
  lengthBetween: _jaBetween,
  exactLength: _jaExact,
  uppercase: _jaUpper,
  lowercase: _jaLower,
  digit: _jaDigit,
  special: _jaSpecial,
  noRepeating: _jaRepeat,
  startsWith: _jaStarts,
  notStartsWith: _jaNotStarts,
  endsWith: _jaEnds,
  contains: _jaContains,
  only: _jaOnly,
  none: _jaNone,
  join: _jaJoin,
  chars: {
    RegexChar.letters: 'かな・漢字・英字',
    RegexChar.englishLetters: '半角英字',
    RegexChar.uppercase: '英大文字',
    RegexChar.lowercase: '英小文字',
    RegexChar.digits: '半角数字',
    RegexChar.whitespace: 'スペース',
    RegexChar.special: '記号',
  },
  space: 'スペース',
  noSpaces: 'スペースを含まない',
  email: '有効なメールアドレス',
  phone: '有効な電話番号',
  url: '有効なURL',
  iban: '有効なIBAN',
  sameAs: 'パスワードが一致している',
  required: '必須項目です',
  notContains: '名前を含まない',
  met: '達成',
  unmet: '未達成',
  strength: ['とても弱い', '弱い', '普通', '強い', 'とても強い'],
  show: 'パスワードを表示',
  hide: 'パスワードを非表示',
  passwordField: 'パスワード',
  emailField: 'メールアドレス',
  userNameField: 'ユーザー名',
);
