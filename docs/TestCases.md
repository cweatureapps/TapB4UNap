# Manual test cases

## Extension UI

1. Tap sleep, counter begins

2. Tap cancel, goes back to starting screen

3. When tap on save, says "saving..."

4. After saving, open the today extension, it is reset


## Saving from extension

1. fresh install, no permissions, no data, app is not running
- launches app, prompt for permissions, then save
- note the delay during user input, should not impact the saved time
- open extension again after save, should be reset correctly

2. app is in the background, save from extensions
- will come into foreground and save

3. app is in foreground, save from extensions
will save

4. background the app, and switch back to it
the screen will be cleared

## Editing the time

1. tap adjust. then cancel, main screen shouldn't change

2. fields should be correct:
- start and end times should correspond to the most recent sleep
- sleep duration should be shown, including seconds

3. move the date pickers
- sleep duration should be updated
- seconds should dropped to zero
- for invalid sleep, should have red error message
- for valid sleep, goes back to black color

4. tap save
- on saving, seconds remain dropped at zero
- check saved correctly

## HealthKit Permissions

### Not determined yet
1. Reset simulator contents and settings
2. From widget, tap on Sleep
3. In the alert, select **Not Now**
Expected: The widget text should update to say that it needs permission
4. Close the today extensions, and re-open
Expected: The widget text should reset to the original
5. Redo test steps 2-4 again 

### Permission denied - first time
1. Reset simulator contents and settings
2. From widget, tap on Sleep
3. In the alert, select **Open "TapB4UNap"**
Expected: App should open and show the permissions screen
4. Select "Don't Allow"
Expected: the app text should update to say that it needs permission
5. open today extensions to see the widget again
Expected: The widget should be reset

### Permission denied - user takes a long time
Repeat test ***Permission denied - first time*** , but wait 30 seconds in step 4, on the apple health permission screen

### Permission denied - from widget
Pre-condition: already denied
1. From widget, tap on sleep
Expected: The widget text should immediately update to say that it needs permission
2. Close the today extensions, and re-open
Expected: The widget should be reset

### Grant permissions manually
Pre-condition: already denied
1. Go to apple health and manually grant both read/write permissions
2. From widget, start and end to record sleep
Expected: should be saved sucessfully

### Permission granted - first time
1. Reset simulator contents and settings
2. From widget, tap on sleep
3. In the alert, select **Open "TapB4UNap"**
Expected: App should open and show the permissions screen
4. Grant write permissions
Expected: the app text should update to say that it was saved, and the sleep time that was recorded. Open up apple health to confirm it was saved ok.

### Permission granted - user takes a long time
Repeat test ***Permission granted - first time*** , but wait 30 seconds in step 4, on the apple health permission screen
Expected: also check that the waiting time doesn't get included



