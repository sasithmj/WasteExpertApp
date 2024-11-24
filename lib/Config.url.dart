const url = "http://192.168.120.115:3001/";
// const url = "http://172.17.75.206:3001/";
const registrationUrl = "${url}registration";
const loginUrl = "${url}login";

const scheduleUrl = "${url}schedule/scheduleWaste";
const getscheduleUrl = "${url}schedule/getscheduleWaste";
const updatescheduledateUrl = "${url}schedule/updatescheduleWaste";
const deletescheduledateUrl = "${url}schedule/deletescheduleWaste";
const getSchedulePickupDataUrl = "${url}schedulePickup/getScheduleByUserId";

const wasteReportUrl = "${url}reportWaste/reportWaste";
const getwasteReportUrl = "${url}reportWaste/getReportedWaste";

const recognizeWasteUrl = "${url}recognize/recognizeWaste";

const getSmartBindataUrl = "${url}smartbin/gerNearbySmartbin";
const getAllSmartBindataUrl = "${url}smartbin/getSmartBin";

const updateLocationUrl = "${url}updatelocation";
const updateAddressUrl = "${url}updateaddress";
const getUserDetailsUrl = "${url}userdetails";
const updateProfilePictureUrl = "${url}updateprofilepicture";
const updateProfileUrl = "${url}updateProfile";

const getRewardsUrl = "${url}rewards/getUserRewards";
