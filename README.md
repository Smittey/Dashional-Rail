# Dashional Rail
A widget for the Dashing framework to display live data from National Rail. The widget shows warning messages from stations, if trains are cancelled, or if they are delayed and by how long.


![National-Rail-Dashing-Widget
](http://i.imgur.com/13mI5ZF.png "National-Rail-Dashing-Widget")


## Installation Steps 

1. You need an access token to use National Rail's realtime API 'OpenLDBWS'. This can be obtained [here](https://realtime.nationalrail.co.uk/OpenLDBWSRegistration/Registration)
3. Copy `national_rail.html`, `national_rail.coffee`, and `national_rail.scss` into the `/widgets/national_rail` directory. Put the `national_rail.rb` file in your `/jobs` folder.
4. Edit the following variables in `national_Rail.rb`
	5. `token` - Your access token from above
	6. `numRows` - The number of rows that you wish to show on your widget. The default is `8`
	7. `crs` - Your desired station code [which can be found here](http://www.nationalrail.co.uk/static/documents/content/station_codes.csv)

## Usage

Place the following code into your `.erb` layout file:

```
<li data-row="3" data-col="4" data-sizex="2" data-sizey="1">
    <div data-id="NationalRail" data-view="NationalRail" data-unordered="true" data-title="Trains (LHD)" style="background-color: #0f516b"></div>
    <i class="fa fa-train icon-background"></i>
</li>
```