export declare type PluginEvent = {
    type: string;
    detail: any;
};
export declare type Keyring = {
    tacsLeaseTokenTableVersion: string;
    tacsLeaseTokenTable: {
        vehicleAccessGrantId: string;
        leaseToken: {
            leaseId: string;
            userId: string;
            sorcId: string;
            serviceGrantList: {
                serviceGrantId: string;
                validators: {
                    startTime: string;
                    endTime: string;
                };
            }[];
            leaseTokenDocumentVersion: string;
            leaseTokenId: string;
            sorcAccessKey: string;
            startTime: string;
            endTime: string;
        };
    }[];
    tacsSorcBlobTableVersion: string;
    tacsSorcBlobTable: {
        tenantId: string;
        externalVehicleRef: string;
        blob: {
            sorcId: string;
            blob: string;
            blobMessageCounter: string;
        };
    }[];
};
export declare type TACS = {
    initialize: (accessGrantId: string, keyring: Keyring) => Promise<void>;
    connect: () => Promise<void>;
    disconnect: () => Promise<void>;
    lock: () => Promise<void>;
    unlock: () => Promise<void>;
    enableIgnition: () => Promise<void>;
    disableIgnition: () => Promise<void>;
    requestTelematicsData: () => Promise<void>;
    requestLocation: () => Promise<void>;
};
