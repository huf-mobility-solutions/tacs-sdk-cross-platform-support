/*global cordova, module*/

// This file reppresents the bridge between cordova and native code
// on cordova you will use Huf.sampleFunction1
const packageName = "Huf"

module.exports = {
  /**
   * Register a callback id with the native Swift code and execute lock command
   * 
   * @param {callback} success Success function callback. Assuming your exec call completes 
   * successfully, this function is invoked (optionally with any parameters you pass back to it).
   * @param {callback} error Error function callback. If the operation does not complete successfully, 
   * this function is invoked (optionally with an error parameter).
   */
  executeLockCommand: (success, error) => {
    cordova.exec(success, error, packageName, 'registerCallbackId', [])
    cordova.exec(success, error, packageName, 'executeLock', [])
  },
  /**
   * Register a callback id with the native Swift code and execute unlock command
   * 
   * @param {callback} success Success function callback. Assuming your exec call completes 
   * successfully, this function is invoked (optionally with any parameters you pass back to it).
   * @param {callback} error Error function callback. If the operation does not complete successfully, 
   * this function is invoked (optionally with an error parameter).
   */
  executeUnlockCommand: (success, error) => {
    cordova.exec(success, error, packageName, 'registerCallbackId', [])
    cordova.exec(success, error, packageName, 'executeUnlock', [])
  },
  /**
   * Register a callback id with the native Swift code and execute location command
   * 
   * @param {callback} success Success function callback. Assuming your exec call completes 
   * successfully, this function is invoked (optionally with any parameters you pass back to it).
   * @param {callback} error Error function callback. If the operation does not complete successfully, 
   * this function is invoked (optionally with an error parameter).
   */
  executeLocationCommand: (success, error) => {
    cordova.exec(success, error, packageName, 'registerCallbackId', [])
    cordova.exec(success, error, packageName, 'executeLocation', [])
  },
  /**
   * Register a callback id with the native Swift code and execute telematics command
   * 
   * @param {callback} success Success function callback. Assuming your exec call completes 
   * successfully, this function is invoked (optionally with any parameters you pass back to it).
   * @param {callback} error Error function callback. If the operation does not complete successfully, 
   * this function is invoked (optionally with an error parameter).
   */
  executeTelematicsCommand: (success, error) => {
    cordova.exec(success, error, packageName, 'registerCallbackId', [])
    cordova.exec(success, error, packageName, 'executeTelematics', [])
  },
  /**
   * Register a callback id with the native Swift code and execute engine off command
   * 
   * @param {callback} success Success function callback. Assuming your exec call completes 
   * successfully, this function is invoked (optionally with any parameters you pass back to it).
   * @param {callback} error Error function callback. If the operation does not complete successfully, 
   * this function is invoked (optionally with an error parameter).
   */
  executeEngineOffCommand: (success, error) => {
    cordova.exec(success, error, packageName, 'registerCallbackId', [])
    cordova.exec(success, error, packageName, 'executeEngineOff', [])
  },
  /**
   * Register a callback id with the native Swift code and execute engine on command
   * 
   * @param {callback} success Success function callback. Assuming your exec call completes 
   * successfully, this function is invoked (optionally with any parameters you pass back to it).
   * @param {callback} error Error function callback. If the operation does not complete successfully, 
   * this function is invoked (optionally with an error parameter).
   */
  executeEngineOnCommand: (success, error) => {
    cordova.exec(success, error, packageName, 'registerCallbackId', [])
    cordova.exec(success, error, packageName, 'executeEngineOn', [])
  },
  /**
   * Register a callback id with the native Swift code and execute connect command
   * 
   * @param {callback} success Success function callback. Assuming your exec call completes 
   * successfully, this function is invoked (optionally with any parameters you pass back to it).
   * @param {callback} error Error function callback. If the operation does not complete successfully, 
   * this function is invoked (optionally with an error parameter).
   */
  connectToCAM: (success, error) => {
    cordova.exec(success, error, packageName, 'registerCallbackId', [])
    cordova.exec(success, error, packageName, 'connectBle', [])
  },
  /**
   * Register a callback id with the native Swift code and execute disconnect command
   * 
   * @param {callback} success Success function callback. Assuming your exec call completes 
   * successfully, this function is invoked (optionally with any parameters you pass back to it).
   * @param {callback} error Error function callback. If the operation does not complete successfully, 
   * this function is invoked (optionally with an error parameter).
   */
  disconnectFromCAM: (success, error) => {
    cordova.exec(success, error, packageName, 'registerCallbackId', [])
    cordova.exec(success, error, packageName, 'disconnectBle', [])
  },
  /**
   * Register a callback id with the native Swift code and initialize the plugin by 
   * building the TACS Manager and building the keyring necessary to establish a successful
   * BLE connection.
   * 
   * @param {callback} success Success function callback. Assuming your exec call completes 
   * successfully, this function is invoked (optionally with any parameters you pass back to it).
   * @param {callback} error Error function callback. If the operation does not complete successfully, 
   * this function is invoked (optionally with an error parameter).
   */
  initPlugin: (success, error, keyringData) => {
    cordova.exec(success, error, packageName, 'registerCallbackId', [])
    cordova.exec(success, error, packageName, 'initPlugin', [keyringData])
  }
}
