# ShakeItPhoto


## Become a Tester

If you would like to provide feedback on ShakeIt Photo's upcoming releases,
please [let us know](http://www.momentpark.com/contact-us) and we will invite
you to Test Flight.

You can [find a summary of the latest changes in our changelog](./CHANGELOG.md)

## Become a Contributor

Familiarize yourself with [Zinc's guide to becoming a
contributor](https://www.zinc.coop/contributing/) and read on!

### Prerequisites

[Download the GoogleService-Info.plist from the Firebase console] and place it
in the project root directory. See [Add Firebase to your iOS project] for more
information.

Install [rbenv](https://github.com/rbenv/rbenv) and install ruby 2.7.2
We **HIGHLY RECOMMEND** that you read the Readme for rbenv to learn about your install and configuration options.
This is a Quick/typical summary of commands
```bash
brew install rbenv ruby-build
rbenv init
rbenv install 2.7.2
rbenv local 2.7.2
gem install bundler
bundle install
pod install
````


Open `ShakeItPhoto.xcworkspace` with XCode

[download the googleservice-info.plist from the firebase console]:
  https://console.firebase.google.com/u/0/project/shake-it-photo/settings/general/ios:com.greyscalegorilla.ShakeItPhoto
[add firebase to your ios project]: https://firebase.google.com/docs/ios/setup
