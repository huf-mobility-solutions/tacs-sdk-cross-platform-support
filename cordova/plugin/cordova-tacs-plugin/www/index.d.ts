/**
 * Keyring format for the TACS plugin.
 */
export declare type Keyring = {
    tacsLeaseTokenTableVersion: string;
    tacsLeaseTokenTable: {
        vehicleAccessGrantId: string;
        leaseToken: {
            leaseId: string;
            userId: string;
            sorcId: string;
            serviceGrantList: {
                serviceGrantId: string;
                validators: {
                    startTime: string;
                    endTime: string;
                };
            }[];
            leaseTokenDocumentVersion: string;
            leaseTokenId: string;
            sorcAccessKey: string;
            startTime: string;
            endTime: string;
        };
    }[];
    tacsSorcBlobTableVersion: string;
    tacsSorcBlobTable: {
        tenantId: string;
        externalVehicleRef: string;
        blob: {
            sorcId: string;
            blob: string;
            blobMessageCounter: string;
        };
    }[];
};
/**
 * Enables access to Car Access Modules using the TACS service.
 */
export declare type TACS = {
    /**
     * Initializes the plugin with the TACS keyring you want to use.
     * Call this function everytime you want to use a different keyring or want
     * to access a different vehicle with another accessGrantId.
     *
     * @param accessGrantId
     * The access grant ID for your vehicle. This has to match the
     * vehicleAccessGrantId of your desired vehicle in the tacsLeaseTokenTable
     * of your keyring.
     * @param keyring
     * The TACS keyring you want to use to access a vehicle.
     * @returns
     * A Promise that resolves after the plugin has been initialized with the
     * new keyring and accessGrantId.
     */
    initialize: (accessGrantId: string, keyring: Keyring) => Promise<void>;
    /**
     * Connects to the vehicle. To specify which vehicle should be accessed,
     * call TACS.initialize first.
     *
     * @returns
     * A Promise that resolves after the connect command has been send.
     * Changes to the connection state will be published using a separate
     * event.
     *
     * @example
     * // Subscribe to the connectionStateChanged event
     * document.addEventListener("tacs:connectionStateChanged", event => {
     *     // Access the updated connection state
     *     const connectionState = event.detail.state
     *     console.log(connectionState)
     * })
     *
     * // Initialize the TACS plugin and connect.
     * TACS.initialize(accessGrantId, keyring)
     *     .then(() => TACS.connect())
     */
    connect: () => Promise<void>;
    /**
     * Disconnects from the vehicle that the plugin is currently connected to.
     *
     * @returns
     * A Promise that resolves after the disconnect command has been send.
     * Changes to the connection state will be published using a separate
     * event.
     *
     * @example
     * // Subscribe to the connectionStateChanged event
     * document.addEventListener("tacs:connectionStateChanged", event => {
     *     // Access the updated connection state
     *     const connectionState = event.detail.state
     *     console.log(connectionState)
     * })
     *
     * // Disconnect sometime after the plugin has been initialized and a
     * // connection has been established.
     * TACS.disconnect()
     */
    disconnect: () => Promise<void>;
    /**
     * Locks the vehicle that the plugin is currently connected to.
     *
     * @returns
     * A Promise that resolves after the lock command has been send.
     * Changes to the door status will be published using a separate
     * event.
     *
     * @example
     * // Subscribe to the doorStatusChanged event
     * document.addEventListener("tacs:doorStatusChanged", event => {
     *     // Access the updated door status
     *     const doorStatus = event.detail.state
     *     console.log(doorStatus)
     * })
     *
     * // Call the lock command sometime after the plugin has been initialized
     * // and a connection has been established.
     * TACS.lock()
     */
    lock: () => Promise<void>;
    /**
     * Unlocks the vehicle that the plugin is currently connected to.
     *
     * @returns
     * A Promise that resolves after the unlock command has been send.
     * Changes to the door status will be published using a separate
     * event.
     *
     * @example
     * // Subscribe to the doorStatusChanged event
     * document.addEventListener("tacs:doorStatusChanged", event => {
     *     // Access the updated door status
     *     const doorStatus = event.detail.state
     *     console.log(doorStatus)
     * })
     *
     * // Call the unlock command sometime after the plugin has been initialized
     * // and a connection has been established.
     * TACS.unlock()
     */
    unlock: () => Promise<void>;
    /**
     * Enables the ignition of vehicle that the plugin is currently connected
     * to. This enables the driver to start the ignition and drive the vehicle.
     *
     * @returns
     * A Promise that resolves after the enable ignition command has been send.
     * Changes to the ignition status will be published using a separate
     * event.
     *
     * @example
     * // Subscribe to the ignitionStatusChanged event
     * document.addEventListener("tacs:ignitionStatusChanged", event => {
     *     // Access the updated ignition status
     *     const ingitionStatus = event.detail.state
     *     console.log(ingitionStatus)
     * })
     *
     * // Call the enable ignition command sometime after the plugin has been
     * // initialized and a connection has been established.
     * TACS.enableIgnition()
     */
    enableIgnition: () => Promise<void>;
    /**
     * Disables the ignition of vehicle that the plugin is currently connected
     * to. This restricts the driver from starting the ignition.
     *
     * @returns
     * A Promise that resolves after the disable ignition command has been send.
     * Changes to the ignition status will be published using a separate
     * event.
     *
     * @example
     * // Subscribe to the ignitionStatusChanged event
     * document.addEventListener("tacs:ignitionStatusChanged", event => {
     *     // Access the updated ignition status
     *     const ingitionStatus = event.detail.state
     *     console.log(ingitionStatus)
     * })
     *
     * // Call the disnable ignition command sometime after the plugin has been
     * // initialized and a connection has been established.
     * TACS.disableIgnition()
     */
    disableIgnition: () => Promise<void>;
    /**
     * Requests the telematics data of vehicle that the plugin is currently
     * connected to.
     *
     * @returns
     * A Promise that resolves after the request telematics data command has
     * been send. Telematics data updates will be published using a separate
     * event.
     *
     * @example
     * // Subscribe to the telematicsDataChanged event
     * document.addEventListener("tacs:telematicsDataChanged", event => {
     *     // Determine the type of telematics data that has changed and access
     *     // the value and unit of the data.
     *     switch (event.detail.type) {
     *         case "odometer":
     *
     *             const odometerStatus = event.detail.value
     *                 + " "
     *                 + event.detail.unit
     *
     *             console.log("Odometer:", odometerStatus)
     *
     *             break
     *         case "fuelLevelAbsolute":
     *
     *             const fuelLevelAbsoluteStatus = event.detail.value
     *                 + " "
     *                 + event.detail.unit
     *
     *             console.log("Absolute fuel level:", fuelLevelAbsoluteStatus)
     *
     *             break
     *         case "fuelLevelPercentage":
     *
     *             const fuelLevelPercentageStatus = event.detail.value
     *                 + " "
     *                 + event.detail.unit
     *
     *             console.log("Fuel level percentage:", fuelLevelPercentageStatus)
     *
     *             break
     *     }
     * })
     *
     * // Call the request telematics data command sometime after the plugin has
     * // been initialized and a connection has been established.
     * TACS.requestTelematicsData()
     */
    requestTelematicsData: () => Promise<void>;
    /**
 * Requests the current location of vehicle that the plugin is currently
 * connected to.
 *
 * @returns
 * A Promise that resolves after the request location command has been send.
 * Location updates will be published using a separate event.
 *
 * @example
 * // Subscribe to the locationChanged event
 * document.addEventListener("tacs:telematicsDataChanged", event => {
 *     const longitude = event.detail.longitude
 *     const latitude = event.detail.latitude
 *     const accuracy = event.detail.accuracy
 *
 *     console.log("Location:", longitude, latitude, accuracy)
 * })
 *
 * // Call the request location command sometime after the plugin has been
 * // initialized and a connection has been established.
 * TACS.requestLocation()
 */
    requestLocation: () => Promise<void>;
};
