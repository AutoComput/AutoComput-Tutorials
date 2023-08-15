// You will need all the code below as well as the automatic imports that FlutterFlow provides:
/* // Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!
*/


//Optional but useful: You will need to make a custom function called 'formatBytes' and use this code to convert the file size into a readable format:

/*
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
*/

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

Future customUploader(
    DocumentReference projectRef, DocumentReference userRef) async {
  // Allows the user to pick multiple files, change to false to only allow one file
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(allowMultiple: true);

  // Retrieves the project ID
  String projectID = projectRef.id;

  // Retrieves user information
  DocumentSnapshot userSnapshot = await userRef.get();
  Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

  // Checks if any files were selected
  if (result != null) {
    // Allows uploads to happen in parallel
    List<Future<void>> uploadFutures = [];

    // Loops through the selected files
    for (var file in result.files) {
      uploadFutures.add(
        // Adding all the uploads to the list of futures
        () async {
          try {
            // Specifies the storage location for the file
            final ref = FirebaseStorage.instance.ref().child(
                'workOrderUploads/${projectID}/${file.name}'); // Change to whatever folder/path you like

            // Determines the MIME type of the file
            // i.e. the file name and extension and the type.
            final mimeType = lookupMimeType(file.name);

            // Initiates the upload process
            UploadTask uploadTask = ref.putData(
              file.bytes!,
              SettableMetadata(contentType: mimeType),
            );

            // Waits for the upload task to complete
            TaskSnapshot taskSnapshot = await uploadTask;

            // Retrieves metadata and download URL
            FullMetadata metadata = await taskSnapshot.ref.getMetadata();
            String downloadUrl = await taskSnapshot.ref.getDownloadURL();
            // Converts file size to human-readable form
            String humanReadableSize = formatBytes(metadata.size ?? 0, 2);

            // Creates a record of the uploaded file with various metadata.
            var uploadRecord = {
              'downloadURL': downloadUrl,
              'workOrderReference': projectRef.path,
              'firebasePathReference': metadata.fullPath,
              'fileName': metadata.name,
              'fileType': mimeType,
              'fileSize': metadata.size,
              'fileSizeHumanReadable': humanReadableSize,
              'timeCreated': metadata.timeCreated,
              'lastUpdated': metadata.updated,
              'owner': userRef,
              'ownerDisplayName': userData['display_name'],
              'ownerPhotoUrl': userData['photo_url'],
            };

            // Adds the upload record to a Firestore subcollection
            await projectRef.collection('uploadedFiles').add(uploadRecord);
            print('Record added for file: ${metadata.name}');
          } catch (e) {
            // Prints an error message if the upload fails
            print(
                'Failed to upload and save metadata for file ${file.name}: $e');
          }
        }(),
      );
    }

    // Waits for all file uploads to complete in parallel
    await Future.wait(uploadFutures);
  } else {
    return; // Exits the function if no files were selected
  }
}
