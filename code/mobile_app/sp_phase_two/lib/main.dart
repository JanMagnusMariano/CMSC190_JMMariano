import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import 'blocs/authentication/bloc.dart';
import 'blocs/connection/bloc.dart' as Local;
import 'blocs/settings/bloc.dart';

import 'repository/rethink_user.dart';
import 'repository/rethink_weather.dart';

import 'ui/start_screen.dart';
import 'utils/cache_services.dart';

// Login and Signup : https://github.com/sherazmahar/Flutter-Login-Signup-UI
// Home : https://github.com/mitesh77/Best-Flutter-UI-Templates/blob/master/best_flutter_ui_templates/lib/fitness_app/fitness_app_home_screen.dart

// TODO : change finding of file name to this line
// tmpFile = File
// String fileName = tmpFile.path.split('/').last;

// Black phone device number: R9AMB0ZLZ0J
// White phone device number: 52108d81531ac423

// TODO: Change guest mode sign in from Anonymous sign in to temporary token sign in
// TODO: Add more detailed documentation/comments
// TODO: Create new regex validator for information input. Old regex is in spphaseone
// TODO: Improve offline/online interaction, especially information handling
// TODO: Implement animation and transitions (i.e Loading Screens, Screen Switching)
//        - Transitions when switching between online and offline
//        - Transitions for Login, Sign Up, Home Weather

// TODO: Try to find a way to prevent application from breaking when weather files are tampered
// TODO: Have newly registered accounts undergo tutorial for familiarization
// TODO: Divide screens into small widgets
// TODO: Offer prompt to login when connection is back

// Widget-specific TODOs
// TODO : Sign-in & Register - Add validation logic and proper responses to input (i.e when empty, incorrect credentials)
// TODO : Sign-in & Register - Add transition animation when switching pages
// TODO : Sign-in & Register - Test every case for offline/online authentication

/// To fix immediately : Weather does not refresh even when online?
///                        Implement prompt when offline login then online home
///                        Provide access token even when not logged in

/// Cases :
/// Wrong Credentials
/// Offline Register
///       Expected Result - Reject registering
///       Actual Result - Same as expected result
/// Online login, Online Home Weather
///       Expected Result - Can view profile, Can weather search live weather data, Can change personal information and liked places, Can refresh manually and automatically
///       Actual Result - Same as expected result
/// Online login, Offline Home Weather (Needs more testing)
///       Expected Result - Can view profile, Can weather search cached weather data, Can change personal information and liked places then store in cache to send to database when online, Cannot refresh manually and automatically (i.e Show error message or prompt)
///       Actual Result - Same as expected result (?)
///
/// Offer prompt when in offline mode then connected, whether to sign in or continue using in offline mode
/// Offline login, Online Home Weather (To Fix)
///       Expected Result - Cannot view profile, Can weather search live weather data, Cannot change liked places because there should not be an option in the first place, Can refresh manually and automatically
///       Actual Result - Cannot view profile, updated weather search data is not fetched, has option to like places, refreshes

// TODO : Home Profile - Finalize design
// TODO : Home Settings - Finalize design
// TODO : Weather Icon - Finalize icons to be used and clean up code thereafter
// TODO : Weather Search - Finalize design
// TODO : Weather Detailed - Finalize design and finish formatting texts and etc.
// TODO : Home - Finalize design
// TODO : Home - Change prompt text when switching modes
// TODO : Home - Finalize offline/online interactions and transitions and error responses

// TODO : Register Bloc & Sign In Bloc - Finish input validation logic
// TODO : Connection Bloc - Clean up events and states, specify use-cases
// TODO : User Data Bloc - Handle error cases in try-catch blocks properly
// TODO : Weather Data Bloc - Animation when transitioning from WeatherDataLoading to WeatherDataLoaded

// TODO : All repositories - Handle caching (i.e Store sent data and send when internet connection is available)
// TODO : All repositories - Handle error cases in try-catch blocks properly
// TODO : Storage Repository - Handle updating of weather data properly

// Idea: Allow authentication via code sent in SMS?
// Idea: Allow user comments about weather and weather information to be sent via SMS?

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build();

  final RethinkUser _userDB = new RethinkUser();
  final RethinkWeather _weather = new RethinkWeather();
  final CacheServices _db = new CacheServices();

  await _weather.setData();
  await _db.create();

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<Local.ConnectionState>(
          create: (context) => Local.ConnectionBloc().connController.stream,
        ),
        BlocProvider(create: (context) => new AuthenticationBloc()),
        BlocProvider(create: (context) => new SettingsBloc()),
      ],
      child: Application(),
    ),
  );
}

///-----
///
///-----

class Application extends StatefulWidget {
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GestureDetector(
      onTap: () => WidgetsBinding.instance.focusManager.primaryFocus?.unfocus(),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            home: StartScreen(),
            darkTheme: ThemeData.dark(),
            theme: ThemeData.light(),
            themeMode: ThemeMode.light,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    //BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
    //BlocProvider.of<WeatherDataBloc>(context).add(WeatherLoggedOut());
    Local.ConnectionBloc().close();
    super.dispose();
  }
}
