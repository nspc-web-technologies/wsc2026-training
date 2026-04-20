export function getDistanceFromLatLonInKm(latitude1, longitude1, latitude2, longitude2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(latitude2-latitude1);  // deg2rad below
    var dLon = deg2rad(longitude2-longitude1);
    var a =
      Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(deg2rad(latitude1)) * Math.cos(deg2rad(latitude2)) *
      Math.sin(dLon/2) * Math.sin(dLon/2)
      ;
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    var d = R * c; // Distance in km
    return d;
}


function deg2rad(deg) {
    return deg * (Math.PI/180)
}