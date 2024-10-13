import React from 'react'
import './textField.scss'

const TextField = ({placeholder , val , label,onChangeHandler,name}) => {
  
  return (
    <>
    <div className='fieldSet'>
      <label className='label'>
        {label}
      </label>
      <input type='text' name={name} className='author_id' value={val} onChange={onChangeHandler} placeholder={placeholder}/>
    </div>
    </>
  )
}

export default TextField