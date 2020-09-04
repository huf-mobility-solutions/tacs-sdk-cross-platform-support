## Introduction

The cordova folder contains 2 parts - 

1. app 
2. plugin

The app folder contains a sample app with the plugin dependancy. The app has UI buttons which on user click talks to the plugin and receive the events from the plugin and display it in the UI. 

The plugin folder contains the actual logic implementation, the Secure Access and the TACS library. The plugin implementation talks to the TACS library and responds back to the app.

## Using the keyring in the app

The keyring is hardcoded in the index.js inside the -

```
app/TACSCordovaApp/www/js 
```

The keyring can be accessed by the app with fetch API or any other suitable way.

## Making changes in the plugin

Any changes if done in the **Huf.js** or **Huf.swift** requires the plugin to be removed and added new and the app needs to be built again based on the platform. Here are the commands - 

```
app/TACSCordovaApp $ cordova plugin remove com.playmoove.huf 
```

```
app/TACSCordovaApp $ cordova plugin add ../../plugin/cordova-huf-bluetooth
```

```
app/TACSCordovaApp $ cordova build ios
```

## Making changes in the app

Any changes in the app requires the app to be built -

```
app/TACSCordovaApp $ cordova build ios
```

Once the code is built, the app can be run from the XCode with the iPhone connected.

## Allowing bluetooth in the app

The app requires the Bluetooth to be on and this needs user permission. This has been set in the XCode by clicking on the project name and going to the Info tab and adding the key **Bluetooth Always Usage Description**.