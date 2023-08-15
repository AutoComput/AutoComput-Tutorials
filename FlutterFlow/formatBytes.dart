// This is a custom "Function" in Flutterflow; directly aids the customUploader custom "Action"
// Helper function for the customUploader used in FlutterFlow
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../flutter_flow/lat_lng.dart';
import '../../flutter_flow/place.dart';
import '../../flutter_flow/uploaded_file.dart';
import '../../flutter_flow/custom_functions.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

String formatBytes(
  int bytes,
  int decimals,
) {
  /// MODIFY CODE ONLY BELOW THIS LINE

  // If the number of bytes is zero or negative, return "0 B"
  if (bytes <= 0) return "0 B";

  // Suffixes to represent the units of the file size
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB"];

  // Calculate the logarithm to base 1024 of the bytes to determine the appropriate suffix index
  var i = (math.log(bytes) / math.log(1024)).floor();

  // Convert the bytes to the correct unit, round to the specified number of decimals, and append the appropriate suffix
  return ((bytes / math.pow(1024, i)).toStringAsFixed(decimals)) +
      ' ' +
      suffixes[i];

  /// MODIFY CODE ONLY ABOVE THIS LINE
}
