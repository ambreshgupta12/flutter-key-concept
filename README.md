# Flutter Redux Architecture 


# redux [![pub package](https://img.shields.io/pub/v/provider.svg)](https://pub.dev/packages/redux)

Redux architecture in your Flutter apps. We will demonstrate the most important components by walking you through building a simple demo application and discuss the fundamentals of the architecture, highlight the best practices along the way.

## *Why Redux?*
Redux is an architecture with a unidirectional data flow that makes it easy to develop applications that are easy to test and maintain.


## *What is Redux?


Redux is one of the most popular javascript libraries and a widely used application architecture pattern among React, React Native, and Flutter developers. Data management and data handling issues grow with the size of an application and they become really important for larger ones. Especially when you’re dealing with a global data store — a way to access the same information from different parts of the application.


Previously, you either had to create singleton classes to store the data or pass all the necessary objects through a whole hierarchy of screens, with both solutions making your application difficult to test and to adapt to future changes. Fortunately, Redux is here to solve those problems for you.


It uses a unidirectional data flow model to create an immutable data stream and follows the logic of asynchronous and reactive programming. It means there’s a single source of truth (called store) which provides the information across your whole application and keeps the data globally accessible. With every modification in the store, a completely new application state is generated and passed to the subscribed components. This way we can make the data immutable between refresh cycles and avoid inconsistent states.



## *Architecture*


<img src="https://blog.novoda.com/content/images/2018/03/redux-architecture-overview.png" alt="Redux Architecture" />
