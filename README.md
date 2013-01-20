UM Laundry JSON API Notes
==========

AJAX JS URL: http://housing.umich.edu/sites/www.housing.umich.edu/modules/hsg_laundry/hsg-laundry-ajax2.js

getBuildings() -> http://housing.umich.edu/laundry-locator/locations/0

    {"locations": [
        {"loc": {
            "building": "Alice Lloyd Hall",
            "code": "10" //BUILDING_CODE **REQUIRED TO BE VALID**
        }},
        ...
    ]}

getRooms(BUILDING) -> http://housing.umich.edu/laundry-locator/rooms/BUILDING/0

    {"rooms":[
        {"room": {
            "name": "South",
            "code":"31" /* Use 0 for all rooms */
        }},
        ...
    ]}

getStatus(BUILDING, ROOM = 0) -> http://housing.umich.edu/laundry-locator/status/BUILDING/ROOM/0

    {"statuses": [
        {"stat": {
            "name":"Available",
            "code": "1" /* Use 0 for all statuses */
        }},
        ...
    ]}

getReport(BUILDING, ROOM = 0, STATUS = 0) -> http://housing.umich.edu/laundry-locator/report/BUILDING/ROOM/STATUS/0

    30|| /* Number of results */
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
