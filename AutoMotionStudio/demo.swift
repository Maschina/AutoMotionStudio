import Cocoa
import Foundation

// Move around and click automatically at random places in macos, kinda human like in a cheap way.


// Moves the mouse pointer to `moves` random locations on the screen and runs the `action` function at
// each point with the point as argument.
func mouseMoveWithAction(moves: Int, action: (CGPoint) -> Void = defaultAction) {
	let screenSize = NSScreen.main?.visibleFrame.size
	let currentLocation = NSEvent.mouseLocation
	var currentPoint = CGPoint(x: currentLocation.x, y: currentLocation.y)
	
	for _ in 0 ... (moves - 1) {
		let randomXPos = CGFloat.random(in: 0..<screenSize!.width)
		let randomYPos = CGFloat.random(in: 0..<screenSize!.height)
		let destination = CGPoint(x: randomXPos, y: randomYPos)
		let easing = Float.random(in: 270..<650)
		
		humanizedMouseMove(from: currentPoint, to: destination, easing: easing)
		
		let pause = pauseTime()
		print("pause: ", pause)
		usleep(useconds_t(pause))
		currentPoint = destination
		
		action(currentPoint)
	}
	print("done with \(moves) moves")
}

func defaultAction(point: CGPoint) {
	print("<no action at \(point)>")
}

// Pause for slightly longer 20% of the time
func pauseTime() -> Int {
	let pauseType = Int.random(in: 0..<100)
	if(pauseType >= 80) {
		let longPause = Int.random(in: 100_000..<2_000_000)
		return longPause
	} else {
		let shortPause = Int.random(in: 10_000..<500_000)
		return shortPause
	}
}

func moveMouseTo(point: CGPoint) {
	CGEvent(mouseEventSource: nil, mouseType: CGEventType.mouseMoved, mouseCursorPosition: point, mouseButton: CGMouseButton.left)?.post(tap: CGEventTapLocation.cghidEventTap)
}

func mouseClick(point: CGPoint, mouseButton: CGMouseButton = CGMouseButton.left) {
	CGEvent(mouseEventSource: nil, mouseType: CGEventType.leftMouseDown, mouseCursorPosition: point, mouseButton: mouseButton)?.post(tap: CGEventTapLocation.cghidEventTap)
	usleep(useconds_t(Int.random(in: 400_010..<600_200)))
	CGEvent(mouseEventSource: nil, mouseType: CGEventType.leftMouseUp, mouseCursorPosition: point, mouseButton: mouseButton)?.post(tap: CGEventTapLocation.cghidEventTap)
}

// Moves the mouse from point `from` to point `to`, with some `easing` factor.
// Easing means ramping up the movement smoothly in the beginning, and ramping it down towards the end.
// The cheap "humanized" factor.
func humanizedMouseMove(from: CGPoint, to: CGPoint, easing: Float = 100.0) {
	print("current location: ", from)
	print("moving to: ", to)
	let distance = distanceBetween(from: from, to: to)
	let steps = Int(distance * CGFloat(easing) / 100) + 1;
	let xDiff = to.x - from.x
	let yDiff = to.y - from.y
	let stepSize = 1.0 / Double(steps)
	
	for i in 0 ... steps {
		let factor = cubicEaseOut(point: Float(stepSize) * Float(i))
		let stepPoint = CGPoint(x: from.x + (CGFloat(factor) * xDiff), y: from.y + (CGFloat(factor) * yDiff))
		moveMouseTo(point: stepPoint)
		usleep(useconds_t(stepPause()))
	}
}

func stepPause() -> Int {
	return Int.random(in: 200..<300)
}

func distanceBetween(from: CGPoint, to: CGPoint) -> CGFloat {
	let distanceX = from.x - to.x
	let distanceY = from.y - to.y
	return sqrt(distanceX * distanceX + distanceY * distanceY)
}

// stolen from cliclick
func cubicEaseOut(point: Float) -> Float {
	if(point < 0.5) {
		return 4 * point * point * point
	} else {
		let f = ((2 * point) - 2)
		return 0.5 * f * f * f + 1
	}
}


