#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(Tacs, RCTEventEmitter)

RCT_EXTERN_METHOD(setupEventChannel:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(initialize:(NSString)accessGrantId withKeyringJson:(NSString)keyringJson
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

@end
