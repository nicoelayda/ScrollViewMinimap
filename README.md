# ScrollViewMinimap

ScrollViewMinimap is a control for adding minimap functionality to `UIScrollView`.

![ScrollViewMinimap_Preview](https://user-images.githubusercontent.com/4868132/101295673-0f4f4f00-385a-11eb-9fa2-8a92baf772d2.gif)

## Features

- Automatic sizing based on scroll view's content view.
- Automatic thumbnail generation.
- Customisable highlight rect.

## Installation

Download [ScrollViewMinimap.swift](https://github.com/nicoelayda/ScrollViewMinimap/blob/master/ScrollViewMinimap/ScrollViewMinimap.swift) and add it to your project.

Support for Cocoapods and Swift Package Manager will be added soon.

## Usage
1. Add `ScrollViewMinimap` to your `UIScrollView`'s view controller.
2. In `viewDidLoad()`, set the `scrollView` property to your scroll view.

    ```swift
    minimap.scrollView = scrollView
    ```
    
3. In your `UIScrollViewDelegate`, call `update(animated:)` in `scrollViewDidScroll(_:)` and `scrollViewDidZoom(_:)` .

    ```swift
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        minimap.update(animated: true)
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        minimap.update(animated: true)
    }
    ```

Check out **ScrollViewMinimap.xcodeproj** for a fully functional sample app.

## License

MIT. See [LICENSE](https://github.com/nicoelayda/ScrollViewMinimap/blob/master/LICENSE).

## Credits

App Icon from [Freepik](https://www.freepik.com).

Sample Photo from [Unsplash](https://unsplash.com/photos/KwT8fAZq6fI).

