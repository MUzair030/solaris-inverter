import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/domain/usecases/ForgotPasswordUseCase.dart';
import 'package:threepol_inverter_flutter/presentation/pages/NotificationsScreen.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/ChangePasswordViewModel.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/DeleteDeviceViewModel.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/EditUserViewModel.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/ForgotPasswordViewModel.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/NetworkMonitor.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/NotificationProvider.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/SelectedDeviceProvider.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/SendOtpViewModel.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/UserDetailsViewModel.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/VerifyOtpViewModel.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/provisioning_provider.dart';
import 'package:threepol_inverter_flutter/services/DeviceMonitoringService.dart';
import 'package:threepol_inverter_flutter/services/NotificationService.dart';
import 'package:threepol_inverter_flutter/utils/SharedPreferencesHelper.dart';
import 'package:threepol_inverter_flutter/utils/requestNotificationPermission.dart';

import 'core/network/dio_client.dart';
import 'data/repositories_impl/ChangePasswordRepositoryImpl.dart';
import 'data/repositories_impl/DeleteRepositoryImpl.dart';
import 'data/repositories_impl/DeviceRepositoryImpl.dart';
import 'data/repositories_impl/ForgotPasswordRepositoryImpl.dart';
import 'data/repositories_impl/MacRepositoryImpl.dart';
import 'data/repositories_impl/OtpRepositoryImpl.dart';
import 'data/repositories_impl/SendOtpRepositoryImpl.dart';
import 'data/repositories_impl/UserRepositoryImpl.dart';
import 'data/repositories_impl/auth_repository_impl.dart';
import 'data/repositories_impl/provisioning_repository_impl.dart';
import 'domain/usecases/AddMacUseCase.dart';
import 'domain/usecases/ChangePasswordUseCase.dart';
import 'domain/usecases/DeleteDeviceUseCase.dart';
import 'domain/usecases/FetchDevicesUseCase.dart';
import 'domain/usecases/GetUserDetailsUseCase.dart';
import 'domain/usecases/LoginUseCase.dart';
import 'domain/usecases/SendOtpUseCase.dart';
import 'domain/usecases/VerifyOtpUseCase.dart';
import 'domain/usecases/provisioning_delete_usecase.dart';
import 'domain/usecases/signup_usecase.dart';
import 'presentation/pages/SplashScreen.dart';
import 'presentation/viewmodels/DeviceViewModel.dart';
import 'presentation/viewmodels/MacViewModel.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
// import 'core/navigation/app_navigator.dart';
//
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await SharedPreferencesHelper.init();
  await NotificationService.init();
  await DeviceMonitoringService.initialize();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final mac = await SharedPreferencesHelper.getMacData();
  final name = await SharedPreferencesHelper.getnameData();
  final power = await SharedPreferencesHelper.getpowerData();

  final dioClient = DioClient();
  await dioClient.init();

  // Repositories
  final authRepository = AuthRepositoryImpl(dioClient);
  final macRepository = MacRepositoryImpl(dioClient: dioClient);
  final userdetailRepository = UserRepositoryImpl(dioClient);
  final deviceRepository = DeviceRepositoryImpl(dioClient);
  final changepasswordRepository = ChangePasswordRepositoryImpl(dioClient);
  final repository = SendOtpRepositoryImpl(dioClient);

  // Use Cases
  final addMacUseCase = AddMacUseCase(repository: macRepository);
  final fetchUserUseCase = GetUserDetailsUseCase(userdetailRepository);
  final fetchDevicesUseCase = FetchDevicesUseCase(deviceRepository);
  final signupUseCase = SignupUseCase(authRepository);
  final loginUseCase = LoginUseCase(authRepository);
  final changePasswordUseCase = ChangePasswordUseCase(changepasswordRepository);
  final deleteDeviceUseCase = DeleteDeviceUseCase(DeleteRepositoryImpl());

  final useCase = SendOtpUseCase(repository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NotificationProvider()..loadNotifications(),
          child: const NotificationsScreen(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProvisioningProvider(
            ProvisioningDeleteDeviceUseCase(
              ProvisioningRepositoryImpl(dioClient),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => NetworkMonitor(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(signupUseCase, loginUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => ChangePasswordViewModel(changePasswordUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => MacViewModel(addMacUseCase: addMacUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              DeviceViewModel(fetchDevicesUseCase: fetchDevicesUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              DeleteDeviceViewModel(deleteUseCase: deleteDeviceUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => UserDetailsViewModel(useCase: fetchUserUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => EditUserViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = SelectedDeviceProvider();
            if (mac != null && name != null && power != null) {
              provider.setDevice(mac, name, power);
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => SendOtpViewModel(useCase),
        ),
        ChangeNotifierProvider(
          create: (_) => VerifyOtpViewModel(
            VerifyOtpUseCase(
              OtpRepositoryImpl(dioClient),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ForgotPasswordViewModel(
            ForgotPasswordUseCase(
              ForgotPasswordRepositoryImpl(dioClient),
            ),
          ),
        ),
      ],
      builder: (context, child) {
        return SafeArea(
          top: false,
          bottom: true,
          child: child!,
        );
      },
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MK Inverters',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // navigatorKey: navigatorKey,
      home: SplashScreen(),
    );
  }
}
