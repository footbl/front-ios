#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();
var shouldSelectGroups = false

if (window.buttons()["Next"].checkIsValid()) {
	shouldSelectGroups = true
	window.buttons()["Next"].tap();
	target.delay(1)
	window.buttons()["Next"].tap();
	target.delay(1)
	window.buttons()["Next"].tap();
	target.delay(1)
	window.buttons()["Next"].tap();
	target.delay(1)
	window.buttons()["Get started"].tap();
	target.delay(1)
	window.buttons()["Sign in"].tap();
	app.keyboard().typeString("fsaragoca@me.com\n");
	window.secureTextFields()[0].secureTextFields()[0].tap();
	app.keyboard().typeString("madeatsampa\n");
	target.delay(10)
} else {
	target.delay(5)
}
captureLocalizedScreenshot('0-matches')
target.frontMostApp().tabBar().buttons()[0].tap();
if (shouldSelectGroups) {
	target.delay(3)
	target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.57, y:0.07}});
	target.frontMostApp().navigationBar().leftButton().tap();
	target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.58, y:0.23}});
	target.frontMostApp().navigationBar().leftButton().tap();
	target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.47, y:0.42}});
	target.frontMostApp().navigationBar().leftButton().tap();
	target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.47, y:0.61}});
	target.frontMostApp().navigationBar().leftButton().tap();
}
target.delay(1)
captureLocalizedScreenshot('1-groups')
window.tableViews()[0].tapWithOptions({tapOffset:{x:0.63, y:0.07}});
window.segmentedControls()[0].buttons()[1].tap();
captureLocalizedScreenshot('2-group-ranking')
app.navigationBar().leftButton().tap();
app.tabBar().buttons()[2].tap();
captureLocalizedScreenshot('3-user-profile')
app.navigationBar().rightButton().tap();
target.delay(5)
window.segmentedControls()[0].buttons()[1].tap();
captureLocalizedScreenshot('4-user-transfers')
target.delay(1)