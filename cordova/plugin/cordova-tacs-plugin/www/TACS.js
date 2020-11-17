"use strict";
const packageName = "TACSPlugin";
const createTACS = () => {
    const setupEventChannel = () => new Promise((resolve, reject) => {
        const handleEvent = (event) => {
            const customEvent = new CustomEvent(event.type, { detail: event.detail });
            document.dispatchEvent(customEvent);
        };
        const handleInitialized = () => {
            document.removeEventListener("tacs:initialized", handleInitialized);
            resolve();
        };
        document.addEventListener("tacs:initialized", handleInitialized);
        cordova.exec(handleEvent, reject, packageName, 'setupEventChannel', []);
    });
    const initializeInternal = (accessGrantId, keyring) => new Promise((resolve, reject) => {
        const keyringData = JSON.stringify(keyring);
        cordova.exec(resolve, reject, packageName, 'initialize', [accessGrantId, keyringData]);
    });
    const initialize = (accessGrantId, keyring) => setupEventChannel()
        .then(() => initializeInternal(accessGrantId, keyring));
    const connect = () => new Promise((resolve, reject) => {
        cordova.exec(resolve, reject, packageName, 'connect', []);
    });
    const disconnect = () => new Promise((resolve, reject) => {
        cordova.exec(resolve, reject, packageName, 'disconnect', []);
    });
    const lock = () => new Promise((resolve, reject) => {
        cordova.exec(resolve, reject, packageName, 'lock', []);
    });
    const unlock = () => new Promise((resolve, reject) => {
        cordova.exec(resolve, reject, packageName, 'unlock', []);
    });
    const enableIgnition = () => new Promise((resolve, reject) => {
        cordova.exec(resolve, reject, packageName, 'enableIgnition', []);
    });
    const disableIgnition = () => new Promise((resolve, reject) => {
        cordova.exec(resolve, reject, packageName, 'disableIgnition', []);
    });
    const requestTelematicsData = () => new Promise((resolve, reject) => {
        cordova.exec(resolve, reject, packageName, 'requestTelematicsData', []);
    });
    const requestLocation = () => new Promise((resolve, reject) => {
        cordova.exec(resolve, reject, packageName, 'requestLocation', []);
    });
    const tacs = {
        initialize,
        connect,
        disconnect,
        lock,
        unlock,
        enableIgnition,
        disableIgnition,
        requestTelematicsData,
        requestLocation,
    };
    return tacs;
};
module.exports = createTACS();
