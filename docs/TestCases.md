# Manual test cases

## UI interactions

### From the widget
Pre-condition: app is closed. Launch the widget. screen is in initial state, with "Tap sleep to start"

1. Tap sleep, counter begins. The time shown should not shift around with each 1 second tick
2. Tap Cancel, goes back to starting screen
3. Start sleep again. Tap on Wake, it will show how long you slept for.
4. open up the (app), confirm it also shows the sleeping time
5. Tap on Done  
    a. immediately tap on reset, screen should reset  
    b. tap on reset only after timeout, screen should reset
6. open up the (app), confirm that screen state is also reset
7. confirm saved OK in HealthKit


### From the app
Pre-condition: app is closed. Launch the app. screen is in initial state, with "Tap sleep to start"  

Repeat the above test from the app.  
In step 4 and 6, verify for the widget, rather than the app


## Screen reset

### From the widget
Pre-condition: After successful save

1. Close widget and open it immediately, the finish screen is still shown.
2. close widget and open it, wait for the reset timeout, and then open it again. The starting screen is shown

### From the app
Pre-condition: After successful save

1. Background the app, and open it again back immediately, the finish screen is still shown.
2. Background the app, wait for the reset timeout, and then open it again. The starting screen is shown



## Editing the time

### From the App
Pre-condition: After successful save

1. Tap adjust.  
 Expected:
	* adjustment screen opens
	* start and end times should correspond to the most recent sleep
	* sleep duration should be shown, including seconds

2. Change the pickers. But then tap cancel.  
 Expected: 
	* after cancel, adjustment shouldn't be saved
	* finish screen with adjust screen should be shown, and you should be able to to launch adjust again

3. Repeat (2) but wait for reset timeout

4. Tap adjust again. Move the date pickers  
	* sleep duration should be updated
	* seconds should dropped to zero
	* for invalid sleep, should have red error message
	* for valid sleep, goes back to black color

4. tap save  
	* on saving, seconds remain dropped at zero
	* check saved correctly
	* finish screen with adjust screen should be shown, and you should be able to to launch adjust again
	* For TX: opening TX will also show the correct adjusted value, and you should be able to to launch adjust again

5. Tap adjust again  
	* start and end times should correspond to the most recent sleep (from the adjustment)
	* sleep duration should be shown, including seconds


### From the widget
Repeat above test case, but initiate the adjust from the widget. It will open up the app to do the adjust.

### Adjusting a deleted sample
Pre-condition: saved into HealthKit, and on the adjust screen

1. Go into Apple Health, and delete the sample
2. Try to adjust it from TapB4UNap, and tap Save
Expected: Something went wrong error message



## HealthKit Permissions

### TestCase 1 - Not determined yet (from widget)
1. Reset simulator contents and settings
2. From widget, tap on Sleep
3. In the alert, select **Not Now**  
 Expected: The widget text should update to say that it needs permission
4. Close the today extensions, and re-open  
 Expected: The widget text should reset to the original
5. Redo test steps 2-4 again 

### TestCase 2 - Not determined yet (from app)
1. Reset simulator contents and settings
2. From app, tap on Sleep  
 Expected: App should open and show the permissions screen
3. Kill the app, and reopen  
 Expected: The text should reset to the original
4. Redo test steps 2-4 again 

### TestCase 3 - Permission denied (from widget) - first time
1. Reset simulator contents and settings
2. From widget, tap on Sleep
3. In the alert, select **Open "TapB4UNap"**  
 Expected: App should open and show the permissions screen
4. Select "Don't Allow"  
 Expected: the app text should update to say that it needs permission
5. Open up the widget. 
Expected: Text should say it needs permission

### TestCase 3B - Permission denied - user takes a long time
Repeat TestCase 3, but wait 30 seconds before step 4, on the apple health permission screen
Expected: the app text should update to say that it needs permission

### TestCase 4 - Permission denied (from app) - first time
1. Reset simulator contents and settings
2. From app, tap on Sleep  
 Expected: App should open and show the permissions screen
3. Select "Don't Allow"  
 Expected: the app text should update to say that it needs permission
4. Open up the widget. 
 Expected: Text should say it needs permission

### TestCase 4B - Permission denied - user takes a long time
Repeat TestCase 4, but wait 30 seconds before step 3, on the apple health permission screen
Expected: the app text should update to say that it needs permission

### TestCase 5 - Permission already denied
Pre-condition: already denied
 
1. Open up the widget. 
Expected: Text should say it needs permission
2. Switch app and return it foreground. 
Expected: Text should say it needs permission

### TestCase 6 - Grant permissions manually
Pre-condition: already denied

1. Go to apple health and manually grant permissions
2. Open up the widget. Should be on the begin sleep screen.
3. Open up the app. Should be on the begin sleep screen.

### TestCase 7 - Permission granted (from widget) - first time
1. Reset simulator contents and settings
2. From widget, tap on sleep
3. In the alert, select **Open "TapB4UNap"**
Expected: App should open and show the permissions screen
4. Grant permissions and tap Allow
Expected: On the app, the counter should begin and show it is sleeping
5. Open the widget
Expected: Counter is also showing on the widget

### TestCase 7B - Permission granted (from widget) - user takes a long time
Repeat TestCase 7, but wait 30 seconds before step 4, on the apple health permission screen

Note: The sleep start time begins when the healthkit timeout happens at around the 30 second mark

### TestCase 8 - Permission granted (from app) - first time
1. Reset simulator contents and settings
2. From app, tap on sleep
Expected: App should open and show the permissions screen
3. Grant permissions and tap Allow
Expected: On the app, the counter should begin and show it is sleeping
4. Open the widget
Expected: Counter is also showing on the widget

### TestCase 8B - Permission granted (from app) - user takes a long time
Repeat TestCase 8, but wait 30 seconds before step 3, on the apple health permission screen

### TestCase 9 - Revoke permission while after sleep started
Pre-condition: sleeping and timer is counting, make sure the app is open

1. Go to apple health and manually revoke permission
2. Go back to the app
Expected: it should immediately say permissions are required
3. Open the today extension
Expected: it should say permissions are required
4. Close and reopen the app
Expected: it should say permissions are required
5. Go to apple health and manually grant permissions
Expected: Both app and widget resume the counter again, and sleep was started at the original time


## Location Services

### Reset will cancel geofence

1. Start sleep, geofence should be created
2. Reset, geofence should be cancelled. Leaving geofence will not fire notification.

### Exit geofence 
Pre-condition: Sleeping and timer is counting. 

1. While app is terminated, exit geofence  
 Expected: Notification should be delivered (eventually), may be a few minutes. 
2. While app is suspended, exit geofence  
 Expected: Notification is shown. Timer continues counting.
3. Repeat step 2. When banner is shown, tap on the banner. 
 Expected: Launches app and wakes  
4. While app in foreground, exit geofence  
 Expected: Alert is shown, asking whether or not to wake. OK will wake, cancel will do nothing.

Post-condition: Only 1 region exit is ever fired
 

### Tap on notification 
Pre-condition: There is a notification you can tap on

1. While app is terminated, tap on previous notification  
2. While app is suspended, tap on previous notification  
3. While app in foreground, tap on previous notification  

Expected: Launches app and wakes  

