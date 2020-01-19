import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

import 'package:polka_wallet/utils/localStorage.dart';

part 'assets.g.dart';

class AssetsStore extends _AssetsStore with _$AssetsStore {
  AssetsStore();
}

abstract class _AssetsStore with Store {
  _AssetsStore();

  @observable
  String description = '';

  @observable
  Account newAccount = Account('');

  @observable
  Account currentAccount = Account('');

  @observable
  ObservableList<Account> accountList = ObservableList<Account>();

  @action
  void setNewAccount(Map<String, dynamic> acc) {
    Map<String, dynamic> newAcc = Account.toJson(newAccount);
    for (var k in acc.keys) {
      newAcc[k] = acc[k];
    }
    newAccount = Account.fromJson(newAcc);

    print('setNewAccount:');
    print(Account.toJson(newAccount));
  }

  @action
  void setCurrentAccount(Account acc) {
    currentAccount = acc;

    print('setCurrentAccount:');
    print(Account.toJson(currentAccount));

    LocalStorage.setCurrentAccount(Account.toJson(acc));
  }

  @action
  Future<void> addAccount(Account acc) async {
    Map<String, dynamic> account = Account.toJson(acc);
    LocalStorage.addAccount(account);
    LocalStorage.setCurrentAccount(account);

    loadAccount();
  }

  @action
  Future<void> removeAccount(Account acc) async {
    LocalStorage.removeAccount(acc.address);

    List<Map<String, dynamic>> accounts = await LocalStorage.getAccountList();
    if (accounts.length > 0) {
      LocalStorage.setCurrentAccount(accounts[0]);
    } else {
      LocalStorage.setCurrentAccount(Map<String, dynamic>());
    }

    loadAccount();
  }

  @action
  Future<void> loadAccount() async {
    Map<String, dynamic> acc = await LocalStorage.getCurrentAccount();
    currentAccount = Account.fromJson(acc);

    List<Map<String, dynamic>> accList = await LocalStorage.getAccountList();
    print('load accounts: ${jsonEncode(accList)}');
    accList.forEach((i) => accountList.add(Account.fromJson(i)));
  }
}

@JsonSerializable()
class Account extends _Account with _$Account {
  Account(String name) : super(name);

  static Account fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);
  static Map<String, dynamic> toJson(Account acc) => _$AccountToJson(acc);
}

abstract class _Account with Store {
  _Account(this.name);

  @observable
  String name = '';

  @observable
  String password = '';

  @observable
  String address = '';

  @observable
  String seed = '';

  @observable
  String mnemonic = '';
}
