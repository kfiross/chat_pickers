// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chats_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ChatsStore on _ChatsStore, Store {
  Computed<StoreState> _$stateComputed;

  @override
  StoreState get state =>
      (_$stateComputed ??= Computed<StoreState>(() => super.state)).value;

  final _$_messagesFutureAtom = Atom(name: '_ChatsStore._messagesFuture');

  @override
  ObservableFuture<List<Message>> get _messagesFuture {
    _$_messagesFutureAtom.context.enforceReadPolicy(_$_messagesFutureAtom);
    _$_messagesFutureAtom.reportObserved();
    return super._messagesFuture;
  }

  @override
  set _messagesFuture(ObservableFuture<List<Message>> value) {
    _$_messagesFutureAtom.context.conditionallyRunInAction(() {
      super._messagesFuture = value;
      _$_messagesFutureAtom.reportChanged();
    }, _$_messagesFutureAtom, name: '${_$_messagesFutureAtom.name}_set');
  }

  final _$messagesAtom = Atom(name: '_ChatsStore.messages');

  @override
  List<Message> get messages {
    _$messagesAtom.context.enforceReadPolicy(_$messagesAtom);
    _$messagesAtom.reportObserved();
    return super.messages;
  }

  @override
  set messages(List<Message> value) {
    _$messagesAtom.context.conditionallyRunInAction(() {
      super.messages = value;
      _$messagesAtom.reportChanged();
    }, _$messagesAtom, name: '${_$messagesAtom.name}_set');
  }

  final _$errorMessageAtom = Atom(name: '_ChatsStore.errorMessage');

  @override
  String get errorMessage {
    _$errorMessageAtom.context.enforceReadPolicy(_$errorMessageAtom);
    _$errorMessageAtom.reportObserved();
    return super.errorMessage;
  }

  @override
  set errorMessage(String value) {
    _$errorMessageAtom.context.conditionallyRunInAction(() {
      super.errorMessage = value;
      _$errorMessageAtom.reportChanged();
    }, _$errorMessageAtom, name: '${_$errorMessageAtom.name}_set');
  }

  final _$getMessagesAsyncAction = AsyncAction('getMessages');

  @override
  Future getMessages(String chatId) {
    return _$getMessagesAsyncAction.run(() => super.getMessages(chatId));
  }
}
