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

  final ChatsRepository _chatsRepository;
  _ChatsStore(this._chatsRepository);

  @observable
  ObservableFuture<List<Message>> _messagesFuture;

  @observable
  List<Message> messages;

  @observable
  String errorMessage;

  @computed
  StoreState get state {
    if(_messagesFuture == null){
      return StoreState.initial;
    }
    else if(_messagesFuture.status == FutureStatus.pending){
      return StoreState.loading;
    }
    else if(_messagesFuture.status == FutureStatus.fulfilled){
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
      _messagesFuture = ObservableFuture(result);
      messages = await _messagesFuture;
    }
    on Exception{
      errorMessage = "Could not load chat";
    }

  }
}