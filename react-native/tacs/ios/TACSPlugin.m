#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(TACSPlugin, RCTEventEmitter)

RCT_EXTERN_METHOD(initialize:(NSString)accessGrantId withKeyringJson:(NSString)keyringJson
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(connect:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(disconnect:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(lock:(RCTPromiseResolveBlock)resolve
withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(unlock:(RCTPromiseResolveBlock)resolve
withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(enableIgnition:(RCTPromiseResolveBlock)resolve
withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(disableIgnition:(RCTPromiseResolveBlock)resolve
withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(requestTelematicsData:(RCTPromiseResolveBlock)resolve
withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(requestLocation:(RCTPromiseResolveBlock)resolve
withRejecter:(RCTPromiseRejectBlock)reject)

@end
