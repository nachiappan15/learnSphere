import React from "react";
import "./button.scss";

const Button = ({ buttonText, onClickHandler, purpose }) => {
  let classType = "";
  switch (purpose) {
    case "copy":
      classType = "copy-button";
      break;
    case "add":
      classType = "add-button";
      break;
    case "dalete":
      classType = "delete-button";
      break;
    case "create":
      classType = "create-button";
      break;
    default:
      classType = "default-button";
  }
  return (
    <button
      className={`btn ${classType}`}
      type="button"
      onClick={onClickHandler}
    >
      {buttonText}
    </button>
  );
};

export default Button;
