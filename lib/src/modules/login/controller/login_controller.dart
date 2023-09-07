import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:my_money/src/modules/login/service/login_service.dart';
import 'package:my_money/src/router/app_router.dart';
import 'package:my_money/src/shared/components/app_snackbar.dart';
import 'package:my_money/src/shared/helpers/validator.dart';
import 'package:my_money/src/shared/storage/app_keys.dart';
import 'package:my_money/src/shared/storage/app_secure_storage.dart';
part 'login_controller.g.dart';

class LoginController = _LoginController with _$LoginController;

abstract class _LoginController with Store {
  LoginService service = LoginService();

  @observable
  bool isLoading = false;

  @observable
  bool isSuccess = false;

  late String email;
  late String password;
  late BuildContext buildContext;

  @action
  Future<void> checkData({
    required String emailController,
    required String passwordController,
    required BuildContext buildContext,
  }) async {
    this.buildContext = buildContext;
    if (_validate(
        emailController: emailController,
        passwordControler: passwordController)) {
      email = emailController;
      password = passwordController;
      setLoading();
      await sendData();
    } else {
      AppSnackbar.openMessage(
        context: buildContext,
        message: "Verifique os dados preenchidos",
      );
    }
  }

  bool _validate({
    required String emailController,
    required String passwordControler,
  }) {
    return (Validator.isEmail(emailController) && passwordControler.isNotEmpty);
  }

  @action
  Future<void> sendData() async {
    Map result = await service.sendData(
      username: email,
      password: password,
    );

    result.containsKey('success')
        ? setSucess()
        : getException(result['exception']);
  }

  @action
  void setSucess({bool? value}) => isSuccess = value ?? !isSuccess;

  @action
  void setLoading({bool? value}) => isLoading = value ?? !isLoading;

  @action
  void getException(int code) {
    setLoading();
    switch (code) {
      case 401:
        AppSnackbar.openMessage(
          context: buildContext,
          message: "Acesso não autorizado",
        );
        break;
      case 400:
        AppSnackbar.openMessage(
          context: buildContext,
          message: "Dados inválidos",
        );
        break;
      default:
        AppSnackbar.openMessage(
          context: buildContext,
          message: "Erro inesperado, tente mais tarde",
        );
    }
  }
}
