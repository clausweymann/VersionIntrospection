# VersionIntrospection

[![CI Status](http://img.shields.io/travis/clausweymann/VersionIntrospection.svg?style=flat)](https://travis-ci.org/clausweymann/VersionIntrospection)
[![Version](https://img.shields.io/cocoapods/v/VersionIntrospection.svg?style=flat)](http://cocoapods.org/pods/VersionIntrospection)
[![License](https://img.shields.io/cocoapods/l/VersionIntrospection.svg?style=flat)](http://cocoapods.org/pods/VersionIntrospection)
[![Platform](https://img.shields.io/cocoapods/p/VersionIntrospection.svg?style=flat)](http://cocoapods.org/pods/VersionIntrospection)

Extremely simple tool that parses the Podfile.lock, which is expected to be in the main bundle, and exposes the versions information of the dependencies for use in code. e.g. to decide if data needs to be migrated.
## TODOs

* At the moment the version is a string, this should be changed to support comparison
* Podfile.lock should be added to the project automatically if possible
* All the information of the Podfile.lock should be exposed (especially cocoapods version)
* Parsing could be improved
* Test coverage should be increased

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Podfile.lock needs to be in the main bundle

## Installation

VersionIntrospection is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "VersionIntrospection"
```

## Author

Claus Weymann, claus.weymann@sprylab.com

## License

VersionIntrospection is available under the MIT license. See the LICENSE file for more info.
