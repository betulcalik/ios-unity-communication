<!-- PROJECT LOGO -->
<p align="center">
  <h1 align="center"> iOS-Unity Communication </h1>

  <p align="center">
    This repository is an iOS project that includes iOS and Unity communication.
    <br />
    <a href="https://github.com/betulcalik/ios-unity-communication/tree/main/ios-unity-communication"><strong>Explore the project »</strong></a>
    <br />
    <br />
    <a href="https://github.com/betulcalik/ios-unity-communication/issues">Report Bug</a>
  </p>
</p>

---
<!-- Article and code links -->

<a href="https://medium.com/mop-developers/communicate-with-a-unity-game-embedded-in-a-swiftui-ios-app-1cefb38ff439"><strong>Communicate with a Unity game embedded in a SwiftUI iOS App »</strong></a>

<!-- Table Of Contents -->

## Table Of Contents

### 1. Technologies
1. Unity
2. UnityFramework
3. NativeCallProxy

### 2. Steps to Embed a Unity Game into an iOS Application
1. Create an Unity project.
2. Export the Unity project.
3. Drag and drop the Unity-iPhone.xcodeproj file to the iOS workspace.
4. Add a new framework to the iOS workspace: 
```
General >
Frameworks, Libraries and Embedded Content >
Click the + button >
Select the UnityFramework.framework from the list.
```

| | |
|-|-|
|`NOTE` | You must connect and run on a real device to successful build. |

### 3. iOS to Unity Communication
1. Create a struct called UnityMessage.
```
struct UnityMessage {
    let objectName: String?
    let methodName: String?
    let messageBody: String?
}
```
2. Create a cache array for cases where Unity is not initialized.
```
var cachedMessages = [UnityMessage]()
```
3. Create a sendMessage function to sending message to Unity.
* Object Name: Name of Unity object.
* Method Name: Name of Unity method.
* Message: Message to Unity.

```
func sendMessage(_ objectName: String, methodName: String, message: String) {
    let msg: UnityMessage = UnityMessage(
        objectName: objectName,
        methodName: methodName,
        messageBody: message)

    // Send the message right away if Unity is initialized, else cache it
    if isInitialized {
        unityFramework?.sendMessageToGO(
            withName: msg.objectName,
            functionName: msg.methodName,
            message: msg.messageBody)
    } else {
        cachedMessages.append(msg)
    }
}
```
4. Send message to Unity.
```
UnityManager.shared.sendMessage(
    "Ball",
    methodName: "SetBallColor",
    message: "red")
```

### 4. Unity to iOS Communication

1. Create a NativeCallProxy.h file.

```
#import <Foundation/Foundation.h>

@protocol NativeCallsProtocol
@required
- (void) sendMessageToMobileApp:(NSString*)message;
// other methods
@end

__attribute__ ((visibility("default")))
@interface FrameworkLibAPI : NSObject
+(void) registerAPIforNativeCalls:(id<NativeCallsProtocol>) aApi;

@end
```

2. Create a NativeCallProxy.mm file.

```
#import <Foundation/Foundation.h>
#import "NativeCallProxy.h"

@implementation FrameworkLibAPI

id<NativeCallsProtocol> api = NULL;
+(void) registerAPIforNativeCalls:(id<NativeCallsProtocol>) aApi
{
    api = aApi;
}

@end

extern "C"
{
    void sendMessageToMobileApp(const char* message)
    {
        return [api sendMessageToMobileApp:[NSString stringWithUTF8String:message]];
    }
}
```

3. Add NativeCallProxy.h and NativeCallProxy.mm files to the Unity.
4. Create a bridging header file in the iOS project.

```
#import <UnityFramework/NativeCallProxy.h>
```

5. Send message to the iOS project using NativeAPI in the Unity project.

```
public class NativeAPI {
    [DllImport("__Internal")]
    public static extern void sendMessageToMobileApp(string message);
}

public void ButtonPressed()
{
    pressCount++;
    NativeAPI.sendMessageToMobileApp("The button has been tapped " + pressCount.ToString() + " times!");
}

```

6. Implement the NativeCallsProtocol in the iOS project. And get message from Unity using sendMessage() function.

```
extension ViewController: NativeCallsProtocol {
    func sendMessage(toMobileApp message: String) {
        print(message)
    }
}
```

### 3. Application Overview

