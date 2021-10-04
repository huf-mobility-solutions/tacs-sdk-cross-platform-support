import { useEffect } from "react"
import type {
  BluetoothState,
  ConnectionState,
  DiscoveryState,
  DoorStatus,
  EventStateDetail,
  IgnitionStatus,
  LocationDetail,
  TelematicsDataDetail
} from "react-native-tacs"

import { TACSKeyringType, TACSService } from "./TACSService"
import { useTACSEvent } from "./useTACSEvent"

/**
 * Initializes the TACS SDK to use the given keyring and access grant ID.
 * @param accessGrantId Access grant ID, must correspond with one defined in
 * the keyring
 * @param tacsKeyring TACS keyring
 */
export const useKeyring = (
  accessGrantId: string,
  tacsKeyring: TACSKeyringType,
) => {
  useEffect(() => {
    TACSService.initialize(accessGrantId, tacsKeyring)
      .then(() => console.info("initialized"))
      .catch((error) => console.error(error))
  }, [accessGrantId, tacsKeyring])
}

/**
 * Returns the current Bluetooth state.
 * @returns Current Bluetooth state
 */
export const useBluetoothState = () => {
  const bluetoothState = useTACSEvent<BluetoothState>(
    "bluetoothStateChanged",
    "unknown",
    ({state}: EventStateDetail<BluetoothState>) => state
  )

  return bluetoothState
}

/**
 * Returns the current discovery state for the Car Access Module.
 * @returns Current discovery status
 */
export const useDiscoveryState = () => {
  const discoveryState = useTACSEvent<DiscoveryState>(
    "discoveryStateChanged",
    "unknown",
    ({state}: EventStateDetail<DiscoveryState>) => state
  )

  return discoveryState
}

/**
 * Returns the current connection state for the Car Access Module.
 * @returns Current connection status
 */
export const useConnectionState = () => {
  const connectionState = useTACSEvent<ConnectionState>(
    "connectionStateChanged",
    "unknown",
    ({state}: EventStateDetail<ConnectionState>) => state
  )

  return connectionState
}

/**
 * Returns the door status of the vehicle currently connected to.
 * @returns Current door status
 */
export const useDoorStatus = () => {
  const doorStatus = useTACSEvent<DoorStatus>(
    "doorStatusChanged",
    "unknown",
    ({state}: EventStateDetail<DoorStatus>) => state
  )

  return doorStatus
}

/**
 * Returns the ignition status (immobilizer) of the vehicle currently connected
 * to.
 * @returns Current ignition status (immobilizer)
 */
export const useIgnitionStatus = () => {
  const ignitionStatus = useTACSEvent<IgnitionStatus>(
    "ignitionStatusChanged",
    "unknown",
    ({state}: EventStateDetail<IgnitionStatus>) => state
  )

  return ignitionStatus
}

type TelematicsData = {
  fuelLevelAbsolute: "unknown" | string
  fuelLevelPercentage: "unknown" | string
  odometer: "unknown" | string
}

/**
 * Returns the telematics data of the vehicle currently connected.
 * to.
 * @returns Current telematics data
 */
export const useTelematicsData = () => {
  const ignitionStatus = useTACSEvent<TelematicsData>(
    "telematicsDataChanged",
    {
      fuelLevelAbsolute: "unknown",
      fuelLevelPercentage: "unknown",
      odometer: "unknown",
    },
    ({type, unit, value, error}: TelematicsDataDetail, previousState) => {
      const updatedValue = {} as Record<typeof type, string>

      updatedValue[type] = error ? "unknown" : `${value}${unit}`

      const updatedState = Object.assign({}, previousState, updatedValue);

      return updatedState
    }
  )

  return ignitionStatus
}

type Location = {
  latitude: "unknown" | number
  longitude: "unknown" | number
  accuracy: "unknown" | number
}

/**
 * Returns the location of the vehicle currently connected.
 * to.
 * @returns Current location
 */
export const useLocation = () => {
  const ignitionStatus = useTACSEvent<Location>(
    "locationChanged",
    {
      latitude: "unknown",
      longitude: "unknown",
      accuracy: "unknown",
    },
    ({ latitude, longitude, accuracy, error }: LocationDetail) => {
      if (error) {
        return {
          latitude: "unknown",
          longitude: "unknown",
          accuracy: "unknown",
        }
      }

      return {
        latitude: latitude ?? "unknown",
        longitude: longitude ?? "unknown",
        accuracy: accuracy ?? "unknown",
      }
    },
  )

  return ignitionStatus
}
