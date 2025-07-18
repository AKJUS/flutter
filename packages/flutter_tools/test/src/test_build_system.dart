// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_tools/src/build_info.dart';
import 'package:flutter_tools/src/build_system/build_system.dart';

class TestBuildSystem implements BuildSystem {
  /// Create a [BuildSystem] instance that returns the provided results in order.
  TestBuildSystem.list(this._results, [this._onRun]) : _exception = null, _singleResult = null;

  /// Create a [BuildSystem] instance that returns the provided result for every build
  /// and buildIncremental request.
  TestBuildSystem.all(this._singleResult, [this._onRun])
    : _exception = null,
      _results = <BuildResult>[];

  /// Create a [BuildSystem] instance that always throws the provided error for every build
  /// and buildIncremental request.
  TestBuildSystem.error(this._exception)
    : _singleResult = null,
      _results = <BuildResult>[],
      _onRun = null;

  final List<BuildResult> _results;
  final BuildResult? _singleResult;
  final Exception? _exception;
  final void Function(Target target, Environment environment)? _onRun;
  var _nextResult = 0;

  @override
  Future<BuildResult> build(
    Target target,
    Environment environment, {
    BuildSystemConfig buildSystemConfig = const BuildSystemConfig(),
  }) async {
    if (_onRun != null) {
      _onRun.call(target, environment);
    }
    if (_exception != null) {
      throw _exception;
    }
    if (_singleResult != null) {
      return _singleResult;
    }
    if (_nextResult >= _results.length) {
      throw StateError('Unexpected build request of ${target.name}');
    }
    return _results[_nextResult++];
  }

  @override
  Future<BuildResult> buildIncremental(
    Target target,
    Environment environment,
    BuildResult? previousBuild,
  ) async {
    if (_onRun != null) {
      _onRun.call(target, environment);
    }
    if (_exception != null) {
      throw _exception;
    }
    if (_singleResult != null) {
      return _singleResult;
    }
    if (_nextResult >= _results.length) {
      throw StateError('Unexpected buildIncremental request of ${target.name}');
    }
    return _results[_nextResult++];
  }
}

/// Encodes a map of key-value pairs into a comma-separated base64 encoded string.
///
/// ## Example
///
/// ```dart
/// print(encodeDartDefines({'FLUTTER_WEB': 'true', 'FLUTTER_WEB_CANVASKIT_URL': 'https://example.com'}));
/// // RkxVVFRFUl9XRUI9dHJ1ZQo=,RkxVVFRFUl9XRUJfQ0FOVkFTS0lUX1VSTD1odHRwczovL2V4YW1wbGUuY29t
/// ```
String encodeDartDefinesMap(Map<String, String> defines) {
  final flattened = <String>[
    for (final MapEntry<String, String> entry in defines.entries) '${entry.key}=${entry.value}',
  ];
  return encodeDartDefines(flattened);
}
