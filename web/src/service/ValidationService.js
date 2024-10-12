import { all } from "axios";
import { MODAL_CONSTANTS } from "../Constants/CommonConstants";

export const validateData = ({authorId , imageSet}) => {
    let validate = {
        valid :true,
        msg : ""
    }
    if(authorId === ""){
        validate.valid = false;
        validate.msg  = MODAL_CONSTANTS.ModalMessages.errorAuthorId;
    }
    else{
        if(!imageSet.length >0 ){
            validate.valid = false;
            validate.msg  = MODAL_CONSTANTS.ModalMessages.errorImageCount;
        }
        else{
            let allImages = imageSet.map(obj => Object.values(obj)).flat();
            if(allImages.includes(null)){
                validate.valid = false;
                validate.msg  = MODAL_CONSTANTS.ModalMessages.errorImageNull;
            }
        }
    }
    return validate;
}
