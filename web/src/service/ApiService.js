import axios from "axios";
import { constructPayload } from "../utils/constructPayload";
import { alignFileName } from "../utils/FileNameUtils";

export const postData = async ({ authorId, imageSet }) => {
  let modifiedImages = alignFileName(imageSet);
  let payloadData = constructPayload(authorId, modifiedImages);
  let response = await axios
    .post("http://localhost:8080/upload", payloadData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    })
    .then((response) => {
      return response;
    });

  return response;
};
