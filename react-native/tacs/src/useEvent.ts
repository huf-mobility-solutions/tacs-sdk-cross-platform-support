import { useState } from "react"

export default <T>(target: any, eventName: string, initialState: T, mapper?: (event: any) => T) => {
  const [value, setValue] = useState<T>(() => initialState)

  target.addListener(eventName, (event: any) => {
    if (mapper) {
      const newValue = mapper(event)
      setValue(newValue)
    } else {
      setValue(event)
    }
  });

  return value
}
