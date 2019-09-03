# Changelog

## 09/02/19

Created methods for deleting all planted crops, deleting a single planted crop, and finding a single crop from planted crops (single_planted_crop).

Also figured out how to input the values for the insertion for a planted crop. Check the `add_planted_crop` method at the bottom for comments that contain the correct logic. The logic for assembling the input array will be Ruby-side logic, done in the route before invoking the `add_planted_crop` method. 

Created layout for each single crop route. Need to **separate the name and picture from the information pertaining to the crop**. Two separate divs!

Created layout for the calendar. It successfully displays on the `calendar` route. 

Next steps:
1. Create form for inputting information into calendar.
2. Format information from the form into a data structure that the database can use.

Created test suite. Only test right now is verifying that the `blue_jazz` route displays the correct information in the response body. It works!
