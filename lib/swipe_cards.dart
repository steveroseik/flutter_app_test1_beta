import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:sizer/sizer.dart';
import 'draggable_card.dart';
import 'profile_card.dart';

class SwipeCards extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final Widget? likeTag;
  final Widget? nopeTag;
  final Widget? superLikeTag;
  final MatchEngine matchEngine;
  final Function onStackFinished;
  final Function(SwipeItem, int)? itemChanged;
  final Function(SlideRegion region)? regionChanged;
  final Function(SlideDirection direction, int index)? onNewAction;
  final bool fillSpace;
  final bool upSwipeAllowed;
  final bool leftSwipeAllowed;
  final bool rightSwipeAllowed;

  SwipeCards({
    Key? key,
    required this.matchEngine,
    required this.onStackFinished,
    required this.itemBuilder,
    this.likeTag,
    this.nopeTag,
    this.superLikeTag,
    this.fillSpace = true,
    this.upSwipeAllowed = false,
    this.leftSwipeAllowed = true,
    this.rightSwipeAllowed = true,
    this.itemChanged,
    this.regionChanged,
    this.onNewAction
  }) : super(key: key);

  @override
  _SwipeCardsState createState() => _SwipeCardsState();
}

class _SwipeCardsState extends State<SwipeCards> {
  Key? _frontCard;
  SwipeItem? _currentItem;
  double _nextCardScale = 0.9;
  SlideRegion? slideRegion;

  @override
  void initState() {
    widget.matchEngine.addListener(_onMatchEngineChange);
    _currentItem = widget.matchEngine.currentItem;
    if (_currentItem != null) {
      _currentItem!.addListener(_onMatchChange);
    }
    int? currentItemIndex = widget.matchEngine._currentItemIndex;
    if (currentItemIndex != null) {
      _frontCard = Key(currentItemIndex.toString());
    }
    super.initState();
  }

  @override
  void dispose() {
    if (_currentItem != null) {
      _currentItem!.removeListener(_onMatchChange);
    }
    widget.matchEngine.removeListener(_onMatchEngineChange);
    super.dispose();
  }

  @override
  void didUpdateWidget(SwipeCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.matchEngine != oldWidget.matchEngine) {
      oldWidget.matchEngine.removeListener(_onMatchEngineChange);
      widget.matchEngine.addListener(_onMatchEngineChange);
    }
    if (_currentItem != null) {
      _currentItem!.removeListener(_onMatchChange);
    }
    _currentItem = widget.matchEngine.currentItem;
    if (_currentItem != null) {
      _currentItem!.addListener(_onMatchChange);
    }
  }

  void _onMatchEngineChange() {
    setState(() {
      if (_currentItem != null) {
        _currentItem!.removeListener(_onMatchChange);
      }
      _currentItem = widget.matchEngine.currentItem;
      if (_currentItem != null) {
        _currentItem!.addListener(_onMatchChange);
      }
      _frontCard = Key(widget.matchEngine._currentItemIndex.toString());
    });
  }

  void _onMatchChange() {
    setState(() {
      //match has been changed
    });
  }

  Widget _buildFrontCard() {
    return ProfileCard(
      key: _frontCard,
      child: widget.itemBuilder(context, widget.matchEngine._currentItemIndex!),
    );
  }

  Widget _buildBackCard() {
    return Transform(
      // origin: Offset(-20.w, 0),
      transform: Matrix4.identity()..scale(_nextCardScale, _nextCardScale),
      alignment: Alignment.centerLeft,
      child: ProfileCard(
        child: widget.itemBuilder(context, widget.matchEngine._nextItemIndex!),
      ),
    );
  }

  void _onSlideUpdate(double distance) {
    setState(() {
      _nextCardScale = 0.9 + (0.1 * (distance / 100.0)).clamp(0.0, 0.1);
    });
  }

  void _onSlideRegion(SlideRegion? region) {

    setState(() {
      slideRegion = region;
      widget.regionChanged?.call(region?? SlideRegion.frozen);
      SwipeItem? currentMatch = widget.matchEngine.currentItem;
      if (currentMatch != null && currentMatch.onSlideUpdate != null) {
        currentMatch.onSlideUpdate!(region);
      }
    });
  }

  void _onSlideOutComplete(SlideDirection? direction) {
    SwipeItem? currentMatch = widget.matchEngine.currentItem;
    widget.onNewAction?.call(direction?? SlideDirection.inn, widget.matchEngine._currentItemIndex!);
    switch (direction) {
      case SlideDirection.left:
        currentMatch?.nope();
        break;
      case SlideDirection.right:
        currentMatch?.like();
        break;
      case SlideDirection.up:
        currentMatch?.superLike();
        break;
      default:
        break;
    }

    if (widget.matchEngine._nextItemIndex! <
        widget.matchEngine._swipeItems!.length) {
      widget.itemChanged?.call(
          widget.matchEngine.nextItem!, widget.matchEngine._nextItemIndex!);
    }

    widget.matchEngine.cycleMatch();
    if (widget.matchEngine.currentItem == null) {
      widget.onStackFinished();
    }
  }

  SlideDirection? _desiredSlideOutDirection() {
    switch (widget.matchEngine.currentItem!.decision) {
      case Decision.nope:
        return SlideDirection.left;
      case Decision.like:
        return SlideDirection.right;
      case Decision.superLike:
        return SlideDirection.up;
      case Decision.comeback:
        return SlideDirection.inn;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: widget.fillSpace == true ? StackFit.expand : StackFit.loose,
      children: <Widget>[
        if (widget.matchEngine.nextItem != null)
          IgnorePointer(
            child: DraggableCard(
              card: _buildBackCard(),
              isBackCard: true,
            ),
          ),
        if (widget.matchEngine.currentItem != null)
          Opacity(
            opacity: widget.matchEngine.currentItem!.decision == Decision.comeback ? 0 : 1,
            child: DraggableCard(
              card: _buildFrontCard(),
              likeTag: widget.likeTag,
              nopeTag: widget.nopeTag,
              superLikeTag: widget.superLikeTag,
              slideTo: _desiredSlideOutDirection(),
              onSlideUpdate: _onSlideUpdate,
              onSlideRegionUpdate: _onSlideRegion,
              onSlideOutComplete: _onSlideOutComplete,
              upSwipeAllowed: widget.upSwipeAllowed,
              leftSwipeAllowed: widget.leftSwipeAllowed,
              rightSwipeAllowed: widget.rightSwipeAllowed,
              isBackCard: false,
            ),
          )
      ],
    );
  }
}

class MatchEngine extends ChangeNotifier {
  List<SwipeItem>? _swipeItems;
  int? _currentItemIndex;
  int? _nextItemIndex;

  MatchEngine({
    List<SwipeItem>? swipeItems,
  }) : _swipeItems = swipeItems {
    _currentItemIndex = 0;
    _nextItemIndex = 1;
  }

// my edits
  refreshEngine() {
    _currentItemIndex = 0;
    _nextItemIndex = 1;
    if (_swipeItems != null){
      for (var e in _swipeItems!) { if (e.decision != Decision.liked) e.resetMatch(false); }
    }
  }

  setStartingIndex(int index){
    _currentItemIndex = index;
    _nextItemIndex = index+1;
  }

  printItemsDecision(){
    print(_swipeItems!.length);
    _swipeItems!.forEach((e) { print('${e.decision}');});
  }





  SwipeItem? get currentItem => _currentItemIndex! < _swipeItems!.length
      ? _swipeItems![_currentItemIndex!]
      : null;

  SwipeItem? get nextItem => _nextItemIndex! < _swipeItems!.length
      ? _swipeItems![_nextItemIndex!]
      : null;

  SwipeItem? get prevItem => _currentItemIndex!-1 >= 0
      ? _swipeItems![_currentItemIndex!-1]
      : null;

  void cycleMatch() {
    if (currentItem!.decision != Decision.undecided) {
      currentItem!.killItem();
      _currentItemIndex = _nextItemIndex;
      int nextIndex = _swipeItems!.indexWhere((e) => e.decision != Decision.liked, _nextItemIndex!+1);
      _nextItemIndex = nextIndex == -1 ? _nextItemIndex! + 1 : nextIndex;
      notifyListeners();
    }
  }

  bool rewindMatch({bool? liked}){

    int rewindIndex = -1;

    if (liked?? false) {
      rewindIndex = _currentItemIndex!-1;
    }else{
      if (_swipeItems != null && _swipeItems!.isNotEmpty){
        for (int i = _currentItemIndex!-1 ; i >= 0; i--){
          if (_swipeItems![i].decision != Decision.liked){
            rewindIndex = i;
            break;
          }
        }
      }
    }

    if (rewindIndex != -1){
      if (_currentItemIndex! < _swipeItems!.length &&
          (_currentItemIndex! >= 0)){
        currentItem!.resetMatch(false);
      }
      _nextItemIndex = _currentItemIndex;
      _currentItemIndex = rewindIndex;
      currentItem!.decision = Decision.comeback;
      notifyListeners();
      currentItem!.resetMatch(true);
      return true;
    }else{
      if (_swipeItems!.indexWhere((e) => e.decision != Decision.liked) != -1){
        return true;
      }
      return false;
    }

  }
}

class SwipeItem extends ChangeNotifier {
  final dynamic content;
  final Function? likeAction;
  final Function? superlikeAction;
  final Function? nopeAction;
  final Future Function(SlideRegion? slideRegion)? onSlideUpdate;
  Decision decision = Decision.undecided;

  SwipeItem({
    this.content,
    this.likeAction,
    this.superlikeAction,
    this.nopeAction,
    this.onSlideUpdate,
  });

  void slideUpdateAction(SlideRegion? slideRegion) async {
    try {
      await onSlideUpdate!(slideRegion);
    } catch (e) {}
    notifyListeners();
  }

  void like() {
    if (decision == Decision.undecided) {
      decision = Decision.like;
      try {
        likeAction?.call();
      } catch (e) {}
      notifyListeners();
    }
  }

  void nope() {
    if (decision == Decision.undecided) {
      decision = Decision.nope;
      try {
        nopeAction?.call();
      } catch (e) {}
      notifyListeners();
    }
  }

  void superLike() {
    if (decision == Decision.undecided) {
      decision = Decision.superLike;
      try {
        superlikeAction?.call();
      } catch (e) {}
      notifyListeners();
    }
  }

  Future resetMatch(bool? easeIn) async{
    final check = easeIn?? false;
    if(check){
      await Future.delayed(const Duration(milliseconds: 50));
      decision = Decision.undecided;
      notifyListeners();

    }else{
      if (decision != Decision.undecided) {
        decision = Decision.undecided;
        notifyListeners();
      }
    }

  }

  killItem(){
    switch(decision){

      case Decision.nope:
        decision = Decision.noped;
        break;
      case Decision.like:
        decision = Decision.liked;
        break;
        // FIX SUPERLIKED TO USE
      case Decision.superLike:
        decision = Decision.liked;
        break;
      default:
        decision = Decision.undecided;
    }
  }
}

enum Decision { undecided, nope, like, superLike , comeback, liked, noped}