{* DO NOT EDIT THIS FILE! Use an override template instead. *}
{if is_set( $attribute_base )|not}
  {def $attribute_base = 'ContentObjectAttribute'}
{/if}
<div class="block">

<div class="element">
{run-once}
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor={ezini('GMapSettings', 'UseSensor', 'ezgmaplocation.ini')}"></script>
<script type="text/javascript">
{literal}
function eZGmapLocation_MapControl( attributeId, latLongAttributeBase )
{
    var mapid = 'ezgml-map-' + attributeId;
    var latid  = 'ezcoa-' + latLongAttributeBase + '_latitude';
    var longid = 'ezcoa-' + latLongAttributeBase + '_longitude';
    var geocoder = null;
    var addressid = 'ezgml-address-' + attributeId;
    var zoommax = 13;

    var showAddress = function()
    {
        var address = document.getElementById( addressid ).value;
        if ( geocoder )
        {
            geocoder.geocode( {'address' : address}, function( results, status )
            {
                if ( status == google.maps.GeocoderStatus.OK )
                {
                    map.setOptions( { center: results[0].geometry.location, zoom : zoommax } );
										marker.setPosition(  results[0].geometry.location );
                    updateLatLngFields( results[0].geometry.location );
                }
                else
                {
                     alert( address + " not found" );
                }
            });
        }
    };
    
    var updateLatLngFields = function( point )
    {
        document.getElementById(latid).value = point.lat();
        document.getElementById(longid).value = point.lng();
        document.getElementById( 'ezgml-restore-button-' + attributeId ).disabled = false;
        document.getElementById( 'ezgml-restore-button-' + attributeId ).className = 'button';
    };

    var restoretLatLngFields = function()
    {
        document.getElementById( latid ).value     = document.getElementById('ezgml_hidden_latitude_' + attributeId ).value;
        document.getElementById( longid ).value    = document.getElementById('ezgml_hidden_longitude_' + attributeId ).value;
        document.getElementById( addressid ).value = document.getElementById('ezgml_hidden_address_' + attributeId ).value;
        if ( document.getElementById( latid ).value && document.getElementById( latid ).value != 0 )
        {
            var point = new google.maps.LatLng( document.getElementById( latid ).value, document.getElementById( longid ).value );
            //map.setCenter(point, 13);
            marker.setPosition( point );
            map.panTo( point );
        }
        document.getElementById( 'ezgml-restore-button-' + attributeId ).disabled = true;
        document.getElementById( 'ezgml-restore-button-' + attributeId ).className = 'button-disabled';
        return false;
    };

    var getUserPosition = function()
    {
        navigator.geolocation.getCurrentPosition( function( position )
        {
            var location = '';
            var point = new google.maps.LatLng( position.coords.latitude, position.coords.longitude );

            if ( navigator.geolocation.type == 'Gears' && position.gearsAddress )
                location = [position.gearsAddress.city, position.gearsAddress.region, position.gearsAddress.country].join(', ');
            else if ( navigator.geolocation.type == 'ClientLocation' )
                location = [position.address.city, position.address.region, position.address.country].join(', ');

            document.getElementById( addressid ).value = location;
            map.setOptions( {zoom: zoommax, center: point} );
            marker.setPosition( point );
            updateLatLngFields( point );
        },
        function( e )
        {
            alert( 'Could not get your location, error was: ' + e.message );
        },
        { 'gearsRequestAddress': true });
    };

		var startPoint = null;
		var zoom = 0;
		var map = null;
		var marker = null;
        
    if ( document.getElementById( latid ).value && document.getElementById( latid ).value != 0 )
    {
        startPoint = new google.maps.LatLng( document.getElementById( latid ).value, document.getElementById( longid ).value );
        zoom = zoommax;
    }
    else
    {
        startPoint = new google.maps.LatLng( 0, 0 );
    }
    
    map = new google.maps.Map( document.getElementById( mapid ), { center: startPoint, zoom : zoom, mapTypeId: google.maps.MapTypeId.ROADMAP } );
    marker = new google.maps.Marker({ map: map, position: startPoint, draggable: true });
    google.maps.event.addListener( marker, 'dragend', function( event ){
    	updateLatLngFields( event.latLng );
			document.getElementById( addressid ).value = '';
    })
    
    geocoder = new google.maps.Geocoder();
    google.maps.event.addListener( map, 'click', function( event )
    {
			marker.setPosition( event.latLng );
			map.panTo( event.latLng );
			updateLatLngFields( event.latLng );
			document.getElementById( addressid ).value = '';
     });


    document.getElementById( 'ezgml-address-button-' + attributeId ).onclick = showAddress;
    document.getElementById( 'ezgml-restore-button-' + attributeId ).onclick = restoretLatLngFields;

    if ( navigator.geolocation )
    {
        document.getElementById( 'ezgml-mylocation-button-' + attributeId ).onclick = getUserPosition;
        document.getElementById( 'ezgml-mylocation-button-' + attributeId ).className = 'button';
        document.getElementById( 'ezgml-mylocation-button-' + attributeId ).disabled = false;
    }
 
}
{/literal}
</script>
{/run-once}

<script type="text/javascript">
<!--

if ( window.addEventListener )
    window.addEventListener('load', function(){ldelim} eZGmapLocation_MapControl( {$attribute.id}, "{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}" ) {rdelim}, false);
else if ( window.attachEvent )
    window.attachEvent('onload', function(){ldelim} eZGmapLocation_MapControl( {$attribute.id}, "{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}" ) {rdelim} );

-->
</script>

    <input type="text" id="ezgml-address-{$attribute.id}" size="62" name="{$attribute_base}_data_gmaplocation_address_{$attribute.id}" value="{$attribute.content.address}"/>
    <input class="button" type="button" id="ezgml-address-button-{$attribute.id}" value="{'Find address'|i18n('extension/ezgmaplocation/datatype')}"/>
    <input class="button-disabled" type="button" id="ezgml-restore-button-{$attribute.id}" value="{'Restore'|i18n('extension/ezgmaplocation/datatype')}" onclick="javascript:void( null ); return false" disabled="disabled"  title="{'Restores location and address values to what it was on page load.'|i18n('extension/ezgmaplocation/datatype')}" />

    <input id="ezgml_hidden_address_{$attribute.id}" type="hidden" name="ezgml_hidden_address_{$attribute.id}" value="{$attribute.content.address}" disabled="disabled" />
    <input id="ezgml_hidden_latitude_{$attribute.id}" type="hidden" name="ezgml_hidden_latitude_{$attribute.id}" value="{$attribute.content.latitude}" disabled="disabled" />
    <input id="ezgml_hidden_longitude_{$attribute.id}" type="hidden" name="ezgml_hidden_longitude_{$attribute.id}" value="{$attribute.content.longitude}" disabled="disabled" />
    <div id="ezgml-map-{$attribute.id}" style="width: 500px; height: 280px; margin-top: 2px;"></div>
</div>

<div class="element">
  <div class="block">
    <label>{'Latitude'|i18n('extension/ezgmaplocation/datatype')}:</label>
    <input id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_latitude" class="box ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}" type="text" name="{$attribute_base}_data_gmaplocation_latitude_{$attribute.id}" value="{$attribute.content.latitude}" />
  </div>
  
  <div class="block">
    <label>{'Longitude'|i18n('extension/ezgmaplocation/datatype')}:</label>
    <input id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_longitude" class="box ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}" type="text" name="{$attribute_base}_data_gmaplocation_longitude_{$attribute.id}" value="{$attribute.content.longitude}" />
  </div>

  <div class="block">
    <input class="button-disabled" type="button" id="ezgml-mylocation-button-{$attribute.id}" value="{'My current location'|i18n('extension/ezgmaplocation/datatype')}" onclick="javascript:void( null ); return false" disabled="disabled" title="{'Gets your current position if your browser support GeoLocation and you grant this website access to it! Most accurate if you have a built in gps in your Internet device! Also note that you might still have to type in address manually!'|i18n('extension/ezgmaplocation/datatype')}" />
  </div>
</div>

<div class="break"></div>
</div>