import { NativeEventEmitter, NativeModules } from 'react-native'

type TacsType = {
  multiply(a: number, b: number): Promise<number>
  setupEventChannel(callback: (event: any) => void): void
  initialize(accessGrantId: string, keyringJson: string): Promise<string>
  connect(): Promise<void>
  disconnect(): Promise<void>
};

const { Tacs } = NativeModules

export const TacsEvents = new NativeEventEmitter(Tacs)

export default Tacs as TacsType

export * from "./hooks"
