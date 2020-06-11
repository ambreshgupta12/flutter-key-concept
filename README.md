# Flutter Redux Architecture 

Redux architecture in your Flutter apps. We will demonstrate the most important components by walking you through building a simple demo application and discuss the fundamentals of the architecture, highlight the best practices along the way.

## Adding Redux to your app
### redux  [![pub package](https://img.shields.io/pub/v/provider.svg)](https://pub.dev/packages/redux)
### flutter_redux  [![pub package](https://img.shields.io/pub/v/provider.svg)](https://pub.dev/packages/flutter_redux)
### redux_thunk  [![pub package](https://img.shields.io/pub/v/provider.svg)](https://pub.dev/packages/redux_thunk)


## *Why Redux?*
Redux is an architecture with a unidirectional data flow that makes it easy to develop applications that are easy to test and maintain.


## *What is Redux?


Redux is one of the most popular javascript libraries and a widely used application architecture pattern among React, React Native, and Flutter developers. Data management and data handling issues grow with the size of an application and they become really important for larger ones. Especially when you’re dealing with a global data store — a way to access the same information from different parts of the application.


Previously, you either had to create singleton classes to store the data or pass all the necessary objects through a whole hierarchy of screens, with both solutions making your application difficult to test and to adapt to future changes. Fortunately, Redux is here to solve those problems for you.


It uses a unidirectional data flow model to create an immutable data stream and follows the logic of asynchronous and reactive programming. It means there’s a single source of truth (called store) which provides the information across your whole application and keeps the data globally accessible. With every modification in the store, a completely new application state is generated and passed to the subscribed components. This way we can make the data immutable between refresh cycles and avoid inconsistent states.



## *Architecture*


<img src="https://blog.novoda.com/content/images/2018/03/redux-architecture-overview-middleware.png" alt="Redux Architecture" />

## Components

Usually, components are UI elements presenting data on the screen and initiating changes of the application’s state by responding to user interactions (for example, when the user presses the login button or types in its login credentials). Components cannot communicate directly with the global store. Instead, they need to encapsulate the information (in our previous example, a new username value) required for the changes and dispatch them using actions.
## Actions
Actions carry the information in their payload and pass it to reducers. In Dart programming language the actions can be represented by different classes. It’s a good practice to keep the actions separated by features into separate files to prevent your objects growing too large.
## Reducer
Reducers receive the information through actions and implement the business logic layer to handle data and generate the next state of the application. It’s important to remember that the reducers always create a new copy of the state, keeping it immutable between the refresh cycles.
## Middleware
Middleware adds more layers to your application by intercepting the actions before they reach the reducers and do additional data processing. Middleware provides better code separation and makes the layers easy to replace. For example, if you‘re using a database engine in your application you’ll be able to only swap the DB related parts in the future without touching any other parts of the code. Good examples of popular middleware are loggers, databases, thunks or sagas.
## Store
The store represents the current global state of your application. It can only be changed by the reducers and when it happens the components which are observing particular values in the store will be automatically notified.

## Configure store
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
