# [1.6.1] - 2020-04-14

- Support for Xcode 11.4

# [1.6.0] - 2020-03-23

- Added timeout handling for discovery

# [1.5.1] - 2020-02-26

- Added `notConnected` error response in case a vehicle feature was requested in a not connected state 

# [1.5.0] - 2020-02-18

- Added Event tracking to the SDK

# [1.4.0] - 2020-01-24

- Support for Xcode 11.3
- Added error notification when the key is destroyed

# [1.3.0] - 2019-11-22

- Support for Xcode 11.2
- The `isBluetoothEnabled` signal of `SorcManager` was replaced with `bluetoothState` signal which provides new `BluetoothState` enum. This especially simplifies handling of `unauthorized` state of BLE interface which became important in iOS 13.

# [1.2.0] - 2019-10-31

- Added functionality to receive vehicle location via BLE

# [1.1.1] - 2019-10-11

- Fixed issue where the documentation was not created

# [1.1.0] - 2019-09-27

- Added support for Xcode 11

# [1.0.1] - 2019-09-20

- Added minor improvements to build tools

# [1.0.0] - 2019-05-24

- Initial version
