package com.playmoove.huf;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;

import java.util.ArrayList;

public class Huf extends CordovaPlugin {

    static final String TAG = "HUFBtPlugin";

    // Helper function to send response
    private void sendSuccess(CallbackContext callbackContext, String message) {
        sendSuccess(callbackContext, message, true);
    }

    private void sendError(CallbackContext callbackContext, String message) {
        sendError(callbackContext, message, true);
    }

    private void sendSuccess(CallbackContext callbackContext, String message, boolean keepOpen) {
        PluginResult pr = new PluginResult(PluginResult.Status.OK, message);
        pr.setKeepCallback(keepOpen);
        Log.i(TAG, message);
        callbackContext.sendPluginResult(pr);
    }

    private void sendError(CallbackContext callbackContext, String message, boolean keepOpen) {
        PluginResult pr = new PluginResult(PluginResult.Status.ERROR, message);
        pr.setKeepCallback(keepOpen);
        Log.e(TAG, message);
        callbackContext.sendPluginResult(pr);
    }

    // Cordova functions
    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        Log.i("CORDOVA ACTION: " + action, data.toString());
        switch (action) {
            case "setup":
                if (!requestForAllPermissions(this.cordova.getActivity())) {
                    sendError(callbackContext, "MISSING_PERMISSIONS", false);
                    return false;
                }
            case "hello":
                sendSuccess(callbackContext, "HELLO_WORLD", false);
            default:
                return false;
        }
    }

    /**
     * Check a given permission
     *
     * @param permission         The permission to check
     * @param awaitedValue       The awaited value
     * @param requiredPermission The permission array to update
     */
    private void checkPermission(String permission, int awaitedValue, ArrayList<String> requiredPermission, Context context) {
        int permissionValue = ContextCompat.checkSelfPermission(context, permission);
        if (permissionValue != 0 && permissionValue != awaitedValue && requiredPermission != null) {
            requiredPermission.add(permission);
        }
    }

    /**
     * Check all required permissions
     *
     * @return An array containing the required permissions
     */
    private String[] checkAllPermissions(Context context) {
        ArrayList<String> requiredPermissions = new ArrayList<>();
        checkPermission(android.Manifest.permission.ACCESS_COARSE_LOCATION, PackageManager.GET_PERMISSIONS, requiredPermissions, context);
        checkPermission(android.Manifest.permission.BLUETOOTH_ADMIN, PackageManager.GET_PERMISSIONS, requiredPermissions, context);

        String[] requiredPermissionArray = new String[requiredPermissions.size()];
        requiredPermissions.toArray(requiredPermissionArray);
        return requiredPermissionArray;
    }

    /**
     * Check if all permissions are set, popup user if needed.
     *
     * @return true if all permissions are set, false otherwise
     */
    private boolean requestForAllPermissions(Activity activity) {
        String[] requiredPermissions = checkAllPermissions(activity.getApplicationContext());

        // ask permissions if needed
        if (requiredPermissions.length != 0) {
            ActivityCompat.requestPermissions(activity, requiredPermissions, 1);
        }

        // recheck if all permissions have been accepted
        requiredPermissions = checkAllPermissions(activity.getApplicationContext());
        return requiredPermissions.length == 0;
    }
}
