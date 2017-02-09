# Dailyme

[![license](https://img.shields.io/github/license/mashape/apistatus.svg)]()
[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)]()
[![Language](https://img.shields.io/badge/language-swift%201-yellow.svg)]()

Dailyme tracks how user answers questions in a diary like fashion. Each day user asked different question.

- [x] Client-side application
- [x] Restful architecture
- [x] Coredata

## Requirements

- iOS Deployment Target 9.2+
- XCode 8.0+
- CocoaPods 1.2.0+

## Installation

#### CocoaPods
[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

Pull repository. Change directory to `/TheDailyMe`. You'll need to run 
```bash
$ cd ./TheDailyMe
$ pod update
```
Pods will generate `TheDailyMe.xcworkspace`. Run it with XCode.


## Usage
- Answer question you get every day.
- Review your answers in calendar view.

## Project structure
- Network. Conversation with API done via Network Manager library. It's a powerful interface designed to control life cycle of multiple instances of NSURLSessionDataTask. You can start exploring it from `DGTNetworkManager`.


## License

TheDailyMe uses the MIT license. Please file an issue if you have any questions or if you'd like to share how you're using this project.
