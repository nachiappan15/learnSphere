export const alignFileName = (images) => {
    const modified = images.map( ({markerImg , modelImg}) => {
        let markerExt = markerImg.name.split('.').pop()
        let modelImgName = modelImg.name;
        let refernceName = modelImgName.substring(0 , modelImgName.lastIndexOf("."));

        markerImg =  renameFile(markerImg ,`${refernceName}.${markerExt}` )
        
        return {markerImg , modelImg}
    })
    return modified;
}




const renameFile = (file , newName) => {

    return new File([file], newName , {
        type : file.type,
        lastModified : file.lastModified
    })
}