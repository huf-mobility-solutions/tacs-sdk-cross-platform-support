import * as React from 'react'
import { NavigationContainer } from "@react-navigation/native"
import { createNativeStackNavigator } from "@react-navigation/native-stack"

import TestScreen from './TestScreen'

const Stack = createNativeStackNavigator()

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="React Native TACS Example" component={TestScreen}></Stack.Screen>
      </Stack.Navigator>
    </NavigationContainer>
  )
}
