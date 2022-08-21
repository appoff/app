import Foundation

enum Copy {
    static let policy = """
This app is **not** tracking you in anyway, nor sharing any information from you with no one, we are also not storing any data concerning you.

We make use of Apple's *iCloud* to synchronise your maps across your own devices, but no one else has access to them if you don't share them directly.

Whatever you do with this app is up to you and we **don't** want to know about it.
"""
    
    static let terms = """
We make use of Apple's iCloud to synchronise your maps.

There is nothing stored on iCloud that could be linked to you or your devices.

Your maps get stored both locally and on a *public database* on iCloud.

They are stored on the *public database* so that it doesn't affect your own's account iCloud quota. Instead we take care of the quota for you, we pay for this storage so that you don't have to pay for it with your account.

Even though they get stored in a *public database*, **no one else but you can read or access your maps unless you share them directly with them**.

By using this app you are accepting these terms.
"""
    
    static let basic = """
You need at least **2 markers** to create a map. This way it is possible to know what area to save.

You can add more than 2 markers, as many as needed, but there is a limit on the maximum size of the map.

When a map is too big it can consume the whole memory of your device, and they took a very long time to create.

Make your maps as small as possible.

Once you set your desired markers on the map, you can hit **Save** and the map creation will begin, please be patient, this process can take a few minutes to complete.

Avoid creating maps under a cellular network, this will consume huge amounts of your mobile data.

Once you have created a map is not possible to edit it anymore, if you want to change anything you need to create a new one instead.
"""
    
    static let markers = """
You can add markers to specific points on the map in different ways.

**iOS**
— Touching down on the map and keeping it pressed for a few seconds (**Long press touch**).

**macOS**
— Clicking on a point and keeping it pressed for over 1 second.
— Right clicking on a point.

It is also possible to add markers by searching for a specific address or point of interest, if you select any search result it will be added to the map.

If you want to add a marker on your current location you can do that on the **Options** menu.

Every time you add or remove a marker the directions between the markers will be updated.

Once a marker is added you can remove it by selecting it and hitting the remove button on the popup.
"""
}
