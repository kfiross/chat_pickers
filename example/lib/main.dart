import 'package:bubble/bubble.dart';
import 'package:chat_pickers/chat_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:giphy_client/giphy_client.dart';
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
      title: 'Chat app demo',
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
  String _chatUid;
  bool _isBlocked = false;
  bool _first;

  String _nextUid;
  int _prevPos;
  bool _isRTL = false;

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
        setState(() {

        });
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

  }

  @override
  void dispose() {
    _disposers.forEach((disposer) => disposer());
    super.dispose();
  }

  void _handleSubmit() {
    final text =  _chatController.text;

    String content = text.trim();
    _chatController.clear();

    if (content.isEmpty) return;

    TextMessage message = TextMessage(
      text: content,
      senderId: widget.myUid,
      time: DateTime.now(),
    );

    _chatStore.addMessage(message);
  }



  _buildTextMessage(TextMessage message, bool isMe) {
    return Row(
      mainAxisAlignment: isMe
          ? (_isRTL) ? MainAxisAlignment.start : MainAxisAlignment.end
          : (_isRTL) ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[

        Bubble(
          margin: BubbleEdges.only(top: 7, bottom: 7),
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

        Bubble(
          margin: BubbleEdges.only(top: 7, bottom: 7),
          alignment: Alignment.topRight,
          nip: isMe ? BubbleNip.rightTop : BubbleNip.leftTop,
          color: isMe ? Color.fromRGBO(225, 255, 199, 1.0): Colors.white,
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
              SizedBox(height: 6),
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.end,
//                : (_isRTL) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[
//              Text(
//                message.text,
//                style: TextStyle(
//                  color: Colors.black,
//                  fontSize: 17.0,
//                ),
//              ),
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


  Widget buildData(BuildContext context, List<Message> messages) {
    messages = messages?.reversed?.toList();
    DateTime lastDateTime = messages[0]?.time;
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

      ],
    );
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
                body(context),
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
                          onSelected: (gif){
                            _addGifMessage(gif);
                          }

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
       ///     Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _addGifMessage(GiphyGif gif) {
    PhotoMessage message = PhotoMessage(
      isGif: true,
      url: gif.images.original.url,
      senderId: widget.myUid,
      time: DateTime.now(),
    );

    _chatStore.addMessage(message);
  }
}

