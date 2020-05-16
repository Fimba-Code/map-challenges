import React from "react";
import { Text, View, SafeAreaView } from "react-native";
import * as Permissions from "expo-permissions";
import { Feather } from "@expo/vector-icons";
import Polyline from "@mapbox/polyline";
import MapView, { Polyline as Line, Marker } from "react-native-maps";
import { GooglePlacesAutocomplete } from "react-native-google-places-autocomplete";
import { styles, autoCompleteStyle } from "./styles";
import * as Constants from "./constants/mapConfig";
import Colors from "./constants/colors";
import TripDetails from "./components/TripDetails";

const baseURL = "https://maps.googleapis.com/maps/api/directions/json";

interface Coords {
  latitude: number | null;
  longitude: number | null;
}

interface Location {
  latitude: number | null;
  longitude: number | null;
  destLatitude: number | null;
  destLongitude: number | null;
  duration: string;
  distance: string;
  from: string;
  to: string;
}

export default function App() {
  const map = React.useRef();
  const [location, setLocation] = React.useState<Location>({
    latitude: null,
    longitude: null,
    destLatitude: null,
    destLongitude: null,
    duration: "",
    distance: "",
    from: "",
    to: "",
  });

  const [coords, setCoords] = React.useState<Array<Coords>>([]);

  const getLocationPermissions = async () => {
    const { status } = await Permissions.getAsync(Permissions.LOCATION);
    if (status !== "granted") {
      const res = await Permissions.askAsync(Permissions.LOCATION);
    }
    navigator.geolocation.getCurrentPosition(
      ({ coords: { latitude, longitude } }) =>
        setLocation({ ...location, latitude, longitude }),
      (error) => console.log({ error }),
      { enableHighAccuracy: true, maximumAge: 2000, timeout: 2000 }
    );
  };

  React.useEffect(() => {
    getLocationPermissions();
  }, []);

  const geDirections = async (startLoc: string, desPlaceID: string) => {
    try {
      const res = await fetch(
        `${baseURL}?origin=${startLoc}&destination=place_id:${desPlaceID}&mode=transit&key=${Constants.API_KEY}`
      );

      const resJson = await res.json();
      setLocation({
        ...location,
        destLatitude: resJson.routes[0].legs[0].end_location.lat,
        destLongitude: resJson.routes[0].legs[0].end_location.lng,
        duration: resJson.routes[0].legs[0].duration.text,
        distance: resJson.routes[0].legs[0].distance.text,
        from: resJson.routes[0].legs[0].start_address,
        to: resJson.routes[0].legs[0].end_address,
      });

      const points = Polyline.decode(
        resJson.routes[0].overview_polyline.points
      );
      const coords = points.map((point) => {
        return {
          latitude: point[0],
          longitude: point[1],
        };
      });

      setCoords(coords);

      const options = {
        edgePadding: Constants.EDGE_PADDING,
      };

      map.current.fitToCoordinates(coords, options); //fit all points
    } catch (error) {
      console.log("error:", error);
    }
  };

  if (location.latitude) {
    return (
      <SafeAreaView style={styles.container}>
        <MapView
          ref={map}
          style={styles.map}
          showsUserLocation
          initialRegion={{
            latitude: location.latitude,
            longitude: location.longitude,
            latitudeDelta: 0.0922,
            longitudeDelta: 0.0421,
          }}
          zoomEnabled
          provider="google"
        >
          <Line
            strokeWidth={3}
            strokeColor={Colors.defaultColor}
            lineJoin="bevel"
            coordinates={coords}
          />
          {location.destLatitude && (
            <Marker
              coordinate={{
                latitude: location.destLatitude,
                longitude: location.destLongitude,
              }}
              pinColor={Colors.defaultColor}
            />
          )}
        </MapView>

        <GooglePlacesAutocomplete
          placeholder="Enter Destination"
          minLength={2}
          autoFocus={false}
          returnKeyType={"search"}
          listViewDisplayed="false"
          fetchDetails={true}
          renderDescription={(row) => row.description}
          onPress={(data, details = null) => {
            geDirections(
              `${location.latitude},${location.longitude}`,
              data.place_id
            );
          }}
          getDefaultValue={() => ""}
          query={Constants.SEARCH_QUERY}
          styles={autoCompleteStyle}
          nearbyPlacesAPI="GooglePlacesSearch"
          GooglePlacesSearchQuery={Constants.GOOGLE_PLACES_QUERY}
          filterReverseGeocodingByTypes={Constants.GEO_CODING_TYPE}
          debounce={200}
        />

        {location.destLatitude && <TripDetails location={location} />}
      </SafeAreaView>
    );
  } else {
    return (
      <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
        <Text>Enable LOCATION</Text>
      </View>
    );
  }
}
