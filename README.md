# ios-app

#### To clone a local copy of the xcode project onto your computer,
`git clone https://github.com/morningsignout/ios-app.git`


#### Once you have a local copy:
**you MUST open ios-app.xcworkspace** in xcode. **NOT ios-app.xcodeproj.** This has to do with using Cocoapods as a dependency manager for the AFNetworking library.


#### Git Workflow
Let's try to work on separate branches for development and only push changes to `dev` once they are fully functional and "production ready". We only merge into `master` whenever the app is ready for release or approved by the App Store.

When merging changes, use `git merge --no-ff <branch-to-merge>` instead of `git merge <branch-to-merge>` so that we can track changes and make sure that branches are not lost in the merging process.

Checkout [this](http://rogerdudler.github.io/git-guide/) guide for help on git.
