import React from 'react'
import "./header.scss"
import HEADER_CONSTANTS from '../../Constants/Header.constants.js'

const Header = () => {
  return (
    <header>
      <div className='logo-container'>
        <img src='../assets/images/logo.svg'/>
      </div>
      <p className='name'>
        {HEADER_CONSTANTS.logoName} <span className='tag'>{HEADER_CONSTANTS.admin}</span>
      </p>
    </header>
  )
}

export default Header