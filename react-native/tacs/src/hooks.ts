import { useEffect } from "react"
import Tacs, { TacsEvents } from "react-native-tacs"
import useEvent from "./useEvent"

export const useKeyring = (accessGrantId: string, keyringJson: string) => {
  useEffect(() => {
    Tacs.initialize(accessGrantId, keyringJson)
      .then(() => console.info("initialized"))
      .catch((error) => console.error(error))
  }, [accessGrantId, keyringJson])
}

export const useBluetoothState = () => {
  const bluetoothState = useEvent<string>(
    TacsEvents,
    "bluetoothStateChanged",
    "unknown",
    ({state}) => state
  )

  return bluetoothState
}

export const useConnectionState = () => {
  const connectionState = useEvent<string>(
    TacsEvents,
    "connectionStateChanged",
    "unknown",
    ({state}) => state
  )

  return connectionState
}

export const useDoorStatus = () => {
  const doorStatus = useEvent<string>(
    TacsEvents,
    "doorStatusChanged",
    "unknown",
    ({state}) => state
  )

  return doorStatus
}

export const useIgnitionStatus = () => {
  const ignitionStatus = useEvent<string>(
    TacsEvents,
    "ignitionStatusChanged",
    "unknown",
    ({state}) => state
  )

  return ignitionStatus
}

    // "discoveryStarted",
    // "discovered",
    // "discoveryFailed",
    // "connectionStateChanged",
    // "doorStatusChanged",
    // "ignitionStatusChanged",
    // "locationChanged",
    // "telematicsDataChanged"
