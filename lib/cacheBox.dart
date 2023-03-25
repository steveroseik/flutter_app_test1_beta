import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/JsonObj.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/pages/user_profile.dart';
import 'package:hive/hive.dart';
import 'FETCH_wdgts.dart';



int petLimit = 6;

List<PetBox> petBoxFromJson(String data) => List<PetBox>.from(json.decode(data).map((e) => PetBox.fromJson(e)));
String petBoxToJson(List<PetBox> pets) => json.encode(List<dynamic>.from(pets.map((e) => e.toJson())));

class PetBox{
  PetBox({
    required this.pet,
    required this.expDate
  });

  DateTime expDate;
  PetProfile pet;

  Map<String, dynamic> toJson() =>
      {
        "expDate": expDate.millisecondsSinceEpoch,
        "pet": pet.toJson()
      };

  factory PetBox.fromJson(Map<String, dynamic> json ) =>
      PetBox(
          pet: PetProfile.fromJson(json['pet']),
          expDate: DateTime.fromMillisecondsSinceEpoch(json['expDate']));
}

String userBoxToJson(List<UserBox> user) => json.encode(List<dynamic>.from(user.map((e) => e.toJson())));

class UserBox{

  UserBox({
    required this.user,
    required this.expDate
  });

  UserPod user;
  DateTime expDate;

  Map<String, dynamic> toJson() =>
      {
        "expDate": expDate.millisecondsSinceEpoch,
        "user": user.toJson()
      };

  factory UserBox.fromJson(Map<String, dynamic> json ) =>
      UserBox(
          user: UserPod.fromJson(json['user']),
          expDate: DateTime.fromMillisecondsSinceEpoch(json['expDate']));


}


// List<NotifBox> notifBoxFromJson(String data) => List<NotifBox>.from(json.decode(data).map((e) => PetBox.fromJson(e)));
// String notifBoxToJson(List<NotifBox> pets) => json.encode(List<dynamic>.from(pets.map((e) => e.toJson())));
//
// class NotifBox{
//   NotifBox({
//     required this.request,
//     required this.expDate
//   });
//
//   MateRequest request;
//   DateTime expDate;
//
//   Map<String, dynamic> toJson() =>
//       {
//         "expDate": expDate.millisecondsSinceEpoch,
//         "mateRequest": request.toJson()
//       };
//
//   factory NotifBox.fromJson(Map<String, dynamic> json) =>
//     NotifBox(
//       request: singleMateRequestFromJson(json['mateRequest']),
//       expDate: DateTime.fromMillisecondsSinceEpoch(json['expDate']));
//
// }

class NotifCache{
  late List<MateRequest> _sentRequests;
  late List<MateRequest> _receivedRequests;
  late DateTime _lastSent;
  late DateTime _lastReceived;
  String cacheRef = 'notifications';

  get lastReceived => _lastReceived;
  get lastSent => _lastSent;

  get sentRequests => _sentRequests;
  get receivedRequests => _receivedRequests;

  NotifCache(LazyBox box){
    if (box.isNotEmpty && box.keys.contains(cacheRef)){
      generateNotifications(box);
    }else{
      _sentRequests = <MateRequest>[];
      _receivedRequests = <MateRequest>[];
      _lastReceived = DateTime(1999,1,1);
      _lastSent = DateTime(1999,1,1);
    }
  }

  generateNotifications(LazyBox box) async{
    final uid = FirebaseAuth.instance.currentUser!.uid;
    String data = await box.get(cacheRef);

    _sentRequests = <MateRequest>[];
    _receivedRequests = <MateRequest>[];
    final req = mateRequestFromJson(decryptString(data));

    for (var e in req)
    {e.senderId == uid ? _sentRequests.add(e) : _receivedRequests.add(e);}

    sortAll();
  }

  sortAll(){
    sortSent();
    sortReceived();
  }

  sortSent(){
    if (_sentRequests.isNotEmpty){
      _sentRequests.sort((a,b) => a.lastModified.compareTo(b.lastModified));
      _lastSent = _sentRequests.last.lastModified;
    }else{
      _lastSent = DateTime(1999,1,1);
    }
  }
  sortReceived(){
    if (_receivedRequests.isNotEmpty){
      _receivedRequests.sort((a,b) => a.lastModified.compareTo(b.lastModified));
      _lastReceived = _receivedRequests.last.lastModified;
    }else{
      _lastReceived = DateTime(1999,1,1);
    }
  }

  addNewSent(List<MateRequest> reqs){
    _sentRequests.addAll(reqs);
    // for now
    return -1;
  }

  addNewReceived(List<MateRequest> reqs){
    _receivedRequests.addAll(reqs);
    return -1;
  }

}

class PetCache{
  late List<PetBox> _petList;
  late DateTime _lastFetched;
  late Duration _ttl;
  late String _cacheRef;
  DateTime _lastQueryAt = DateTime(1990, 1, 1);
  bool cacheToDate = true;

  PetCache(LazyBox box, String ref){
    _cacheRef = ref;
    generateConfigs(box);
    if (box.isNotEmpty && box.keys.contains(ref)){
      generatePets(box);
    }else{
      // first general time
      _petList = <PetBox>[];
      _lastFetched = DateTime(1990, 1, 1);
    }
  }

  lastBreedFetched(String b){
    final i = _petList.lastIndexWhere((box) => box.pet.breed == b);

    return i == -1 ? (DateTime(1990, 1, 1)) : (_petList[i].pet.lastModified);
  }

  sortPets(){
    if (_petList.isNotEmpty){
      _petList.sort((a, b) => a.pet.lastModified.compareTo(b.pet.lastModified));
      _lastFetched = _petList.last.pet.lastModified;
    }else{
      _lastFetched = DateTime(1990, 1, 1);
    }
  }
  generatePets(LazyBox box) async{
    String text = await box.get(_cacheRef);
    text = decryptString(text);
    _petList = petBoxFromJson(text);
    sortPets();
  }

  generateConfigs(LazyBox box) async{
    if (box.keys.contains('${_cacheRef}_config')){
      List<dynamic> configs = await box.get('${_cacheRef}_config');
      _ttl = configs[0];
    }else{
      // initial value for pet configs
      _ttl = Duration(days: 3);
    }
  }

  HashMap<String, int> expiredPets(){
    final now = DateTime.now();
    HashMap<String, int> petMap = HashMap();
    for (int i= 0; i < _petList.length; i++)
    {
      if (_petList[i].expDate.isBefore(now)) {
        petMap[_petList[i].pet.id] = i;
      }
    }
    return petMap;
  }

  Future<bool> updateExpired() async{
    HashMap<String, int> petMap = expiredPets();
    bool success = false;
    if (petMap.keys.isNotEmpty){
      try{
        final newDocs = await getPetsWithIDs(petMap.keys.toList());
        addRetrievedPets(petMap, newDocs);
        success = true;
      }catch (e){
        print("cache Error (expiration update): $e");
        success = false;
      }
    }else{
      print('cache is good');
      success = true;
    }
    return success;
  }

  addRetrievedPets(HashMap<String, int> index, List<PetProfile> pets){
    if (pets.isNotEmpty){
      for (var pet in pets){
        _petList[index[pet.id]!] = PetBox(pet: pet, expDate: (pet.lastModified.add(_ttl)));
      }
      sortPets();
      cacheToDate = false;
    }

  }

  Future<List<PetProfile>> getOwnerUpdatedPets() async{
    if (_petList.isNotEmpty){
      print('from cache');
      await updateExpired();
    }else{
      _petList.addAll(await createOwnerPetList());
    }
    return _petList.map((e) => e.pet).toList();
  }

  Future<List<PetBox>> createOwnerPetList() async{
    if (_cacheRef == "ownerPets"){
      final petProfiles = await fetchOwnerPets();
      if (petProfiles.isNotEmpty){
        cacheToDate = false;
        return List<PetBox>.generate(petProfiles.length, (i)
        => PetBox(pet: petProfiles[i], expDate: DateTime.now().add(_ttl)));
      }
    }
    return <PetBox>[];
  }

  refreshPetList(List<PetBox> boxes){
    _petList = boxes;
  }

  store(LazyBox box){

    if (!cacheToDate){
      String data = petBoxToJson(_petList);
      List<dynamic> configs = [_ttl];
      data = encryptString(data);
      box.put(_cacheRef, data);
      box.put("${_cacheRef}_config", configs);
      cacheToDate = true;
    }
  }

  addNewPet(PetProfile pet){
    _petList.add(PetBox(pet: pet, expDate: DateTime.now().add(_ttl)));
    cacheToDate = false;
  }

  // ==== general pet cache flow

 Future<List<PetProfile>> generatePetMatches({required PetProfile pet, bool? reset}) async{

    final petList = fetchMatchesFromCache(pet, reset?? false);
    int remainingPets = petLimit - petList.length;

    print('Remaining From cache: $remainingPets');
    while (remainingPets > 0){
      print('accessed Db');
      final response = await fetchMatchesFromDb(pet, remainingPets);
      petList.addAll(response[0]);
      if (!response[1]){
        break;
      }
      remainingPets = petLimit - petList.length;
    }


    return petList;

  }

  List<PetProfile> fetchMatchesFromCache(PetProfile pet, bool reset){
    DateTime now  = DateTime.now();
    List<PetProfile> matches = <PetProfile>[];
    int index = -1;

    if (reset){
      _lastQueryAt = DateTime(1990,1,1);

    }else{
      if (_lastQueryAt != DateTime(1990,1,1)){
        index = _petList.indexWhere((element) => element.pet.lastModified == _lastQueryAt);
      }
    }
    int count = 0;
    for (var e in _petList.getRange(index+1, _petList.length)){
      if ((e.pet.isMale != pet.isMale) &&
          (e.pet.breed == pet.breed) &&
          (e.expDate.isAfter(now))){
        count++;
        matches.add(e.pet);
      }

      if (count == petLimit){
        break;
      }
    }

    if (matches.isNotEmpty){
      // matches.sort((a, b) => a.lastModified.compareTo(b.lastModified));
      _lastQueryAt = matches.last.lastModified;
    }
    return matches;
  }

  Future<List<dynamic>> fetchMatchesFromDb(PetProfile pet, int limit) async{
    _lastFetched = lastBreedFetched(pet.breed);
    //fetch pets from database
    final pets = await fetchMatchesWithLimits(pet, limit, _lastFetched);
    // add to cache and update cache variables
    updatePetCache(pets);
    if (pets.isEmpty || pets.length < limit) {
      return [pets, false];
    }
    return [pets, true];
  }

  // add new pets fetched into cache
  updatePetCache(List<PetProfile> pets){
   DateTime newExp = DateTime.now().add(_ttl);
   List<int> oldIndices = <int>[];

    for (var pet in pets){
      // find last lastModified date, making use of already create for loop
      if (pet.lastModified.isAfter(_lastQueryAt)) { _lastQueryAt = pet.lastModified;}

      final ind = _petList.indexWhere((element) => element.pet.id == pet.id);
      if (ind != -1){
        _petList[ind].pet = pet;
        _petList[ind].expDate = newExp;
        oldIndices.add(pets.indexOf(pet));
      }else{
        _petList.add(PetBox(pet: pet, expDate: newExp));
      }
    }
    for( int index in oldIndices){
      pets.removeAt(index);
    }

    sortPets();
  }


  getListOfPets(List<String> petIDs) async{
    List<PetProfile> filteredList = <PetProfile>[];
    List<String> nonCached = <String>[];
    int index = -1;
    for (var e in petIDs){
      index = _petList.indexWhere((box) => box.pet.id == e);
      (index == -1) ? nonCached.add(e) : filteredList.add(_petList[index].pet);
    }
    final pets = await getPetsWithIDs(nonCached);
    filteredList.addAll(pets);
    addToCache(pets);
    return filteredList;
  }

  addToCache(List<PetProfile> newPets){
    final now = DateTime.now();

    for ( var e in newPets){
      _petList.add(PetBox(pet: e, expDate: now.add(_ttl)));
    }
  }

}


// ==== ===== ==== === === === === = == = =
// CACHE BOX MAIN

class CacheBox{

  late NotifCache _notifCache;
  late PetCache _petCache;
  late PetCache _ownerPetCache;
  UserPod? _userInfo;
  late LazyBox<dynamic> _lazyBox;
  bool _cacheToDate = true;

  storeCache(){

    _petCache.store(_lazyBox);
    _ownerPetCache.store(_lazyBox);
    if (!_cacheToDate){
      if (_userInfo != null){
        String data = userPodToJson(_userInfo!);
        data = encryptString(data);
        _lazyBox.put('ownerInfo', data);
      }else{
        _lazyBox.delete('ownerInfo');
      }
      _cacheToDate = true;
    }
  }

  CacheBox(){
    initCacheBoxes();
  }

  initOwnerCache() async{

    if (_lazyBox.keys.contains('ownerInfo')){
      String ownerText = await _lazyBox.get('ownerInfo');
      ownerText = decryptString(ownerText);
      _userInfo = userPodFromJson(ownerText);
    }
  }

  initCacheBoxes() async{
    _lazyBox = await Hive.openLazyBox('cache');
    _petCache = PetCache(_lazyBox, 'petCache');
    _ownerPetCache = PetCache(_lazyBox, 'ownerPets');
    _notifCache = NotifCache(_lazyBox);
    // initOwnerCache();
  }

  get lastSentNotif => _notifCache.lastSent;
  get lastReceivedNotif => _notifCache.lastReceived;


  bool getUserSession(String uid, String email){

    if (_userInfo!.email == email){
      return true;
    }
    return false;
  }

  UserPod getUserInfo(){
    return _userInfo!.copyWith();
  }

  storeUser(UserPod user){
    _userInfo = user.copyWith();
    _cacheToDate = false;
    refreshPetCache();
  }


  refreshPetCache(){
    List<PetBox> allPets = List.from(_petCache._petList)..addAll(_ownerPetCache._petList);
    List<PetBox> genPets = <PetBox>[];
    List<PetBox> ownerPets  = <PetBox>[];
    final uid = _userInfo!.id;
    for(var box in allPets){
      if (box.pet.ownerId == uid){
        ownerPets.add(box);
      }else{
        genPets.add(box);
      }
    }
    _petCache.refreshPetList(genPets);
    _ownerPetCache.refreshPetList(ownerPets);
  }

  bool isUserCached(String uid){
    if (_userInfo != null){
      if (_userInfo!.id == uid){
        return true;
      }else{
        // clear missed cache
        _userInfo = null;
      }
    }
    return false;
  }

  bool ownerHasPets(){
    if (_userInfo != null && _userInfo!.petCount > 0){
      return true;
    }
    return false;
  }

  Future<List<PetPod>> getUserPets() async{

    final pets = await _ownerPetCache.getOwnerUpdatedPets();

    return pets.map((e) => PetPod(pet: e, isSelected: false)).toList();
  }

  incrementUserPets(PetProfile newPet) async{
    final count = _userInfo!.petCount++;
    _ownerPetCache.addNewPet(newPet);
    _cacheToDate = false;

    // fix lastModified field not updated
    int resp;
    resp = await incrementUserPetCount(_userInfo!.id, count);
    // another trial out of failure
    if (resp != 200){
      resp = await incrementUserPetCount(_userInfo!.id, count);
    }
    return resp;
  }


  showCachePets(){
    print('count: ${_petCache._petList.length}');
    for ( var pet in _petCache._petList){

      print('${pet.pet.name}, exp: ${pet.expDate}, isMale: ${pet.pet.isMale}');
    }
  }

  List<PetProfile> testPet(PetProfile pet, bool reset){
    return _petCache.fetchMatchesFromCache(pet, reset);
  }

  Future fetchPetQuery({PetProfile? pet, bool? reset}) async{

    if (pet != null){
     final pets = await _petCache.generatePetMatches(pet: pet, reset: reset);
     return convertToPods(pets, true);
    }
    return <PetPod>[];
  }

  addNewNotifications({required List<MateRequest> items, bool? sent}){
    return sent?? false ? _notifCache.addNewSent(items) : _notifCache.addNewReceived(items);
  }

  getPetList(List<String> ids) async{
    return await _petCache.getListOfPets(ids);
  }


  get cachedSentNotif => _notifCache.sentRequests;
  get cachedReceivedNotif => _notifCache.receivedRequests;

  signOut(){
    _userInfo = null;
    FirebaseAuth.instance.signOut();
  }

  clearAll(){
    _lazyBox.clear();
  }


  // change in user info
  updateUserInfo({
    int? petCount
}){
    _userInfo!.petCount = petCount?? _userInfo!.petCount;
  }

}