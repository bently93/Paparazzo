## Overview

![Version](https://cocoapod-badges.herokuapp.com/v/Paparazzo/badge.png)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

[Changelog](https://github.com/avito-tech/Paparazzo/blob/master/CHANGELOG.md) | See the changes introduced in each Paparazzo version.

**Paparazzo** is a component for picking and editing photos.

|            | Key Features                             |
|------------|------------------------------------------|
| :camera:   | Taking photos using camera               |
| :iphone:   | Picking photos from user's photo library |
| :scissors: | Photo cropping and rotation              |
| :droplet: | Applying filters to photos                |

![Demo](PaparazzoDemo.gif)

# Contents

* [Installation](#installation)
* [Usage](#usage)
  * [Presenting entire module](#present-whole-module)
    * [Additional parameters of MediaPicker module](#MediaPickerModule)
    * [Memory constraints when cropping](#memory-constraints)
  * [Presenting photo library](#present-gallery)
  * [Presenting mask cropper](#present-maskCropper)
  * [UI Customization](#ui-customization)
* [ImageSource](#ImageSource)
  * [Typical use cases](#use-cases)
    * [Displaying in UI](#displaying-in-ui)
    * [Getting image data](#getting-image-data)
    * [Getting image size](#getting-image-size)

# <a name="installation" />Installation
There are two options to install Paparazzo using [CocoaPods](http://cocoapods.org).

Using [Marshroute](https://github.com/avito-tech/Marshroute):

```ruby
pod "Paparazzo"
```

or if you don't use Marshroute and prefer not to get it as an additional dependency:

```ruby
pod "Paparazzo/Core"
```

# <a name="usage" />Usage
You can use either the entire module or photo library exclusively.

## <a name="present-whole-module" />Presenting entire module
Initialize module assembly using `Paparazzo.AssemblyFactory` (or `Paparazzo.MarshrouteAssemblyFactory` if you use [Marshroute](https://github.com/avito-tech/Marshroute)):
```swift
let factory = Paparazzo.AssemblyFactory()
let assembly = factory.mediaPickerAssembly()
```
Create view controller using assembly's `module` method:
```swift
let data = MediaPickerData(
    items: items,
    autocorrectionFilters: filters,
    selectedItem: items.last,
    maxItemsCount: maxItemsCount,
    cropEnabled: true,
    autocorrectEnabled: true,
    cropCanvasSize: cropCanvasSize
)

let viewController = assembly.module(
    data: data,
    routerSeed: routerSeed,    // omit this parameter if you're using Paparazzo.AssemblyFactory
    configure: configure
)
```
Method parameters:
* _items_ — array of photos that should be initially selected when module is presenter.
* _filters_ — array of filters that can be applied to photos.
* _selectedItem_ — selected photo. If set to `nil` or if _items_ doesn't contain any photo with matching _identifier_, then the first photo in array will be selected.
* _maxItemsCount_ — maximum number of photos that user is allowed to pick.
* _cropEnabled_ — boolean flag indicating whether user can perform photo cropping.
* _autocorrectEnabled_ — boolean flag indicating whether user can apply filters to photo .
* _cropCanvasSize_ — maximum size of canvas when cropping photos. (see [Memory constraints when cropping](#memory-constraints)).
* _routerSeed_ — routerSeed provided by Marshroute.
* _configure_ — closure that allows you to provide [module's additional parameters](#MediaPickerModule).

### <a name="MediaPickerModule" />Additional parameters of MediaPicker module
Additional parameters is described in protocol `MediaPickerModule`:

* `setContinueButtonTitle(_:)`,  `setContinueButtonEnabled(_:)` , `setContinueButtonVisible(_:)` and `setContinueButtonStyle(_:)` allow to customize "Continue" button text and availability.
* `setAccessDeniedTitle(_:)`,  `setAccessDeniedMessage(_:)`  and `setAccessDeniedButtonTitle(_:)` allow to customize "Access Deined" view texts.
* `setCropMode(_:)` allow to customize photo crop behavior.
* `onItemsAdd` is called when user picks items from photo library or takes a new photo using camera.
* `onItemUpdate` is called after user performed cropping.
* `onItemAutocorrect` is called after applying filter.
* `onItemMove` is called after moving photo.
* `onItemRemove` is called when user deletes photo.
* `onFinish` and `onCancel` is called when user taps Continue and Close respectively.

### <a name="memory-constraints" />Memory constraints when cropping
When cropping photo on devices with low RAM capacity your application can crash due to memory warning. It happens because in order to perform actual cropping we need to put a bitmap of the original photo in memory. To descrease a chance of crashing on older devices (such as iPhone 4 or 4s) we can scale the source photo beforehand so that it takes up less space in memory. _cropCanvasSize_ is used for that. It specifies the size of the photo we should be targeting when scaling.

## <a name="present-gallery" />Presenting photo library
Initialize module assembly using `Paparazzo.AssemblyFactory` (or `Paparazzo.MarshrouteAssemblyFactory` if you use [Marshroute](https://github.com/avito-tech/Marshroute)):
```swift
let factory = Paparazzo.AssemblyFactory()
let assembly = factory.photoLibraryAssembly()
```
Create view controller using assembly's `module` method:
```swift
let viewController = assembly.module(
    selectedItems: selectedItems,
    maxSelectedItemsCount: maxSelectedItemsCount,
    routerSeed: routerSeed,    // omit this parameter if you're using Paparazzo.AssemblyFactory
    configure: configure
)
```
* _selectedItems_ — preselected photos (or `nil`).
* _maxItemsCount_ — maximum number of photos that user is allowed to pick.
* _routerSeed_ — routerSeed provided by Marshroute.
* _configure_ — closure used to provide additional module setup.

## <a name="present-maskCropper" />Presenting mask cropper
MaskCropper is a module which provides easy way to customize cropping experience. See CroppingOverlayProvider protocol to get more details.

Initialize module assembly using `Paparazzo.AssemblyFactory` (or `Paparazzo.MarshrouteAssemblyFactory` if you use [Marshroute](https://github.com/avito-tech/Marshroute)):
```swift
let factory = Paparazzo.AssemblyFactory()
let assembly = factory.maskCropperAssembly()
```
Create view controller using assembly's `module` method:
```swift
let data = MaskCropperData(
    imageSource: photo.image,
    cropCanvasSize: cropCanvasSize
)
let viewController = assembly.module(
    data: data,
    croppingOverlayProvider: croppingOverlayProvider,
    routerSeed: routerSeed,    // omit this parameter if you're using Paparazzo.AssemblyFactory
    configure: configure
)
```
* _imageSource_ — photo that should be cropped.
* _croppingOverlayProvider_ — provider from CroppingOverlayProvidersFactory.
* _routerSeed_ — routerSeed provided by Marshroute.
* _configure_ — closure used to provide additional module setup.

## <a name="ui-customization" />UI Customization
You can customize colors, fonts and icons used in photo picker. Just pass an instance of `PaparazzoUITheme` to the initializer of assembly factory.

```swift
var theme = PaparazzoUITheme()
theme.shutterButtonColor = .blue
theme.accessDeniedTitleFont = .boldSystemFont(ofSize: 17)
theme.accessDeniedMessageFont = .systemFont(ofSize: 17)
theme.accessDeniedButtonFont = .systemFont(ofSize: 17)
theme.cameraContinueButtonTitleFont = .systemFont(ofSize: 17)
theme.cancelRotationTitleFont = .boldSystemFont(ofSize: 14)

let assemblyFactory = Paparazzo.AssemblyFactory(theme: theme)
```

# <a name="ImageSource" />ImageSource
Photos picked by user via Paparazzo is provided to you either as `MediaPickerItem` (when using MediaPicker module) or as `PhotoLibraryItem` (when using PhotoLibrary module). Both of these enitities are just wrappers around `ImageSource`, which is a protocol that allows you to get different image representations regardless of where it comes from.

`ImageSource` is designed to be plaform-independent. You can use it both on iOS and macOS.

See the sections below to understand how to use `ImageSource` in different use cases.

## <a name="use-cases" />Typical use cases
### <a name="displaying-in-ui" />Displaying in UI
To present `ImageSource` in `UIImageView`, you should use extension method that comes with `ImageSource/UIKit` pod:

```swift
func setImage(
    fromSource: ImageSource?,
    size: CGSize? = nil,
    placeholder: UIImage? = nil,
    placeholderDeferred: Bool = false,
    adjustOptions: ((_ options: inout ImageRequestOptions) -> ())? = nil,
    resultHandler: ((ImageRequestResult<UIImage>) -> ())? = nil)
    -> ImageRequestId?
```

In most cases you just want to use its simplest version, passing only the first parameter:

`imageView.setImage(fromSource: imageSource)`

### <a name="getting-image-data" />Getting image data
To get image data use `ImageSource.fullResolutionImageData(completion:)`:

```swift
imageSource.fullResolutionImageData { data in
    try? data?.write(to: fileUrl)
}
```

### <a name="getting-image-size" />Getting image size
To get image size use `ImageSource.imageSize(completion:)`:

```swift
imageSource.imageSize { size in
    // do something with size
}
```

# Authors
Andrey Yutkin (ayutkin@avito.ru)
Artem Peskishev (aopeskishev@avito.ru)
Timofey Khomutnikov (tnkhomutnikov@avito.ru)
Vladimir Kaltyrin (vkaltyrin@avito.ru)

# License
MIT
