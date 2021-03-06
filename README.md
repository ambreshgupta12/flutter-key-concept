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

 These are our “BLoCs” that control input from and output to our widgets.

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

 These are simply the pages of our app.

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
#### *Widget*

Any other widgets needed by our pages.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_clean_architecture/core/constant/page_route_constants.dart';
import 'package:login_clean_architecture/core/resources/styles.dart' as MyTheme;

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController textEditingController;
  final TextInputType keyboardType;
  final errorText;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String> validator;
  final List<TextInputFormatter> inputFormatters;
  final int maxLength;
  final int maxLines;
  final TextStyle hintStyle;
  final Function tap;
  final bool isFocused;
  final String counterText;
  final bool autoValidate;
  final textAlignment;
  final FocusNode currentFocusNode;
  final FocusNode nextFocusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String> onFieldSubmitted;
  final ValueChanged<String> onChanged;
  final String prefixText;

  CustomTextField({
    key,
    this.hint,
    this.textEditingController,
    this.keyboardType,
    this.errorText,
    this.obscureText,
    this.textCapitalization,
    this.validator,
    this.inputFormatters,
    this.maxLength = 100,
    this.maxLines = 1,
    this.hintStyle,
    this.tap,
    this.isFocused,
    this.counterText = "",
    this.autoValidate = false,
    this.currentFocusNode,
    this.nextFocusNode,
    this.onFieldSubmitted,
    this.onChanged,
    this.textInputAction = TextInputAction.done,
    this.textAlignment = TextAlign.left,
    this.prefixText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return TextFormField(
      textCapitalization: keyboardType == TextInputType.emailAddress
          ? TextCapitalization.none
          : TextCapitalization.sentences,
      textInputAction: textInputAction,
      maxLength: maxLength,
      controller: textEditingController,
      onTap: tap,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: MyTheme.TextStyles.getMediumText(
          _width, MyTheme.Colors.black, PageRouteConstants.kRegular),
      textAlign: textAlignment,
      focusNode: currentFocusNode,
      inputFormatters: inputFormatters,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      decoration: InputDecoration(
        errorStyle: TextStyle(
            color: isFocused ? MyTheme.Colors.red : MyTheme.Colors.red),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
                width: MyTheme.AppDimension.px1,
                color: isFocused
                    ? MyTheme.Colors.black
                    : MyTheme.Colors.black.withOpacity(.50)),
            borderRadius: BorderRadius.all(
              Radius.circular(MyTheme.AppDimension.px22),
            )),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
                width: MyTheme.AppDimension.px1,
                color: isFocused
                    ? MyTheme.Colors.black
                    : MyTheme.Colors.black.withOpacity(.50)),
            borderRadius: BorderRadius.all(
              Radius.circular(MyTheme.AppDimension.px22),
            )),
        prefixText: prefixText,
        prefixStyle: MyTheme.TextStyles.getMediumText(
            _width, MyTheme.Colors.white, PageRouteConstants.kRegular),
        counterText: counterText,
        hintStyle: MyTheme.TextStyles.getSmallText(
            _width,
            isFocused
                ? MyTheme.Colors.white
                : MyTheme.Colors.white.withOpacity(.50),
            PageRouteConstants.kRegular),
        hintText: hint,
        contentPadding: EdgeInsets.only(
            left: MyTheme.AppDimension.px16,
            top: MyTheme.AppDimension.px12,
            bottom: MyTheme.AppDimension.px12,
            right: MyTheme.AppDimension.px12),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                width: MyTheme.AppDimension.px1,
                color: isFocused
                    ? MyTheme.Colors.black
                    : MyTheme.Colors.black.withOpacity(.50)),
            borderRadius: BorderRadius.all(
              Radius.circular(MyTheme.AppDimension.px22),
            )),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              width: MyTheme.AppDimension.px1, color: MyTheme.Colors.black),
          borderRadius: BorderRadius.all(
            Radius.circular(MyTheme.AppDimension.px22),
          ),
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(MyTheme.AppDimension.px22),
            ),
            borderSide: BorderSide(
                color: isFocused
                    ? MyTheme.Colors.black
                    : MyTheme.Colors.black.withOpacity(.50),
                width: MyTheme.AppDimension.px1)),
      ),
      validator: validator,
      //define method here or in place of use
      autovalidate: autoValidate,
    );
  }
}
```


## *Domain*

- Domain is the inner layer which shouldn't be susceptible to the whims of changing data sources or porting our app to Angular Dart. It will contain only the core business logic (use cases) and business objects (entities). It should be totally independent of every other layer.

- But... How is the domain layer completely independent when it gets data from a Repository, which is from the data layer?  Do you see that fancy colorful gradient for the Repository? That signifies that it belongs to both layers at the same time. We can accomplish this with dependency inversion.

<img src="https://i0.wp.com/resocoder.com/wp-content/uploads/2019/08/domain-layer-diagram.png?w=141&ssl=1"/>
Repositories are on the edge between data and domain.

- That's just a fancy way of saying that we create an abstract Repository class defining a contract of what the Repository must do - this goes into the domain layer. We then depend on the Repository "contract" defined in domain, knowing that the actual implementation of the Repository in the data layer will fullfill this contract.

<img src="https://i0.wp.com/resocoder.com/wp-content/uploads/2019/08/domain-layer.png?w=366&ssl=1"/>





#### *Entities*

These are our business objects, which have business logic has class methods.

``` dart
class UserData {
  String name;
  int id;
  String email;
  String gender;
  String region;

  String type;
  String password;

  UserData(
      {this.name,
      this.id,
      this.email,
      this.gender,
      this.region,
      this.type,
      this.password});
}
```

#### *Repositories*

These are interfaces only, implemented in the data layer.

```dart
import 'package:dartz/dartz.dart';
import 'package:login_clean_architecture/core/error/failures.dart';
import 'package:login_clean_architecture/features/login/data/models/login/login_request.dart';
import 'package:login_clean_architecture/features/login/domain/entities/user_data.dart';

abstract class LoginRepository {
  Future<Either<Failure, UserData>> getLoginAccessToken(
      LoginRequest loginRequest);
}
```

#### *Usecases*

Also known as “transaction scripts”, each use case is a collection of actions to achieve a desired user goal.

```dart
import 'package:dartz/dartz.dart';
import 'package:login_clean_architecture/features/login/domain/entities/user_data.dart';
import 'package:meta/meta.dart';
import 'package:login_clean_architecture/core/error/failures.dart';
import 'package:login_clean_architecture/core/usecases/usecase.dart';
import 'package:login_clean_architecture/features/login/data/models/login/login_request.dart';
import 'package:login_clean_architecture/features/login/domain/repositories/login_repository.dart';

class GetSignIn implements UseCase<UserData, Params> {
  final LoginRepository loginRepository;

  GetSignIn(this.loginRepository);

  @override
  Future<Either<Failure, UserData>> call(params) async {
    return await loginRepository.getLoginAccessToken(params.loginRequest);
  }
}

class Params {
  LoginRequest loginRequest;

  Params({@required this.loginRequest});
}
```




## *Data*

- The data layer consists of a Repository implementation (the contract comes from the domain layer) and data sources - one is usually for getting remote (API) data and the other for caching that data. Repository is where you decide if you return fresh or cached data, when to cache it and so on.

- You may notice that data sources don't return Entities but rather Models. The reason behind this is that transforming raw data (e.g JSON) into Dart objects requires some JSON conversion code. We don't want this JSON-specific code inside the domain Entities - what if we decide to switch to XML?

<img src="https://i0.wp.com/resocoder.com/wp-content/uploads/2019/08/data-layer-diagram.png?w=329&ssl=1"/>
The data layer works with Models, not Entities.


- The store represents the current global state of your application. It can only be changed by the reducers and when it happens the components which are observing particular values in the store will be automatically notified.

<img src="https://i1.wp.com/resocoder.com/wp-content/uploads/2019/08/data-layer.png?w=416&ssl=1"/>

#### *Datasources*

Code that interacts with databases or with the Android/iOS platform.

The RemoteDataSource will perform HTTP GET requests on the Login API. LocalDataSource will simply cache data using the shared_preferences package.

```dart 
/* LoginRemoteDataSource */
import 'package:login_clean_architecture/features/login/data/models/login/login_request.dart';
import 'package:login_clean_architecture/features/login/data/models/login/login_response.dart';

abstract class LoginRemoteDataSource {
  Future<LoginResponse> getAccessToken(LoginRequest loginRequest);
}

```
```dart 
/* LoginRemoteDatasourceImplementation */
import 'package:dio/dio.dart';
import 'package:login_clean_architecture/core/error/exceptions.dart';
import 'package:login_clean_architecture/core/constant/url_constant.dart';

import 'package:login_clean_architecture/features/login/data/datasources/login_remote_datasource.dart';
import 'package:login_clean_architecture/features/login/data/models/login/login_request.dart';
import 'package:login_clean_architecture/features/login/data/models/login/login_response.dart';
import 'package:meta/meta.dart';

class LoginRemoteDatasourceImpl implements LoginRemoteDataSource {
  final Dio dio;

  LoginRemoteDatasourceImpl({@required this.dio});

  @override
  Future<LoginResponse> getAccessToken(LoginRequest loginRequest) async {
    final response = await dio.post(UrlConstant.BASE_URL + UrlConstant.LOGIN,
        data: loginRequest.toJson());
    if (response.statusCode == 200) {
      return LoginResponse.fromJson(response.data);
    } else {
      throw ServerException();
    }
  }
}
```

#### *Models*

These are similar to our models but have additional methods, such as toJson and fromJson that allow us to interact with our data sources.

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:login_clean_architecture/features/login/data/models/login/result.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  String status;
  int code;
  String message;
  Result result;

  LoginResponse({this.status, this.code, this.message, this.result});

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
```

#### *Repositories*

 These are the actual implementations of the repositories in our domain layer. Repositories use different data sources to provide functionality to our use cases.
 
 ```dart
 import 'package:dartz/dartz.dart';
import 'package:login_clean_architecture/core/error/failures.dart';
import 'package:login_clean_architecture/features/login/data/datasources/login_remote_datasource.dart';
import 'package:login_clean_architecture/features/login/data/mapper/remote_mappers.dart';
import 'package:login_clean_architecture/features/login/data/models/login/login_request.dart';
import 'package:login_clean_architecture/features/login/domain/entities/user_data.dart';
import 'package:login_clean_architecture/features/login/domain/repositories/login_repository.dart';
import 'package:login_clean_architecture/core/network/network_info.dart';

import 'package:meta/meta.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource remoteDataSource;

  final NetworkInfo networkInfo;

  LoginRepositoryImpl({
    @required this.remoteDataSource,
    @required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserData>> getLoginAccessToken(
      LoginRequest loginRequest) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(mapLoginResponseToUserData(
            await remoteDataSource.getAccessToken(loginRequest)));
      } catch (e) {
        return Left(ServerFailure());
      }
    }
    return Left(ServerFailure());
  }
}
```

## *Pros of Clean Architecture*

- Consistent business logic through the app.
- Swappable data persistence, external systems integration, and presentation.
- Enables carving out a vertical feature slice into a separate service (microservice, nanoservice/serverless) without much difficulty.
- Promotes more testable and thought design patterns (Core business logic tends to always be testable)

## *Cons of Clean Architecture*

- Requires more intentional design (you can't reference data persistence APIs directly in your business logic).
- Due to the business logic being agnostic of the outer layers you can loose optimizations in being closer to library features and implementations with the benefit of looser coupling.
- Can be overkill when only a CRUD app is needed.

## *Refrences*

1. https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/
2. https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
3. https://medium.com/@juanito.taveras/my-first-large-flutter-app-a-clean-architecture-approach-89be201a884a
4. https://dev.to/hurricaneinteractive/clean-architecture-your-approach-5ae6
5. https://pub.dev/packages/flutter_clean_architecture

## *User login credentials*
```json
{
"email":"paras@aeologic.com",
"password":"Paras@123"
}
```

  
