# Pre-built Workout Plans

This directory contains pre-built workout plans that are automatically imported into the app on first launch.

## Adding to Xcode Project

To ensure these files are included in the app bundle:

1. In Xcode, right-click on the `PersonalFitnessTracker` group in the Project Navigator
2. Select "Add Files to PersonalFitnessTracker..."
3. Navigate to and select the `Resources` folder
4. Make sure "Create folder references" is selected (not "Create groups")
5. Ensure "PersonalFitnessTracker" target is checked
6. Click "Add"

## Adding New Workout Plans

To add new pre-built workout plans:

1. Add your JSON file to this directory (`PersonalFitnessTracker/Resources/WorkoutPlans/`)
2. The file must have a `.json` extension
3. The JSON must follow the complex format supported by the PlanParserService
4. The plan will be automatically imported on the next app launch (or you can reset by deleting the app and reinstalling)

## Resetting Pre-built Plans

To force the app to re-import pre-built plans:
- Delete the app from the simulator/device and reinstall
- Or manually delete the UserDefaults key `hasLoadedPrebuiltPlans`
