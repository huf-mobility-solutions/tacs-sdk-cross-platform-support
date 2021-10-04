import React from "react"
import { StyleSheet, Text, View } from "react-native"

type LabeledValueProps = {
  label: string
  value: any
}

export default function LabeledValue({
  label,
  value,
}: LabeledValueProps) {
  return (
    <View style={styles.container}>
        <Text style={styles.label}>{label}</Text>
        <Text style={styles.value}>{value}</Text>
      </View>
  )
}


const styles = StyleSheet.create({
  container: {
    flexDirection: "column",
    alignItems: "center",
  },
  label: {
    fontSize: 14,
    color: "#BDBDBD"
  },
  value: {
    fontSize: 18,
  }
})
