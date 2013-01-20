UM Laundry JSON API Notes
==========

AJAX JS URL: http://housing.umich.edu/sites/www.housing.umich.edu/modules/hsg_laundry/hsg-laundry-ajax2.js
Last Updated 8/6/2011

getBuildings() -> http://housing.umich.edu/laundry-locator/locations/RAND_INT

{
    "locations": [
        {
            "loc": {
                "building": "Alice Lloyd Hall",
                "code": "10" //BUILDING_CODE **REQUIRED TO BE VALID**
            }
        },

        ...

    ]
}

getRooms() -> http://housing.umich.edu/laundry-locator/rooms/BUILDING_CODE/RAND_INT

{
    "rooms":[
        {
            "room": {
                "name": "South",
                "code":"31" //ROOM_CODE **USING 0 GETS YOU ALL ROOMS**
            }
        },

        ...

    ]
}

getStatus() -> http://housing.umich.edu/laundry-locator/status/BUILDING_CODE/ROOM_CODE/RAND_INT

{
    "statuses": [
        {
            "stat": {
                "name":"Available",
                "code": "1" //STATUS_CODE **USING 0 GETS YOU ALL STATUSES**
            }
        },

        ...

    ]
}

getReport() -> http://housing.umich.edu/laundry-locator/report/BUILDING_CODE/ROOM_CODE/STATUS_CODE/RAND_INT

30|| //NUMBER_RESULTS **IF 0, NOTHING ON PAGE**
<table class="mach_disp">
    <tr>
        <th>ID</th>
        <th>Machine Type</th>
        <th>Status</th>
        <th>Time Remaining</th>
        <th>Room</th>
    </tr>
    <tr class="mach_busy">
        <td>1</td>
        <td>Washer</td>
        <td>In Use</td>
        <td>22m</td>
        <td>Jordan</td>
    </tr>

    ...

</table>
