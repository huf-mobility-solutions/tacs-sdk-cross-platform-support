# cordova-tacs-plugin

## Introduction

The Cordova TACS plugin contains to folders:

1. app 
2. plugin

The app folder contains a sample app that allows the user to connect to a CAM 
and control various functions.

The plugin folder contains the actual TACS plugin implementation, the Secure 
Access and the TACS library.

## Using the keyring in the app

The keyring used in the sample app is hardcoded and has to be replaced with the
correct on for your CAM. You can change the keyring if the file 
`app/www/js/index.js`.

## Making changes in the plugin

Any changes if done in the **TACS.js**, **TACSPlugin.swift** or 
**TACSPlugin.java** requires the plugin to be removed and added anew. For 
convenience a bash script runs all the necessary steps. 

```
$ bash update_plugin.sh
```

## Allowing bluetooth in the app

The app requires the Bluetooth to be on and this needs user permission. This has 
been set in the XCode by clicking on the project name and going to the Info tab 
and adding the key **Bluetooth Always Usage Description**.