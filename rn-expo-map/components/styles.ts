import { StyleSheet } from "react-native";
import Colors from "../constants/colors";

export default StyleSheet.create({
  bottomModal: {
    justifyContent: "flex-end",
    marginHorizontal: 10,
    paddingVertical: 10,
    height: 200,
    backgroundColor: Colors.white,
    borderTopLeftRadius: 13,
    borderTopRightRadius: 15,
  },
  modalContent: {
    backgroundColor: Colors.white,
    padding: 22,
    justifyContent: "center",
    alignItems: "center",
  },
  icon: {
    marginRight: 5,
  },
  modalHeaderText: {
    fontWeight: "bold",
    fontSize: 12,
    color: Colors.defaultColor,
  },
  tripDetails: {
    color: Colors.secondaryColor,
    fontSize: 12,
  },
});
