package com.hufsm.sixsense.tacs;

import android.Manifest;
import android.app.AlertDialog;
import android.bluetooth.BluetoothAdapter;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.net.Uri;
import android.provider.Settings;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;

import com.google.gson.Gson;
import com.hufsm.location.mobile.LocationInterface;
import com.hufsm.secureaccess.ble.log.LoggingInterface;
import com.hufsm.secureaccess.ble.model.lease.LeaseToken;
import com.hufsm.secureaccess.ble.model.lease.LeaseTokenBlob;
import com.hufsm.tacs.mobile.TacsInterface;
import com.hufsm.tacs.mobile.TacsKeyring;
import com.hufsm.tacs.mobile.TacsUtils;
import com.hufsm.tacs.mobile.VehicleAccessInterface;
import com.hufsm.telematics.mobile.TelematicsInterface;
import com.karumi.dexter.Dexter;
import com.karumi.dexter.DexterBuilder;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.PermissionDeniedResponse;
import com.karumi.dexter.listener.PermissionGrantedResponse;
import com.karumi.dexter.listener.PermissionRequest;
import com.karumi.dexter.listener.single.PermissionListener;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collection;
import java.util.UUID;

public class TACSPlugin extends CordovaPlugin implements TacsInterface.Callback, LoggingInterface.EventLogCallback {

    static final String TAG = "TACSPlugin";

    private long totalSearchTimeInMs = 30000;
    private long searchOverDueTimeInMs = 10000;
    private int maxConnectionRetryTimeInMs = 20000;

    private CallbackContext callbackContext;

    private TacsInterface tacsInterface;

    private TacsInterface.ConnectionStatus previousConnectionStatus;

    private VehicleAccessInterface.DoorStatus previousDoorStatus;

    private VehicleAccessInterface.ImmobilizerStatus previousImmobilizerStatus;

    private LocationInterface.LocationData previousLocationData;

    // Cordova functions
    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        Log.i("Calling TACS Plugin: " + action, data.toString());
        switch (action) {
            case "setupEventChannel":
                setupEventChannel(callbackContext);
                return true;
            case "initialize":
                initialize(data, callbackContext);
                return true;
            case "connect":
                connect(callbackContext);
                return true;
            case "disconnect":
                disconnect(callbackContext);
                return true;
            case "unlock":
                unlock(callbackContext);
                return true;
            case "lock":
                lock(callbackContext);
                return true;
            case "enableIgnition":
                enableIgnition(callbackContext);
                return true;
            case "disableIgnition":
                disableIgnition(callbackContext);
                return true;
            case "requestLocation":
                requestLocation(callbackContext);
                return true;
            case "requestTelematicsData":
                requestTelematicsData(callbackContext);
                return true;
            default:
                return false;
        }
    }

    private void setupEventChannel(CallbackContext callbackContext) {

        Log.i(TAG, "TACS setting up event channel...");

        this.callbackContext = callbackContext;

        dispatchEvent("initialized", new JSONObject());
    }

    private void initialize(JSONArray data, CallbackContext callbackContext) throws JSONException {

        Log.i(TAG, "TACS initializing plugin...");

        checkBluetoothEnabled();

        tacsInterface = new TacsInterface.Builder(this, cordova.getActivity().getApplicationContext())
                .enableMockMode(false)
                .setSearchOverdueTimeLimit(searchOverDueTimeInMs)
                .setSearchAbortTimeLimit(totalSearchTimeInMs)
                .setMaxConnectionRetryTime(maxConnectionRetryTimeInMs)
                .build();

        tacsInterface.logging().registerEventCallback(this);

        String accessGrantId = data.getString(0);

        String keyringJson = data.getString(1);

        Gson gson = new Gson();

        TacsKeyring keyring = gson.fromJson(keyringJson.toString(), TacsKeyring.class);

        boolean accessGrantIsValid = tacsInterface.useAccessGrant(accessGrantId, keyring);

        if (accessGrantIsValid) {

            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, "Ready to connect");

            callbackContext.sendPluginResult(pluginResult);

        } else {

            PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "Keyring invalid");

            callbackContext.sendPluginResult(pluginResult);
        }
    }

    private void connect(CallbackContext callbackContext) {

        tacsInterface.searchAndConnect();

        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);

        callbackContext.sendPluginResult(pluginResult);
    }

    private void disconnect(CallbackContext callbackContext) {

        tacsInterface.cancelSearch();
        tacsInterface.cancelConnection();

        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);

        callbackContext.sendPluginResult(pluginResult);
    }

    private void unlock(CallbackContext callbackContext) {

        tacsInterface.vehicleAccess().unlockDoors();

        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);

        callbackContext.sendPluginResult(pluginResult);
    }

    private void lock(CallbackContext callbackContext) {

        tacsInterface.vehicleAccess().lockDoors();

        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);

        callbackContext.sendPluginResult(pluginResult);
    }

    private void enableIgnition(CallbackContext callbackContext) {

        tacsInterface.vehicleAccess().controlImmobilizer(false);

        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);

        callbackContext.sendPluginResult(pluginResult);
    }

    private void disableIgnition(CallbackContext callbackContext) {

        tacsInterface.vehicleAccess().controlImmobilizer(true);

        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);

        callbackContext.sendPluginResult(pluginResult);
    }

    private void requestLocation(CallbackContext callbackContext) {

        tacsInterface.telematics().queryLocation();

        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);

        callbackContext.sendPluginResult(pluginResult);
    }

    private void requestTelematicsData(CallbackContext callbackContext) {

        Collection<TelematicsInterface.TelematicsDataType> dataTypes = new ArrayList<>();
        dataTypes.add(TelematicsInterface.TelematicsDataType.FUEL_LEVEL_ABSOLUTE);
        dataTypes.add(TelematicsInterface.TelematicsDataType.FUEL_LEVEL_PERCENTAGE);
        dataTypes.add(TelematicsInterface.TelematicsDataType.ODOMETER);

        tacsInterface.telematics().queryTelematicsData(dataTypes);

        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);

        callbackContext.sendPluginResult(pluginResult);
    }

    private void dispatchEvent(String type, JSONObject detail) {

        try {
            JSONObject event = new JSONObject();
            event.put("type", "tacs:" + type);
            event.put("detail", detail);

            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, event);

            pluginResult.setKeepCallback(true);

            callbackContext.sendPluginResult(pluginResult);
        } catch (JSONException exception) {
            Log.e(TAG, exception.toString());
        }
    }

    @Override
    public void updateVehicleStatus(TacsInterface.VehicleStatus vehicleStatus) {
        handleConnectionStatus(vehicleStatus);

        if (vehicleStatus.getConnectionStatus().isConnected()) {
            handleDoorStatus(vehicleStatus);
            handleIgnitionStatus(vehicleStatus);
            handleTelematicsDataStatus(vehicleStatus);
            handleLocationStatus(vehicleStatus);
        }
    }

    private void handleConnectionStatus(TacsInterface.VehicleStatus vehicleStatus) {

        TacsInterface.ConnectionStatus connectionStatus = vehicleStatus.getConnectionStatus();

        if (connectionStatus != previousConnectionStatus) {

            previousConnectionStatus = connectionStatus;

            try {
                String state = "";

                switch (connectionStatus) {
                    case CONNECTED:
                        state = "connected";
                        break;
                    case SEARCHING:
                    case CONNECTING:
                        state = "connecting";
                        break;
                    default:
                        state = "disconnected";
                        break;
                }

                JSONObject detail = new JSONObject();
                detail.put("state", state);

                dispatchEvent("connectionStateChanged", detail);
            } catch (JSONException exception) {
                Log.e(TAG, "Could not send connectionStateChanged event: " + exception.toString());
            }
        }
    }

    private void handleDoorStatus(TacsInterface.VehicleStatus vehicleStatus) {

        VehicleAccessInterface.DoorStatus doorStatus = vehicleStatus.getDoorStatus();

        if (doorStatus != previousDoorStatus) {

            previousDoorStatus = doorStatus;

            try {
                String state = "";

                switch (doorStatus) {
                    case DOORS_LOCKED:
                        state = "locked";
                        break;
                    case DOORS_UNLOCKED:
                        state = "unlocked";
                        break;
                    default:
                        state = "error";
                        break;
                }

                JSONObject detail = new JSONObject();
                detail.put("state", state);
                if (state.equals("error")) {
                    detail.put("message", doorStatus.toString());
                }

                dispatchEvent("doorStatusChanged", detail);
            } catch (JSONException exception) {
                Log.e(TAG, "Could not send doorStatusChanged event: " + exception.toString());
            }
        }
    }

    private void handleIgnitionStatus(TacsInterface.VehicleStatus vehicleStatus) {

        VehicleAccessInterface.ImmobilizerStatus immobilizerStatus = vehicleStatus.getImmobilizerStatus();

        if (immobilizerStatus != previousImmobilizerStatus) {

            previousImmobilizerStatus = immobilizerStatus;

            try {
                String state = "";

                switch (immobilizerStatus) {
                    case VEHICLE_START_POSSIBLE:
                        state = "enabled";
                        break;
                    case VEHICLE_START_IMPOSSIBLE:
                        state = "disabled";
                        break;
                    default:
                        state = "error";
                        break;
                }

                JSONObject detail = new JSONObject();
                detail.put("state", state);
                if (state.equals("error")) {
                    detail.put("message", immobilizerStatus.toString());
                }

                dispatchEvent("ignitionStatusChanged", detail);
            } catch (JSONException exception) {
                Log.e(TAG, "Could not send ignitionStatusChanged event: " + exception.toString());
            }
        }
    }

    private void handleTelematicsDataStatus(TacsInterface.VehicleStatus vehicleStatus) {

        Collection<TelematicsInterface.TelematicsData> allTelematicsData = vehicleStatus.getTelematicsData();

        for (TelematicsInterface.TelematicsData telematicsData : allTelematicsData) {

            try {

                String type = "";

                switch (telematicsData.type()) {
                    case ODOMETER:
                        type = "odometer";
                        break;
                    case FUEL_LEVEL_ABSOLUTE:
                        type = "fuelLevelAbsolute";
                        break;
                    case FUEL_LEVEL_PERCENTAGE:
                        type = "fuelLevelPercentage";
                        break;
                }

                JSONObject detail = new JSONObject();
                detail.put("type", type);

                TelematicsInterface.TelematicsStatusCode statusCode = telematicsData.statusCode();

                if (statusCode == TelematicsInterface.TelematicsStatusCode.SUCCESS) {
                    detail.put("unit", telematicsData.unit());
                    detail.put("value", telematicsData.value());
                } else {
                    detail.put("error", statusCode.toString());
                }

                dispatchEvent("telematicsDataChanged", detail);
            } catch (JSONException exception) {
                Log.e(TAG, "Could not send telematicsDataChanged event: " + exception.toString());
            }
        }
    }

    private void handleLocationStatus(TacsInterface.VehicleStatus vehicleStatus) {

        LocationInterface.LocationData locationData = vehicleStatus.getLocationData();

        if (locationData == null) {
            return;
        }

        if (previousLocationData != null
            && locationData.getAccuracy().equals(previousLocationData.getAccuracy())
            && locationData.getLatitude().equals(previousLocationData.getLatitude())
            && locationData.getLongitude().equals(previousLocationData.getLongitude())) {
            return;
        }

        previousLocationData = locationData;

        try {

            JSONObject detail = new JSONObject();

            LocationInterface.LocationStatusCode statusCode = locationData.getLocationStatusCode();

            if (statusCode == LocationInterface.LocationStatusCode.SUCCESS) {
                detail.put("latitude", locationData.getLatitude());
                detail.put("longitude", locationData.getLongitude());
                detail.put("accuracy", locationData.getAccuracy());
            } else {
                detail.put("error", statusCode.toString());
            }

            dispatchEvent("locationChanged", detail);
        } catch (JSONException exception) {
            Log.e(TAG, "Could not send locationChanged event: " + exception.toString());
        }
    }

    @Override
    public void updateDeviceStatus(TacsInterface.BluetoothDeviceStatus bluetoothDeviceStatus, String s) {

    }

    @Override
    public void logEvent(LoggingInterface.LogEvent logEvent) {
        Log.i(TAG, logEvent.toString());
    }

    private void checkBluetoothEnabled() {

        BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

        if (bluetoothAdapter != null) {
            if (bluetoothAdapter.isEnabled()) {
                checkLocationServicesEnabled();
            } else {
                showBluetoothRequiredDialog();
            }
        }
    }

    private void showBluetoothRequiredDialog() {
        Context context = cordova.getContext();

        AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(context);

        AlertDialog alert = dialogBuilder
            .setTitle("Turn on Bluetooth")
            .setMessage("Please turn on the Bluetooth on your phone in order to establish a secure connection to your vehicle.")
            .setPositiveButton("OK", (dialog, which) -> {
                Intent intent = new Intent();
                intent.setAction(Settings.ACTION_BLUETOOTH_SETTINGS);
                context.startActivity(intent);
            })
            .create();

        alert.show();
    }

    private void checkLocationServicesEnabled() {
        Context context = cordova.getContext();

        LocationManager manager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
        boolean isGpsEnabled = manager.isProviderEnabled(LocationManager.GPS_PROVIDER);

        if (isGpsEnabled) {
            checkLocationPermissions();
        } else {

            AlertDialog alert = new AlertDialog.Builder(context)
                    .setTitle("Turn on Location Services")
                    .setMessage("Some Android phones require Location Services to be enabled in order to scan nearby Bluetooth devices.")
                    .setPositiveButton("OK", (dialog, which) -> {
                        Intent intent = new Intent();
                        intent.setAction(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
                        context.startActivity(intent);
                    })
                    .create();

            alert.show();
        }
    }

    private void checkLocationPermissions() {
        Context context = cordova.getContext();

        Dexter.withActivity(cordova.getActivity())
                .withPermission(Manifest.permission.ACCESS_FINE_LOCATION)
                .withListener(new PermissionListener() {
                    @Override
                    public void onPermissionGranted(PermissionGrantedResponse permissionGrantedResponse) {
                    }

                    @Override
                    public void onPermissionDenied(PermissionDeniedResponse permissionDeniedResponse) {
                        if (permissionDeniedResponse.isPermanentlyDenied()) {
                            Intent intent = new Intent(
                                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                    Uri.parse("package:" + BuildConfig.LIBRARY_PACKAGE_NAME)
                            );
                            context.startActivity(intent);
                        }
                    }

                    @Override
                    public void onPermissionRationaleShouldBeShown(PermissionRequest permissionRequest, PermissionToken permissionToken) {
                        permissionToken.continuePermissionRequest();
                    }
            }).check();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        tacsInterface.closeInterface();
    }
}
