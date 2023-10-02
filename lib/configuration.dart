import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dd;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'FETCH_wdgts.dart';
import 'JsonObj.dart';
import 'cacheBox.dart';
import 'package:pdf/pdf.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pw;


enum NavPages{
  home,
  reminder,
  explore,
  breed,
  settings
}

// user states
enum usrState{
  completeUser,
  newUser,
  userAlreadyExists,
  connectionError
}

enum sliderStatus{ up, left, right, none }

enum profileState { requested, pendingApproval, friend, noFriendship, owner, undefined}
enum requestState { pending, denied, accepted, undefined }
enum petRelation {sender, receiver, none}

String details = 'My job requires moving to another country. '
    'I do not have the opportunity to take the cat with me. '
    'I am looking for good people who will shelter my pet';

Map vaccineFList = {
  "rabies": "Rabies",
  "parvoVirus": "Parvo Virus",
  "distemper": "Distemper",
  "hepatitis": "Hepatitis",
  "parainfluenza": "Parainfluenza",
  "dhpp1": "DHPP first shot",
  "dhpp2": "DHPP second shot",
  "dhpp3": "DHPP third shot",
};

List<Map> categories = [
  {"name": 'Food',"imagePath":'assets/images/Bone.png'},
  {"name": 'Health',"imagePath":'assets/images/Health.png'},
  {"name": 'Breeds',"imagePath":'assets/images/dog.png'},
  {"name": 'Training',"imagePath":'assets/images/Train.png'},
];


List<Map> navList = [
  {'icon': Icons.pets_rounded,'title': 'Adoption'},
  {'icon': Icons.markunread_mailbox_rounded,'title': 'Donation'},
  {'icon': Icons.add_rounded,'title': 'Add Pet'},
  {'icon': Icons.favorite_rounded,'title': 'Favorites'},
  {'icon': Icons.mail_rounded,'title': 'Messages'},
  {'icon': Icons.person,'title': 'Profile'},
];


final key32 = encrypt.Key.fromBase16('faec7d5b616e5e4ff6119894f3d367476f6480208114ef11defc0a8c51ea76b4');
final iv16 =  encrypt.IV.fromBase16('9219d32e744667b39f882f68112f9251');

String encryptString(String s) {


  final encrypter = encrypt.Encrypter(encrypt.AES(key32));

  final encrypted = encrypter.encrypt(s, iv: iv16);

  return encrypted.base16;

}

String decryptString(String s){
  final encrypter = encrypt.Encrypter(encrypt.AES(key32));

  final decrypted = encrypter.decrypt16(s, iv: iv16);

  return decrypted;
}

class SupabaseCredentials{
  static const String APIKEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxzbXFvdWVvYmVic29ldWhpYWF3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2NjYyNTI3MjIsImV4cCI6MTk4MTgyODcyMn0.AD-WjgLJl21S0G9Dtlx7cwOT2bQM2a73n6ysNI9jrfA";
  static const String APIURL = "https://lsmqoueobebsoeuhiaaw.supabase.co";

  static SupabaseClient supabaseClient = SupabaseClient(APIURL, APIKEY);

}

Color primaryColor = const Color(0xff376565);

List<BoxShadow> shadowList = [
  const BoxShadow(color: Colors.grey,blurRadius: 10,offset: Offset(10,10))
];

class Article{
  final String url;
  final String title;
  final String urlImage;
  final String type;

  const Article({
    required this.url,
    required this.title,
    required this.urlImage,
    required this.type,
  });
}

List<Article> articles =  [];
List<Article> health_articles =  [];
List<Article> food_articles =  [];
List<Article> training_articles =  [];
List<Article> breeds_articles =  [];


int getFileSize(File file){
  int sizeInBytes = file.lengthSync();
  int sizeInKb = sizeInBytes ~/ (1024);
  return sizeInKb;
}

Future<bool> notifierChange(ValueNotifier V) {
  Completer<bool> completer = Completer();
  V.addListener(() async {
    completer.complete(V.value);
  });
  return completer.future;
}

extension UniquePets on Iterable<MateRequest>{
  Set<MateRequest> toSetWithRules() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final resultSet = <MateRequest>{};
    for (var element in this) {
      if (element.senderId == uid){
        if (!resultSet.any((e) =>
        (e.receiverPetId == element.receiverPetId) ||
            (e.senderPetId == element.receiverPetId))) {
          resultSet.add(element);
        }
      }else{
        if (!resultSet.any((e) =>
        (e.receiverPetId == element.senderPetId) ||
            (e.senderPetId == element.senderPetId))) {
          resultSet.add(element);
        }
      }

    }
    return resultSet;
  }
}

// class RequestsProvider with ChangeNotifier{
//   List<MateItem> reqItems = <MateItem>[];
//
//   get requests => reqItems;
//
//   get pendingRequests => reqItems.where((item) => item.stat == requestState.pending).toList();
//
//   get friends => reqItems.where((item) => item.stat == requestState.accepted).toList();
//
//   set requestItems(List<MateItem> items){
//     reqItems = items;
//     notifyListeners();
//   }
//
//   addItems(List<MateItem> items){
//     reqItems.addAll(items);
//     notifyListeners();
//   }
//
//   addItem (MateItem item){
//     reqItems.add(item);
//     print('item added: ${item.item.pet.name}');
//     notifyListeners();
//   }
//
//   removeAt(int i){
//     reqItems.removeAt(i);
//     notifyListeners();
//   }
//
//   removeWithId(String id){
//     reqItems.removeWhere((e) => e.request!.id == id);
//     notifyListeners();
//   }
//
//   findRelation(String petId1, String petId2){
//     int i = reqItems.indexWhere((e){
//       return (e.request!.senderPetId == petId1 &&
//               e.request!.receiverPetId == petId2) ||
//           (e.request!.senderPetId == petId2 &&
//               e.request!.receiverPetId == petId1);
//     });
//
//     if (i == -1){
//       return petRelation.none;
//     }else{
//       if (reqItems[i].item.pet.id == petId1){
//         return petRelation.sender;
//       }
//       return petRelation.receiver;
//     }
//   }
//
//   updateRequest(MateRequest request, requestState s){
//     int i = reqItems.indexWhere((e) => e.request!.id == request.id);
//
//     if (i == -1 ) return false;
//
//     reqItems[i].request!.status = s;
//     notifyListeners();
//     return true;
//   }
// }

Future<File> _getImageFromNetwork(String url, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final imagePath = '${directory.path}/$fileName';
  final imageFile = File(imagePath);

  if (imageFile.existsSync()) {
    // Image already exists, return the file.
    return imageFile;
  } else {
    // Image doesn't exist, download it from network and save it.
    final response = await http.get(Uri.parse(url));
    await imageFile.create(recursive: true);
    await imageFile.writeAsBytes(response.bodyBytes);
    return imageFile;
  }
}

Future<ImageProvider> getNetworkImage(String url, String fileName) async {
  final file = await _getImageFromNetwork(url, fileName);
  return FileImage(file);
}

Future<String?> generatePDFImages(List<String> imagePaths) async {
  try{
    final pdf = pw.Document();
    final outputDir = await getApplicationDocumentsDirectory();

    for (final imagePath in imagePaths) {
      final image = img.decodeImage(File(imagePath).readAsBytesSync());
      final pdfImage = pw.MemoryImage(
        Uint8List.fromList(img.encodePng(image!)),
      );

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(pdfImage),
            );
          },
        ),
      );
    }

    final pdfFilePath = '${outputDir.path}/output${Random().nextInt(100)}.pdf';
    final file = File(pdfFilePath);
    await file.writeAsBytes(await pdf.save());

    print('PDF file generated at $pdfFilePath');

    return file.path;
  }catch (e){
    print(e);
    return null;
  }
}

Future<String> getCachedPdfPathWithProgress(
    String pdfUrl, {
      String cacheDirectoryName = 'cached_pdfs',
      Function(int, int)? onReceiveProgress,
    }) async {
  final appDocumentsDirectory = await getApplicationDocumentsDirectory();
  final cacheDirectory = Directory('${appDocumentsDirectory.path}/$cacheDirectoryName');
  if (!cacheDirectory.existsSync()) {
    cacheDirectory.createSync();
  }

  final pdfFilename = pdfUrl.split('/').last;
  final cachedPdfFile = File('${cacheDirectory.path}/$pdfFilename');

  if (cachedPdfFile.existsSync()) {
    return cachedPdfFile.path;
  }

  final dio = dd.Dio();
  try {
    final response = await dio.get(
      pdfUrl,
      options: dd.Options(
        responseType: dd.ResponseType.bytes,
        followRedirects: false, // To avoid following redirects for progress events.
      ),
      onReceiveProgress: onReceiveProgress,
      cancelToken: dd.CancelToken(), // Create a cancel token for canceling the request.
    );

    cachedPdfFile.writeAsBytesSync(response.data);

    return cachedPdfFile.path;
  } catch (e) {
    print('Error downloading PDF: $e');
    return '';
  }
}

// clear cached pdfs

Future<int> clearCachedPDFs() async {
  try {
    // Get the temporary directory where PDF files are cached.
    final Directory tempDir = await getTemporaryDirectory();

    // List all files in the directory.
    final List<FileSystemEntity> files = tempDir.listSync();

    // Define a file extension filter (e.g., '.pdf') to target only PDF files.
    const String pdfExtension = '.pdf';

    int totalSize = 0; // Initialize total size to zero.

    // Iterate through the files and delete PDF files while accumulating their sizes.
    for (final FileSystemEntity file in files) {
      if (file is File && file.path.endsWith(pdfExtension)) {
        final int fileSize = await file.length();
        await file.delete();
        totalSize += fileSize;
      }
    }

    print('Cached PDFs cleared successfully.');
    return totalSize; // Return the total size of deleted files.
  } catch (e) {
    print('Error clearing cached PDFs: $e');
    return -1; // Return -1 to indicate an error.
  }
}


