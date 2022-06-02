import Foundation

enum Copy {
    static let policy = """
This app is **not** tracking you in anyway, nor sharing any information from you with no one, we are also not storing any data concerning you.

We make use of Apple's *iCloud* to synchronise your maps across your own devices, but no one else has access to them if you don't share them directly.

If you allow **notifications** these are going to be displayed only for giving feedback on actions you take while using the app, we **don't** want to contact you in anyway and specifically we **don't** want to send you **Push Notifications**.

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
}
