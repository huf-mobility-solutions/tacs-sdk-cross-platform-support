import { useEffect, useState } from "react"

import { TACSService } from "./TACSService"

export function useTACSEvent<T>(
  eventName: string,
  initialState: T,
  mapper?: (event: any, previousState: T) => T,
) {
  const [value, setValue] = useState<T>(() => initialState)

  useEffect(() => {
    const handleEvent = (detail: any) => {
      if (mapper) {
        const newValue = mapper(detail, value)
        setValue(newValue)
      } else {
        setValue(detail)
      }
    }

    TACSService.addEventListener(eventName, handleEvent)

    return () => {
      TACSService.removeEventListener(eventName, handleEvent)
    }
  }, [])

  return value
}
