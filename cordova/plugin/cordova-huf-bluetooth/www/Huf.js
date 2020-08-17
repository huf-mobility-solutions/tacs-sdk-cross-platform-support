/*global cordova, module*/

// This file reppresents the bridge between cordova and native code
// on cordova you will use Huf.sampleFunction1
const packageName = "Huf"

module.exports = {
  sampleFunction1: (name, successCallback, errorCallback) => {
    cordova.exec(successCallback, errorCallback, packageName, 'nameOfTheActionInTheNativeImplementation', [name])
  },
  executeLockCommand: () => {
    cordova.
  },
  sampleFunction2WithPromise: (action, data) => {
    return new Promise((resolve, reject) => {
      cordova.exec(resolve, reject, packageName, action, data)
    })
  },
}
