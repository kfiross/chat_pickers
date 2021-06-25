// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chats_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ChatsStore on _ChatsStore, Store {
  Computed<StoreState>? _$stateComputed;

  @override
  StoreState get state => (_$stateComputed ??=
          Computed<StoreState>(() => super.state, name: '_ChatsStore.state'))
      .value;

  final _$messagesFutureAtom = Atom(name: '_ChatsStore.messagesFuture');

  @override
  ObservableFuture<List<Message>>? get messagesFuture {
    _$messagesFutureAtom.reportRead();
    return super.messagesFuture;
  }

  @override
  set messagesFuture(ObservableFuture<List<Message>>? value) {
    _$messagesFutureAtom.reportWrite(value, super.messagesFuture, () {
      super.messagesFuture = value;
    });
  }

  final _$messagesAtom = Atom(name: '_ChatsStore.messages');

  @override
  List<Message>? get messages {
    _$messagesAtom.reportRead();
    return super.messages;
  }

  @override
  set messages(List<Message>? value) {
    _$messagesAtom.reportWrite(value, super.messages, () {
      super.messages = value;
    });
  }

  final _$errorMessageAtom = Atom(name: '_ChatsStore.errorMessage');

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  final _$getMessagesAsyncAction = AsyncAction('_ChatsStore.getMessages');

  @override
  Future<dynamic> getMessages(String chatId) {
    return _$getMessagesAsyncAction.run(() => super.getMessages(chatId));
  }

  final _$addMessageAsyncAction = AsyncAction('_ChatsStore.addMessage');

  @override
  Future<dynamic> addMessage(Message message) {
    return _$addMessageAsyncAction.run(() => super.addMessage(message));
  }

  @override
  String toString() {
    return '''
messagesFuture: ${messagesFuture},
messages: ${messages},
errorMessage: ${errorMessage},
state: ${state}
    ''';
  }
}
