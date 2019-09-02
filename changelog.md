# Changelog

## 09/02/19

Created methods for deleting all planted crops, deleting a single planted crop, and finding a single crop from planted crops (single_planted_crop).

Also figured out how to input the values for the insertion for a planted crop. Check the `add_planted_crop` method at the bottom for comments that contain the correct logic. The logic for assembling the input array will be Ruby-side logic, done in the route before invoking the `add_planted_crop` method. 