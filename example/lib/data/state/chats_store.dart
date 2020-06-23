import 'package:example/data/model/message.dart';
import 'package:example/domain/repositories_api/chats_repositary.dart';
import 'package:mobx/mobx.dart';


part 'chats_store.g.dart';

class ChatsStore extends _ChatsStore with _$ChatsStore{
  ChatsStore(ChatsRepository chatsRepository) : super(chatsRepository);
}

enum StoreState {initial, loading, loaded }

abstract class _ChatsStore with Store{
  //final ChatsRepository _chatsRepository = ChatsRepositoryImpl();

  bool _first = false;

  final ChatsRepository _chatsRepository;
  _ChatsStore(this._chatsRepository);

  @observable
  ObservableFuture<List<Message>> messagesFuture;

  @observable
  List<Message> messages;

  @observable
  String errorMessage;

  @computed
  StoreState get state {
    if(messagesFuture == null){
      return StoreState.initial;
    }
    else if(messagesFuture.status == FutureStatus.pending){
      return _first ? StoreState.loading : StoreState.loaded;
    }
    else if(messagesFuture.status == FutureStatus.fulfilled){
      if(_first)
        _first = false;
      return StoreState.loaded;
    }

    // if  _futureMessages.status == FutureStatus.rejected
    return StoreState.initial;        // StoreState.error
  }

  @action
  Future getMessages(String chatId) async{
    try{
      errorMessage = null;
      var result = _chatsRepository.fetchAllChatMessages(chatId);
      messagesFuture = ObservableFuture(result);
      messages = await messagesFuture;
    }
    on Exception{
      errorMessage = "Could not load chat";
    }

  }

  @action
  Future addMessage(Message message) async{
    try{
      errorMessage = null;
      var result = _chatsRepository.addMessage("chatId", message);
      messagesFuture = ObservableFuture(result);
      messages = await messagesFuture;
    }
    on Exception{
      errorMessage = "Could not add message";
    }
  }
}