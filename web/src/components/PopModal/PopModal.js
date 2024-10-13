import React, { useEffect, useState } from 'react'
import './popModal.scss'
import { IoIosCloseCircleOutline } from "react-icons/io";

const PopModal =({show , message , closeModal , msgType}) => {

    const [showElement , setShowElemet] = useState(show);
    useEffect(()=>{
        setShowElemet(show);
    },[show])
    
  return (
    <div className={`popup_container ${showElement ? "" : "hide"}`}>
        <div className='bg' onClick={closeModal}></div>
        <div className={`modal ${msgType}`}>
            <button className='close-modal'
            onClick={closeModal}>
            <IoIosCloseCircleOutline   size={30}/>
            </button>
            <p className='modal_msg'>
                {message}
            </p>
        </div>
    </div>
  )
} 

export default PopModal
