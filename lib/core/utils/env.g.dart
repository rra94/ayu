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
    3657021401,
    2946448976,
    4175114761,
    1657115715,
    905151008,
    2744031763,
    2384445304,
    2154377267,
  ];

  static const List<int> _envieddatafdcApiKey = <int>[
    3657021312,
    2946448927,
    4175114844,
    1657115665,
    905151103,
    2744031832,
    2384445245,
    2154377322,
  ];

  static final String fdcApiKey = String.fromCharCodes(List<int>.generate(
    _envieddatafdcApiKey.length,
    (int i) => i,
    growable: false,
  ).map((int i) => _envieddatafdcApiKey[i] ^ _enviedkeyfdcApiKey[i]));

  static const List<int> _enviedkeysentryDns = <int>[
    2259895305,
    2932588281,
    3287482328,
    3131194324,
    3810021704,
    3362339843,
    1534559167,
  ];

  static const List<int> _envieddatasentryDns = <int>[
    2259895373,
    2932588215,
    3287482251,
    3131194251,
    3810021661,
    3362339921,
    1534559219,
  ];

  static final String sentryDns = String.fromCharCodes(List<int>.generate(
    _envieddatasentryDns.length,
    (int i) => i,
    growable: false,
  ).map((int i) => _envieddatasentryDns[i] ^ _enviedkeysentryDns[i]));

  static const List<int> _enviedkeysupabaseProjectUrl = <int>[
    1882791477,
    777445004,
    221042633,
    1803269778,
    1137907600,
    103704975,
    1867328912,
    1091768422,
    4088276557,
    2767045729,
    3105781910,
  ];

  static const List<int> _envieddatasupabaseProjectUrl = <int>[
    1882791525,
    777445086,
    221042566,
    1803269848,
    1137907669,
    103705036,
    1867328964,
    1091768377,
    4088276504,
    2767045683,
    3105781978,
  ];

  static final String supabaseProjectUrl = String.fromCharCodes(
      List<int>.generate(
    _envieddatasupabaseProjectUrl.length,
    (int i) => i,
    growable: false,
  ).map((int i) =>
          _envieddatasupabaseProjectUrl[i] ^ _enviedkeysupabaseProjectUrl[i]));

  static const List<int> _enviedkeysupabaseProjectAnonKey = <int>[
    2776525815,
    4323829,
    29403773,
    4038482720,
    214285123,
    319418985,
    224503987,
    2345674555,
  ];

  static const List<int> _envieddatasupabaseProjectAnonKey = <int>[
    2776525750,
    4323771,
    29403698,
    4038482798,
    214285084,
    319418914,
    224504054,
    2345674594,
  ];

  static final String supabaseProjectAnonKey = String.fromCharCodes(
      List<int>.generate(
    _envieddatasupabaseProjectAnonKey.length,
    (int i) => i,
    growable: false,
  ).map((int i) =>
          _envieddatasupabaseProjectAnonKey[i] ^
          _enviedkeysupabaseProjectAnonKey[i]));
}
