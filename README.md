# *Flutter with Clean Architecture*

The idea behind the clean architecture concept is to make the project scalable, easy to maintain and testable, creating separate layers and always depending on abstractions and not concrete classes.

## *Why Clean Architecture?*

An important goal of clean architecture is to provide developers with a way to organize code in such a way that it encapsulates the business logic but keeps it separate from the delivery mechanism. Visually, the levels of clean architecture are organized into an unspecified number of rings. The outer levels of the rings are lower level mechanisms and the inner, higher levels contain policies and entities.

## *What is Clean Architecture?*

- Clean architecture is a software design philosophy that separates the elements of a design into ring levels. The main rule of clean architecture is that code dependencies can only come from the outer levels inward. Code on the inner layers can have no knowledge of functions on the outer layers. The variables, functions and classes (any entities) that exist in the outer layers can not be mentioned in the more inward levels. It is recommended that data formats also stay separate between levels.

- Clean architecture was created by Robert C. Martin and promoted on his blog, Uncle Bob. Like other software design philosophies, clean architecture attempts to provide a methodology to use in coding in order to make it easier to develop quality code that performs better is easier to change, update and has fewer dependencies.

## *Key points*

1. **Independence of frameworks:** Your project can never be dependent on an external framework, there must always be a layer that abstracts logic, thus making it possible to remove the framework without impacting the application.

2. **Testable:** The business rule layer must be tested without dependence on UI, Bank or Web Service.
3. **Independence of the UI:** Your system should not be aware of the existence of a UI, being possible to replace its graphical interface with a terminal without problems.

4. **Independence from external agents:** Your business rules should not know about the existence of the world around you. In other words, she just needs to know what she needs to perform her responsibility.



## *Architecture*


<img src="https://blog.cleancoder.com/uncle-bob/images/2012-08-13-the-clean-architecture/CleanArchitecture.jpg" alt="Clean Architecture" />

- This is where we can employ clean architecture and test driven development. As proposed by our friendly Uncle Bob, we should all strive to separate code into independent layers and depend on abstractions instead of concrete implementations.

- How can such an independence be achieved? Although we're getting ahead of ourselves a bit, on the layered "onion" image below, the horizontal arrows ---> represent dependency flow. For example, Entities do not depend on anything, Use Cases depend only on Entities etc.

- All of this is, well, a bit abstract (pun intended). Also, while the essence of clean architecture remains the same for every framework, the devil lies in the details. Principles like SOLID and YAGNI sound nice, you may even understand what they mean, but it won't do you any good if you don't know how to start writing clean code.

## *Application Layers*

<img src="https://i0.wp.com/resocoder.com/wp-content/uploads/2019/08/Clean-Architecture-Flutter-Diagram.png?w=556&ssl=1" alt="Clean Architecture" />


## *Components*

It is architecture based on the book and blog by Uncle Bob. It is a combination of concepts taken from the Onion Architecture and other architectures. The main focus of the architecture is separation of concerns and scalability. It consists of four main modules: Presentation, Domain, Data.

## *Presentation*

This is the stuff you're used to from "unclean" Flutter architecture. You obviously need widgets to display something on the screen. These widgets then dispatch events to the Bloc and listen for states (or an equivalent if you don't use Bloc for state management).

<img src="https://i0.wp.com/resocoder.com/wp-content/uploads/2019/08/presentation-layer-diagram.png?w=287&ssl=1"/>

### *Applied to the Login App*

We will have only a single page with widgets called LoginScreen with a single LoginBloc.

<img src="https://i1.wp.com/resocoder.com/wp-content/uploads/2019/08/presentation-layer-2.png?w=206&ssl=1"/>

#### *Login Bloc*
```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_clean_architecture/core/constant/string_constant.dart';
import 'package:login_clean_architecture/core/error/failures.dart';
import 'package:login_clean_architecture/core/util/helper.dart';
import 'package:login_clean_architecture/core/util/validator.dart';
import 'package:login_clean_architecture/features/login/data/models/login/login_request.dart';
import 'package:login_clean_architecture/features/login/domain/entities/user_data.dart';
import 'package:login_clean_architecture/features/login/domain/usecases/get_sign_in.dart';
import 'package:login_clean_architecture/features/login/presentation/bloc/login.dart';
import 'package:meta/meta.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final GetSignIn getSignIn;
  final Validator validators;

  LoginBloc({
    @required GetSignIn signIn,
    @required Validator validator,
  })  : assert(signIn != null),
        assert(validator != null),
        getSignIn = signIn,
        validators = validator;

  @override
  LoginState get initialState => Empty();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is SignInEvent) {
      yield Loading();
      try {
        final failureOrLogin = await getSignIn(Params(
            loginRequest: LoginRequest(
                email: event.loginRequest.email,
                password: event.loginRequest.password)));

        yield* _eitherLoadedOrErrorState(failureOrLogin);
      } catch (error) {
        Helper.printLogValue("LoginFailure");
        yield LoginFailure(message: error.toString());
      }
    }
    if (event is PasswordChangedEvent) {
      yield state.copyWith(
        isPasswordValid: _isPasswordValid(event.password),
      );
    }
    if (event is EmailChangedEvent) {
      yield state.copyWith(
        isEmailValid: _isEmailValid(event.email),
      );
    }
  }

  bool _isEmailValid(String email) {
    return validators.validateEmail(email);
  }

  bool _isPasswordValid(String password) {
    return validators.validatePassword(password);
  }

  Stream<LoginState> _eitherLoadedOrErrorState(
    Either<Failure, UserData> failureOrLogin,
  ) async* {
    yield failureOrLogin.fold(
      (failure) => LoginFailure(message: _mapFailureToMessage(failure)),
      (user) => SignInState(userData: user),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return StringConstant.server_failure_message;
      case CacheFailure:
        return StringConstant.cache_failure_message;
      default:
        return 'Unexpected error';
    }
  }
}
```
##### *Login State*
```dart
import 'package:login_clean_architecture/features/login/domain/entities/user_data.dart';
import 'package:meta/meta.dart';

class LoginState {
  final bool isEmailValid;
  final bool isPasswordValid;

  const LoginState({
    this.isEmailValid = true,
    this.isPasswordValid = true,
  });

  factory LoginState.initial() {
    return LoginState(
      isEmailValid: true,
      isPasswordValid: true,
    );
  }

  LoginState copyWith({
    bool isEmailValid,
    bool isPasswordValid,
  }) {
    return LoginState(
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
    );
  }

  @override
  String toString() {
    return '''LoginState {
      isEmailValid: $isEmailValid,
      isPasswordValid: $isPasswordValid,
    }''';
  }
}

class Empty extends LoginState {}

class Loading extends LoginState {}

class LoginFailure extends LoginState {
  String message;

  LoginFailure({this.message});
}

class SignInState extends LoginState {
  final UserData userData;

  SignInState({@required this.userData});
}
```
##### *Login Event*

```dart
import 'package:login_clean_architecture/features/login/data/models/login/login_request.dart';
import 'package:meta/meta.dart';

abstract class LoginEvent {}

class SignInEvent extends LoginEvent {
  LoginRequest loginRequest;

  SignInEvent({@required this.loginRequest});

  List<Object> get props => [loginRequest];
}

class EmailChangedEvent extends LoginEvent {
  final String email;

  EmailChangedEvent({@required this.email});

  List<Object> get props => [email];
}

class PasswordChangedEvent extends LoginEvent {
  final String password;

  PasswordChangedEvent({@required this.password});

  List<Object> get props => [password];
}
```

#### *Login Page*

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_clean_architecture/core/util/check_connectivity.dart';

import 'package:login_clean_architecture/core/constant/page_route_constants.dart';
import 'package:login_clean_architecture/core/constant/string_constant.dart';
import 'package:login_clean_architecture/core/util/helper.dart';
import 'package:login_clean_architecture/features/login/data/models/login/login_request.dart';
import 'package:login_clean_architecture/features/login/domain/entities/user_data.dart';
import 'package:login_clean_architecture/features/login/presentation/bloc/login.dart';
import 'package:login_clean_architecture/features/login/presentation/widgets/custom_text_field.dart';
import 'package:login_clean_architecture/core/resources/styles.dart' as MyTheme;
import '../../../../injection_container.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  LoginBloc loginBloc;
  final loginUserDetails = UserData();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey progressKey = GlobalKey();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  _onEmailChanged() {
    loginUserDetails.email = _emailController.text;
    if (loginUserDetails.email.isNotEmpty) {
      loginBloc.add(EmailChangedEvent(
        email: _emailController.text,
      ));
    }
  }

  _onPasswordChanged() {
    loginUserDetails.password = _passwordController.text;
    if (loginUserDetails.password.isNotEmpty) {
      loginBloc.add(PasswordChangedEvent(
        password: _passwordController.text,
      ));
    }
  }

  Widget _email(LoginState loginState, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          StringConstant.email,
          style: MyTheme.TextStyles.getMediumText(
              size.width, MyTheme.Colors.black, PageRouteConstants.kBold),
        ),
        SizedBox(
          height: MyTheme.AppDimension.px8,
        ),
        CustomTextField(
          hint: StringConstant.type_email,
          obscureText: false,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          errorText: StringConstant.please_enter_email_address,
          textEditingController: _emailController,
          currentFocusNode: _emailFocus,
          isFocused: loginUserDetails.email != null &&
                  loginUserDetails.email.isNotEmpty
              ? true
              : false,
          validator: (_) {
            return (loginUserDetails.email == null ||
                        loginUserDetails.email.isEmpty) ||
                    loginState.isEmailValid
                ? null
                : StringConstant.invalid_user_name;
          },
        )
      ],
    );
  }

  Widget _password(LoginState loginState, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          StringConstant.password,
          style: MyTheme.TextStyles.getMediumText(
              size.width, MyTheme.Colors.black, PageRouteConstants.kBold),
        ),
        SizedBox(
          height: MyTheme.AppDimension.px8,
        ),
        CustomTextField(
          hint: StringConstant.password_hint,
          obscureText: true,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          errorText: StringConstant.invalid_password,
          textEditingController: _passwordController,
          currentFocusNode: _passwordFocus,
          isFocused: loginUserDetails.password != null &&
                  loginUserDetails.password.isNotEmpty
              ? true
              : false,
          validator: (_) {
            return (loginUserDetails.password == null ||
                        loginUserDetails.password.isEmpty) ||
                    loginState.isPasswordValid
                ? null
                : StringConstant.invalid_password;
          },
        )
      ],
    );
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
      backgroundColor: MyTheme.Colors.black,
    ));
  }

  Widget _submitButton(Size size, LoginState state) {
    return Container(
      width: size.width,
      height: kBottomNavigationBarHeight,
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is SignInState) {
            if (state.userData != null) {
              Navigator.pushReplacementNamed(
                  context, PageRouteConstants.home_screen,
                  arguments: state.userData);
            }
          } else if (state is LoginFailure) {
            Helper.errorDialog(context, StringConstant.error_message,
                StringConstant.invalid_user_credentials);
          }
        },
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            if (state is Loading) {
              return Helper.progressWidget(progressKey);
            } else {
              return RaisedButton(
                child: Text(
                  StringConstant.sign_in,
                  style: MyTheme.TextStyles.getMediumText(size.width,
                      MyTheme.Colors.white, PageRouteConstants.kSemiBold),
                ),
                onPressed: () {
                  if (!(_emailController.text.length > 0) ||
                      !state.isEmailValid) {
                    showInSnackBar(StringConstant.invalid_email);
                  } else if (!(_passwordController.text.length > 0) ||
                      !state.isPasswordValid) {
                    showInSnackBar(StringConstant.invalid_password);
                  } else {
                    checkConnectivity().then((internetStatus) {
                      if (internetStatus) {
                        if (progressKey.currentWidget == null) {
                          BlocProvider.of<LoginBloc>(context).add(
                            SignInEvent(
                                loginRequest: LoginRequest(
                                    email: _emailController.text,
                                    password: _passwordController.text)),
                          );
                        }
                      } else {
                        Helper.errorDialog(
                            context,
                            StringConstant.internet_alert,
                            StringConstant.please_check_internet_connectivity);
                      }
                    });
                  }
                },
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(MyTheme.AppDimension.px28),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (_) => sl<LoginBloc>(),
      child: Scaffold(
          backgroundColor: MyTheme.Colors.white,
          key: _scaffoldKey,
          resizeToAvoidBottomPadding: true,
          body: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Container(
              height: size.height,
              width: size.width,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: kBottomNavigationBarHeight,
                    ),
                    Container(
                      width: MyTheme.AppDimension.px150,
                      height: MyTheme.AppDimension.px150,
                      child: Image.asset(
                        'assets/images/logo.png',
                      ),
                    ),
                    Text(StringConstant.sign_in,
                        style: MyTheme.TextStyles.getLargeText(size.width,
                            MyTheme.Colors.black, PageRouteConstants.kBold)),
                    BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, state) => Container(
                        width: size.width * 0.85,
                        child: Column(
                          children: <Widget>[
                            _email(state, size),
                            SizedBox(height: size.height * .03),
                            _password(state, size),
                            SizedBox(height: size.height * .03),
                            _submitButton(size, state)
                          ],
                        ),
                      ),
                    )
                  ]),
            ),
          )),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
    loginBloc = sl<LoginBloc>();
    super.initState();
  }
}
```


## *Reducer*

Reducers receive the information through actions and implement the business logic layer to handle data and generate the next state of the application. It’s important to remember that the reducers always create a new copy of the state, keeping it immutable between the refresh cycles.
## *Middleware*

Middleware adds more layers to your application by intercepting the actions before they reach the reducers and do additional data processing. Middleware provides better code separation and makes the layers easy to replace. For example, if you‘re using a database engine in your application you’ll be able to only swap the DB related parts in the future without touching any other parts of the code. Good examples of popular middleware are loggers, databases, thunks or sagas.
## *Store*

The store represents the current global state of your application. It can only be changed by the reducers and when it happens the components which are observing particular values in the store will be automatically notified.

## *Configure store*

We would like to store the user data after a successful login and also we would like to present a loading indicator if an API call is in progress. Also, we’d like to display a friendly message if an error happened. We have to compose the stored objects to match those requirements.


In the first round, we’ll be creating the root object (AppState) which will encapsulate all the related states for the features. In this example, we‘ll only cover the login part, but the store can easily be extended in the future to handle more features:

```dart
import 'package:meta/meta.dart';
import 'package:reduxdemo/model/user_state.dart';

@immutable
class AppState {
  final UserState userState;

  AppState({@required this.userState});

  factory AppState.initial() {
    return AppState(
      userState: UserState.initial(),
    );
  }

  AppState copyWith({
    UserState userState,
  }) {
    return AppState(
      userState: userState ?? this.userState,
    );
  }

  @override
  int get hashCode =>
      //isLoading.hash Code ^
  userState.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppState && userState == other.userState;
}
```
We have to make sure to overwrite operator equals (operator ==) and the copyWith methods so Redux can detect which parts of the store changed and can generate the proper values for the next state.

It’s also advised to specify the values for the initial state so we can be sure everything is properly set up when we launch our application.

As the above example shows, we can combine states together, so we can separate them by features. Dividing them into smaller components makes them easier to understand and modify in the future:

```dart
import 'package:meta/meta.dart';
import 'package:reduxdemo/model/login/login_response.dart';

@immutable
class UserState {
  final bool isLoading;
  final bool loginError;
  final LoginResponse loginResponse;

   UserState({
    @required this.isLoading,
    @required this.loginError,
    @required this.loginResponse,
  });

  factory UserState.initial() {
    return new UserState(isLoading: false, loginError: false, loginResponse: null);
  }

  UserState copyWith({bool isLoading, bool loginError, LoginResponse loginResponse}) {
    return new UserState(
        isLoading: isLoading ?? this.isLoading, loginError: loginError ?? this.loginError, loginResponse: loginResponse ?? this.loginResponse);
  }

 @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          loginError == other.loginError &&
          loginResponse == other.loginResponse;

  @override
  int get hashCode => isLoading.hashCode ^ loginResponse.hashCode;
}
```
After defining the properties for each state we would like to use (for example, isLoading, loginError and user for UserState), and creating the store hierarchy, we’ll be able to create the global state for our application. Redux provides a simple way to achieve it:
```dart
 final store = Store<AppState>(
      appReducer,
      initialState: new AppState.initial(),
      middleware: [thunkMiddleware]
  );
  ```
After we defined the global store, we have to make sure the values for the states (eg: UserState) are available through the application and the components are able to connect to them. In Dart, we can use the StoreProvider class which makes the stored values available for the components:
```dart
@override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        title: 'Flutter Redux Example',
        navigatorKey: Keys.navKey,
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: LoginScreen(title: 'Log in'),
        routes: {
          Routes.homeScreen: (context) {
            return HomeScreen();
          },
        },
      ),
    );
  }
  ```
  
## *Actions*

Now, that we have successfully configured the store, we can start integrating the actions to initiate changes in the global state.

Actions are generated by application events and carry the information which will be consumed by the reducers. For example, if the user presses the login button we should fire an action to start the login API call and present the loading indicator.

```dart
class StartLoadingAction {
  StartLoadingAction();
}

class LoginSuccessAction {
  final LoginResponse user;

  LoginSuccessAction(this.user);
}

class LoginFailedAction {
  LoginFailedAction();
}
```
## *Reducers*

Reducers are responsible for generating the next global state of the application by transforming the information received from the actions and setting the related values in the store:
```dart
import 'package:redux/redux.dart';
import 'package:reduxdemo/model/user_state.dart';
import 'package:reduxdemo/redux/actios/login_actions.dart';

final loginReducer = combineReducers<UserState>([
  TypedReducer<UserState, LoginSuccessAction>(_loginSuccess),
  TypedReducer<UserState, LoginFailedAction>(_loginFailed),
  TypedReducer<UserState, StartLoadingAction>(_startLoading),
]);

UserState _loginSuccess(UserState state, LoginSuccessAction action) {
  return state.copyWith(
      loginResponse: action.loginResponse, isLoading: false, loginError: false);
}

UserState _loginFailed(UserState state, LoginFailedAction action) {
  return state.copyWith(
      isLoading: false, loginError: true, loginResponse: null);
}

UserState _startLoading(UserState state, StartLoadingAction action) {
  return state.copyWith(isLoading: true, loginError: false);
}
```
Reducers may contain business logic and data transformation, eg filtering arrays and converting them to the right format.

## *Middleware*

If we’d like to implement more complex business logic or create separate layers for data handling we should use middleware. This way we are able to intercept actions and transform the information from their payload before it reaches the reducers.

In the following example we’ll discuss how to use one of the most popular middleware, the thunks:
### *Thunks*

Thunks help us to combine different actions or asynchronous methods (eg API calls, database updates) together and allow us to implement more complex logic.


 In our demo application, we’ll use a thunk to implement login related functions:
 
- present the loading indicator when the user starts the login flow
- call the login API and handle the result
- navigate to the home page if the login was successful
- present an error message for incorrect credentials

### *Adding thunks to the project*

And add thunks to the middleware list when configuring the global store:

```dart
  final store = Store<AppState>(
      appReducer,
      initialState: new AppState.initial(),
      middleware: [thunkMiddleware]
  );
  ```
 After the setup phase was completed, we can start implementing the thunk for handling user login.
 ### *Implementing login thunk*
 
 Thunks can be implemented similarly to actions, but instead of simply carrying the information, they handle additional app logic and even combine other actions:
 ```dart
 ThunkAction loginUser(String email, String password, BuildContext context) {
  LoginRequest loginRequest = LoginRequest(email: email, password: password);
  return (Store store) async {
    new Future(() async {
      store.dispatch(new StartLoadingAction());
      AppClient().login(UrlConstant.LOGIN, loginRequest).then((loginResponse) {
        store.dispatch(new LoginSuccessAction(loginResponse));
        Navigator.of(context).pushReplacementNamed(
            PageRouteConstants.home_screen,
            arguments: loginResponse);
      }, onError: (error) {
        store.dispatch(new LoginFailedAction());
      });
    });
  };
}
```
In the above example, login thunk is even responsible for navigating the user to the next screen in case of successful authentication. Let’s dig a bit deeper into how to combine navigation with Redux thunks

## *Handling navigation*

In Flutter we have two different approaches to handle navigation within our apps when using Redux:

- observe the changes in the global store and perform navigation if a related boolean property change (for example, isLoading changes from true to false and there were no errors). However there are two disadvantages of using this approach: our code will be more complex and difficult to read as it generates a lot of conditional statements and also we’d have to add new actions to reset the state after the navigation transition is finished.

- create a new action for navigation and call it directly from the thunk. This solution is much simpler and results in more readable code. That’s what we’re going to focus on.

### *Defining routes*

In Flutter, routes are sub-properties of the main application, they are listed with unique string keys and the connected screens. The keys should be used as constants and separated into a different class so we can change them more easily in the future.
```dart
class Routes {
  static final homeScreen = "HOME_SCREEN";
}

@override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        ...
        routes: {
          Routes.homeScreen: (context) {
            return HomeScreen();
          },
        },
      ),
    );
  }
  ```
After defining the routes of the application, we’ll discuss how to use the Navigator class and to make the navigator accessible from the thunks.

### *Creating global navigator*

Navigation between the screens can be implemented using the Navigator class:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder:
      (context) => SecondRoute()),
);
```
Notice that the first parameter of the navigator is the current context, which means this method can only be used from widgets and not from actions. To solve this problem we have to store a global navigator instance and make it accessible across the whole app:

```dart 
class Keys {
  static final navKey = new GlobalKey<NavigatorState>();
}

MaterialApp(
  ...
  navigatorKey: Keys.navKey,
),
```
and from now on we’ll be able to do the navigation from the actions:

```dart
Keys.navKey.currentState.pushNamed(Routes.homeScreen)
```

## *Components*

Usually, components create (or call) actions and observe the state changes. Components form all the visible elements on the UI and users are able to interact with them. They can be connected to our Redux store and present their current values in the UI. Flutter Redux provides a convenient way to do so by using the StoreConnector class:

```dart
@override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: MyTheme.Colors.white,
        resizeToAvoidBottomPadding: true,
        body: StoreConnector<AppState, _LoginViewModel>(
          converter: (store) => _LoginViewModel.fromStore(store),
          builder: (_, viewModel) => buildContent(viewModel, size),
          onDidChange: (viewModel) {
            if (viewModel.loginError) {
              Helper.errorDialog(context, StringConstant.error_message,
                  StringConstant.invalid_user_credentials);
            }
          },
        ));
  }
  ```
  
  The three most important callback functions are:
  
  - converter: by specifying the converter method, we will be able to observe parts of the whole Redux store and filter the component related variables. It’s important to implement this method if we would like to avoid updating our component every time something changes in the store which can lead to performance issues. The best way to choose the properties that we’re interested in is to use a ViewModel class and separate the filtering logic:
  
  ```dart
  class _LoginViewModel {
  final bool isLoading;
  final bool loginError;
  final LoginResponse user;

  final Function(String, String, BuildContext) login;

  _LoginViewModel({
    this.isLoading,
    this.loginError,
    this.user,
    this.login,
  });

  static _LoginViewModel fromStore(Store<AppState> store) {
    return _LoginViewModel(
      isLoading: store.state.userState.isLoading,
      loginError: store.state.userState.loginError,
      user: store.state.userState.loginResponse,
      login: (String username, String password, BuildContext context) {
        store.dispatch(loginUser(username, password, context));
      },
    );
  }
}
```
- builder: the collected properties from the converter method are passed to the builder which composes the Widget component based on those values.
- onDidChange: as soon as a property is changed in the store, the component will receive the new value in this method and will be able to change its state accordingly.

## *Pros of Redux*

- Circular, unidirectional data flow.
- Immutability, the State is never mutated outside of the dataflow.
- In synchronous situations, Redux guarantees the application will behave in a very predictable manner. This makes debugging easy.
- The State is contained in something called a Store, and you can keep the previous 5 versions of the State in the app, with a list of actions performed. This can give you a record of events that happened just before a crash, and this is something that can be priceless when debugging!

## *Cons of Redux*

- A lot of boilerplate.
- A paradigm of having reducers and actions is mind-bending to many people.
- Redux well in synchronous situations but there can be serious side effects when you start doing things asynchronously.

## *Refrences*

1. https://brainsandbeards.com/blog/ultimate-redux-guide-for-flutter
2. https://blog.novoda.com/introduction-to-redux-in-flutter
3. https://medium.com/@mahmudahsan/how-to-use-redux-in-flutter-app-6299f69fadee
4. https://blog.codemagic.io/flutter-tutorial-pros-and-cons-of-state-management-approaches/

## *User login credentials*
```json
{
"email":"paras@aeologic.com",
"password":"Paras@123"
}
```

  
