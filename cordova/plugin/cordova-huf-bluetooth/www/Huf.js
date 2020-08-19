/*global cordova, module*/

// This file reppresents the bridge between cordova and native code
// on cordova you will use Huf.sampleFunction1
const packageName = "Huf"

module.exports = {
  sampleFunction1: (name, successCallback, errorCallback) => {
    cordova.exec(successCallback, errorCallback, packageName, 'nameOfTheActionInTheNativeImplementation', [name])
  },
  executeLockCommand: () => {
    return new Promise((resolve, reject) => {
      cordova.exec(resolve, reject, packageName, 'executeLock', [])
    })
  },
  executeUnlockCommand: () => {
    return new Promise((resolve, reject) => {
      cordova.exec(resolve, reject, packageName, 'executeUnlock', [])
    })
  },
  executeImmobilizerOnCommand: () => {
    return new Promise((resolve, reject) => {
      cordova.exec(resolve, reject, packageName, 'executeImmobilizerOn', [])
    })
  },
  executeImmobilizerOffCommand: () => {
    return new Promise((resolve, reject) => {
      cordova.exec(resolve, reject, packageName, 'executeImmobilizerOff', [])
    })
  },
  connectToCAM: () => {
    return new Promise((resolve, reject) => {
      cordova.exec(resolve, reject, packageName, 'connectBle', [])
    })
  },
  disconnectFromCAM: () => {
    return new Promise((resolve, reject) => {
      cordova.exec(resolve, reject, packageName, 'disconnectBle', [])
    })
  },
  buildKeyring: (keyringData) => {
    return new Promise((resolve, reject) => {
      console.log(keyringData)
      cordova.exec(resolve, reject, packageName, 'buildKeyring', [keyringData])
    })
  }
}
