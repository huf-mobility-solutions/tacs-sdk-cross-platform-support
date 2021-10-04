import React from "react"
import { StyleSheet, Text, TouchableOpacity } from "react-native"

type StyledButtonProps = {
  title: string
  onPress: () => any
}

export default function StyledButton({ title, onPress }: StyledButtonProps) {
  return (
    <TouchableOpacity style={styles.container} onPress={onPress}>
      <Text style={styles.text}>{title}</Text>
    </TouchableOpacity>
  )
}

const styles = StyleSheet.create({
  container: {
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderRadius: 100,
    backgroundColor: "#6633cc",
    marginHorizontal: 8,
    flex: 1,
  },
  text: {
    color: "#FFFFFF",
    fontSize: 16,
    textAlign: "center",
  },
})
