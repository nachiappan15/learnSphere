import React from 'react'
import './fileUpload.scss'
import { MdOutlineFileUpload } from "react-icons/md";
import { FaImage } from "react-icons/fa";

const FileUpload =({placeholder,val,onChangeHandler ,index , name,fileType}) => {
  return (
    <>
    <label className='file_upload_label' htmlFor={`file_upload${name}_${index}`}>
      {
        val == null ?
        <>
        <MdOutlineFileUpload className='upload_icon_pending'/>
        <p className='label_text'>
          {placeholder}
        </p>
        </>
        :
        <>
        <FaImage className='upload_icon_success'/>
        <p className='label_text'>
          {val.name}
        </p>
        </>
      }
    </label>
    <input type='file' id={`file_upload${name}_${index}`}  className='file_upload' onChange={(e)=>onChangeHandler(e,index,name)} accept={fileType} />
    </>
  )
}

export default FileUpload