import { EventSubscriptionVendor, NativeEventEmitter, NativeModules } from 'react-native'

type TACSPluginType = EventSubscriptionVendor & {
  initialize(accessGrantId: string, keyringJson: string): Promise<string>
  connect(): Promise<void>
  disconnect(): Promise<void>
  unlock(): Promise<void>
  lock(): Promise<void>
  enableIgnition(): Promise<void>
  disableIgnition(): Promise<void>
  requestTelematicsData(): Promise<void>
  requestLocation(): Promise<void>
};

export type TACSKeyringType = {
  tacsLeaseTokenTable:
    {
      leaseToken: {
        endTime: string
        leaseId: string
        leaseTokenDocumentVersion: string
        leaseTokenId: string
        serviceGrantList:  {
            serviceGrantId: string
            validators: {
              endTime: string,
              startTime: string
            }
          }[]
        sorcAccessKey: string
        sorcId: string
        startTime: string
        userId: string
      },
      vehicleAccessGrantId: string
  }[]
  tacsLeaseTokenTableVersion: string,
  tacsSorcBlobTable:
    {
      blob: {
        blob: string
        blobMessageCounter: string
        sorcId: string
      },
      externalVehicleRef: string
      tenantId: string
    }[]
  tacsSorcBlobTableVersion: string
}

export type EventStateDetail<T> = {
  state: T
  message?: string
}

type EventState = "error" | "unknown"

export type BluetoothState
  = EventState
  | "unsupported"
  | "unauthorized"
  | "poweredOff"
  | "poweredOn"

export type DiscoveryState
  = EventState
  | "discoveryStarted"
  | "discovered"
  | "discoveryFailed"

export type ConnectionState
  = EventState
  | "connected"
  | "connecting"
  | "disconnected"

export type DoorStatus
  = EventState
  | "locked"
  | "unlocked"

  export type IgnitionStatus
    = EventState
    | "enabled"
    | "disabled"

export type TelematicsDataDetail = {
  type: "fuelLevelAbsolute" | "fuelLevelPercentage" | "odometer"
  unit?: string
  value?: string
  error?: string
}

export type LocationDetail = {
  latitude?: number,
  longitude?: number,
  accuracy?: number,
  error?: string
}

export type TACSServiceType = {
  /**
   * Initializes the TACS SDK to use the given keyring and access grant ID.
   * @param accessGrantId Access grant ID, must correspond with one defined in
   * the keyring
   * @param tacsKeyring TACS keyring
   */
  initialize(
    accessGrantId: string,
    tacsKeyring: TACSKeyringType
  ): Promise<string>

  /**
   * Connects to the vehicle. Make sure the TACS SDK was properly initialized
   * before.
   */
  connect(): Promise<void>
  /**
   * Disconnects from the vehicle currently connected to.
   */
  disconnect(): Promise<void>

  /**
   * Unlocks the vehicle currently connected to.
   */
  unlock(): Promise<void>
  /**
   * Locks the vehicle currently connected to.
   */
  lock(): Promise<void>

  /**
   * Enables the ignition of the vehicle currently connected to (disabling the
   * immobilizer).
   */
  enableIgnition(): Promise<void>
  /**
   * Disables the ignition of the vehicle currently connected to (enabling the
   * immobilizer).
   */
  disableIgnition(): Promise<void>

  /**
   * Requests the current telematics data from the Car Access Module.
   */
  requestTelematicsData(): Promise<void>
  /**
   * Requests the current location inforamtion from the Car Access Module.
   */
  requestLocation(): Promise<void>

  /**
   * Adds a listener for the specified event from the TACS SDK.
   * @param event
   * @param listener
   */
  addEventListener(event: string, listener: (detail: any) => void): void
  addEventListener(
    event: "bluetoothStateChanged",
    listener: (detail: EventStateDetail<BluetoothState>) => void
  ): void
  addEventListener(
    event: "discoveryStateChanged",
    listener: (detail: EventStateDetail<DiscoveryState>) => void
  ): void
  addEventListener(
    event: "connectionStateChanged",
    listener: (detail: EventStateDetail<ConnectionState>) => void
  ): void
  addEventListener(
    event: "doorStatusChanged",
    listener: (detail: EventStateDetail<DoorStatus>) => void
  ): void
  addEventListener(
    event: "ignitionStatusChanged",
    listener: (detail: EventStateDetail<IgnitionStatus>) => void
  ): void
  addEventListener(
    event: "telematicsDataChanged",
    listener: (detail: TelematicsDataDetail) => void
  ): void
  addEventListener(
    event: "locationChanged",
    listener: (detail: LocationDetail) => void
  ): void

  /**
   * Removes a listener for the specified event from the TACS SDK.
   * @param event
   * @param listener
   */
  removeEventListener(event: string, listener: (detail: any) => void): void
}

const { TACSPlugin } = NativeModules as { TACSPlugin: TACSPluginType }

const TACSEvents = new NativeEventEmitter(TACSPlugin)

export const TACSService: TACSServiceType = {
  initialize: (accessGrantId, tacsKeyring) => {
    const tacsKeyringJson = JSON.stringify(tacsKeyring)

    return TACSPlugin.initialize(accessGrantId, tacsKeyringJson)
  },

  connect: () => TACSPlugin.connect(),
  disconnect: () => TACSPlugin.disconnect(),

  unlock: () => TACSPlugin.unlock(),
  lock: () => TACSPlugin.lock(),

  enableIgnition: () => TACSPlugin.enableIgnition(),
  disableIgnition: () => TACSPlugin.disableIgnition(),

  requestTelematicsData: () => TACSPlugin.requestTelematicsData(),
  requestLocation: () => TACSPlugin.requestLocation(),

  addEventListener: (event: string, listener: (detail: any) => void) => {
    TACSEvents.addListener(event, listener)
  },
  removeEventListener: (event: string, listener: (detail: any) => void) => {
    TACSEvents.removeListener(event, listener)
  },
}
