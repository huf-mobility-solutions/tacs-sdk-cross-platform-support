# Cordova TACS Plugin

## Introduction

The Cordova TACS plugin contains to folders:

1. app 
2. plugin

The app folder contains a sample app that allows the user to connect to a CAM 
and control various functions.

The plugin folder contains the actual TACS plugin implementation, the native Secure 
Access and TACS libraries.

## Making changes to the plugin

Any changes done in the **TACS.js**, **TACSPlugin.swift** or 
**TACSPlugin.java** requires the plugin to be removed and added anew. For 
convenience a bash script runs all the necessary steps:

```
$ bash update_plugin.sh
```

## Integrating the plugin into another app

To install the plugin into another Cordova-based app, place the `plugin` folder 
next to your Cordova app folder similar to this example project. Then open a 
command line, go to your app folder and run the following command:

```
$ cordova plugin add ../plugin/cordova-tacs-plugin
```

To remove it just run

```
$ cordova plugin rm cordova-tacs-plugin
```

## Using the TACS plugin

The project in the `app` folder contains a sample on how to use the TACS plugin.
It contains examples for all functionality exposed to your cordova application.

For further information on the plugin's functions, consult the documentation 
located in `plugins/cordova-tacs-plugin/docs`.

## Using the keyring in the sample app

The keyring used in the sample app is hardcoded and has to be replaced with the
correct on for your CAM. You can change the keyring if the file 
`app/www/js/index.js`. Make sure that you also adjust the accessGrantId to fit 
your CAM/Vehicle.

## Allowing bluetooth in the app

The app requires the Bluetooth to be on and this needs user permission. This has 
been set in the XCode by clicking on the project name and going to the Info tab 
and adding the key **Bluetooth Always Usage Description**.