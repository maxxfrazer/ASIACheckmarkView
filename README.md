ASIACheckmarkView
======================

Customizable checkmark button view. Allows to easily animate between states, with optional intermediate "Spinning" state - if you want to beautifully morph betweeen two states, but need to wait for API in between. Clean and moder look, along with being easy-to-use. Support Swift 3.0.1.

## Screenshots:

![Custom style Screenshot](https://github.com/amichnia/ASIACheckmarkView/raw/master/Screenshots/ASIACheckmarkView.gif)

# Usage

Add button on storyboard, set its class to __*ASIACheckmarkView*__. Check the attributes inspector and play with the values, to get desired effect.

Note, that spinning animation does not work in storyboard IBDesignable.

![Custom style Screenshot](https://github.com/amichnia/ASIACheckmarkView/raw/master/Screenshots/Storyboard.png)

### Code

Animating state change:

Swift
```swift
let checkmark: ASIACheckmarkView

func changeState() {
		let newValue = !checkmark.boolValue // boolValue describes current checkmark state
		checkmark.animate(checked: newValue) // animate to state you want
}

func changeStateWithCompletion() {
		let newValue = !checkmark.boolValue // boolValue describes current checkmark state
		checkmark.animateTo(newValue){
			print("changed state to \(checkmark.boolValue)")
		}
}

@IBAction func changeStateWithSpinner() {
		let newValue = !checkmark.boolValue
		checkmark.animate(checked: newValue) 	// animate to state you want
		checkmark.isSpinning = true       // PLACE THIS AFTER ANIMATE TO CALL!
}

func endSpinning() {
		// OPTIONAL - You might call "checkmark.animate(checked: some_value)" here
		// - if you want to alter state after finishing spinning
		// (Yes -> spinning -> Yes) for example
		checkmark.isSpinning = false
}

```

## Credits

Created by [Andrzej Michnia](https://github.com/amichnia/).

Animations design by [Asia Michnia](http://jmichnia.tumblr.com)

## License

__ASIACheckmarkView__ is available under the MIT license. See the LICENSE file for more info.
