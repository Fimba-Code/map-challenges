import { StyleSheet, Platform } from "react-native";
import Colors from "./constants/colors";

export const styles = StyleSheet.create({
  container: {
    ...StyleSheet.absoluteFillObject,
  },
  map: {
    flex: 1,
    ...StyleSheet.absoluteFillObject,
  },
});

export const autoCompleteStyle = {
  textInputContainer: {
    backgroundColor: "transparent",
    borderTopWidth: 0,
    borderBottomWidth: 0,
  },
  textInput: {
    marginLeft: 15,
    marginRight: 15,
    borderRadius: 5,
    height: 38,
    color: Colors.secondaryColor,
    fontSize: 16,
    ...Platform.select({
      ios: {
        shadowColor: Colors.defaultColor,
        shadowOffset: {
          width: 0,
          height: 2,
        },
        shadowOpacity: 0.25,
        shadowRadius: 3.84,
      },
      android: {
        elevation: 5,
      },
    }),
  },
  listView: {
    backgroundColor: Colors.white,
    marginLeft: 15,
    marginRight: 15,
  },
};
