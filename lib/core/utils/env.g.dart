// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env.dart';

// **************************************************************************
// EnviedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: .env
final class _Env {
  static const List<int> _enviedkeyfdcApiKey = <int>[
    2746334971,
    3808847371,
    235274088,
    1529354350,
    1187561827,
    2685549405,
    3211049423,
    855629228,
  ];

  static const List<int> _envieddatafdcApiKey = <int>[
    2746334882,
    3808847428,
    235274045,
    1529354300,
    1187561788,
    2685549334,
    3211049354,
    855629301,
  ];

  static final String fdcApiKey = String.fromCharCodes(List<int>.generate(
    _envieddatafdcApiKey.length,
    (int i) => i,
    growable: false,
  ).map((int i) => _envieddatafdcApiKey[i] ^ _enviedkeyfdcApiKey[i]));

  static const List<int> _enviedkeysentryDns = <int>[
    1674937581,
    3120279333,
    3542739470,
    3002172609,
    862269082,
    3595367284,
    3062643635,
  ];

  static const List<int> _envieddatasentryDns = <int>[
    1674937513,
    3120279403,
    3542739549,
    3002172574,
    862269135,
    3595367206,
    3062643711,
  ];

  static final String sentryDns = String.fromCharCodes(List<int>.generate(
    _envieddatasentryDns.length,
    (int i) => i,
    growable: false,
  ).map((int i) => _envieddatasentryDns[i] ^ _enviedkeysentryDns[i]));

  static const List<int> _enviedkeysupabaseProjectUrl = <int>[
    2805166732,
    4177226688,
    2367126237,
    133472573,
    2319488342,
    4097825618,
    1724605985,
    563189411,
    2387146050,
    2855980266,
    750383601,
  ];

  static const List<int> _envieddatasupabaseProjectUrl = <int>[
    2805166812,
    4177226642,
    2367126162,
    133472631,
    2319488275,
    4097825553,
    1724606069,
    563189500,
    2387146007,
    2855980216,
    750383549,
  ];

  static final String supabaseProjectUrl = String.fromCharCodes(
      List<int>.generate(
    _envieddatasupabaseProjectUrl.length,
    (int i) => i,
    growable: false,
  ).map((int i) =>
          _envieddatasupabaseProjectUrl[i] ^ _enviedkeysupabaseProjectUrl[i]));

  static const List<int> _enviedkeysupabaseProjectAnonKey = <int>[
    2416322065,
    950352809,
    594074072,
    2131009693,
    3191741335,
    4050297388,
    437003060,
    2294399555,
  ];

  static const List<int> _envieddatasupabaseProjectAnonKey = <int>[
    2416322128,
    950352871,
    594074007,
    2131009747,
    3191741384,
    4050297447,
    437003121,
    2294399514,
  ];

  static final String supabaseProjectAnonKey = String.fromCharCodes(
      List<int>.generate(
    _envieddatasupabaseProjectAnonKey.length,
    (int i) => i,
    growable: false,
  ).map((int i) =>
          _envieddatasupabaseProjectAnonKey[i] ^
          _enviedkeysupabaseProjectAnonKey[i]));

  static const List<int> _enviedkeygeminiApiKey = <int>[];

  static const List<int> _envieddatageminiApiKey = <int>[];

  static final String geminiApiKey = String.fromCharCodes(List<int>.generate(
    _envieddatageminiApiKey.length,
    (int i) => i,
    growable: false,
  ).map((int i) => _envieddatageminiApiKey[i] ^ _enviedkeygeminiApiKey[i]));
}
