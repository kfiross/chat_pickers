import 'dart:io';

import 'package:bubble/bubble.dart';
import 'package:chat_pickers/chat_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

import 'data/model/message.dart';
import 'data/repositories/chats_repository_impl.dart';
import 'data/state/chats_store.dart';
import 'utils/string_util.dart';
import 'widgets/auto_direction_rtl.dart';
import 'widgets/round_icon_button.dart';

class AppColors{
  AppColors._();

  static const colorPrimary = Color(0xFF075e55);
  static const colorPrimaryDark = Color(0xFF424242);
  static const colorAccent = Color(0xFF00cc3e);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Provider(
      create: (_) => ChatsStore(ChatsRepositoryImpl()),
        child: HomeScreen(
          "Other User",
        ),
      ),
    );
  }
}

var currChatUid = "";    //??
class HomeScreen extends StatefulWidget {
  final String name;

  final String myUid = "me";
  final String otherUid = "other";


  HomeScreen(this.name);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>  with SingleTickerProviderStateMixin{
  final TextEditingController _chatController = TextEditingController();
  final _scrollController = ScrollController();
  bool canSend = false;
  String _messageText = '';
  bool _isShowSticker = false;

  var _imageUrl;
  var _messages = <Message>[
    TextMessage(text: "me too honey!", time: DateTime(2020, 4, 21, 16, 31), senderId: "myId"),
    TextMessage(text: "I miss u!!", time: DateTime(2020, 4, 21, 16, 30), senderId: "otherId"),
  ];
  String _chatUid;
  bool _isBlocked = false;
  bool _first;

  String _nextUid;
  int _prevPos;
  bool _isRTL = false;

  bool _showGifKeyboard = false;

  var _options = [
    "View contact",
    "Media,links and docs",
    "Search",
    "Mute Notification",
    "Wallpaper",
    "More",
  ];

  // for state management
  ChatsStore _chatStore;
  List<ReactionDisposer> _disposers;


  AnimationController _animationController;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _chatUid = widget.myUid.compareTo(widget.otherUid) > 0
        ? "${widget.myUid}_${widget.otherUid}"
        : "${widget.otherUid}_${widget.myUid}";

    _first = true;

    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    _chatController.addListener(() {
      if(_chatController.text.isEmpty)
        _animationController.forward();
      else
        _animationController.reverse();

    });

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _chatStore ??= Provider.of<ChatsStore>(context);

    _disposers ??= [
      reaction(
            (_) => _chatStore.errorMessage, (String message){
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message),));
      },),
    ];

    _chatStore.getMessages("chatId");

    //   _isRTL = Provider.of<AppLanguage>(context).isRTL();

//    FBDatabase().listenReference(
//      path: "users/${widget.otherUid}/profilePic",
//      onData: ((snapshot) {
//        var partUrl = snapshot.value;
//
//        try {
//          _imageUrl = '${Constants.MY_FIREBASE_STORAGE_PRE_URL}$partUrl';
//        } catch (e) {
//          print("no image url");
//        }
//
//        FBDatabase().listenReference(
//          path: 'matches/users/${widget.myUid}/${widget.otherUid}',
//          onData: ((snapshot) {
//            setState(() {
//              _isBlocked = !snapshot.value;
//            });
//          }),
//        );
//      }),
//    );
  }

  @override
  void dispose() {
    //    _chatBloc.close();
    _disposers.forEach((disposer) => disposer());
    super.dispose();
  }

  void _handleSubmit() {
    final text =  _chatController.text;

//    String content = text.trim();
//    _chatController.clear();
//
//    if (content.isEmpty) return;
//
//    TextMessage message = TextMessage(
//      text: content,
//      senderId: widget.myUid,
//      time: DateTime.now().subtract(widget.difference),
//    );
//
//    setState(() {
//      //_messages.insert(0, message);
//    });
//
//    var ref = FBDatabase().getReference("chats/$_chatUid");
//    var key = ref.push().key;
//    ref.update({"$key": message.toJson()});
  }

  _buildTextMessage(TextMessage message, bool isMe) {
    return Row(
      mainAxisAlignment: isMe
          ? (_isRTL) ? MainAxisAlignment.start : MainAxisAlignment.end
          : (_isRTL) ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
//        Container(
//          margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
//          //width: MediaQuery.of(context).size.width * 0.5,
//          decoration: BoxDecoration(
//            color: isMe ? AppColors.colorPrimary : Colors.white,
//            borderRadius: BorderRadius.circular(25),
//          ),
//          child: Column(
//            crossAxisAlignment: isMe
//                ? (_isRTL) ? CrossAxisAlignment.start : CrossAxisAlignment.end
//                : (_isRTL) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//            children: <Widget>[
//              Text(
//                message.text,
//                style: TextStyle(
//                  color: (isMe) ? Colors.white : AppColors.colorPrimary,
//                  fontSize: 16.0,
//                ),
//              ),
//              SizedBox(height: 8.0),
//              Text(
//                message.time == null ? "" : getInDayDate(message.time),
//                textAlign: (isMe) ? TextAlign.left : TextAlign.right,
//                style: TextStyle(
//                  color: (isMe) ? Colors.white : Colors.black,
//                  fontSize: 14.0,
//                  fontWeight: FontWeight.w800,
//                ),
//              ),
//            ],
//          ),
//        ),
        Bubble(
          margin: BubbleEdges.only(top: 10, bottom: 10),
          alignment: Alignment.topRight,
          nip: isMe ? BubbleNip.rightTop : BubbleNip.leftTop,
          color: isMe ? Color.fromRGBO(225, 255, 199, 1.0): Colors.white,
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.end,
//                : (_isRTL) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                message.text,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17.0,
                ),
              ),
              SizedBox(width: 8.0),
              Text(
                message.time == null ? "" : getInDayDate(message.time),
                textAlign: (isMe) ? TextAlign.left : TextAlign.right,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildPhotoMessage(PhotoMessage message, bool isMe) {
    return Row(
      mainAxisAlignment: isMe
          ? (_isRTL) ? MainAxisAlignment.start : MainAxisAlignment.end
          : (_isRTL) ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          width: 180,
          decoration: BoxDecoration(
            color: isMe ? AppColors.colorPrimary : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? (_isRTL) ? CrossAxisAlignment.start : CrossAxisAlignment.end
                : (_isRTL) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Material(
                child: InkWell(
                  child: (message.isGif != null && message.isGif)
                      ? Image.network(
                    message.url,
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  )
                      : Image.network(
                    message.url ?? "",
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
//                    placeholder: (context, url) => Container(
//                      color: AppColors.colorPrimary,
//                      height: 160,
//                      width: 160,
//                      child: Center(
//                          child: CircularProgressIndicator(
//                            valueColor:
//                            AlwaysStoppedAnimation<Color>(Colors.white),
//                          )),
//                    ),
                  ),
                  onTap: () {
                    // open image in big
                    var imageDialog = AlertDialog(
                      content: Container(
                        child: Image.network(
                          message.url ?? "",
                          fit: BoxFit.cover,
//                          placeholder: (context, url) => Container(
//                            width: 160,
//                            height: 160,
//                            child: CircularProgressIndicator(),
//                          ),
                        ),
                      ),
                    );

                    showDialog(context: context, builder: (_) => imageDialog);
                  },
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                message.time == null ? "" : getInDayDate(message.time),
                textAlign: (isMe) ? TextAlign.left : TextAlign.right,
                style: TextStyle(
                  color: (isMe) ? Colors.white : Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildDateDivider(Message message) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
//        Divider(color: Colors.grey[600], thickness: 1),
        Bubble(
          alignment: Alignment.center,
          color: Color.fromRGBO(212, 234, 244, 1.0),
          child: Text(dateToSimpleString(message.time), textAlign: TextAlign.center, style: TextStyle(fontSize: 13.0)),
        ),
      ],
    );
  }

  _buildMessage(Message message, bool isMe) {
    var msg;
    var deleteMessageTitle = "";
    if (message is TextMessage) {
      msg = _buildTextMessage(message, isMe);
//      deleteMessageTitle = AppLocalizations()
//          .translate("delete_message", args: [message.text]);
    } else if (message is PhotoMessage) {
      msg = _buildPhotoMessage(message, isMe);
//      deleteMessageTitle = AppLocalizations().translate("delete_photo");
    }
    final msg2 = InkWell(
      child: msg,
      onLongPress: () {
//        var dialog = AlertDialog(
//          title: Text(deleteMessageTitle),
//          actions: <Widget>[
//            Container(
//              width: MediaQuery.of(context).size.width * 0.7,
//              child: Row(
//                crossAxisAlignment: CrossAxisAlignment.center,
//                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                children: <Widget>[
//                  FlatButton(
//                    child: Text(
//                        AppLocalizations().translate("delete_for_me")),
//                    onPressed: () {},
//                  ),
//                  FlatButton(
//                      child:
//                      Text(AppLocalizations().translate("cancel")),
//                      onPressed: () {
//                        Navigator.of(context).pop();
//                      }),
//                  isMe
//                      ? FlatButton(
//                    child: Text(
//                        AppLocalizations().translate("destroy")),
//                    onPressed: () {},
//                  )
//                      : Container(),
//                ],
//              ),
//            ),
//          ],
//        );
//
//        showDialog(
//            useRootNavigator: false,
//            context: context,
//            builder: (context) => dialog);
      },
    );

    if (isMe) {
      return msg2;
    }
    return Column(
      children: <Widget>[
        msg2,
      ],
    );

  }


  Widget body(BuildContext context){
    return Observer(builder: (context) {
      switch(_chatStore.state){
        case StoreState.initial:
          return Expanded(child: Container());

        case StoreState.loading:
          return buildLoader();

        case StoreState.loaded:
          return buildData(context, _chatStore.messages);

        default:
          return Container();
      }
    });
  }
//  Widget body(BuildContext context) {
//    return BlocBuilder(
//      bloc: _chatBloc,
//      builder: (context, state) {
//        if (state is InitialChatsState) return Expanded(child: Container());
//        if (state is LoadingState) {
//          return buildLoader();
//        }
////        else if (state is LoadedListState) {
////          if (state.messages == null || state.messages.isEmpty) {
////            return _buildEmptyMessage();
////          }
////          _messages = state.messages;
////          _nextUid = state.nextUid;
////          _prevPos = state.lastMessagePos;
////          return buildData(context, state.messages, false);
////        }
//        else if (state is FinishedLoadingListState) {
//          if (state.messages == null || state.messages.isEmpty) {
//            return _buildEmptyMessage();
//          }
//          _messages = state.messages;
//          return buildData(context, state.messages, true);
//        } else if (state is AddedNewMessageState) {
//          if (_messages == null || _messages.isEmpty)
//            _messages = [state.message];
//          else if (state.message.time !=
//              _messages[0].time) // weird bug duplicate when strokes keys
//            _messages.insert(0, state.message);
//          return buildData(context, _messages, true);
//        }
//        // if (state is MatchesErrorState)
//        return Container();
//
//        ///buildErrorOutput((state as MatchesErrorState).message);
//      },
//    );
//  }

  Widget buildData(BuildContext context, List<Message> messages) {
    DateTime lastDateTime = messages[0].time;
    bool first = true;

    return Expanded(
      child: Container(
        color: Colors.grey[900],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: NotificationListener<ScrollNotification>(
            //onNotification: _handleScrollNotification,
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.only(top: 15.0),
              controller: _scrollController,
              itemCount: messages.length,//calculateListItemCount(_messages, isFinishedLoading),
              itemBuilder: (BuildContext context, int index) {
//                if (index >= _messages.length && !isFinishedLoading)
//                  return buildLoader();

                final Message message = messages[index];
                final bool isMe =  message.senderId == "me"; // message.senderId == widget.myUid;

                if (index + 1 < messages.length &&
                    messages[index].time.day != messages[index + 1].time.day &&
                    first) {
                  lastDateTime = message.time;
                  first = false;
                  return Column(
                    children: <Widget>[
                      _buildDateDivider(message),
                      _buildMessage(message, isMe)
                    ],
                  );
                } else if (message.time.day != messages.last.time.day &&
                    message.time.day < lastDateTime.day) {
                  lastDateTime = message.time;

                  return Column(
                    children: <Widget>[
                      _buildDateDivider(message),
                      _buildMessage(message, isMe)
                    ],
                  );
                } else if (index == messages.length - 1) {
                  return Column(
                    children: <Widget>[
                      _buildDateDivider(message),
                      _buildMessage(message, isMe),
                    ],
                  );
                }

                return _buildMessage(message, isMe);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLoader() {
    return Expanded(
      child: Container(
        color: Colors.grey[900],
        child: Center(
          child: Container(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyMessage() {
    return Expanded(
      child: Container(
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.mode_comment,
                size: 100,
                color: Colors.red[200],
              ),
              SizedBox(height: 14),
              Text(
                "no chat",
                //AppLocalizations().translate("msg_no_chat"),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.black
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            alignment: AlignmentDirectional.topStart,
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(24)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                Row(
                  children: <Widget>[
                    IconButton(
                      icon: _isShowSticker ? Icon(Icons.keyboard) : Icon(Icons.insert_emoticon),
                      iconSize: 24,
                      color: Colors.grey[600],
                      onPressed: ()  {
                        setState(() {
                          _isShowSticker
                              ? SystemChannels.textInput.invokeMethod('TextInput.show')
                              : SystemChannels.textInput.invokeMethod('TextInput.hide');

                          _isShowSticker = !_isShowSticker;
                        });
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: AutoDirectionRTL(
                    isRTL: _isRTL,
                    text: _messageText.isNotEmpty ? _messageText : _isRTL ? "א" : "a",
                    child: Container(
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onTap: () {
                          setState(() {
                            _isShowSticker = false;
                          });
                        },
                        onChanged: (value) {
                          _messageText = value;
                          setState(() {
                            canSend = value.trim().isNotEmpty;
                          });
                        },
                        controller: _chatController,
                        // onSubmitted: _handleSubmit,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText: "Type a message",
                        ),
                      ),
                    ),
                  ),
                ),
//                IconButton(
//                  icon: Icon(Icons.send),
//                  iconSize: 25.0,
//                  color: AppColors.colorPrimaryDark,
//                  onPressed:
//                  canSend ? () => _handleSubmit(_chatController.text) : null,
//                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: <Widget>[
                      Material(
                        child: InkWell(
                          child: RotationTransition(
                            turns: const AlwaysStoppedAnimation(45 / 360),
                            child: Icon(Icons.attach_file, color: Colors.grey[600], size: 24),
                          ),
                          onTap: (){

                          },
                        ),
                      ),
                      SizedBox(width: 14),
                      Material(
                        child: InkWell(
                          child: Icon(Icons.camera_alt, color: Colors.grey[600], size: 24),
                          onTap: (){

                          },
                        ),
                      ),
                    ],

                  ),
                ),

              ],
            ),
          ),
        ),
     //   _chatController.text.isEmpty
        SizedBox(width: 6),
        RoundIconButton(
          Icons.send,
          backgroundColor: Colors.grey[600],
          iconColor: Colors.white,
          size: 50,
          iconSize: 20,
          onPressed: _chatController.text.isNotEmpty? _handleSubmit : null,
        ),

//        RoundIconButton(
//          backgroundColor: Colors.grey[600],
//          size: 50,
//          icon: _chatController.text.isEmpty
//              ? Icon(Icons.mic, color: Colors.white)
//              : Icon(Icons.send, color: Colors.white, size: 20,),
//          iconSize: ,
//

//        child: AnimatedIcon(
//          icon: AnimatedIcons.pause_play,
//          color: Colors.white,
//          progress: _animationController,
//        )
//        ),
      ],
    );
  }

  _uploadImageChatToStorage(File file) async {
    if (file == null) return;

    /// create key for new ref in database
//    var chatRef = FBDatabase().getReference("chats/$_chatUid");
//    var key = chatRef.push().key;

    /// upload the downloaded image to FirebaseStorage
//    var ref = FBStorage().getReference("images/chats/$_chatUid/$key.png");
//
//
//    var snapshot =
//    await FBStorage().putFile("images/chats/$_chatUid/$key.png", file);

    /// after uploaded completed, save image url in user's photos
//    String downloadUrl = await snapshot.ref.getDownloadURL();

    /// check if photo include nudity
//    var result = await ImageDetection.detectNSFW(imageUrl: downloadUrl);
//    if (result) {
//      // remove detected image from firebase
//      await ref.delete();
//
//      // throw exception to notify user
//      throw NudeImageException();
//    }

//    PhotoMessage message = PhotoMessage(
//      url: downloadUrl,
//      senderId: widget.myUid,
//      time: DateTime.now().subtract(widget.difference),
//    );
//
//    chatRef.update({key: message.toJson()});
//
//    setState(() {});
  }

  _uploadGif(String gifUrl) {
    /// create key for new ref in database
//    var chatRef = FBDatabase().getReference("chats/$_chatUid");
//    var key = chatRef.push().key;
//
//    PhotoMessage message = PhotoMessage(
//      url: gifUrl,
//      senderId: widget.myUid,
//      isGif: true,
//      time: DateTime.now().subtract(widget.difference),
//    );
//
//    chatRef.update({key: message.toJson()});
//
//    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: Text(widget.name),
          leading: _backButtonWidget(),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            color: Colors.grey[900],
            child: Column(
              children: <Widget>[
                _messages==null || _messages.isEmpty
                    ? Expanded(child: Container(color: Colors.grey[900]))
                    : body(context),
                Container(
                    color: Colors.grey[900],
                    child: _buildMessageComposer()),
                SingleChildScrollView(
                  child: Container(
                    height: !_isShowSticker ? 0 : 270,
                    child: ChatPickers(
                      chatController: _chatController,
                      emojiPickerConfig: EmojiPickerConfig(
                          columns: 8,
                          recommendKeywords: ["racing", "horse"],
                          numRecommended: 10,
                          bgBarColor: Colors.black38,
                          bgColor: Colors.grey[900],
                          indicatorColor: Colors.white,
                      ),
                      giphyPickerConfig: GiphyPickerConfig(
                          apiKey: "q3KulxGCIKWrOU283I3xM3DWvMnO5zOV",
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }



  bool _handleScrollNotification(ScrollNotification notification) {
    // if we reached the start of the ListView
    if (notification is ScrollEndNotification &&
        _scrollController.position.extentAfter == 0) {
//      _chatBloc.getNextListPage(_chatUid,
//          nextMessageId: _nextUid, lastMessagePos: _prevPos);
    }

    return false;
  }

  int calculateListItemCount(
      List<Message> listItems, bool hasReachedEndOfResults) {
    return (hasReachedEndOfResults)
        ? listItems.length
        : listItems.length + 1; // +1 for loading indicator
  }

  Widget _buildProfileImage(String imageUrl) {
    var image = (imageUrl == null || imageUrl.contains('null'))
        ? ExactAssetImage("assets/images/blank_profile.png")
        : NetworkImage(imageUrl);

    var circleImageInkWell = CircleImageInkWell(
      onPressed: () {
        // fill me
      },
      size: 32,
      image: image,
      splashColor: Colors.white24,
    );

    return circleImageInkWell;
  }

  _backButtonWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(134.0)),
        shape: BoxShape.rectangle,
      ),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(34.0)),
        color: Colors.transparent,
        child: InkWell(
          child: Row(
            children: <Widget>[
              Icon(Icons.arrow_back),
              _buildProfileImage(null),
            ],
          ),
          onTap: (){
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

