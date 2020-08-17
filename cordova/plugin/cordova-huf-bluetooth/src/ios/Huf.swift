/*
* Notes: The @objc shows that this class & function should be exposed to Cordova.
*/
@objc(Huf) class Huf : CDVPlugin {
  @objc(hello:) // Declare your function name.
  func hello(command: CDVInvokedUrlCommand) { // write the function code.
    /* 
     * Always assume that the plugin will fail.
     * Even if in this example, it can't.
     */
    // Set the plugin result to fail.
    var pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: "The Plugin Failed");
    // Set the plugin result to succeed.
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "The plugin succeeded");
    // Send the function result back to Cordova.
    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
  }

  @objc(executeLock:) // Declare your function name.
  func executeLock(command: CDVInvokedUrlCommand) { // write the function code.
     print("Executing lock")
     
  }
}