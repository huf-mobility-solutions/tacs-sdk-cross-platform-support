# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).


### Added
### Changed
### Fixed
### Removed

## [1.6.1] - 2020-04-14

### Added
- 2020-04-14 : (PLCII-952)  : Build with Xcode 11.4 

## [1.6.0] - 2020-03-23

### Added
- 2020-03-19 : (PLB2B-1062)  : Added timeout handling for discovery

## [1.5.1] - 2020-02-26

### Added
- 2020-02-25 : (PLB2B-1024)  : Add `notConnected` error response in case a vehicle feature was requested in a not connected state 

## [1.5.0] - 2020-02-18

### Added
- 2020-02-17 : (PLB2B-721)  : Add Event tracking to the SDK

## [1.4.0] - 2020-01-24

### Added
- 2020-01-23 : (PLB2B-1004) : Build with Xcode 11.3
- 2020-01-23 : (PLB2B-1000) : Provide key destroyed error

## [1.3.0] - 2019-11-22

### Added
- 2019-11-21 : (PLB2B-943)  : Build with Xcode 11.2
- 2019-11-22 : (PLB2B-942)  : Provide extended BluetoothState including unauthorized state 

## [1.2.0] - 2019-10-31

### Added
- 2019-10-31 : (PLB2B-842)  : Get vehicle position via BLE

### Removed
- 2019-10-30 : (PLB2B-923)  : Removed manual mtu size negotiation

## [1.1.1] - 2019-10-11

### Changed
- 2019-10-11 : (PLB2B-903)  : Migrated to Cocoapods 1.8.3 (use trunk repo from CDN)

### Fixed
- 2019-10-10 : (PLB2B-903)  : Fixed doc generation by upgrading jazzy

## [1.1.0] - 2019-09-27

### Added
- 2019-09-27 : (PLB2B-891)  : Build with Xcode 11

### Fixed
- 2019-09-27 : (PLB2B-891)  : Fixed issue with Carthage which lead to necessity of preparing static setup locally

### Removed
- 2019-09-27 : (PLB2B-891)  : Removed static framework creation script


## [1.0.1] - 2019-09-20

### Added
- 2019-09-09 : (PLB2B-846)  : Added setup for creating static framework

## [1.0.0] - 2019-07-17

### Added
- 2019-06-17 : (PLB2B-412) : Upgrade to Swift 5

### Fixed
- 2019-07-12 : (PLB2B-703)  : Fix issue where vehicle feature requests of the same type were removed after first completion
