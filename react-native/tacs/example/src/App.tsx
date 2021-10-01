import * as React from 'react'

import { StyleSheet, View, Button, Text } from 'react-native'
import Tacs, { useBluetoothState, useConnectionState, useDoorStatus, useIgnitionStatus, useKeyring } from 'react-native-tacs'

export default function App() {
  useKeyring(getAccessGrantId(), getKeyring())

  const bluetoothState = useBluetoothState()
  const connectionState = useConnectionState()
  const doorStatus = useDoorStatus()
  const ignitionStatus = useIgnitionStatus()

  return (
    <View style={styles.container}>
      <Text>{bluetoothState}</Text>
      <Text>{connectionState}</Text>
      <Text>{doorStatus}</Text>
      <Text>{ignitionStatus}</Text>
      <Button title="Connect" onPress={Tacs.connect} />
      <Button title="Disconnect" onPress={Tacs.disconnect} />
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
})

/**
 * Local function to get the keyring. Paste your own keyring here.
 */
const getKeyring = () => JSON.stringify({
  "tacsLeaseTokenTable": [
    {
      "leaseToken": {
        "endTime": "2221-07-31T11:17:05.000Z",
        "leaseId": "ac1a1d99-9a49-4e53-aee4-ee1113afbf2a",
        "leaseTokenDocumentVersion": "1",
        "leaseTokenId": "e77eefe0-f02a-4c68-b7a2-7550ca7b473a",
        "serviceGrantList": [
          {
            "serviceGrantId": "1",
            "validators": {
              "endTime": "2221-07-31T11:17:05Z",
              "startTime": "2021-09-17T11:17:05Z"
            }
          },
          {
            "serviceGrantId": "2",
            "validators": {
              "endTime": "2221-07-31T11:17:05Z",
              "startTime": "2021-09-17T11:17:05Z"
            }
          },
          {
            "serviceGrantId": "3",
            "validators": {
              "endTime": "2221-07-31T11:17:05Z",
              "startTime": "2021-09-17T11:17:05Z"
            }
          },
          {
            "serviceGrantId": "4",
            "validators": {
              "endTime": "2221-07-31T11:17:05Z",
              "startTime": "2021-09-17T11:17:05Z"
            }
          },
          {
            "serviceGrantId": "5",
            "validators": {
              "endTime": "2221-07-31T11:17:05Z",
              "startTime": "2021-09-17T11:17:05Z"
            }
          },
          {
            "serviceGrantId": "6",
            "validators": {
              "endTime": "2221-07-31T11:17:05Z",
              "startTime": "2021-09-17T11:17:05Z"
            }
          },
          {
            "serviceGrantId": "9",
            "validators": {
              "endTime": "2221-07-31T11:17:05Z",
              "startTime": "2021-09-17T11:17:05Z"
            }
          },
          {
            "serviceGrantId": "10",
            "validators": {
              "endTime": "2221-07-31T11:17:05Z",
              "startTime": "2021-09-17T11:17:05Z"
            }
          }
        ],
        "sorcAccessKey": "4c66a5aa6d31f4f8617c21d7d2a86594",
        "sorcId": "9b1cee15-b483-4ae4-b31a-5e72e3eb7a91",
        "startTime": "2021-09-17T11:17:05.000Z",
        "userId": "Apple:001029.446e2d06f7224be38bceea8fdb897f08.1535"
      },
      "vehicleAccessGrantId": "ac1a1d99-9a49-4e53-aee4-ee1113afbf2a"
    }
  ],
  "tacsLeaseTokenTableVersion": "1631877982832",
  "tacsSorcBlobTable": [
    {
      "blob": {
        "blob": "AZsc7hW0g0rksxpecuPrepEBACkDAACAgyvl9uLWEhiUZRP4e8RHwj+yMWewDs3la2f4Esq2HU1nGyg0Ce5PM5d5oUiAxf49NDPWAbFRtF8ZdYujnzV8eOQAlibUQYmHmgTt4GtDgGqNAj0LHydp1+OxhI9Gkz3OMBXZi/kb/BwIjTs/GJ+HtfNybmsvxZIUszam85rUc3TQFc0CmHEV9kU5INbKi92Yi92Iy7NAJa/SjLHc1+v+xvnqAQPZcQUW7ApCh7xVitXKmW0Fl2IEr+mDlu/l1isJYyGT2Dj9Kjufwpc7VDmAOeMNBawkM6vFy0Dv8QFjVOHu0jhMagrLvOyrWzl0WjLjK2/vRPynZPb/aCTDWUOZL4y9vdNfU+OJpl07EnHWR0ZY7jQdYVp/whNqA5V90qDbhl3CcyjKO6T45TQ4BGyZE9nN7nqgQbC30GroesSBkn/n8Qds3khtpN1W0Sp4snrF0N0zWIJUk3+6hnWot+xi4KM/Flz20Pc2VZpuVRQ0pmM5FZBwDBfSrVF3DO3/WVwjJ3qCBv1+DxFjsokZl8EsFwxZp0XplhhM9awCVw7X4O2h/CYzm/NoobygJbBVUcu7hlubaYIf9PA7T0oXy2X+2Nw37nmGej/U0Rl+SDfXeDHc6Iej+9SpncgHEew5V6P6QlBJ14vgdihrMwMnRKJ6Ky9qbXnj67Ltehtt3TAAaBxjHDZ0hc6bUcxf71NPhhmGc9PL9I9L1TVP4JN0fpM1HMRvb1HI4CyFUQtQ9QXezv9Nj6NdBXLjhwX2hrYnUsT47oiA8Fhj5FBeKdC6Q3/IYLAcqq9vKNBe3Omdajz/uVl76rHjE3knD6qkKUWxc3wBsguTeqD3A+9zNVwEo/d5CFjx7wOoyYESFiTk5lrPHyVoB6Qc0Qi4mwO9wI7ITDPdng4tCXFNtbQyjYgz4Z80y+TlwkkOBTWSWct15I5PJcSTTTEVmP++l8hGiH+CeugMjVhLBNbUh5i4qrSGyn7Ec2hJy4DUHbFs4azk+RIe44BvFiN88Ik3V8E73OandyiFFIJYpDYPGRtyLp/aZSxII9ZK08BuwgNWqWpwnhC+s28fJv0jd362Fbuyrk9BJJ/vIcPadP46a7zNtaqbOa7O/AzcF3/bfjqrpyLK7AJSUiboi/l4Fjw/Go2dWqpS8dYQvIqyrV+BE55kwIHPLtjpobV330050UsUmK6KWO8I338339TbCsREBspKhqX0nRP8F6wHeV/i8Tdyf+5R1o8MQnVN637604RljzNTbFdGe8fFTMoInGKJf5bsJRZovhM+9ipsXTcRxvHTwT6SbPSrhL3kwJA5niK1x3f5WV4oJ02zxHK0B61XgEIaATS2NtqZOeFoUnrdDMteAb/SB6jR4S9oBSODrYWvQ7RdvgGnpGU06ILfnqDQWpiu/YGIIVtfYGFDtOt42PXbYup+NIN/K5CYwVdApVFzq2mEEcD5wn6JEbk6ayTpIho/Bz+GwzNTxzb6iqfTsAYzWcEgz1YVDGGimbo4LycRzBoiL1ELeMqCuAwylKueCbcNXh+UZzl/3o7wJkNeez2JXA38QIT8hXLIAwmWTJ1LLqUhBB3LcOOJWna4rFDqy9cNBnP9kyhnX0/ewph5oFf5z/etzlMH/FxORuFYo5yWPfIuIfe9fZnl6r02siFzo08LnXxgtQI7TjdCcHuIzgJkqnS2lmC6zigFPaF4hGUc50yfTJyMlB/mdNau9NzPLyCSLMIquBdA4ssMHQMHpyHnp+f76LQ55OWbGwTW+XZz50t5hBCUpQ==",
        "blobMessageCounter": "809",
        "sorcId": "9b1cee15-b483-4ae4-b31a-5e72e3eb7a91"
      },
      "externalVehicleRef": "okolowski@plcam",
      "tenantId": "default"
    }
  ],
  "tacsSorcBlobTableVersion": "1631877982832"
})

/**
* Local function to get the keyring. Paste the access grant id of the vehicle
* you want to access here. This is located in the tacsLeaseTokenTable of your
* TACS keyring.
*/
const getAccessGrantId = () => {
  return "ac1a1d99-9a49-4e53-aee4-ee1113afbf2a"
}
