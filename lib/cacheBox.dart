import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/APILibraries.dart';
import 'package:flutter_app_test1/JsonObj.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:flutter_app_test1/pages/user_profile.dart';
import 'package:hive/hive.dart';
import 'FETCH_wdgts.dart';



const int petLimit = 2;
const double decayConst = 0.00000386;
const double baseTtl = 1.5 * 86400;

List<PetBox> petBoxFromJson(String data) => List<PetBox>.from(json.decode(data).map((e) => PetBox.fromJson(e)));
String petBoxToJson(List<PetBox> pets) => json.encode(List<dynamic>.from(pets.map((e) => e.toJson())));

DateTime getTTL(DateTime lastModified){
  final now = DateTime.now();
  final timeSince = now.difference(lastModified);
  return now.add(Duration(seconds: (baseTtl + (decayConst * (timeSince.inSeconds))).toInt()));
}

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


class NotifCache{
  late List<MateRequest> _sentRequests;
  late List<MateRequest> _receivedRequests;
  late List<MateRequest> requests;
  late DateTime _lastSent;
  late DateTime _lastReceived;
  String cacheRef = 'notifications';

  get lastReceived => _lastReceived;
  get lastSent => _lastSent;

  List<MateRequest> get sentRequests => _sentRequests;
  List<MateRequest> get receivedRequests => _receivedRequests;

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

  store(LazyBox box){
    removeDuplicates();
    final encrypted = encryptString(mateRequestToJson([..._sentRequests, ..._receivedRequests]));
    box.put(cacheRef, encrypted);
  }

  updateCachedRequest(String id, requestState state){
    int i = _sentRequests.indexWhere((e) => e.id == id);
    if (i == -1) {
      i = _receivedRequests.indexWhere((e) => e.id == id);
      if (i != -1){
        _receivedRequests[i].status = state;
      }
    }else{
      _sentRequests[i].status = state;
    }

  }

  updateRequest( String sender, String receiver, requestState state) async{
    int index = -1;
    index = _sentRequests.indexWhere((e) => e.senderPetId == sender && e.receiverPetId == receiver);
    if (index != -1 ) {
      _sentRequests[index].status = state;
      final resp = await updateMateRequest(_sentRequests[index], state.index);
      if (resp == 200){
        // TODO: Removed to keep lastFetched time correct relevantly, i hope
        // _sentRequests[index].lastModified = DateTime.now();
        return true;
      }

    }
    index = _receivedRequests.indexWhere((e) => e.senderPetId == sender && e.receiverPetId == receiver);
    if (index != -1){
      _receivedRequests[index].status = state;
      final resp = await updateMateRequest(_receivedRequests[index], state.index);
      if (resp == 200){
        //TODO: same ^ _receivedRequests[index].lastModified = DateTime.now();
        return true;
      }
    }
    return false;
  }



  Future<List<String>> refreshRequests(List<PetBox> cache, List<PetBox> ownerCache) async{
    sortAll();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final requests = await refreshMateRequests(lastSent, lastReceived);
    List<MateRequest> tempReqs = List.from(requests);
    List<String> reqIds = <String>[];
    for (var req in tempReqs){
      if (req.senderId == uid){
        if (req.status == requestState.denied) {
          requests.remove(req);
          reqIds.add(req.id);
        }
      }else{
        if (req.status == requestState.undefined){
          requests.remove(req);
          reqIds.add(req.id);
        }
      }
    }
    if (reqIds.isNotEmpty ) deleteRequestsFromServer(reqIds);
    return addNewRequests(requests, cache, ownerCache);
  }

  removeDuplicates(){
    List<int> sentRemove = <int>[];
    for (int i= 0; i< _sentRequests.length; i++){
      int j = _receivedRequests.indexWhere((e) => e.id == _sentRequests[i].id);
      if (j != -1){
        if (_receivedRequests[j].lastModified.isAfter(_sentRequests[i].lastModified)){
          sentRemove.add(i);
        }else{
          _receivedRequests.removeAt(j);
        }
      }
    }
    sentRemove.forEach((i) => _sentRequests.removeAt(i));
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
    for (var e in reqs) {
      int i = _sentRequests.indexWhere((r) => r.id == e.id);
      ( i != -1) ? _sentRequests[i] = e : sentRequests.add(e);
    }
    // for now
    return -1;
  }

  addNewReceived(List<MateRequest> reqs){
    for (var e in reqs) {
      int i = _receivedRequests.indexWhere((r) => r.id == e.id);
      ( i != -1) ? _receivedRequests[i] = e : _receivedRequests.add(e);
    }
    return -1;
  }

  updateRequests(List<PetProfile> pets, String uid){
    for (var e in [..._receivedRequests, ..._sentRequests]){
     if (e.senderId == uid){
       int i = pets.indexWhere((pet) => pet.id == e.receiverPetId);
       if ( i != -1) e.receiverPet = pets[i];
     }else{
       int i = pets.indexWhere((pet) => pet.id == e.senderPetId);
       if ( i != -1) e.senderPet = pets[i];
     }
    }
  }

  List<String> addNewRequests(List<MateRequest> items, List<PetBox> cache, List<PetBox> ownerCache){
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final missingPetIds = <String>[];
    for (var e in items){
      if (e.senderId == uid){
        //find Foreign pet and add to item
        int i = cache.indexWhere((box) => box.pet.id == e.receiverPetId);
        if ( i != -1) {
          e.receiverPet = cache[i].pet;
        }else{
          // fetch foreign pet from database
          missingPetIds.add(e.receiverPetId);
        }
        // then add owner pet data to itgem
        i = ownerCache.indexWhere((box) => box.pet.id == e.senderPetId);
        if (i != -1){
          e.senderPet = ownerCache[i].pet;
          _sentRequests.add(e);
        }


      }else{
        //do the same for received requests
        int i = cache.indexWhere((box) => box.pet.id == e.senderPetId);
        if ( i != -1){
          e.senderPet = cache[i].pet;
        }else{
          missingPetIds.add(e.senderPetId);
        }
        i = ownerCache.indexWhere((box) => box.pet.id == e.receiverPetId);
        if (i != -1){
          e.receiverPet = ownerCache[i].pet;
          _receivedRequests.add(e);
        }
      }
    }
    return missingPetIds;
  }

  Future remove(String id) async{
    await deleteRequestsFromServer([id]);
    int index = _sentRequests.indexWhere((e) => e.id == id);
    if (index != -1){
      _sentRequests.removeAt(index);
    }
    index = _receivedRequests.indexWhere((e) => e.id == id);
    if (index != -1){
      _receivedRequests.removeAt(index);
    }
  }

  MateRequest? findRequestUponId(String id, String? ownerPet){
    int i = _receivedRequests.indexWhere((e) => (e.senderPetId == id));
    if (i != -1) {
      if (ownerPet == null){
        return receivedRequests[i];
      }else{
        if (_receivedRequests[i].receiverPetId == ownerPet) return _receivedRequests[i];
      }
    }
    i = _sentRequests.indexWhere((e) => (e.receiverPetId == id));
    if (i != -1) {
      if (ownerPet == null){
        return sentRequests[i];
      }else{
        if (_sentRequests[i].senderPetId == ownerPet) return sentRequests[i];
      }
    }
    return null;
  }




}

class PetCache{
  late List<PetBox> _petList;
  late DateTime _lastFetched;
  late String _cacheRef;
  DateTime _lastQueryAt = DateTime(1990, 1, 1);
  bool cacheToDate = true;

  PetCache(LazyBox box, String ref){
    print('2nd access');
    _cacheRef = ref;
    if (box.isNotEmpty) {
      if (box.keys.contains(ref)){
        generatePets(box);
      }else{
        // first general time
        _petList = <PetBox>[];
        _lastFetched = DateTime(1990, 1, 1);
      }
    }else{
      _petList = <PetBox>[];
      _lastFetched = DateTime(1990, 1, 1);
    }

  }

  Future<PetProfile?> petWithId(String id) async{
    int i = _petList.indexWhere((e) => e.pet.id == id);
    final now = DateTime.now();
    if (i == -1){
      final newPet = await getSinglePetWithId(id);
      if (newPet != null){
        _petList.add(PetBox(pet: newPet, expDate: getTTL(newPet.lastModified)));
        sortPets();
        cacheToDate = false;
        return newPet;
      }
      return null;
    }
    if (_petList[i].expDate.isAfter(now)) await updateSingleExpired(i);
    return _petList[i].pet;
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

  // generateConfigs(LazyBox box) async{
  //   if (box.keys.contains('${_cacheRef}_config')){
  //     List<dynamic> configs = await box.get('${_cacheRef}_config');
  //     _ttl = configs[0];
  //   }else{
  //     // initial value for pet configs
  //     _ttl = Duration(days: 3);
  //   }
  // }

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

  updateSingleExpired(int index) async{
    final newDocs = await getPetsWithIDs([_petList[index].pet.id]);
    if (newDocs.isNotEmpty){
      _petList[index] = PetBox(pet: newDocs[0], expDate: getTTL(newDocs[0].lastModified));
      cacheToDate = false;
    }
  }

  Future<bool> updateExpired() async{
    HashMap<String, int> petMap = expiredPets();
    bool success = false;
    if (petMap.keys.isNotEmpty){
      try{
        final newDocs = await getPetsWithIDs(petMap.keys.toList());
        addRetrievedPets(petMap, newDocs);
        success = true;
        cacheToDate = false;
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
        _petList[index[pet.id]!] = PetBox(pet: pet, expDate: getTTL(pet.lastModified));
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
        => PetBox(pet: petProfiles[i], expDate: getTTL(petProfiles[i].lastModified)));
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
      // List<dynamic> configs = [_ttl];
      data = encryptString(data);
      box.put(_cacheRef, data);
      // box.put("${_cacheRef}_config", configs);
      cacheToDate = true;
    }
  }

  addNewPet(PetProfile pet){
    _petList.add(PetBox(pet: pet, expDate: getTTL(pet.lastModified)));
    cacheToDate = false;
  }

  // ==== general pet cache flow

 Future<List<PetProfile>> generatePetMatches({required PetProfile pet, bool? reset, required NotifCache oldNotif}) async{

    final petList = fetchMatchesFromCache(pet, reset?? false, oldNotif.sentRequests);
    List<int> petsToRemove = <int>[];
    for (int i = 0; i < petList.length ; i++){
      if (oldNotif._sentRequests.indexWhere((e) => (e.receiverPetId == petList[i].id && e.status == requestState.pending)) != -1){
        petsToRemove.add(i);
      }
    }
    for (int i in petsToRemove) {
      petList.removeAt(i);
    }
    int remainingPets = petLimit - petList.length;

    if (kDebugMode) print('Remaining From cache: $remainingPets');
    while (remainingPets > 0){
      if (kDebugMode) print('accessed Db');
      final response = await fetchMatchesFromDb(pet, remainingPets);
      petList.addAll(response[0]);
      if (!response[1]){
        break;
      }
      List<int> petsToRemove = <int>[];
      for (int i = 0; i < petList.length ; i++){
        if (oldNotif._sentRequests.indexWhere((e) => (e.receiverPetId == petList[i].id && e.status == requestState.pending)) != -1){
          petsToRemove.add(i);
        }
      }
      for (int i in petsToRemove) {
        petList.removeAt(i);
      }
      remainingPets = petLimit - petList.length;
    }
    return petList;

  }

  List<PetProfile> fetchMatchesFromCache(PetProfile pet, bool reset, List<MateRequest> sentRequests){
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
      matches.sort((a, b) => a.lastModified.compareTo(b.lastModified));
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
   List<PetProfile> oldIndices = <PetProfile>[];

    for (var pet in pets){
      // find last lastModified date, making use of already create for loop
      if (pet.lastModified.isAfter(_lastQueryAt)) { _lastQueryAt = pet.lastModified;}

      final ind = _petList.indexWhere((element) => element.pet.id == pet.id);
      if (ind != -1){
        _petList[ind].pet = pet;
        _petList[ind].expDate = getTTL(pet.lastModified);
        oldIndices.add(pet);
      }else{
        _petList.add(PetBox(pet: pet, expDate: getTTL(pet.lastModified)));
      }
    }
   print(oldIndices);
    for( PetProfile p in oldIndices){
      pets.remove(p);
      print('removed ${p.name}');
    }

    sortPets();
  }




  Future<List<PetProfile>> getListOfPets(List<String> petIDs) async{
    List<PetProfile> filteredList = <PetProfile>[];
    List<String> nonCached = <String>[];
    int index = -1;
    final now = DateTime.now();
    for (var e in petIDs){
      index = _petList.indexWhere((box) => (box.pet.id == e && box.expDate.isAfter(now)));
      (index == -1) ? nonCached.add(e) : filteredList.add(_petList[index].pet);
    }
    final pets = await getPetsWithIDs(nonCached);
    filteredList.addAll(pets);
    addToCache(pets);
    return filteredList;
  }

  addToCache(List<PetProfile> newPets){
    int i = -1;
    for ( var e in newPets){
      i = _petList.indexWhere((x) => x.pet.id == e.id);
      if (i == -1){
        _petList.add(PetBox(pet: e, expDate: getTTL(e.lastModified)));
      }else{
        _petList[i].pet = e;
        _petList[i].expDate = getTTL(e.lastModified);
      }

    }
  }

}

String friendsCacheToJson(Map<String, friendsCache> map){
  List<Map<String, dynamic>> list = <Map<String, dynamic>>[];
  for (var entry in map.entries){
    list.add({
      entry.key: entry.value.toJson()
    });
  }
  return json.encode(list);
}

Map<String, friendsCache> friendsCacheFromJson(String data){
  Map<String, friendsCache> map = {};
  json.decode(data).map((e) => map[e.key] = friendsCache.fromJson(e.value));
  return map;
}

class friendsCache{
  DateTime expDate;
  List<String> friends;

  friendsCache(this.expDate, this.friends);

  factory friendsCache.fromJson(Map<String, dynamic> data){
    return friendsCache(
        DateTime.fromMillisecondsSinceEpoch(data['expDate']),
        List<String>.from(data['friends'].map((x) => x)));
  }

  toJson(){
    return {
      'expDate': expDate.millisecondsSinceEpoch,
      'friends': List<dynamic>.from(friends.map((e) => e))
    };
  }
}


// ==== ===== ==== === === === === = == = =
// CACHE BOX MAIN

class CacheBox extends ChangeNotifier{

  late NotifCache _notifCache;
  late PetCache _petCache;
  late PetCache _ownerPetCache;
  Map<String, friendsCache> petFriends = <String, friendsCache>{};
  UserPod? _userInfo;
  late LazyBox<dynamic> _lazyBox;
  bool _cacheToDate = true;

  storeCache(){

    _petCache.store(_lazyBox);
    _ownerPetCache.store(_lazyBox);
    storeFriends();
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

  // initOwnerCache() async{
  //
  //   if (_lazyBox.keys.contains('ownerInfo')){
  //     String ownerText = await _lazyBox.get('ownerInfo');
  //     ownerText = decryptString(ownerText);
  //     _userInfo = userPodFromJson(ownerText);
  //   }
  // }

  initCacheBoxes() async{
    _lazyBox = await Hive.openLazyBox('cache');
    _petCache = PetCache(_lazyBox, 'petCache');
    _ownerPetCache = PetCache(_lazyBox, 'ownerPets');
    _notifCache = NotifCache(_lazyBox);

    if(_lazyBox.keys.contains('petFriends')){
      final data = decryptString(await _lazyBox.get('petFriends'));
      petFriends = friendsCacheFromJson(data);
    }
    // initOwnerCache();
    notifyListeners();
  }

  List<MateRequest> get allRequests => [..._notifCache._sentRequests, ..._notifCache._receivedRequests];
  get lastSentNotif => _notifCache.lastSent;
  get lastReceivedNotif => _notifCache.lastReceived;
  get sentRequests => _notifCache.sentRequests;
  get receivedRequests => _notifCache.receivedRequests;
  List<PetProfile> get ownerPets => List<PetProfile>.generate(_ownerPetCache._petList.length, (index) => _ownerPetCache._petList[index].pet);


  bool getUserSession(String uid, String email){

    if (_userInfo!.email == email){
      return true;
    }
    return false;
  }

  UserPod getUserInfo(){
    return _userInfo!.copyWith();
  }

  storeUser(UserPod user, {List<PetProfile>? pets}){
    _userInfo = user.copyWith();
    _cacheToDate = false;
    refreshPetCache();
    if (pets != null && pets.isNotEmpty ) storeOwnerPets(pets);
    notifyListeners();
  }

  storeOwnerPets(List<PetProfile> pets){
    _ownerPetCache.addToCache(pets);
  }
  
  storeFriends(){
    _lazyBox.put('petFriends', encryptString(friendsCacheToJson(petFriends)));
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

  Future<List<PetPod>> getUserPets() async{

    final pets = await _ownerPetCache.getOwnerUpdatedPets();

    return pets.map((e) => PetPod(pet: e, isSelected: false)).toList();
  }

  incrementUserPets(PetProfile newPet) async{
    _ownerPetCache.addNewPet(newPet);
    _cacheToDate = false;
    notifyListeners();
    //TODO:: FIX!!!!
    // fix lastModified field not updated
    // int resp;
    // resp = await incrementUserPetCount(_userInfo!.id, count);
    // another trial out of failure
    // if (resp != 200){
    //   // resp = await incrementUserPetCount(_userInfo!.id, count);
    // }
    // return resp;
  }


  showCachePets(){
    for ( var pet in _petCache._petList){

      print('${pet.pet.name}, exp: ${pet.expDate}, isMale: ${pet.pet.isMale}');
    }
  }


  Future fetchPetQuery({PetProfile? pet, bool? reset}) async{

    if (pet != null){
      List<int> petsToRemove = <int>[];
      final pets = await _petCache.generatePetMatches(pet: pet, reset: reset, oldNotif: _notifCache);
      for (int i = 0; i < pets.length ; i++){
        if (_notifCache._sentRequests.indexWhere((e) => (e.receiverPetId == pets[i].id && e.status == requestState.pending)) != -1){
          petsToRemove.add(i);
        }
      }
      for (int i in petsToRemove) {
        pets.removeAt(i);
      }
      return convertToPods(pets, true);
    }

    return <PetPod>[];
  }

  addNewNotifications({required List<MateRequest> items}){
    _notifCache.addNewRequests(items, _petCache._petList, _ownerPetCache._petList);
    notifyListeners();
  }

  Future<bool> addOwnerPet(String name, String dogBreed, bool isMale,
      DateTime petBirthDate, String photoUrl, String uid, List<String> vaccines, String pdfUrl) async{

    final data = await addPet(name, dogBreed, isMale, petBirthDate, photoUrl, uid, vaccines, pdfUrl);
    if (data[0] == 200){
      _ownerPetCache.addNewPet(data[1]);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<List<PetProfile>> getPetList(List<String> ids) async{
    return await _petCache.getListOfPets(ids);
  }

  removeNotification({required String id, bool? fromServer}) async{
    await _notifCache.remove(id);
    //TODO: remove notification from server as well
    if (fromServer?? false) await deleteRequestsFromServer([id]) ? null : print('failed');
    notifyListeners();
  }


  MateRequest? getSinglePetRelation(String petId, {String? ownerPet}){
    return _notifCache.findRequestUponId(petId, ownerPet);
    //TODO: MAY FIX TO GET from online database
  }

  List<MateRequest> getPetRelations(String petId){
    List<MateRequest> rel = _notifCache.sentRequests.where((e) => e.receiverPetId == petId).toList();
    rel.addAll(_notifCache.receivedRequests.where((e) => e.senderPetId == petId));
    return rel;
  }

  Future<List<dynamic>> getPetState({required ownerPetId, required petId}) async{

    int sentFind = _notifCache.sentRequests.indexWhere((e) => (e.receiverPetId == petId && e.senderPetId == ownerPetId));
    int receivedFind = _notifCache.receivedRequests.indexWhere((e) => (e.senderPetId == petId && e.receiverPetId == ownerPetId));

    String? reqId;


    if (sentFind != -1){
      reqId = _notifCache._sentRequests[sentFind].id;
     switch(_notifCache._sentRequests[sentFind].status){
       case requestState.pending:
         return [profileState.requested, reqId];
       case requestState.denied:
         return [profileState.undefined, reqId];
       case requestState.accepted:
         return [profileState.friend, reqId];
       case requestState.undefined:
         return [profileState.undefined, reqId];
     }
    }

    if (receivedFind != -1){
      reqId = _notifCache._receivedRequests[receivedFind].id;
      switch(_notifCache._sentRequests[sentFind].status){
        case requestState.pending:
          return [profileState.pendingApproval, reqId];
        case requestState.denied:
          return [profileState.noFriendship, reqId];
        case requestState.accepted:
          return [profileState.friend, reqId];
        case requestState.undefined:
          return [profileState.undefined, reqId];
      }
    }
    final newReq = await fetchPetsRelation(ownerPetId, petId);
    if (newReq != null && newReq.isNotEmpty){
      addNewNotifications(items: newReq);
      notifyListeners();
      for (var req in newReq){
        if (req.senderPetId == ownerPetId && req.receiverPetId == petId){
          switch(req.status){
            case requestState.pending:
              return [profileState.requested, req.id];
            case requestState.denied:
              return [profileState.undefined, req.id];
            case requestState.accepted:
              return [profileState.friend, req.id];
            case requestState.undefined:
              return [profileState.undefined, req.id];
          }
        }
        if (req.receiverPetId == ownerPetId && req.senderPetId == petId){
         switch(req.status){
           case requestState.pending:
             return [profileState.pendingApproval,req.id];
           case requestState.denied:
             return [profileState.undefined, req.id];
           case requestState.accepted:
             return [profileState.friend, req.id];
           case requestState.undefined:
             return [profileState.undefined, req.id];
         }
        }
      }
    }

    return [profileState.noFriendship, null];

  }

  Future<bool> updateMateRequest({required String sender, required String receiver, required requestState state}) async{
    final ret = await _notifCache.updateRequest(sender, receiver, state);
    notifyListeners();
    return ret;
  }

  updateCachedRequest({required String reqId, required requestState state}){
    _notifCache.updateCachedRequest(reqId, state);
    notifyListeners();
  }

  void addPetFriendList(String petId, String newId) {
    final ttl = DateTime.now().add(const Duration(days: 1));
    if (!petFriends.containsKey(petId)) {
      petFriends[petId] = friendsCache(ttl, [newId]);
    } else if (!petFriends[petId]!.friends.contains(newId)) {
      petFriends[petId]!.friends.add(newId);
    }
    notifyListeners();
  }

  Future<bool> updateMateRequests() async{
    try{
      List<String> ids = await _notifCache.refreshRequests(_petCache._petList, _ownerPetCache._petList);
      if (ids.isNotEmpty){
        final newPets = await getPetsWithIDs(ids.toSet().toList());
        _petCache.addToCache(newPets);
        _notifCache.updateRequests(newPets, _userInfo!.id);
      }
      notifyListeners();
      return true;
    }catch (e){
      if (kDebugMode) print('updateMateRequests Error: $e');
      return false;
    }

  }

  Future<UserPod?> getPetOwnerInfo(String oId) async{
    //TODO: cache users info for limited time
    return await getPetOwner(oId);
  }


  Future<List<PetProfile>> cachedFriends(List<PetPod> pods) async{
    List<String> keys = List<String>.generate(pods.length, (index) => pods[index].pet.id);
    List<String> ids = await fetchLatestList(keys);
    notifyListeners();
    return (ids.isNotEmpty) ? await _petCache.getListOfPets(ids) : <PetProfile>[];
  }

  Future<List<String>> fetchLatestList(List<String> keys) async{
    List<String> nonCached = <String>[];
    List<String> friendsList = <String>[];
    final now = DateTime.now();
    for (var e in keys) {
      if (petFriends.keys.contains(e)){
        if(petFriends[e]!.expDate.isBefore(now)){
          friendsList.addAll(petFriends[e]!.friends);
        }else{
          nonCached.add(e);
        }
      }else{
        nonCached.add(e);
      }
    }
    final newEntries = await getPetFriendsList(nonCached);

    for (var entry in newEntries.entries){
      petFriends[entry.key] = friendsCache(now.add(const Duration(days: 1)), entry.value);
      friendsList.addAll(entry.value);
    }
    notifyListeners();
    return friendsList;

  }

  Future<PetProfile?> getPetWithId(String id) async{
    PetProfile? pet = await _petCache.petWithId(id);
    notifyListeners();
    return pet;
  }

  signOut(){
    _userInfo = null;
    FirebaseAuth.instance.signOut();
  }

  clearAll(){
    _lazyBox.clear();
  }

}