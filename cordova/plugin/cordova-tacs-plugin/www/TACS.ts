import { PluginEvent, Keyring, TACS } from "./contracts";

const packageName = "TACSPlugin"

const createTACS = () => {


  const setupEventChannel = () => new Promise((resolve, reject) => {

    const handleEvent = (event: PluginEvent) => {
    
      const customEvent = new CustomEvent(event.type, event.detail)
  
      document.dispatchEvent(customEvent)
    }

    const handleInitialized = () => {
      
      document.removeEventListener("tacs:initialized", handleInitialized)

      resolve()
    }

    document.addEventListener("tacs:initialized", handleInitialized)

    cordova.exec(handleEvent, reject, packageName, 'setupEventChannel', [])
  })

  const initializeInternal = (accessGrantId: string, keyring: Keyring) => new Promise<void>((resolve, reject) => {

    const keyringData = JSON.stringify(keyring)

    cordova.exec(resolve, reject, packageName, 'initialize', [accessGrantId, keyringData])
  })

  const initialize = (accessGrantId: string, keyring: Keyring) => setupEventChannel()
    .then(() => initializeInternal(accessGrantId, keyring))

  const connect = () => new Promise<void>((resolve, reject) => {
    cordova.exec(resolve, reject, packageName, 'connect', [])
  })

  const disconnect = () => new Promise<void>((resolve, reject) => {
    cordova.exec(resolve, reject, packageName, 'disconnect', [])
  })

  const lock = () => new Promise<void>((resolve, reject) => {
    cordova.exec(resolve, reject, packageName, 'lock', [])
  })

  const unlock = () => new Promise<void>((resolve, reject) => {
    cordova.exec(resolve, reject, packageName, 'unlock', [])
  })

  const enableIgnition = () => new Promise<void>((resolve, reject) => {
    cordova.exec(resolve, reject, packageName, 'enableIgnition', [])
  })

  const disableIgnition = () => new Promise<void>((resolve, reject) => {
    cordova.exec(resolve, reject, packageName, 'disableIgnition', [])
  })

  const requestTelematicsData = () => new Promise<void>((resolve, reject) => {
    cordova.exec(resolve, reject, packageName, 'requestTelematicsData', [])
  })

  const requestLocation = () => new Promise<void>((resolve, reject) => {
    cordova.exec(resolve, reject, packageName, 'requestLocation', [])
  })

  const tacs: TACS = {
    initialize,
    connect,
    disconnect,
    lock,
    unlock,
    enableIgnition,
    disableIgnition,
    requestTelematicsData,
    requestLocation,
  }

  return tacs
}

export = createTACS()
