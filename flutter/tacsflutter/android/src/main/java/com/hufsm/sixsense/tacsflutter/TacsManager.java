package com.hufsm.sixsense.tacsflutter;

import android.content.Context;

import com.hufsm.tacs.mobile.TacsInterface;
import com.hufsm.tacs.mobile.TacsKeyring;
import com.hufsm.telematics.mobile.TelematicsInterface;

public class TacsManager implements TacsInterface.Callback {

    private TacsInterface tacsInterface;
    private TacsKeyring keyring = null;
    static final String MY_MOCK_ACCESS_GRANT_ID = "MySampleAccessGrantId";

    public TacsManager(Context context) {
        if (tacsInterface != null) {
            tacsInterface.closeInterface();
        }

        tacsInterface = new TacsInterface.Builder(this, context)
                .enableMockMode(false)
                .build();
    }

    public void buildKeyring() {
        if (tacsInterface.useAccessGrant(MY_MOCK_ACCESS_GRANT_ID, keyring)) {
            //The key ring is loaded successfully
        } else {
            //Invalid keyring
        }
    }

    public void connect() {
        tacsInterface.searchAndConnect();
    }

    public void disconnect() {
        tacsInterface.cancelAll();
    }

    public void lockDoors() {
        tacsInterface.vehicleAccess().lockDoors();
    }

    public void unlockDoors() {
        tacsInterface.vehicleAccess().unlockDoors();
    }

    public void enableEngine() {
        tacsInterface.vehicleAccess().controlImmobilizer(false);
    }

    public void disableEngine() {
        tacsInterface.vehicleAccess().controlImmobilizer(true);
    }

    public void getLocation() {
        tacsInterface.telematics().queryLocation();
    }

    public void getTelematics() {
        tacsInterface.telematics().queryTelematicsData(TelematicsInterface.TelematicsDataType.buildRequest());
    }

    @Override
    public void updateVehicleStatus(TacsInterface.VehicleStatus vehicleStatus) {

    }

    @Override
    public void updateDeviceStatus(TacsInterface.BluetoothDeviceStatus bluetoothDeviceStatus, String s) {

    }
}
