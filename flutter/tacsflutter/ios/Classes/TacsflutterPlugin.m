#import "TacsflutterPlugin.h"
#if __has_include(<tacsflutter/tacsflutter-Swift.h>)
#import <tacsflutter/tacsflutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tacsflutter-Swift.h"
#endif

@implementation TacsflutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTacsflutterPlugin registerWithRegistrar:registrar];
}
@end
