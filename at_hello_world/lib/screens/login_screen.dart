import 'dart:ui';
// import 'package:newserverdemo/screens/home_screen.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../service/client_sdk_service.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_utils/at_logger.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

/// User Login screen
class LoginScreen extends StatefulWidget {
  /// Login screen id.
  /// This helps to navigate from one screen to another screen.
  static final String id = 'LoginScreen';
  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  bool showSpinner = false;
  String? atSign;
  ClientSdkService clientSDKInstance = ClientSdkService.getInstance();
  AtClientPreference? atClientPreference;
  final AtSignLogger _logger = AtSignLogger('Plugin example app');
  Future<void> call() async {
    await clientSDKInstance
        .getAtClientPreference()
        .then((AtClientPreference? value) => atClientPreference = value);
  }

  @override
  void initState() {
    call();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text('Home'),
      ),
      body: Builder(
        builder: (BuildContext context) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: TextButton(
                onPressed: () async {
                  final result = await AtOnboarding.onboard(
                    context: context,
                    config: AtOnboardingConfig(
                      atClientPreference: atClientPreference!,
                      rootEnvironment: RootEnvironment.Production,
                      domain: MixedConstants.ROOT_DOMAIN,
                      appAPIKey: MixedConstants.prodAPIKey,
                    ),
                  );
                  switch (result.status) {
                    case AtOnboardingResultStatus.success:
                      atSign = result.atsign;
                      clientSDKInstance.atsign = result.atsign!;
                      // clientSDKInstance.atClientServiceMap = result.value;
                      // clientSDKInstance.atClientServiceInstance = value[atsign];
                      _logger.finer('Successfully onboarded $atSign');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                      break;
                    case AtOnboardingResultStatus.error:
                      _logger.severe(
                          'Onboarding throws ${result.errorCode} ${result.message} error');
                      break;
                    case AtOnboardingResultStatus.cancel:
                      _logger.severe('Onboarding cancelled by user');
                      break;
                  }
                },
                child: const Text(AppStrings.scanQr),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () async {
                KeyChainManager _keyChainManager =
                    KeyChainManager.getInstance();
                List<String>? _atSignsList =
                    await _keyChainManager.getAtSignListFromKeychain();
                if (_atSignsList.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '@sign list is empty.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else {
                  for (String element in _atSignsList) {
                    await _keyChainManager.deleteAtSignFromKeychain(element);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Keychain cleaned',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                AppStrings.resetKeychain,
                style: TextStyle(color: Colors.blueGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
