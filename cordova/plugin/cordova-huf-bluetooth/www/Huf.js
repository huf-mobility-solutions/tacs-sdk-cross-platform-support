/*global cordova, module*/

// This file reppresents the bridge between cordova and native code
// on cordova you will use Huf.sampleFunction1
const packageName = "Huf"

module.exports = {
  executeLockCommand: (success, fail) => {
    cordova.exec(success, fail, packageName, 'registerCallbackId', [])
    cordova.exec(success, fail, packageName, 'executeLock', [])
  },
  executeUnlockCommand: (success, fail) => {
    cordova.exec(success, fail, packageName, 'registerCallbackId', [])
    cordova.exec(success, fail, packageName, 'executeUnlock', [])
  },
  executeLocationCommand: (success, fail) => {
    cordova.exec(success, fail, packageName, 'registerCallbackId', [])
    cordova.exec(success, fail, packageName, 'executeLocation', [])
  },
  executeTelematicsCommand: (success, fail) => {
    cordova.exec(success, fail, packageName, 'registerCallbackId', [])
    cordova.exec(success, fail, packageName, 'executeTelematics', [])
  },
  executeImmobilizerOnCommand: (success, fail) => {
    cordova.exec(success, fail, packageName, 'registerCallbackId', [])
    cordova.exec(success, fail, packageName, 'executeImmobilizerOn', [])
  },
  executeImmobilizerOffCommand: (success, fail) => {
    cordova.exec(success, fail, packageName, 'registerCallbackId', [])
    cordova.exec(success, fail, packageName, 'executeImmobilizerOff', [])
  },
  connectToCAM: (success, fail) => {
    cordova.exec(success, fail, packageName, 'registerCallbackId', [])
    cordova.exec(success, fail, packageName, 'connectBle', [])
  },
  disconnectFromCAM: (success, fail) => {
    cordova.exec(success, fail, packageName, 'registerCallbackId', [])
    cordova.exec(success, fail, packageName, 'disconnectBle', [])
  },
  buildKeyring: (keyringData) => {
    return new Promise((resolve, reject) => {
      cordova.exec(resolve, reject, packageName, 'buildKeyring', [keyringData])
    })
  }
}
